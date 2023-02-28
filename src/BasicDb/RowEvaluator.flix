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



    pub enum RowEvaluator[r: Region, ka: Type, ef: Bool, a: Type](Graded.Evaluator[ka, Interop/Sql.ResultSet[r], ef, a])


    instance GradedFunctor[RowEvaluator[r, ka]] { 
        pub def map(f: a -> b \ ef1, x: RowEvaluator[r, ka, ef, a]): RowEvaluator[r, ka, ef and ef1, b] = 
            BasicDb/RowEvaluator.map(f, x)
    }

    instance GradedApplicative[RowEvaluator[r, ka]] { 
        pub def point(x: a): RowEvaluator[r, ka, ef, a] = 
            BasicDb/RowEvaluator.point(x)

        pub def ap(f: RowEvaluator[r, ka, ef1, a -> b \ ef2], 
                    x: RowEvaluator[r, ka, ef, a]): RowEvaluator[r, ka, ef and ef1 and ef2, b] = 
            BasicDb/RowEvaluator.ap(f, x)
    }

    instance GradedMonad[RowEvaluator[r, ka]] { 
        pub def flatMap(k: a -> RowEvaluator[r, ka, ef1, b] \ ef2, 
                        x: RowEvaluator[r, ka, ef, a]): RowEvaluator[r, ka, ef and ef1 and ef2, b] = 
            BasicDb/RowEvaluator.flatMap(k, x)
    }

    instance GradedZero[RowEvaluator[r, ka]] {
        pub def empty(): RowEvaluator[r, ka, ef, a] = 
            BasicDb/RowEvaluator.empty()
    }

    instance GradedOr[RowEvaluator[r, ka]] {
        pub def orelse(a: RowEvaluator[r, ka, ef1, a], 
                        b: RowEvaluator[r, ka, ef2, a]): RowEvaluator[r, ka, ef1 and ef2, a] =
            BasicDb/RowEvaluator.orelse(a, b)
    }

    instance GradedError[RowEvaluator[r, ka]] {
        pub def throwError(msg: String): RowEvaluator[r, ka, ef, a] = 
            BasicDb/RowEvaluator.throwError(msg)

        pub def mapError(f: String -> String \ ef1, 
                        ma: RowEvaluator[r, ka, ef, a]): RowEvaluator[r, ka, ef and ef1, a] =
            BasicDb/RowEvaluator.mapError(f, ma)

        pub def catchError(ma: RowEvaluator[r, ka, ef, a], 
                            f: String -> RowEvaluator[r, ka, ef1, a] \ ef2): RowEvaluator[r, ka, ef and ef1 and ef2, a] =
            BasicDb/RowEvaluator.catchError(ma, f)
    }

}

namespace BasicDb/RowEvaluator {

    use BasicDb.RowEvaluator
    use BasicDb.RowEvaluator.{RowEvaluator}

    use Interop/Sql.ResultSet
    use Interop/Sql.ResultSet.{ResultSet}

    pub def getRowEvaluator(x: RowEvaluator[r, ka, ef, a]): Graded.Evaluator[ka, ResultSet[r], ef, a] = 
        let RowEvaluator(x1) = x;
        x1


    pub def runRowEvaluator(ma: RowEvaluator[r, a, ef, a], 
                            e: ResultSet[r]): Result[String, a] \ ef =
        Graded/Evaluator.runEvaluator(getRowEvaluator(ma), e)


    pub def point(x: a): RowEvaluator[r, ka, ef, a] = 
        RowEvaluator(Graded/Evaluator.point(x))

    pub def map(f: a -> b \ ef1, 
                x: RowEvaluator[r, ka, ef, a]): RowEvaluator[r, ka, ef and ef1, b]=
        RowEvaluator(Graded/Evaluator.map(f, getRowEvaluator(x)))

    pub def ap(mf: RowEvaluator[r, ka, ef1, a -> b \ ef2], 
                ma: RowEvaluator[r, ka, ef, a]): RowEvaluator[r, ka, ef and ef1 and ef2, b] =
        RowEvaluator(Graded/Evaluator.ap(getRowEvaluator(mf), getRowEvaluator(ma)))

    pub def flatMap(k: a -> RowEvaluator[r, ka, ef1, b] \ ef2, 
                    x: RowEvaluator[r, ka, ef, a]): RowEvaluator[r, ka, ef and ef1 and ef2, b] =
        RowEvaluator(Graded/Evaluator.flatMap(k >> getRowEvaluator, getRowEvaluator(x)))


