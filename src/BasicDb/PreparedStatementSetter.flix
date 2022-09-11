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


    pub enum PreparedStatementSetter[r: Region, ka: Type, a: Type](MonadLib.MutStateError[r, ka, Interop/Sql.PreparedStatement[r], a])

    instance Functor[PreparedStatementSetter[r, ka]] { 
        pub def map(f: a -> b \ ef, x: PreparedStatementSetter[r, ka, a]): PreparedStatementSetter[r, ka, b] \ ef = 
            BasicDb/PreparedStatementSetter.map(f, x)
    }

    instance Applicative[PreparedStatementSetter[r, ka]] { 
        pub def point(x: a): PreparedStatementSetter[r, ka, a] = 
            BasicDb/PreparedStatementSetter.point(x)

        pub def ap(f: PreparedStatementSetter[r, ka, a -> b \ ef], x: PreparedStatementSetter[r, ka, a]): PreparedStatementSetter[r, ka, b] \ ef = 
            BasicDb/PreparedStatementSetter.ap(f, x)
    }

    instance Monad[PreparedStatementSetter[r, ka]] { 
        pub def flatMap(k: a -> PreparedStatementSetter[r, ka, b] \ ef, x: PreparedStatementSetter[r, ka, a]): PreparedStatementSetter[r, ka, b] \ ef = 
            BasicDb/PreparedStatementSetter.flatMap(k, x)
    }

    instance MonadLib.MonadError[PreparedStatementSetter[r, ka]] {
        pub def throwError(msg: String): PreparedStatementSetter[r, ka, a] = 
            BasicDb/PreparedStatementSetter.throwError(msg)

        pub def mapError(f: String -> String \ ef, ma: PreparedStatementSetter[r, ka, a]): PreparedStatementSetter[r, ka, a] \ ef =
            BasicDb/PreparedStatementSetter.mapError(f, ma)

        pub def catchError(ma: PreparedStatementSetter[r, ka, a], f: String -> PreparedStatementSetter[r, ka, a] \ ef): PreparedStatementSetter[r, ka, a] \ ef =
            BasicDb/PreparedStatementSetter.catchError(ma, f)
    }

}

namespace BasicDb/PreparedStatementSetter {


    use BasicDb.PreparedStatementSetter;
    use BasicDb.PreparedStatementSetter.{PreparedStatementSetter};
    
    use Interop/Sql.PreparedStatement;
    use Interop/Sql.PreparedStatement.{PreparedStatement};

    pub def getPreparedStatementSetter(x: PreparedStatementSetter[r, ka, a]): MonadLib.MutStateError[r, ka, PreparedStatement[r], a] = 
        let PreparedStatementSetter(x1) = x;
        x1

    pub def runPreparedStatementSetter!(r: Region[r], 
                                        ma: PreparedStatementSetter[r, a, a], 
                                        st: PreparedStatement[r]): Result[a, String] \ r =
        MonadLib/MutStateError.runMutStateError(r, getPreparedStatementSetter(ma), st)

    pub def point(x: a): PreparedStatementSetter[r, ka, a] = 
        PreparedStatementSetter(MonadLib/MutStateError.point(x))

    pub def map(f: a -> b \ ef, x: PreparedStatementSetter[r, ka, a]): PreparedStatementSetter[r, ka, b] \ ef =
        PreparedStatementSetter(MonadLib/MutStateError.map(f, getPreparedStatementSetter(x)))

    pub def ap(mf: PreparedStatementSetter[r, ka, a -> b \ ef], ma: PreparedStatementSetter[r, ka, a]): PreparedStatementSetter[r, ka, b] \ ef =
        PreparedStatementSetter(MonadLib/MutStateError.ap(getPreparedStatementSetter(mf), getPreparedStatementSetter(ma)))

    pub def flatMap(k: a -> PreparedStatementSetter[r, ka, b] \ ef, x: PreparedStatementSetter[r, ka, a]): PreparedStatementSetter[r, ka, b]  \ ef = 
        PreparedStatementSetter(MonadLib/MutStateError.flatMap(k >> getPreparedStatementSetter, getPreparedStatementSetter(x)))


    pub def throwError(msg: String): PreparedStatementSetter[r, ka, a] = 
        PreparedStatementSetter(MonadLib/MutStateError.throwError(msg))

    pub def mapError(f: String -> String \ ef, ma: PreparedStatementSetter[r, ka, a]): PreparedStatementSetter[r, ka, a] \ ef =
        PreparedStatementSetter(MonadLib/MutStateError.mapError(f, getPreparedStatementSetter(ma)))

