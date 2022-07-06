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


    pub enum PreparedStatementSetter[_r: Region, a: Type](##java.sql.PreparedStatement -> Result[a, String])

    instance Functor[PreparedStatementSetter[r]] { 
        pub def map(f: a -> b & ef, x: PreparedStatementSetter[r, a]): PreparedStatementSetter[r, b] & ef = 
            BasicDb/PreparedStatementSetter.map(f, x)
    }

    instance Applicative[PreparedStatementSetter[r]] { 
        pub def point(x: a): PreparedStatementSetter[r, a] = 
            BasicDb/PreparedStatementSetter.point(x)

        pub def ap(f: PreparedStatementSetter[r, a -> b & ef], x: PreparedStatementSetter[r, a]): PreparedStatementSetter[r, b] & ef = 
            BasicDb/PreparedStatementSetter.ap(f, x)
    }

    instance Monad[PreparedStatementSetter[r]] { 
        pub def flatMap(k: a -> PreparedStatementSetter[r, b] & ef, x: PreparedStatementSetter[r, a]): PreparedStatementSetter[r, b] & ef = 
            BasicDb/PreparedStatementSetter.flatMap(k, x)
    }


}

namespace BasicDb/PreparedStatementSetter {


    use BasicDb.PreparedStatementSetter;
    use BasicDb.PreparedStatementSetter.{PreparedStatementSetter};
    
    pub def point(x: a): PreparedStatementSetter[r, a] = PreparedStatementSetter(_ -> Ok(x))


    pub def throwError(msg: String): PreparedStatementSetter[r, a] = PreparedStatementSetter(_ -> Err(msg))

