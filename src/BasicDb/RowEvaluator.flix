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

    pub enum RowEvaluator[r: Region, a: Type](##java.sql.ResultSet -> Result[a, String] & r)

    instance Functor[RowEvaluator[r]] { 
        pub def map(f: a -> b & ef, x: RowEvaluator[r, a]): RowEvaluator[r, b] & ef = 
            BasicDb/RowEvaluator.map(f, x)
    }

    instance Applicative[RowEvaluator[r]] { 
        pub def point(x: a): RowEvaluator[r, a] = 
            BasicDb/RowEvaluator.point(x)

        pub def ap(f: RowEvaluator[r, a -> b & ef], x: RowEvaluator[r, a]): RowEvaluator[r, b] & ef = 
            BasicDb/RowEvaluator.ap(f, x)
    }

    instance Monad[RowEvaluator[r]] { 
        pub def flatMap(k: a -> RowEvaluator[r, b] & ef, x: RowEvaluator[r, a]): RowEvaluator[r, b] & ef = 
            BasicDb/RowEvaluator.flatMap(k, x)
    }

}

namespace BasicDb/RowEvaluator {

    use BasicDb.RowEvaluator;
    use BasicDb.RowEvaluator.{RowEvaluator};

    pub def point(x: a): RowEvaluator[r, a] = RowEvaluator(_ -> Ok(x) as & r)

    pub def throwError(msg: String): RowEvaluator[r, a] = RowEvaluator(_ -> Err(msg) as & r)