    pub def catchError(ma: PreparedStatementSetter[r, ka, a], f: String -> PreparedStatementSetter[r, ka, a] \ ef): PreparedStatementSetter[r, ka, a] \ ef =
        PreparedStatementSetter(MonadLib/MutStateError.catchError(getPreparedStatementSetter(ma), f >> getPreparedStatementSetter))


    def liftSetterResult!(f: PreparedStatement[r] -> Result[a, err] \ ef): PreparedStatementSetter[r, ka, a] \ ef with ToString[err] =
        PreparedStatementSetter(MonadLib/MutStateError.liftSetterResult!(f))
    
    pub def liftAction(f: Unit -> a \ ef): PreparedStatementSetter[r, ka, a] \ ef =
        PreparedStatementSetter(MonadLib/MutStateError.liftAction(f))
    
        
    pub def liftActionResult(f: Unit -> Result[a, err] \ ef): PreparedStatementSetter[r, ka, a] \ ef with ToString[err] =
        PreparedStatementSetter(MonadLib/MutStateError.liftActionResult(f))


/*

    def liftPrim(update: ##java.sql.PreparedStatement -> Result[a, String] \ ef): PreparedStatementSetter[r, ka, a] \ ef =
        PreparedStatementSetter(s -> update(s) as \ Pure) as \ ef

    pub def liftOption(errMsg: String, x: Option[a]): PreparedStatementSetter[r, ka, a] = match x {
        case Some(x1) => point(x1)
        case None     => throwError(errMsg)
    }

    pub def liftResult(x: Result[a, String]): PreparedStatementSetter[r, ka, a] = match x { 
        case Ok(x1)   => point(x1)
        case Err(msg) => throwError(msg)
    }

    pub def liftResult1(makeErrMsg: e -> String, x: Result[a, e]): PreparedStatementSetter[r, ka, a] = match x { 
        case Ok(x1) => point(x1)
        case Err(e) => throwError(makeErrMsg(e))
    }

    pub def liftValidation(makeErrMsg: List[e] -> String, x: Validation[a, e]): PreparedStatementSetter[r, ka, a] = match x { 
        case Success(x1) => point(x1)
        case Failure(es) => throwError(makeErrMsg(Nec.toList(es)))
    }

    pub def liftAction(fn: Unit -> a \ ef): PreparedStatementSetter[r, ka, a] \ ef = 
        PreparedStatementSetter(_ -> {let a = fn() as \ Pure; Ok(a)}) as \ ef

    pub def liftActionResult(fn: Unit -> Result[a, String] \ ef): PreparedStatementSetter[r, ka, a] \ ef = 
        PreparedStatementSetter(_ -> fn() as \ Pure) as \ ef


    // Note - the primitive setX! functions index from 1, we add 1 to calls
    // so FactIO's API indexes from 0.
*/

    pub def putNullAt!(ix: Int32): PreparedStatementSetter[r, ka, Unit] \ Write(r) =
        liftSetterResult!(Interop/Sql/PreparedStatement.setNull!(ix + 1, BasicDb/Internal/Types.sql_type_null()))

    pub def putStringAt!(ix: Int32, str: String): PreparedStatementSetter[r, ka, Unit] \ Write(r) =
        liftSetterResult!(Interop/Sql/PreparedStatement.setString!(ix + 1, str))

    pub def putBoolAt!(ix: Int32, b: Bool): PreparedStatementSetter[r, ka, Unit] \ Write(r) =
        liftSetterResult!(Interop/Sql/PreparedStatement.setBool!(ix + 1, b))

    pub def putInt8At!(ix: Int32, n: Int8): PreparedStatementSetter[r, ka, Unit] \ Write(r) =
        liftSetterResult!(Interop/Sql/PreparedStatement.setInt8!(ix + 1, n))

    pub def putInt16At!(ix: Int32, n: Int16): PreparedStatementSetter[r, ka, Unit] \ Write(r) =
        liftSetterResult!(Interop/Sql/PreparedStatement.setInt16!(ix + 1, n))

    pub def putInt32At!(ix: Int32, n: Int32): PreparedStatementSetter[r, ka, Unit] \ Write(r) =
        liftSetterResult!(Interop/Sql/PreparedStatement.setInt32!(ix + 1, n))

    pub def putInt64At!(ix: Int32, n: Int64): PreparedStatementSetter[r, ka, Unit] \ Write(r) =
        liftSetterResult!(Interop/Sql/PreparedStatement.setInt64!(ix + 1, n))