    // MatchEvaluator can be MonadOr because it does not "step".
    // It is only applied to the current match.

    pub def empty(): RowEvaluator[r, ka, ef, a] = throwError("empty")

    pub def orelse(ma: RowEvaluator[r, ka, ef1, a], 
                    mb: RowEvaluator[r, ka, ef2, a]): RowEvaluator[r, ka, ef1 and ef2, a] =
        RowEvaluator(Graded/Evaluator.orelse(getRowEvaluator(ma), getRowEvaluator(mb)))


    pub def throwError(msg: String): RowEvaluator[r, ka, ef, a] = 
        RowEvaluator(Graded/Evaluator.throwError(msg))

    pub def mapError(f: String -> String \ ef1, 
                    ma: RowEvaluator[r, ka, ef, a]): RowEvaluator[r, ka, ef and ef1, a] =
        RowEvaluator(Graded/Evaluator.mapError(f, getRowEvaluator(ma)))

    pub def catchError(ma: RowEvaluator[r, ka, ef, a], 
                        f: String -> RowEvaluator[r, ka, ef1, a] \ ef2): RowEvaluator[r, ka, ef and ef1 and ef2, a] =
        RowEvaluator(Graded/Evaluator.catchError(getRowEvaluator(ma), f >> getRowEvaluator))

    // def liftGetter(f: ResultSet[r] -> a \ ef): RowEvaluator[r, ka, a] \ ef =
    //     RowEvaluator(Graded/Evaluator.liftGetter(f))

    def liftGetterResult(f: ResultSet[r] -> Result[err, a] \ {ef, Read(r)}): RowEvaluator[r, ka, ef and r, a] with ToString[err] =
        RowEvaluator(Graded/Evaluator.liftGetterResult(f))
    
    pub def liftAction(f: Unit -> a \ ef): RowEvaluator[r, ka, ef, a]  =
        RowEvaluator(Graded/Evaluator.liftAction(f))
    
        
    pub def liftActionResult(f: Unit -> Result[err, a] \ ef): RowEvaluator[r, ka, ef, a] with ToString[err] =
        RowEvaluator(Graded/Evaluator.liftActionResult(f))



/*

    /// TODO are these general combinators in Graded?

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
        
    pub def liftResult(x: Result[String, a]): RowEvaluator[r, ka, a] = match x { 
        case Ok(x1)   => point(x1)
        case Err(msg) => throwError(msg)
    }

    pub def liftResult1(makeErrMsg: e -> String, x: Result[e, a]): RowEvaluator[r, ka, a] = match x { 
        case Ok(x1) => point(x1)
        case Err(e) => throwError(makeErrMsg(e))
    }


    pub def liftValidation(makeErrMsg: List[e] -> String, x: Validation[a, e]): RowEvaluator[r, ka, a] = match x { 
        case Success(x1) => point(x1)
        case Failure(es) => throwError(makeErrMsg(Nec.toList(es)))
    }

    def liftPrim(ask: ##java.sql.ResultSet -> Result[String, a] \ ef): RowEvaluator[r, ka, a] \ ef =
        RowEvaluator(row -> ask(row) as \ r) as \ ef

*/

    // // Note - the Java.Sql's getX functions index from 1, we index from 0.

    /// This is "null safe" - if the internal result is null it is converted to the empty String.
    pub def getStringAt(ix: Int32): RowEvaluator[r, ka, r, String] =
        liftGetterResult(rs -> Interop/Sql/ResultSet.getStringAt(ix + 1, rs) |> Result.map(x1 -> if (Object.isNull(x1)) "" else x1))

    /// This is "null safe" - if the internal result is null it is converted to the empty String.
    pub def getStringNamed(label: String): RowEvaluator[r, ka, r, String] =
        liftGetterResult(rs -> Interop/Sql/ResultSet.getStringNamed(label, rs) |> Result.map(x1 -> if (Object.isNull(x1)) "" else x1))


    // See Javadocs for how a bool value is interpreted...
    pub def getBoolAt(ix: Int32): RowEvaluator[r, ka, r, Bool] =
        liftGetterResult(Interop/Sql/ResultSet.getBoolAt(ix + 1))

