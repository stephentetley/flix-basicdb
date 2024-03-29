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


mod BasicDb {


    pub enum PreparedStatementSetter[r: Region, ka: Type, ef: Eff, a: Type](Graded.Builder[ka, BasicDb.Internal.Sql.PreparedStatement[r], ef, a])

    instance GradedFunctor[PreparedStatementSetter[r, ka]] { 
        pub def map(f: a -> b \ ef1, x: PreparedStatementSetter[r, ka, ef, a]): PreparedStatementSetter[r, ka, ef + ef1, b] = 
            BasicDb.PreparedStatementSetter.map(f, x)
    }

    instance GradedApplicative[PreparedStatementSetter[r, ka]] { 
        pub def point(x: a): PreparedStatementSetter[r, ka, ef, a] = 
            BasicDb.PreparedStatementSetter.point(x)

        pub def ap(f: PreparedStatementSetter[r, ka, ef1, a -> b \ ef2], 
                    x: PreparedStatementSetter[r, ka, ef, a]): PreparedStatementSetter[r, ka, ef + ef1 + ef2, b] = 
            BasicDb.PreparedStatementSetter.ap(f, x)
    }

    instance GradedMonad[PreparedStatementSetter[r, ka]] { 
        pub def flatMap(k: a -> PreparedStatementSetter[r, ka, ef1, b] \ef2, 
                        x: PreparedStatementSetter[r, ka, ef, a]): PreparedStatementSetter[r, ka, ef + ef1 + ef2, b] = 
            BasicDb.PreparedStatementSetter.flatMap(k, x)
    }

    instance GradedError[PreparedStatementSetter[r, ka]] {
        pub def throwError(msg: String): PreparedStatementSetter[r, ka, ef, a] = 
            BasicDb.PreparedStatementSetter.throwError(msg)

        pub def mapError(f: String -> String \ ef1, 
                            ma: PreparedStatementSetter[r, ka, ef, a]): PreparedStatementSetter[r, ka, ef + ef1, a] =
            BasicDb.PreparedStatementSetter.mapError(f, ma)

        pub def catchError(ma: PreparedStatementSetter[r, ka, ef, a], 
                            f: String -> PreparedStatementSetter[r, ka, ef1, a] \ ef2): PreparedStatementSetter[r, ka, ef + ef1 + ef2, a] =
            BasicDb.PreparedStatementSetter.catchError(ma, f)

        pub def reifyError(ma: PreparedStatementSetter[r, ka, ef, a]): PreparedStatementSetter[r, ka, ef, Result[String, a]] =
            BasicDb.PreparedStatementSetter.reifyError(ma)
    }

}

mod BasicDb.PreparedStatementSetter {


    use BasicDb.PreparedStatementSetter;
    use BasicDb.PreparedStatementSetter.{PreparedStatementSetter};
    
    use BasicDb.Internal.Sql.PreparedStatement;
    use BasicDb.Internal.Sql.PreparedStatement.{PreparedStatement};

    pub def getPreparedStatementSetter(x: PreparedStatementSetter[r, ka, ef, a]): Graded.Builder[ka, PreparedStatement[r], ef, a] = 
        let PreparedStatementSetter(x1) = x;
        x1

    /// The state param `st` is expected to be mutated...
    pub def runPreparedStatementSetter!(ma: PreparedStatementSetter[r, a, ef, a], 
                                        st: PreparedStatement[r]): Result[String, a] \ ef =
        Graded.Builder.runBuilder(getPreparedStatementSetter(ma), st)

    pub def point(x: a): PreparedStatementSetter[r, ka, ef, a] = 
        PreparedStatementSetter(Graded.Builder.point(x))

    pub def map(f: a -> b \ ef1, 
                x: PreparedStatementSetter[r, ka, ef, a]): PreparedStatementSetter[r, ka, ef + ef1, b] =
        PreparedStatementSetter(Graded.Builder.map(f, getPreparedStatementSetter(x)))

    pub def ap(mf: PreparedStatementSetter[r, ka, ef1, a -> b \ ef2], 
                ma: PreparedStatementSetter[r, ka, ef, a]): PreparedStatementSetter[r, ka, ef + ef1 + ef2, b] =
        PreparedStatementSetter(Graded.Builder.ap(getPreparedStatementSetter(mf), getPreparedStatementSetter(ma)))

    pub def flatMap(k: a -> PreparedStatementSetter[r, ka, ef1, b] \ ef2, 
                    x: PreparedStatementSetter[r, ka, ef, a]): PreparedStatementSetter[r, ka, ef + ef1 + ef2, b] = 
        PreparedStatementSetter(Graded.Builder.flatMap(k >> getPreparedStatementSetter, getPreparedStatementSetter(x)))


    pub def throwError(msg: String): PreparedStatementSetter[r, ka, ef, a] = 
        PreparedStatementSetter(Graded.Builder.throwError(msg))