    pub def putFloat32At!(ix: Int32, n: Float32): PreparedStatementSetter[r, ka, Unit] \ Write(r) =
        liftSetterResult!(Interop/Sql/PreparedStatement.setFloat32!(ix + 1, n))

    pub def putFloat64At!(ix: Int32, n: Float64): PreparedStatementSetter[r, ka, Unit] \ Write(r) =
        liftSetterResult!(Interop/Sql/PreparedStatement.setFloat64!(ix + 1, n))


    pub def putIsoLocalDateStringAt!(ix: Int32, d: Time.LocalDate): PreparedStatementSetter[r, ka, Unit] \ Write(r) =
        let fmt = Time/Format/DateTimeFormatter.iso_local_date();
        let str = Time/LocalDate.format(fmt, d);
        putStringAt!(ix, str)

    pub def putIsoLocalDateTimeStringAt!(ix: Int32, dt: Time.LocalDateTime): PreparedStatementSetter[r, ka, Unit] \ Write(r) =
        let fmt = Time/Format/DateTimeFormatter.iso_local_date_time();
        let str = Time/LocalDateTime.format(fmt, dt);
        putStringAt!(ix, str)

    pub def putIsoLocalTimeStringAt!(ix: Int32, dt: Time.LocalTime): PreparedStatementSetter[r, ka, Unit] \ Write(r) =
        let fmt = Time/Format/DateTimeFormatter.iso_local_time();
        let str = Time/LocalTime.format(fmt, dt);
        putStringAt!(ix, str)

    pub def putOptionStringAt!(ix: Int32, x: Option[String]): PreparedStatementSetter[r, ka, Unit] \ Write(r) = 
        match x {
            case Some(s) => putStringAt!(ix, s)
            case None    => putNullAt!(ix)
        }

    pub def putOptionBool!(ix: Int32, x: Option[Bool]): PreparedStatementSetter[r, ka, Unit] \ Write(r) = 
        match x {
            case Some(b) => putBoolAt!(ix, b)
            case None    => putNullAt!(ix)
        }

    pub def putOptionInt8At!(ix: Int32, x: Option[Int8]): PreparedStatementSetter[r, ka, Unit] \ Write(r) = 
        match x {
            case Some(n) => putInt8At!(ix, n)
            case None    => putNullAt!(ix)
        }

    pub def putOptionInt16At!(ix: Int32, x: Option[Int16]): PreparedStatementSetter[r, ka, Unit] \ Write(r) = 
        match x {
            case Some(n) => putInt16At!(ix, n)
            case None    => putNullAt!(ix)
        }

    pub def putOptionInt32At!(ix: Int32, x: Option[Int32]): PreparedStatementSetter[r, ka, Unit] \ Write(r) = 
        match x {
            case Some(n) => putInt32At!(ix, n)
            case None    => putNullAt!(ix)
        }

    pub def putOptionInt64At!(ix: Int32, x: Option[Int64]): PreparedStatementSetter[r, ka, Unit] \ Write(r) = 
        match x {
            case Some(n) => putInt64At!(ix, n)
            case None    => putNullAt!(ix)
        }

    pub def putOptionFloat32At!(ix: Int32, x: Option[Float32]): PreparedStatementSetter[r, ka, Unit] \ Write(r) = 
        match x {
            case Some(n) => putFloat32At!(ix, n)
            case None    => putNullAt!(ix)
        }

    pub def putOptionFloat64At!(ix: Int32, x: Option[Float64]): PreparedStatementSetter[r, ka, Unit] \ Write(r) = 
        match x {
            case Some(n) => putFloat64At!(ix, n)
            case None    => putNullAt!(ix)
        }

    pub def putOptionIsoLocalDateStringAt!(ix: Int32, x: Option[Time.LocalDate]): PreparedStatementSetter[r, ka, Unit] \ Write(r) =
        match x {
            case Some(n) => putIsoLocalDateStringAt!(ix, n)
            case None    => putNullAt!(ix)
        }

    pub def putOptionIsoLocalDateTimeStringAt!(ix: Int32, x: Option[Time.LocalDateTime]): PreparedStatementSetter[r, ka, Unit] \ Write(r) =
        match x {
            case Some(n) => putIsoLocalDateTimeStringAt!(ix, n)
            case None    => putNullAt!(ix)
        }

    pub def putOptionIsoLocalTimeStringAt!(ix: Int32, x: Option[Time.LocalTime]): PreparedStatementSetter[r, ka, Unit] \ Write(r) =
        match x {
            case Some(n) => putIsoLocalTimeStringAt!(ix, n)
            case None    => putNullAt!(ix)
        }

}