    // See Javadocs for how a bool value is interpreted...
    pub def getBoolNamed(label: String): RowEvaluator[r, ka, r, Bool] =
        liftGetterResult(Interop/Sql/ResultSet.getBoolNamed(label))

    pub def getInt8At(ix: Int32): RowEvaluator[r, ka, r, Int8] =
        liftGetterResult(Interop/Sql/ResultSet.getInt8At(ix + 1))

    pub def getInt8Named(label: String): RowEvaluator[r, ka, r, Int8] =
        liftGetterResult(Interop/Sql/ResultSet.getInt8Named(label))

    pub def getInt16At(ix: Int32): RowEvaluator[r, ka, r, Int16] =
        liftGetterResult(Interop/Sql/ResultSet.getInt16At(ix + 1))

    pub def getInt16Named(label: String): RowEvaluator[r, ka, r, Int16] =
        liftGetterResult(Interop/Sql/ResultSet.getInt16Named(label))

    pub def getInt32At(ix: Int32): RowEvaluator[r, ka, r, Int32] =
        liftGetterResult(Interop/Sql/ResultSet.getInt32At(ix + 1))

    pub def getInt32Named(label: String): RowEvaluator[r, ka, r, Int32] =
        liftGetterResult(Interop/Sql/ResultSet.getInt32Named(label))

    pub def getInt64At(ix: Int32): RowEvaluator[r, ka, r, Int64] =
        liftGetterResult(Interop/Sql/ResultSet.getInt64At(ix + 1))

    pub def getInt64Named(label: String): RowEvaluator[r, ka, r, Int64] =
        liftGetterResult(Interop/Sql/ResultSet.getInt64Named(label))

    pub def getFloat32At(ix: Int32): RowEvaluator[r, ka, r, Float32] =
        liftGetterResult(Interop/Sql/ResultSet.getFloat32At(ix + 1))
    
    pub def getFloat32Named(label: String): RowEvaluator[r, ka, r, Float32] =
        liftGetterResult(Interop/Sql/ResultSet.getFloat32Named(label))

    pub def getFloat64At(ix: Int32): RowEvaluator[r, ka, r, Float64] =
        liftGetterResult(Interop/Sql/ResultSet.getFloat64At(ix + 1))

    pub def getFloat64Named(label: String): RowEvaluator[r, ka, r, Float64] =
        liftGetterResult(Interop/Sql/ResultSet.getFloat64Named(label))


    /// Cell has type String...
    pub def getLocalDateStringAt(ix: Int32): RowEvaluator[r, ka, r, Time.LocalDate] =
        let* s = getStringAt(ix);
        let fmt = Time/Format/DateTimeFormatter.iso_local_date();
        GradedError.liftResult(Time/LocalDate.parse(fmt, s))
    

    /// Cell has type String...
    pub def getLocalDateStringNamed(label: String): RowEvaluator[r, ka, r, Time.LocalDate] =
        let* s = getStringNamed(label);
        let fmt = Time/Format/DateTimeFormatter.iso_local_date();
        GradedError.liftResult(Time/LocalDate.parse(fmt, s))

    /// Cell has type String...
    pub def getLocalDateTimeStringAt(ix: Int32): RowEvaluator[r, ka, r, Time.LocalDateTime] =
        let* s = getStringAt(ix);
        let fmt = Time/Format/DateTimeFormatter.iso_local_date_time();
        GradedError.liftResult(Time/LocalDateTime.parse(fmt, s))
    

    /// Cell has type String...
    pub def getLocalDateTimeStringNamed(label: String): RowEvaluator[r, ka, r, Time.LocalDateTime] =
        let* s = getStringNamed(label);
        let fmt = Time/Format/DateTimeFormatter.iso_local_date_time();
        GradedError.liftResult(Time/LocalDateTime.parse(fmt, s))

    /// Cell has type String...
    pub def getLocalTimeStringAt(ix: Int32): RowEvaluator[r, ka, r, Time.LocalTime] =
        let* s = getStringAt(ix);
        let fmt = Time/Format/DateTimeFormatter.iso_local_time();
        GradedError.liftResult(Time/LocalTime.parse(fmt, s))
    

    /// Cell has type String...
    pub def getLocalTimeStringNamed(label: String): RowEvaluator[r, ka, r, Time.LocalTime] =
        let* s = getStringNamed(label);
        let fmt = Time/Format/DateTimeFormatter.iso_local_time();
        GradedError.liftResult(Time/LocalTime.parse(fmt, s))

}

