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



    pub enum RowEvaluator[r: Region, ka: Type, a: Type](MonadLib.Evaluator[r, ka, Interop/Sql.ResultSet[r], a])


    instance Functor[RowEvaluator[r, ka]] { 
        pub def map(f: a -> b \ ef, x: RowEvaluator[r, ka, a]): RowEvaluator[r, ka, b] \ ef = 
            BasicDb/RowEvaluator.map(f, x)
    }

    instance Applicative[RowEvaluator[r, ka]] { 
        pub def point(x: a): RowEvaluator[r, ka, a] = 
            BasicDb/RowEvaluator.point(x)

        pub def ap(f: RowEvaluator[r, ka, a -> b \ ef], x: RowEvaluator[r, ka, a]): RowEvaluator[r, ka, b] \ ef = 
            BasicDb/RowEvaluator.ap(f, x)
    }

    instance Monad[RowEvaluator[r, ka]] { 
        pub def flatMap(k: a -> RowEvaluator[r, ka, b] \ ef, x: RowEvaluator[r, ka, a]): RowEvaluator[r, ka, b] \ ef = 
            BasicDb/RowEvaluator.flatMap(k, x)
    }

    instance MonadZero[RowEvaluator[r, ka]] {
        pub def empty(): RowEvaluator[r, ka, a] = 
            BasicDb/RowEvaluator.empty()
    }

    instance MonadLib.MonadOr[RowEvaluator[r, ka]] {
        pub def orelse(a: RowEvaluator[r, ka, a], b: RowEvaluator[r, ka, a]): RowEvaluator[r, ka, a] =
            BasicDb/RowEvaluator.orelse(a, b)
    }

    instance MonadLib.MonadError[RowEvaluator[r, ka]] {
        pub def throwError(msg: String): RowEvaluator[r, ka, a] = 
            BasicDb/RowEvaluator.throwError(msg)

        pub def mapError(f: String -> String \ ef, ma: RowEvaluator[r, ka, a]): RowEvaluator[r, ka, a] \ ef =
            BasicDb/RowEvaluator.mapError(f, ma)

        pub def catchError(ma: RowEvaluator[r, ka, a], f: String -> RowEvaluator[r, ka, a] \ ef): RowEvaluator[r, ka, a] \ ef =
            BasicDb/RowEvaluator.catchError(ma, f)
    }
}

namespace BasicDb/RowEvaluator {

    use BasicDb.RowEvaluator;
    use BasicDb.RowEvaluator.{RowEvaluator};

    use Interop/Sql.ResultSet;
    use Interop/Sql.ResultSet.{ResultSet};

    pub def getRowEvaluator(x: RowEvaluator[r, ka, a]): MonadLib.Evaluator[r, ka, ResultSet[r], a] = 
        let RowEvaluator(x1) = x;
        x1

    pub def runRowEvaluator(r: Region[r], 
                            ma: RowEvaluator[r, a, a], 
                            st: ResultSet[r]): Result[a, String] \ r =
        MonadLib/Evaluator.runEvaluator(r, getRowEvaluator(ma), st)


    pub def point(x: a): RowEvaluator[r, ka, a] = 
        RowEvaluator(MonadLib/Evaluator.point(x))

    pub def map(f: a -> b \ ef, x: RowEvaluator[r, ka, a]): RowEvaluator[r, ka, b] \ ef =
        RowEvaluator(MonadLib/Evaluator.map(f, getRowEvaluator(x)))

    pub def ap(mf: RowEvaluator[r, ka, a -> b \ ef], ma: RowEvaluator[r, ka, a]): RowEvaluator[r, ka, b] \ ef =
        RowEvaluator(MonadLib/Evaluator.ap(getRowEvaluator(mf), getRowEvaluator(ma)))

    pub def flatMap(k: a -> RowEvaluator[r, ka, b] \ ef, x: RowEvaluator[r, ka, a]): RowEvaluator[r, ka, b] \ ef =
        RowEvaluator(MonadLib/Evaluator.flatMap(k >> getRowEvaluator, getRowEvaluator(x)))


    // MatchEvaluator can be MonadOr because it does not "step".
    // It is only runs on the current match.

    pub def empty(): RowEvaluator[r, ka, a] = throwError("empty")

    pub def orelse(ma: RowEvaluator[r, ka, a], mb: RowEvaluator[r, ka, a]): RowEvaluator[r, ka, a] =
        RowEvaluator(MonadLib/Evaluator.orelse(getRowEvaluator(ma), getRowEvaluator(mb)))


