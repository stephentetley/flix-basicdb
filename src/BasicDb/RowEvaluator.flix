/*
 * Copyright 2020 Stephen Tetley
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

namespace BasicDb {

    use BasicDb.RowEvaluator;
    use BasicDb.RowEvaluator.{RowEvaluator};

    pub enum RowEvaluator[a](##java.sql.ResultSet -> Result[a, String] & Impure)

    instance Functor[RowEvaluator] { 
        pub def map(f: a -> b & ef, x: RowEvaluator[a]): RowEvaluator[b] & ef = 
            BasicDb/RowEvaluator.map(f, x)
    }

    instance Applicative[RowEvaluator] { 
        pub def point(x: a): RowEvaluator[a] = 
            BasicDb/RowEvaluator.point(x)

        pub def ap(f: RowEvaluator[a -> b & ef], x: RowEvaluator[a]): RowEvaluator[b] & ef = 
            BasicDb/RowEvaluator.ap(f, x)
    }

    instance Monad[RowEvaluator] { 
        pub def flatMap(k: a -> RowEvaluator[b] & ef, x: RowEvaluator[a]): RowEvaluator[b] & ef = 
            BasicDb/RowEvaluator.flatMap(k, x)
    }

}

namespace BasicDb/RowEvaluator {

    use BasicDb.RowEvaluator;
    use BasicDb.RowEvaluator.{RowEvaluator};

    pub def point(x: a): RowEvaluator[a] =
        RowEvaluator(_ -> Ok(x) as & Impure)

    pub def throwError(msg: String): RowEvaluator[a] =
        RowEvaluator(_ -> Err(msg) as & Impure)

    def apply1(x: RowEvaluator[a], r: ##java.sql.ResultSet): Result[a, String] & Impure =
        let RowEvaluator(f) = x;
        f(r)

    pub def map(f: a -> b & ef, x: RowEvaluator[a]): RowEvaluator[b] & ef =
        RowEvaluator(r ->
            match apply1(x, r) {
                case Ok(a) => {
                    let ans = f(a) as & Impure;
                    Ok(ans)
                }
                case Err(e) => Err(e)
            }
        ) as & ef

    pub def ap(mf: RowEvaluator[a -> b & ef], ma: RowEvaluator[a]): RowEvaluator[b] & ef =
        RowEvaluator(r ->
            match apply1(mf, r) {
                case Ok(f) => {
                    match apply1(ma, r) {
                        case Ok(a) => Ok(f(a) as & Impure)
                        case Err(e2) => Err(e2)
                    }
                }
                case Err(e1) => Err(e1)
            }
        ) as & ef


    pub def bind(x: RowEvaluator[a], k: a -> RowEvaluator[b] & ef): RowEvaluator[b] & ef =
        RowEvaluator(r ->
            match apply1(x, r) {
                case Ok(a) => { let ans = k(a) as & Impure; apply1(ans, r) }
                case Err(e) => Err(e)
            }
        ) as & ef

    pub def flatMap(k: a -> RowEvaluator[b] & ef, x: RowEvaluator[a]): RowEvaluator[b] & ef = bind(x, k)

    pub def optional(x: RowEvaluator[a]): RowEvaluator[Option[a]] =
        RowEvaluator(r ->
            match apply1(x, r) {
                case Ok(a) => Ok(Some(a))
                case Err(_) => Ok(None)
            }
        )


    pub def alt(ma: RowEvaluator[a], mb: RowEvaluator[a]): RowEvaluator[a] =
        RowEvaluator(r ->
            match apply1(ma, r) {
                case Ok(a) => Ok(a)
                case Err(_) => apply1(mb, r) 
            }
        )

        
    def liftPrim(ask: ##java.sql.ResultSet -> Result[a, String] & Impure): RowEvaluator[a] =
        RowEvaluator(r -> ask(r))

    pub def liftOption(x: Option[a], errMsg: String): RowEvaluator[a] = match x { 
        case Some(x1) => point(x1)
        case None => throwError(errMsg)
    }
        
    pub def liftResult(x: Result[a, String]): RowEvaluator[a] = match x { 
        case Ok(x1) => point(x1)
        case Err(msg) => throwError(msg)
    }

    pub def liftResult1(x: Result[a, e], makeErrMsg: e -> String): RowEvaluator[a] = match x { 
        case Ok(x1) => point(x1)
        case Err(e) => throwError(makeErrMsg(e))
    }


    pub def liftValidation(x: Validation[a, e], makeErrMsg: List[e] -> String): RowEvaluator[a] = match x { 
        case Success(x1) => point(x1)
        case Failure(es) => throwError(makeErrMsg(Nec.toList(es)))
    }

    
    pub def liftAction(fn: Unit -> a & Impure): RowEvaluator[a] =
        RowEvaluator(_ -> let x = fn(); Ok(x))
    
        
    pub def liftActionResult(fn: Unit -> Result[a, String] & Impure): RowEvaluator[a] =
        RowEvaluator(_ -> fn())


    // // Note - the primitive getX and setX! functions index from 1, we add 1 to calls
    // // so FactIO's API indexes from 0.

    /// This is "null safe" - if the internal result is null it is converted to the empty String.
    pub def getStringAt(ix: Int32): RowEvaluator[String] =
        let* x1     = liftPrim(x -> BasicDb/Internal/ResultSet.getStringAt(x, ix + 1));
        let ans     = if (Object.isNull(x1)) "" else x1;
        point(ans)

    /// This is "null safe" - if the internal result is null it is converted to the empty String.
    pub def getStringNamed(label: String): RowEvaluator[String] =
        let* x1     = liftPrim(x -> BasicDb/Internal/ResultSet.getStringNamed(x, label));
        let ans     = if (Object.isNull(x1)) "" else x1;
        point(ans)

    // See Javadocs for how a bool value is interpreted...
    pub def getBoolAt(ix: Int32): RowEvaluator[Bool] =
        liftPrim(x -> BasicDb/Internal/ResultSet.getBoolAt(x, ix + 1))

    // See Javadocs for how a bool value is interpreted...
    pub def getBoolNamed(label: String): RowEvaluator[Bool] =
        liftPrim(x -> BasicDb/Internal/ResultSet.getBoolNamed(x, label))

    pub def getInt8At(ix: Int32): RowEvaluator[Int8] =
        liftPrim(x -> BasicDb/Internal/ResultSet.getInt8At(x, ix + 1))

    pub def getInt8Named(label: String): RowEvaluator[Int8] =
        liftPrim(x -> BasicDb/Internal/ResultSet.getInt8Named(x, label))

    pub def getInt16At(ix: Int32): RowEvaluator[Int16] =
        liftPrim(x -> BasicDb/Internal/ResultSet.getInt16At(x, ix + 1))

    pub def getInt16Named(label: String): RowEvaluator[Int16] =
        liftPrim(x -> BasicDb/Internal/ResultSet.getInt16Named(x, label))

    pub def getInt32At(ix: Int32): RowEvaluator[Int32] =
        liftPrim(x -> BasicDb/Internal/ResultSet.getInt32At(x, ix + 1))

    pub def getInt32Named(label: String): RowEvaluator[Int32] =
        liftPrim(x -> BasicDb/Internal/ResultSet.getInt32Named(x, label))

    pub def getInt64At(ix: Int32): RowEvaluator[Int64] =
        liftPrim(x -> BasicDb/Internal/ResultSet.getInt64At(x, ix + 1))

    pub def getInt64Named(label: String): RowEvaluator[Int64] =
        liftPrim(x -> BasicDb/Internal/ResultSet.getInt64Named(x, label))

    pub def getFloat32At(ix: Int32): RowEvaluator[Float32] =
        liftPrim(x -> BasicDb/Internal/ResultSet.getFloat32At(x, ix + 1))
    
    pub def getFloat32Named(label: String): RowEvaluator[Float32] =
        liftPrim(x -> BasicDb/Internal/ResultSet.getFloat32Named(x, label))

    pub def getFloat64At(ix: Int32): RowEvaluator[Float64] =
        liftPrim(x -> BasicDb/Internal/ResultSet.getFloat64At(x, ix + 1))

    pub def getFloat64Named(label: String): RowEvaluator[Float64] =
        liftPrim(x -> BasicDb/Internal/ResultSet.getFloat64Named(x, label))


    /// Cell has type String...
    pub def getLocalDateStringAt(ix: Int32): RowEvaluator[Time.LocalDate] =
        let* s = getStringAt(ix);
        let fmt = Time/Format/DateTimeFormatter.iso_local_date();
        liftResult(Time/LocalDate.parse(fmt, s))
    

    /// Cell has type String...
    pub def getLocalDateStringNamed(label: String): RowEvaluator[Time.LocalDate] =
        let* s = getStringNamed(label);
        let fmt = Time/Format/DateTimeFormatter.iso_local_date();
        liftResult(Time/LocalDate.parse(fmt, s))

    /// Cell has type String...
    pub def getLocalDateTimeStringAt(ix: Int32): RowEvaluator[Time.LocalDateTime] =
        let* s = getStringAt(ix);
        let fmt = Time/Format/DateTimeFormatter.iso_local_date_time();
        liftResult(Time/LocalDateTime.parse(fmt, s))
    

    /// Cell has type String...
    pub def getLocalDateTimeStringNamed(label: String): RowEvaluator[Time.LocalDateTime] =
        let* s = getStringNamed(label);
        let fmt = Time/Format/DateTimeFormatter.iso_local_date_time();
        liftResult(Time/LocalDateTime.parse(fmt, s))

    /// Cell has type String...
    pub def getLocalTimeStringAt(ix: Int32): RowEvaluator[Time.LocalTime] =
        let* s = getStringAt(ix);
        let fmt = Time/Format/DateTimeFormatter.iso_local_time();
        liftResult(Time/LocalTime.parse(fmt, s))
    

    /// Cell has type String...
    pub def getLocalTimeStringNamed(label: String): RowEvaluator[Time.LocalTime] =
        let* s = getStringNamed(label);
        let fmt = Time/Format/DateTimeFormatter.iso_local_time();
        liftResult(Time/LocalTime.parse(fmt, s))

}