    def apply1(x: RowEvaluator[r, a], r: ##java.sql.ResultSet): Result[a, String] & r =
        let RowEvaluator(f) = x;
        f(r)


    def getRowEvaluatorRegion(): RowEvaluator[r, Region[r]] = 
        RowEvaluator(_ -> Ok(() as Region[r]) as & r)


    pub def map(f: a -> b & ef, x: RowEvaluator[r, a]): RowEvaluator[r, b] & ef =
        RowEvaluator(row ->
            match apply1(x, row) {
                case Ok(a) => {
                    let ans = f(a) as & r;
                    Ok(ans)
                }
                case Err(e) => Err(e)
            }
        ) as & ef

    pub def ap(mf: RowEvaluator[r, a -> b & ef], ma: RowEvaluator[r, a]): RowEvaluator[r, b] & ef =
        RowEvaluator(row ->
            match apply1(mf, row) {
                case Ok(f) => {
                    match apply1(ma, row) {
                        case Ok(a) => Ok(f(a) as & r)
                        case Err(e2) => Err(e2)
                    }
                }
                case Err(e1) => Err(e1)
            }
        ) as & ef


    pub def bind(x: RowEvaluator[r, a], k: a -> RowEvaluator[r, b] & ef): RowEvaluator[r, b] & ef =
        flatMap(k, x)

    pub def flatMap(k: a -> RowEvaluator[r, b] & ef, x: RowEvaluator[r, a]): RowEvaluator[r, b] & ef =
        RowEvaluator(row ->
            match apply1(x, row) {
                case Ok(a)  => {let ans = k(a) as & r; apply1(ans, row)}
                case Err(e) => Err(e)
            }
        ) as & ef


    pub def optional(x: RowEvaluator[r, a]): RowEvaluator[r, Option[a]] =
        RowEvaluator(row ->
            match apply1(x, row) {
                case Ok(a)  => Ok(Some(a))
                case Err(_) => Ok(None)
            }
        )


    pub def alt(ma: RowEvaluator[r, a], mb: RowEvaluator[r, a]): RowEvaluator[r, a] =
        RowEvaluator(row ->
            match apply1(ma, row) {
                case Ok(a)  => Ok(a)
                case Err(_) => apply1(mb, row) 
            }
        )

        
    pub def liftOption(errMsg: String, x: Option[a]): RowEvaluator[r, a] = match x { 
        case Some(x1) => point(x1)
        case None     => throwError(errMsg)
    }
        
    pub def liftResult(x: Result[a, String]): RowEvaluator[r, a] = match x { 
        case Ok(x1)   => point(x1)
        case Err(msg) => throwError(msg)
    }

    pub def liftResult1(makeErrMsg: e -> String, x: Result[a, e]): RowEvaluator[r, a] = match x { 
        case Ok(x1) => point(x1)
        case Err(e) => throwError(makeErrMsg(e))
    }


    pub def liftValidation(makeErrMsg: List[e] -> String, x: Validation[a, e]): RowEvaluator[r, a] = match x { 
        case Success(x1) => point(x1)
        case Failure(es) => throwError(makeErrMsg(Nec.toList(es)))
    }

    def liftPrim(ask: ##java.sql.ResultSet -> Result[a, String] & ef): RowEvaluator[r, a] & ef =
        RowEvaluator(row -> ask(row) as & r) as & ef

    
    pub def liftAction(fn: Unit -> a & ef): RowEvaluator[r, a] & ef =
        RowEvaluator(_ -> let x = fn() as & r; Ok(x)) as & ef
    
        
    pub def liftActionResult(fn: Unit -> Result[a, String] & ef): RowEvaluator[r, a] & ef =
        RowEvaluator(_ -> fn() as & r) as & ef


    // // Note - the primitive getX and setX! functions index from 1, we add 1 to calls
    // // so FactIO's API indexes from 0.

    /// This is "null safe" - if the internal result is null it is converted to the empty String.
    pub def getStringAt(ix: Int32): RowEvaluator[r, String] \ Read(r) =
        let* r      = getRowEvaluatorRegion();
        let* x1     = liftPrim(BasicDb/Internal/ResultSet.getStringAt(r, ix + 1));
        let ans     = if (Object.isNull(x1)) "" else x1;
        point(ans)

    /// This is "null safe" - if the internal result is null it is converted to the empty String.
    pub def getStringNamed(label: String): RowEvaluator[r, String] \ Read(r) =
        let* r      = getRowEvaluatorRegion();
        let* x1     = liftPrim(BasicDb/Internal/ResultSet.getStringNamed(r, label));
        let ans     = if (Object.isNull(x1)) "" else x1;
        point(ans)

    // See Javadocs for how a bool value is interpreted...
    pub def getBoolAt(ix: Int32): RowEvaluator[r, Bool] \ Read(r) =
        let* r      = getRowEvaluatorRegion();
        liftPrim(BasicDb/Internal/ResultSet.getBoolAt(r, ix + 1))

    // See Javadocs for how a bool value is interpreted...
    pub def getBoolNamed(label: String): RowEvaluator[r, Bool] \ Read(r) =
        let* r      = getRowEvaluatorRegion();
        liftPrim(BasicDb/Internal/ResultSet.getBoolNamed(r, label))

    pub def getInt8At(ix: Int32): RowEvaluator[r, Int8] \ Read(r) =
        let* r      = getRowEvaluatorRegion();
        liftPrim(BasicDb/Internal/ResultSet.getInt8At(r, ix + 1))

    pub def getInt8Named(label: String): RowEvaluator[r, Int8] \ Read(r) =
        let* r      = getRowEvaluatorRegion();
        liftPrim(BasicDb/Internal/ResultSet.getInt8Named(r, label))

    pub def getInt16At(ix: Int32): RowEvaluator[r, Int16] \ Read(r) =
        let* r      = getRowEvaluatorRegion();
        liftPrim(BasicDb/Internal/ResultSet.getInt16At(r, ix + 1))

    pub def getInt16Named(label: String): RowEvaluator[r, Int16] \ Read(r) =
        let* r      = getRowEvaluatorRegion();
        liftPrim(BasicDb/Internal/ResultSet.getInt16Named(r, label))

    pub def getInt32At(ix: Int32): RowEvaluator[r, Int32] \ Read(r) =
        let* r      = getRowEvaluatorRegion();
        liftPrim(BasicDb/Internal/ResultSet.getInt32At(r, ix + 1))

    pub def getInt32Named(label: String): RowEvaluator[r, Int32] \ Read(r) =
        let* r      = getRowEvaluatorRegion();
        liftPrim(BasicDb/Internal/ResultSet.getInt32Named(r, label))

    pub def getInt64At(ix: Int32): RowEvaluator[r, Int64] \ Read(r) =
        let* r      = getRowEvaluatorRegion();
        liftPrim(BasicDb/Internal/ResultSet.getInt64At(r, ix + 1))

    pub def getInt64Named(label: String): RowEvaluator[r, Int64] \ Read(r) =
        let* r      = getRowEvaluatorRegion();
        liftPrim(BasicDb/Internal/ResultSet.getInt64Named(r, label))

    pub def getFloat32At(ix: Int32): RowEvaluator[r, Float32] \ Read(r) =
        let* r      = getRowEvaluatorRegion();
        liftPrim(BasicDb/Internal/ResultSet.getFloat32At(r, ix + 1))
    
    pub def getFloat32Named(label: String): RowEvaluator[r, Float32] \ Read(r) =
        let* r      = getRowEvaluatorRegion();
        liftPrim(BasicDb/Internal/ResultSet.getFloat32Named(r, label))

    pub def getFloat64At(ix: Int32): RowEvaluator[r, Float64] \ Read(r) =
        let* r      = getRowEvaluatorRegion();
        liftPrim(BasicDb/Internal/ResultSet.getFloat64At(r, ix + 1))

    pub def getFloat64Named(label: String): RowEvaluator[r, Float64] \ Read(r) =
        let* r      = getRowEvaluatorRegion();
        liftPrim(BasicDb/Internal/ResultSet.getFloat64Named(r, label))


    /// Cell has type String...
    pub def getLocalDateStringAt(ix: Int32): RowEvaluator[r, Time.LocalDate] \ Read(r) =
        let* s = getStringAt(ix);
        let fmt = Time/Format/DateTimeFormatter.iso_local_date();
        liftResult(Time/LocalDate.parse(fmt, s))
    

    /// Cell has type String...
    pub def getLocalDateStringNamed(label: String): RowEvaluator[r, Time.LocalDate] \ Read(r) =
        let* s = getStringNamed(label);
        let fmt = Time/Format/DateTimeFormatter.iso_local_date();
        liftResult(Time/LocalDate.parse(fmt, s))

    /// Cell has type String...
    pub def getLocalDateTimeStringAt(ix: Int32): RowEvaluator[r, Time.LocalDateTime] \ Read(r) =
        let* s = getStringAt(ix);
        let fmt = Time/Format/DateTimeFormatter.iso_local_date_time();
        liftResult(Time/LocalDateTime.parse(fmt, s))
    

    /// Cell has type String...
    pub def getLocalDateTimeStringNamed(label: String): RowEvaluator[r, Time.LocalDateTime] \ Read(r) =
        let* s = getStringNamed(label);
        let fmt = Time/Format/DateTimeFormatter.iso_local_date_time();
        liftResult(Time/LocalDateTime.parse(fmt, s))

    /// Cell has type String...
    pub def getLocalTimeStringAt(ix: Int32): RowEvaluator[r, Time.LocalTime] \ Read(r) =
        let* s = getStringAt(ix);
        let fmt = Time/Format/DateTimeFormatter.iso_local_time();
        liftResult(Time/LocalTime.parse(fmt, s))
    

    /// Cell has type String...
    pub def getLocalTimeStringNamed(label: String): RowEvaluator[r, Time.LocalTime] \ Read(r) =
        let* s = getStringNamed(label);
        let fmt = Time/Format/DateTimeFormatter.iso_local_time();
        liftResult(Time/LocalTime.parse(fmt, s))

}