    pub def throwError(msg: String): RowEvaluator[r, ka, a] = 
        RowEvaluator(MonadLib/Evaluator.throwError(msg))

    pub def mapError(f: String -> String \ ef, ma: RowEvaluator[r, ka, a]): RowEvaluator[r, ka, a] \ ef =
        RowEvaluator(MonadLib/Evaluator.mapError(f, getRowEvaluator(ma)))

    pub def catchError(ma: RowEvaluator[r, ka, a], f: String -> RowEvaluator[r, ka, a] \ ef): RowEvaluator[r, ka, a] \ ef =
        RowEvaluator(MonadLib/Evaluator.catchError(getRowEvaluator(ma), f >> getRowEvaluator))

    // def liftGetter(f: ResultSet[r] -> a \ ef): RowEvaluator[r, ka, a] \ ef =
    //     RowEvaluator(MonadLib/Evaluator.liftGetter(f))

    def liftGetterResult(f: ResultSet[r] -> Result[a, err] \ ef): RowEvaluator[r, ka, a] \ ef with ToString[err] =
        RowEvaluator(MonadLib/Evaluator.liftGetterResult(f))
    
    pub def liftAction(f: Unit -> a \ ef): RowEvaluator[r, ka, a] \ ef =
        RowEvaluator(MonadLib/Evaluator.liftAction(f))
    
        
    pub def liftActionResult(f: Unit -> Result[a, err] \ ef): RowEvaluator[r, ka, a] \ ef with ToString[err] =
        RowEvaluator(MonadLib/Evaluator.liftActionResult(f))



/*

    /// TODO are these general combinators in MonadLib?

    pub def optional(x: RowEvaluator[r, ka, a]): RowEvaluator[r, ka, Option[a]] =
        RowEvaluator(row ->
            match apply1(x, row) {
                case Ok(a)  => Ok(Some(a))
                case Err(_) => Ok(None)
            }
        )


    pub def alt(ma: RowEvaluator[r, ka, a], mb: RowEvaluator[r, ka, a]): RowEvaluator[r, ka, a] =
        RowEvaluator(row ->
            match apply1(ma, row) {
                case Ok(a)  => Ok(a)
                case Err(_) => apply1(mb, row) 
            }
        )

        
    pub def liftOption(errMsg: String, x: Option[a]): RowEvaluator[r, ka, a] = match x { 
        case Some(x1) => point(x1)
        case None     => throwError(errMsg)
    }
        
    pub def liftResult(x: Result[a, String]): RowEvaluator[r, ka, a] = match x { 
        case Ok(x1)   => point(x1)
        case Err(msg) => throwError(msg)
    }

    pub def liftResult1(makeErrMsg: e -> String, x: Result[a, e]): RowEvaluator[r, ka, a] = match x { 
        case Ok(x1) => point(x1)
        case Err(e) => throwError(makeErrMsg(e))
    }


    pub def liftValidation(makeErrMsg: List[e] -> String, x: Validation[a, e]): RowEvaluator[r, ka, a] = match x { 
        case Success(x1) => point(x1)
        case Failure(es) => throwError(makeErrMsg(Nec.toList(es)))
    }

    def liftPrim(ask: ##java.sql.ResultSet -> Result[a, String] \ ef): RowEvaluator[r, ka, a] \ ef =
        RowEvaluator(row -> ask(row) as \ r) as \ ef

*/

    // // Note - the Java.Sql's getX functions index from 1, we index from 0.

    /// This is "null safe" - if the internal result is null it is converted to the empty String.
    pub def getStringAt(ix: Int32): RowEvaluator[r, ka, String] \ Read(r) =
        liftGetterResult(rs -> Interop/Sql/ResultSet.getStringAt(ix + 1, rs) |> Result.map(x1 -> if (Object.isNull(x1)) "" else x1))

    /// This is "null safe" - if the internal result is null it is converted to the empty String.
    pub def getStringNamed(label: String): RowEvaluator[r, ka, String] \ Read(r) =
        liftGetterResult(rs -> Interop/Sql/ResultSet.getStringNamed(label, rs) |> Result.map(x1 -> if (Object.isNull(x1)) "" else x1))


    // See Javadocs for how a bool value is interpreted...
    pub def getBoolAt(ix: Int32): RowEvaluator[r, ka, Bool] \ Read(r) =
        liftGetterResult(Interop/Sql/ResultSet.getBoolAt(ix + 1))

    // See Javadocs for how a bool value is interpreted...
    pub def getBoolNamed(label: String): RowEvaluator[r, ka, Bool] \ Read(r) =
        liftGetterResult(Interop/Sql/ResultSet.getBoolNamed(label))