    pub def mapError(f: String -> String \ ef1, 
                        ma: PreparedStatementSetter[r, ka, ef, a]): PreparedStatementSetter[r, ka, ef + ef1, a] =
        PreparedStatementSetter(Graded.Builder.mapError(f, getPreparedStatementSetter(ma)))

    pub def catchError(ma: PreparedStatementSetter[r, ka, ef, a], 
                        f: String -> PreparedStatementSetter[r, ka, ef1, a] \ ef2): PreparedStatementSetter[r, ka, ef + ef1 + ef2, a] =
        PreparedStatementSetter(Graded.Builder.catchError(getPreparedStatementSetter(ma), f >> getPreparedStatementSetter))

    pub def reifyError(ma: PreparedStatementSetter[r, ka, ef, a]): PreparedStatementSetter[r, ka, ef, Result[String, a]] =
        PreparedStatementSetter(Graded.Builder.reifyError(getPreparedStatementSetter(ma)))


    def liftSetterResult!(f: PreparedStatement[r] -> Result[err, a] \ ef): PreparedStatementSetter[r, ka, ef, a] with ToString[err] =
        PreparedStatementSetter(Graded.Builder.liftSetterResult!(f))
    
    pub def liftAction(f: Unit -> a \ ef): PreparedStatementSetter[r, ka, ef, a] =
        PreparedStatementSetter(Graded.Builder.liftAction(f))
    
        
    pub def liftActionResult(f: Unit -> Result[err, a] \ ef): PreparedStatementSetter[r, ka, ef, a] with ToString[err] =
        PreparedStatementSetter(Graded.Builder.liftActionResult(f))


/*

    def liftPrim(update: ##java.sql.PreparedStatement -> Result[String, a] \ ef): PreparedStatementSetter[r, ka, a] \ ef =
        PreparedStatementSetter(s -> update(s) as \ Pure) as \ ef

    pub def liftOption(errMsg: String, x: Option[a]): PreparedStatementSetter[r, ka, a] = match x {
        case Some(x1) => point(x1)
        case None     => throwError(errMsg)
    }

    pub def liftResult(x: Result[String, a]): PreparedStatementSetter[r, ka, a] = match x { 
        case Ok(x1)   => point(x1)
        case Err(msg) => throwError(msg)
    }

    pub def liftResult1(makeErrMsg: e -> String, x: Result[e, a]): PreparedStatementSetter[r, ka, a] = match x { 
        case Ok(x1) => point(x1)
        case Err(e) => throwError(makeErrMsg(e))
    }

    pub def liftValidation(makeErrMsg: List[e] -> String, x: Validation[a, e]): PreparedStatementSetter[r, ka, a] = match x { 
        case Success(x1) => point(x1)
        case Failure(es) => throwError(makeErrMsg(Nec.toList(es)))
    }

    pub def liftAction(fn: Unit -> a \ ef): PreparedStatementSetter[r, ka, a] \ ef = 
        PreparedStatementSetter(_ -> {let a = fn() as \ Pure; Ok(a)}) as \ ef

    pub def liftActionResult(fn: Unit -> Result[String, a] \ ef): PreparedStatementSetter[r, ka, a] \ ef = 
        PreparedStatementSetter(_ -> fn() as \ Pure) as \ ef


    // Note - the primitive setX! functions index from 1, we add 1 to calls
    // so FactIO's API indexes from 0.
*/

    pub def putNullAt!(ix: Int32): PreparedStatementSetter[r, ka, r, Unit] =
        liftSetterResult!(BasicDb.Internal.Sql.PreparedStatement.setNull!(ix + 1, BasicDb.Internal.Sql.Types.sql_type_null()))

    pub def putStringAt!(ix: Int32, str: String): PreparedStatementSetter[r, ka, r, Unit] =
        liftSetterResult!(BasicDb.Internal.Sql.PreparedStatement.setString!(ix + 1, str))

    pub def putBoolAt!(ix: Int32, b: Bool): PreparedStatementSetter[r, ka, r, Unit] =
        liftSetterResult!(BasicDb.Internal.Sql.PreparedStatement.setBool!(ix + 1, b))

    pub def putInt8At!(ix: Int32, n: Int8): PreparedStatementSetter[r, ka, r, Unit] =
        liftSetterResult!(BasicDb.Internal.Sql.PreparedStatement.setInt8!(ix + 1, n))

    pub def putInt16At!(ix: Int32, n: Int16): PreparedStatementSetter[r, ka, r, Unit] =
        liftSetterResult!(BasicDb.Internal.Sql.PreparedStatement.setInt16!(ix + 1, n))

    pub def putInt32At!(ix: Int32, n: Int32): PreparedStatementSetter[r, ka, r, Unit] =
        liftSetterResult!(BasicDb.Internal.Sql.PreparedStatement.setInt32!(ix + 1, n))