    def apply1(x: PreparedStatementSetter[r, a], r: ##java.sql.PreparedStatement): Result[a, String] =
        let PreparedStatementSetter(f) = x;
        f(r)

    def getPSSRegion(): PreparedStatementSetter[r, Region[r]] = 
        PreparedStatementSetter(_ -> Ok(() as Region[r]))

    pub def map(f: a -> b & ef, x: PreparedStatementSetter[r, a]): PreparedStatementSetter[r, b] & ef =
        PreparedStatementSetter(s ->
            match apply1(x, s) {
                case Ok(a) => {
                    let ans = f(a) as & Pure;
                    Ok(ans)
                }
                case Err(e) => Err(e)
            }
        ) as & ef

    pub def ap(mf: PreparedStatementSetter[r, a -> b & ef], ma: PreparedStatementSetter[r, a]): PreparedStatementSetter[r, b] & ef =
        PreparedStatementSetter(s ->
            match apply1(mf, s) {
                case Ok(f) => {
                    match apply1(ma, s) {
                        case Ok(a)   => Ok(f(a) as & Pure)
                        case Err(e2) => Err(e2)
                    }
                }
                case Err(e1) => Err(e1)
            }
        ) as & ef


    pub def bind(x: PreparedStatementSetter[r, a], k: a -> PreparedStatementSetter[r, b] & ef): PreparedStatementSetter[r, b] & ef =
        PreparedStatementSetter(s ->
            match apply1(x, s) {
                case Ok(a)  => {let ans = k(a) as & Pure; apply1(ans, s)}
                case Err(e) => Err(e)
            }
        ) as & ef

    pub def flatMap(k: a -> PreparedStatementSetter[r, b] & ef, x: PreparedStatementSetter[r, a]): PreparedStatementSetter[r, b]  & ef = 
        bind(x, k)

    def liftPrim(update: ##java.sql.PreparedStatement -> Result[a, String] & ef): PreparedStatementSetter[r, a] & ef =
        PreparedStatementSetter(s -> update(s) as & Pure) as & ef

    pub def liftOption(errMsg: String, x: Option[a]): PreparedStatementSetter[r, a] = match x {
        case Some(x1) => point(x1)
        case None     => throwError(errMsg)
    }

    pub def liftResult(x: Result[a, String]): PreparedStatementSetter[r, a] = match x { 
        case Ok(x1)   => point(x1)
        case Err(msg) => throwError(msg)
    }

    pub def liftResult1(makeErrMsg: e -> String, x: Result[a, e]): PreparedStatementSetter[r, a] = match x { 
        case Ok(x1) => point(x1)
        case Err(e) => throwError(makeErrMsg(e))
    }

    pub def liftValidation(makeErrMsg: List[e] -> String, x: Validation[a, e]): PreparedStatementSetter[r, a] = match x { 
        case Success(x1) => point(x1)
        case Failure(es) => throwError(makeErrMsg(Nec.toList(es)))
    }

    pub def liftAction(fn: Unit -> a & ef): PreparedStatementSetter[r, a] & ef = 
        PreparedStatementSetter(_ -> {let a = fn() as & Pure; Ok(a)}) as & ef

    pub def liftActionResult(fn: Unit -> Result[a, String] & ef): PreparedStatementSetter[r, a] & ef = 
        PreparedStatementSetter(_ -> fn() as & Pure) as & ef


    // Note - the primitive setX! functions index from 1, we add 1 to calls
    // so FactIO's API indexes from 0.

    pub def putNullAt!(ix: Int32): PreparedStatementSetter[r, Unit] \ Write(r) =
        use BasicDb/Internal/PreparedStatement.{sql_type_null};
        let* r      = getPSSRegion();
        liftPrim(BasicDb/Internal/PreparedStatement.setNull!(r, ix + 1, sql_type_null()))

    pub def putStringAt!(ix: Int32, str: String): PreparedStatementSetter[r, Unit] \ Write(r) =
        let* r      = getPSSRegion();
        liftPrim(BasicDb/Internal/PreparedStatement.setString!(r, ix + 1, str))

    pub def putBoolAt!(ix: Int32, b: Bool): PreparedStatementSetter[r, Unit] \ Write(r) =
        let* r      = getPSSRegion();
        liftPrim(BasicDb/Internal/PreparedStatement.setBool!(r, ix + 1, b))

    pub def putInt8At!(ix: Int32, n: Int8): PreparedStatementSetter[r, Unit] \ Write(r) =
        let* r      = getPSSRegion();
        liftPrim(BasicDb/Internal/PreparedStatement.setInt8!(r, ix + 1, n))

    pub def putInt16At!(ix: Int32, n: Int16): PreparedStatementSetter[r, Unit] \ Write(r) =
        let* r      = getPSSRegion();
        liftPrim(BasicDb/Internal/PreparedStatement.setInt16!(r, ix + 1, n))

    pub def putInt32At!(ix: Int32, n: Int32): PreparedStatementSetter[r, Unit] \ Write(r) =
        let* r      = getPSSRegion();
        liftPrim(BasicDb/Internal/PreparedStatement.setInt32!(r, ix + 1, n))

    pub def putInt64At!(ix: Int32, n: Int64): PreparedStatementSetter[r, Unit] \ Write(r) =
        let* r      = getPSSRegion();
        liftPrim(BasicDb/Internal/PreparedStatement.setInt64!(r, ix + 1, n))

    pub def putFloat32At!(ix: Int32, n: Float32): PreparedStatementSetter[r, Unit] \ Write(r) =
        let* r      = getPSSRegion();
        liftPrim(BasicDb/Internal/PreparedStatement.setFloat32!(r, ix + 1, n))

    pub def putFloat64At!(ix: Int32, n: Float64): PreparedStatementSetter[r, Unit] \ Write(r) =
        let* r      = getPSSRegion();
        liftPrim(BasicDb/Internal/PreparedStatement.setFloat64!(r, ix + 1, n))


    pub def putIsoLocalDateStringAt!(ix: Int32, d: Time.LocalDate): PreparedStatementSetter[r, Unit] \ Write(r) =
        let fmt = Time/Format/DateTimeFormatter.iso_local_date();
        let str = Time/LocalDate.format(fmt, d);
        putStringAt!(ix, str)

    pub def putIsoLocalDateTimeStringAt!(ix: Int32, dt: Time.LocalDateTime): PreparedStatementSetter[r, Unit] \ Write(r) =
        let fmt = Time/Format/DateTimeFormatter.iso_local_date_time();
        let str = Time/LocalDateTime.format(fmt, dt);
        putStringAt!(ix, str)

    pub def putIsoLocalTimeStringAt!(ix: Int32, dt: Time.LocalTime): PreparedStatementSetter[r, Unit] \ Write(r) =
        let fmt = Time/Format/DateTimeFormatter.iso_local_time();
        let str = Time/LocalTime.format(fmt, dt);
        putStringAt!(ix, str)

    pub def putOptionStringAt!(ix: Int32, x: Option[String]): PreparedStatementSetter[r, Unit] \ Write(r) = 
        match x {
            case Some(s) => putStringAt!(ix, s)
            case None => putNullAt!(ix)
        }

    pub def putOptionBool!(ix: Int32, x: Option[Bool]): PreparedStatementSetter[r, Unit] \ Write(r) = 
        match x {
            case Some(b) => putBoolAt!(ix, b)
            case None => putNullAt!(ix)
        }

    pub def putOptionInt8At!(ix: Int32, x: Option[Int8]): PreparedStatementSetter[r, Unit] \ Write(r) = 
        match x {
            case Some(n) => putInt8At!(ix, n)
            case None => putNullAt!(ix)
        }

    pub def putOptionInt16At!(ix: Int32, x: Option[Int16]): PreparedStatementSetter[r, Unit] \ Write(r) = 
        match x {
            case Some(n) => putInt16At!(ix, n)
            case None => putNullAt!(ix)
        }

    pub def putOptionInt32At!(ix: Int32, x: Option[Int32]): PreparedStatementSetter[r, Unit] \ Write(r) = 
        match x {
            case Some(n) => putInt32At!(ix, n)
            case None => putNullAt!(ix)
        }

    pub def putOptionInt64At!(ix: Int32, x: Option[Int64]): PreparedStatementSetter[r, Unit] \ Write(r) = 
        match x {
            case Some(n) => putInt64At!(ix, n)
            case None => putNullAt!(ix)
        }

    pub def putOptionFloat32At!(ix: Int32, x: Option[Float32]): PreparedStatementSetter[r, Unit] \ Write(r) = 
        match x {
            case Some(n) => putFloat32At!(ix, n)
            case None => putNullAt!(ix)
        }

    pub def putOptionFloat64At!(ix: Int32, x: Option[Float64]): PreparedStatementSetter[r, Unit] \ Write(r) = 
        match x {
            case Some(n) => putFloat64At!(ix, n)
            case None => putNullAt!(ix)
        }

    pub def putOptionIsoLocalDateStringAt!(ix: Int32, x: Option[Time.LocalDate]): PreparedStatementSetter[r, Unit] \ Write(r) =
        match x {
            case Some(n) => putIsoLocalDateStringAt!(ix, n)
            case None    => putNullAt!(ix)
        }

    pub def putOptionIsoLocalDateTimeStringAt!(ix: Int32, x: Option[Time.LocalDateTime]): PreparedStatementSetter[r, Unit] \ Write(r) =
        match x {
            case Some(n) => putIsoLocalDateTimeStringAt!(ix, n)
            case None    => putNullAt!(ix)
        }

    pub def putOptionIsoLocalTimeStringAt!(ix: Int32, x: Option[Time.LocalTime]): PreparedStatementSetter[r, Unit] \ Write(r) =
        match x {
            case Some(n) => putIsoLocalTimeStringAt!(ix, n)
            case None    => putNullAt!(ix)
        }
}