    pub def getInt8At(ix: Int32): RowEvaluator[r, ka, Int8] \ Read(r) =
        liftGetterResult(Interop/Sql/ResultSet.getInt8At(ix + 1))

    pub def getInt8Named(label: String): RowEvaluator[r, ka, Int8] \ Read(r) =
        liftGetterResult(Interop/Sql/ResultSet.getInt8Named(label))

    pub def getInt16At(ix: Int32): RowEvaluator[r, ka, Int16] \ Read(r) =
        liftGetterResult(Interop/Sql/ResultSet.getInt16At(ix + 1))

    pub def getInt16Named(label: String): RowEvaluator[r, ka, Int16] \ Read(r) =
        liftGetterResult(Interop/Sql/ResultSet.getInt16Named(label))

    pub def getInt32At(ix: Int32): RowEvaluator[r, ka, Int32] \ Read(r) =
        liftGetterResult(Interop/Sql/ResultSet.getInt32At(ix + 1))

    pub def getInt32Named(label: String): RowEvaluator[r, ka, Int32] \ Read(r) =
        liftGetterResult(Interop/Sql/ResultSet.getInt32Named(label))

    pub def getInt64At(ix: Int32): RowEvaluator[r, ka, Int64] \ Read(r) =
        liftGetterResult(Interop/Sql/ResultSet.getInt64At(ix + 1))

    pub def getInt64Named(label: String): RowEvaluator[r, ka, Int64] \ Read(r) =
        liftGetterResult(Interop/Sql/ResultSet.getInt64Named(label))

    pub def getFloat32At(ix: Int32): RowEvaluator[r, ka, Float32] \ Read(r) =
        liftGetterResult(Interop/Sql/ResultSet.getFloat32At(ix + 1))
    
    pub def getFloat32Named(label: String): RowEvaluator[r, ka, Float32] \ Read(r) =
        liftGetterResult(Interop/Sql/ResultSet.getFloat32Named(label))

    pub def getFloat64At(ix: Int32): RowEvaluator[r, ka, Float64] \ Read(r) =
        liftGetterResult(Interop/Sql/ResultSet.getFloat64At(ix + 1))

    pub def getFloat64Named(label: String): RowEvaluator[r, ka, Float64] \ Read(r) =
        liftGetterResult(Interop/Sql/ResultSet.getFloat64Named(label))


    /// Cell has type String...
    pub def getLocalDateStringAt(ix: Int32): RowEvaluator[r, ka, Time.LocalDate] \ Read(r) =
        let* s = getStringAt(ix);
        let fmt = Time/Format/DateTimeFormatter.iso_local_date();
        MonadLib/MonadError.liftResult(Time/LocalDate.parse(fmt, s))
    

    /// Cell has type String...
    pub def getLocalDateStringNamed(label: String): RowEvaluator[r, ka, Time.LocalDate] \ Read(r) =
        let* s = getStringNamed(label);
        let fmt = Time/Format/DateTimeFormatter.iso_local_date();
        MonadLib/MonadError.liftResult(Time/LocalDate.parse(fmt, s))

    /// Cell has type String...
    pub def getLocalDateTimeStringAt(ix: Int32): RowEvaluator[r, ka, Time.LocalDateTime] \ Read(r) =
        let* s = getStringAt(ix);
        let fmt = Time/Format/DateTimeFormatter.iso_local_date_time();
        MonadLib/MonadError.liftResult(Time/LocalDateTime.parse(fmt, s))
    

    /// Cell has type String...
    pub def getLocalDateTimeStringNamed(label: String): RowEvaluator[r, ka, Time.LocalDateTime] \ Read(r) =
        let* s = getStringNamed(label);
        let fmt = Time/Format/DateTimeFormatter.iso_local_date_time();
        MonadLib/MonadError.liftResult(Time/LocalDateTime.parse(fmt, s))

    /// Cell has type String...
    pub def getLocalTimeStringAt(ix: Int32): RowEvaluator[r, ka, Time.LocalTime] \ Read(r) =
        let* s = getStringAt(ix);
        let fmt = Time/Format/DateTimeFormatter.iso_local_time();
        MonadLib/MonadError.liftResult(Time/LocalTime.parse(fmt, s))
    

    /// Cell has type String...
    pub def getLocalTimeStringNamed(label: String): RowEvaluator[r, ka, Time.LocalTime] \ Read(r) =
        let* s = getStringNamed(label);
        let fmt = Time/Format/DateTimeFormatter.iso_local_time();
        MonadLib/MonadError.liftResult(Time/LocalTime.parse(fmt, s))

}