    pub def putInt64At!(ix: Int32, n: Int64): PreparedStatementSetter[r, ka, r, Unit] =
        liftSetterResult!(BasicDb.Internal.Sql.PreparedStatement.setInt64!(ix + 1, n))

    pub def putFloat32At!(ix: Int32, n: Float32): PreparedStatementSetter[r, ka, r, Unit] =
        liftSetterResult!(BasicDb.Internal.Sql.PreparedStatement.setFloat32!(ix + 1, n))

    pub def putFloat64At!(ix: Int32, n: Float64): PreparedStatementSetter[r, ka, r, Unit] =
        liftSetterResult!(BasicDb.Internal.Sql.PreparedStatement.setFloat64!(ix + 1, n))


    pub def putIsoLocalDateStringAt!(ix: Int32, d: Time.LocalDate): PreparedStatementSetter[r, ka, r, Unit] =
        let fmt = Time.Format.DateTimeFormatter.iso_local_date();
        let str = Time.LocalDate.format(fmt, d);
        putStringAt!(ix, str)

    pub def putIsoLocalDateTimeStringAt!(ix: Int32, dt: Time.LocalDateTime): PreparedStatementSetter[r, ka, r, Unit] =
        let fmt = Time.Format.DateTimeFormatter.iso_local_date_time();
        let str = Time.LocalDateTime.format(fmt, dt);
        putStringAt!(ix, str)

    pub def putIsoLocalTimeStringAt!(ix: Int32, dt: Time.LocalTime): PreparedStatementSetter[r, ka, r, Unit] =
        let fmt = Time.Format.DateTimeFormatter.iso_local_time();
        let str = Time.LocalTime.format(fmt, dt);
        putStringAt!(ix, str)

    pub def putOptionStringAt!(ix: Int32, x: Option[String]): PreparedStatementSetter[r, ka, r, Unit] = 
        match x {
            case Some(s) => putStringAt!(ix, s)
            case None    => putNullAt!(ix)
        }

    pub def putOptionBool!(ix: Int32, x: Option[Bool]): PreparedStatementSetter[r, ka, r, Unit] = 
        match x {
            case Some(b) => putBoolAt!(ix, b)
            case None    => putNullAt!(ix)
        }

    pub def putOptionInt8At!(ix: Int32, x: Option[Int8]): PreparedStatementSetter[r, ka, r, Unit] = 
        match x {
            case Some(n) => putInt8At!(ix, n)
            case None    => putNullAt!(ix)
        }

    pub def putOptionInt16At!(ix: Int32, x: Option[Int16]): PreparedStatementSetter[r, ka, r, Unit] = 
        match x {
            case Some(n) => putInt16At!(ix, n)
            case None    => putNullAt!(ix)
        }

    pub def putOptionInt32At!(ix: Int32, x: Option[Int32]): PreparedStatementSetter[r, ka, r, Unit] = 
        match x {
            case Some(n) => putInt32At!(ix, n)
            case None    => putNullAt!(ix)
        }

    pub def putOptionInt64At!(ix: Int32, x: Option[Int64]): PreparedStatementSetter[r, ka, r, Unit] = 
        match x {
            case Some(n) => putInt64At!(ix, n)
            case None    => putNullAt!(ix)
        }

    pub def putOptionFloat32At!(ix: Int32, x: Option[Float32]): PreparedStatementSetter[r, ka, r, Unit] = 
        match x {
            case Some(n) => putFloat32At!(ix, n)
            case None    => putNullAt!(ix)
        }

    pub def putOptionFloat64At!(ix: Int32, x: Option[Float64]): PreparedStatementSetter[r, ka, r, Unit] = 
        match x {
            case Some(n) => putFloat64At!(ix, n)
            case None    => putNullAt!(ix)
        }

    pub def putOptionIsoLocalDateStringAt!(ix: Int32, x: Option[Time.LocalDate]): PreparedStatementSetter[r, ka, r, Unit] =
        match x {
            case Some(n) => putIsoLocalDateStringAt!(ix, n)
            case None    => putNullAt!(ix)
        }

    pub def putOptionIsoLocalDateTimeStringAt!(ix: Int32, x: Option[Time.LocalDateTime]): PreparedStatementSetter[r, ka, r, Unit] =
        match x {
            case Some(n) => putIsoLocalDateTimeStringAt!(ix, n)
            case None    => putNullAt!(ix)
        }

    pub def putOptionIsoLocalTimeStringAt!(ix: Int32, x: Option[Time.LocalTime]): PreparedStatementSetter[r, ka, r, Unit] =
        match x {
            case Some(n) => putIsoLocalTimeStringAt!(ix, n)
            case None    => putNullAt!(ix)
        }

}

