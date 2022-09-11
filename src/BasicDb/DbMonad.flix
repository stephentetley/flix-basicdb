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

    /// ##java.sql.Connection is considered an "imperative resource" rather than directly 
    /// analogous to Haskell's IO so we pu it in a region (even though we can't create on 
    /// outside of Impure / IO).


    pub enum DbMonad[r: Region, ka: Type, a: Type](
        MonadLib.MutStateError[r, ka, Interop/Sql.Connection[r], a])
    
    instance Functor[DbMonad[r, ka]] { 
        pub def map(f: a -> b \ ef, x: DbMonad[r, ka, a]): DbMonad[r, ka, b] \ ef = 
            BasicDb/DbMonad.map(f, x)
    }

    instance Applicative[DbMonad[r, ka]] { 
        pub def point(x: a): DbMonad[r, ka, a] = 
            BasicDb/DbMonad.point(x)

        pub def ap(f: DbMonad[r, ka, a -> b \ ef], x: DbMonad[r, ka, a]): DbMonad[r, ka, b] \ ef = 
            BasicDb/DbMonad.ap(f, x)
    }

    instance Monad[DbMonad[r, ka]] { 
        pub def flatMap(k: a -> DbMonad[r, ka, b] \ ef, x: DbMonad[r, ka, a]): DbMonad[r, ka, b] \ ef = 
            BasicDb/DbMonad.flatMap(k, x)
    }

    instance MonadLib.MonadError[DbMonad[r, ka]] {
        pub def throwError(msg: String): DbMonad[r, ka, a] = 
            BasicDb/DbMonad.throwError(msg)

        pub def mapError(f: String -> String \ ef, ma: DbMonad[r, ka, a]): DbMonad[r, ka, a] \ ef =
            BasicDb/DbMonad.mapError(f, ma)

        pub def catchError(ma: DbMonad[r, ka, a], f: String -> DbMonad[r, ka, a] \ ef): DbMonad[r, ka, a] \ ef =
            BasicDb/DbMonad.catchError(ma, f)
    }


    pub type alias PreparedStatement[r: Region] = Interop/Sql.PreparedStatement[r]

    pub type alias Statement[r: Region] = Interop/Sql.Statement[r]

    pub type alias ResultSet[r: Region] = Interop/Sql.ResultSet[r]

}

namespace BasicDb/DbMonad {

    use Basis/System.FilePath;

    use BasicDb.DbMonad;
    use BasicDb.DbMonad.{DbMonad};

    use Interop/Sql.Connection;
    use Interop/Sql.Connection.{Connection};


    use BasicDb.PreparedStatement;
    use BasicDb.PreparedStatement.{PreparedStatement};

    use BasicDb.PreparedStatementSetter;
    use BasicDb.PreparedStatementSetter.{PreparedStatementSetter};

    use BasicDb.ResultSet;
    use BasicDb.RowEvaluator;
    use BasicDb.Statement;
    use Interop/Sql.Statement.{Statement};

    def getDbMonad(x: DbMonad[r, ka, a]): MonadLib.MutStateError[r, ka, Connection[r], a] = 
        let DbMonad(x1) = x;
        x1

    pub def point(x: a): DbMonad[r, ka, a] = 
        DbMonad(MonadLib/MutStateError.point(x))

    /// Needs to allow allow effects (e.g create / access arrays)
    pub def map(f: a -> b \ ef, ma: DbMonad[r, ka, a]): DbMonad[r, ka, b] \ ef = 
        DbMonad(MonadLib/MutStateError.map(f, getDbMonad(ma)))

    pub def ap(mf: DbMonad[r, ka, a -> b \ ef], ma: DbMonad[r, ka, a]): DbMonad[r, ka, b] \ ef = 
        DbMonad(MonadLib/MutStateError.ap(getDbMonad(mf), getDbMonad(ma)))

    pub def flatMap(f: a -> DbMonad[r, ka, b] \ ef, ma: DbMonad[r, ka, a]): DbMonad[r, ka, b] \ ef =
        DbMonad(MonadLib/MutStateError.flatMap(f >> getDbMonad, getDbMonad(ma)))

    pub def throwError(msg: String): DbMonad[r, ka, a] = 
        DbMonad(MonadLib/MutStateError.throwError(msg))
    
    pub def mapError(f: String -> String \ ef, ma: DbMonad[r, ka, a]): DbMonad[r, ka, a] \ ef= 
        DbMonad(MonadLib/MutStateError.mapError(f, getDbMonad(ma)))

    pub def catchError(ma: DbMonad[r, ka, a], f: String -> DbMonad[r, ka, a] \ ef): DbMonad[r, ka, a] \ ef =
        DbMonad(MonadLib/MutStateError.catchError(getDbMonad(ma), f >> getDbMonad))


    // def liftSetter!(f: Connection[r] -> a \ ef): DbMonad[r, ka, Unit] \ ef =
    //     DbMonad(MonadLib/MutStateError.liftSetter!(f) |> Functor.ignore)

    def liftSetterResult!(f: Connection[r] -> Result[a, err] \ ef): DbMonad[r, ka, a] \ ef with ToString[err] =
        DbMonad(MonadLib/MutStateError.liftSetterResult!(f))

    pub def liftAction(f: Unit -> a \ ef): DbMonad[r, ka, a] \ ef = 
        DbMonad(MonadLib/MutStateError.liftAction(f))

    pub def liftActionResult(f: Unit -> Result[a, err] \ ef): DbMonad[r, ka, a] \ ef with ToString[err] = 
        DbMonad(MonadLib/MutStateError.liftActionResult(f))


    ///
    /// Returns the result of applying `ma` to the initial state `s`.
    ///
    def runDbMonadHelper(r: Region[r], 
                        ma: DbMonad[r, a, a], 
                        s: Connection[r]): Result[a, String] \ r = 
        MonadLib/MutStateError.runMutStateError(r, getDbMonad(ma), s)

        
    pub def runDbMonad(r: Region[r], ma: DbMonad[r, a, a], url: String): Result[a, String] \ { r, Impure } = 
        match Interop/Sql/DriverManager.getConnection(r, url) {
            case Err(e)   => Err(e)
            case Ok(conn) => {
                let ans = runDbMonadHelper(r, ma, conn);
                /// ensure conn is closed whether or not ans is `Ok`
                discard Interop/Sql/Connection.closeConnection!(conn);
                ans
            }
        }
        

    pub def runSQLite(r: Region[r], ma: DbMonad[r, a, a], path: FilePath): Result[a, String] \ { r, Impure } = 
        use Basis/System/FilePath.{normalize};
        let url = "jdbc:sqlite:${normalize(path)}";
        runDbMonad(r, ma, url)

    pub def runDuckDB(r: Region[r], ma: DbMonad[r, a, a], path: FilePath): Result[a, String] \ { r, Impure } = 
        use Basis/System/FilePath.{normalize};
        let url = "jdbc:duckdb:${normalize(path)}";
        runDbMonad(r, ma, url)





    // DB operations

    pub def executeSql!(sql: String): DbMonad[r, ka, Bool] \ {IO, Write(r)} = 
        let* stmt   = liftSetterResult!(Interop/Sql/Connection.createStatement!);
        let* ans    = liftActionResult(_ -> Interop/Sql/Statement.execute!(sql, stmt));
        let* _      = liftActionResult(_ -> Interop/Sql/Statement.close!(stmt));
        point(ans)



    pub def setAutoCommit!(autoCommit: Bool): DbMonad[r, ka, Unit] \ Write(r) =
        liftSetterResult!(Interop/Sql/Connection.setAutoCommit!(autoCommit))

    pub def commit!(): DbMonad[r, ka, Unit] \ {IO, Write(r)} =
        liftSetterResult!(Interop/Sql/Connection.commit!)


    pub def createStatement!(): DbMonad[r, ka, Statement[r]] \ Write(r) =
        liftSetterResult!(Interop/Sql/Connection.createStatement!)


    pub def execute!(sql: String, stmt: Statement[r]): DbMonad[r, ka, Bool] \ {IO, Write(r)} =
        liftActionResult(_ -> Interop/Sql/Statement.execute!(sql, stmt))

    pub def executeQuery!(sql: String, stmt: Statement[r]): DbMonad[r, ka, ResultSet[r]] \ {IO, Write(r)} =
        liftActionResult(_ -> Interop/Sql/Statement.executeQuery!(sql, stmt))
        

    pub def executeUpdate!(sql: String, stmt: Statement[r]): DbMonad[r, ka, Int32] \ {IO, Write(r)} =
        liftActionResult(_ -> Interop/Sql/Statement.executeUpdate!(sql, stmt))


    pub def prepareStatement!(sql: String): DbMonad[r, ka, PreparedStatement[r]] \ {Read(r), Write(r)} =
        liftSetterResult!(Interop/Sql/Connection.prepareStatement!(sql))
        


    pub def psExecuteQuery!(stmt: PreparedStatement[r], setter: PreparedStatementSetter[r, a, a]): DbMonad[r, ka, ResultSet[r]] \ Write(r) =
        let* _  = liftActionResult(_ -> Interop/Sql/PreparedStatement.clearParameters!(stmt));
        let* _  = liftActionResult(_ -> BasicDb/PreparedStatementSetter.runPreparedStatementSetter!(() as Region[r], setter, stmt));
        let* rs = liftActionResult(_ -> Interop/Sql/PreparedStatement.executeQuery!(stmt));
        point(rs)



    pub def psExecuteUpdate!(stmt: PreparedStatement[r], setter: PreparedStatementSetter[r, a, a]): DbMonad[r, ka, Int32] \ Write(r) =
        let* _ = liftActionResult(_ -> Interop/Sql/PreparedStatement.clearParameters!(stmt));
        let* _ = liftActionResult(_ -> BasicDb/PreparedStatementSetter.runPreparedStatementSetter!(() as Region[r], setter, stmt));
        liftActionResult(_ -> Interop/Sql/PreparedStatement.executeUpdate!(stmt))


    /// ResultSet

    pub def rsClose!(rs: ResultSet[r]): DbMonad[r, ka, Unit] \ Write(r) =
        liftActionResult(_ -> Interop/Sql/ResultSet.close!(rs))

    pub def rsNext(rs: ResultSet[r]): DbMonad[r, ka, Bool] \ Write(r) =
        liftActionResult(_ -> Interop/Sql/ResultSet.next!(rs))


    pub def rsEval(eval: RowEvaluator[r, a, a], rs: ResultSet[r]): DbMonad[r, ka, a] \ r =
        liftActionResult(_ -> BasicDb/RowEvaluator.runRowEvaluator(() as Region[r], eval, rs))
        


    pub def firstRow(eval: RowEvaluator[r, a, a], rs: ResultSet[r]): DbMonad[r, ka, a] \ Write(r) = 
        let* more   = rsNext(rs);
        if (more) rsEval(eval, rs) else throwError("firstRow - resultset is empty")

    pub def allRows(eval: RowEvaluator[r, a, a], rs: ResultSet[r]): DbMonad[r, ka, List[a]] \ Write(r) = 
        allRowsHelper(eval, rs, ks -> ks)

    /// Start with `next`
    /// This is optimized to avoid repeated unwrapping.
    def allRowsHelper(eval: RowEvaluator[r, a, a],
                        rs: ResultSet[r],  
                        acc: List[a] -> List[a]): DbMonad[r, ka, List[a]] \ Write(r) = 
        let* more   = rsNext(rs);
        if (more) {
            let* a = rsEval(eval, rs);
            allRowsHelper(eval, rs, acc >> (ks -> a :: ks))
        } else 
            Applicative.point(acc(Nil))


    pub def foreachRow(eval: RowEvaluator[r, a, a], rs: ResultSet[r]): DbMonad[r, ka, Unit] \ Write(r) = 
        let* more  = rsNext(rs);
        if (more) {
            let* _ = rsEval(eval, rs);
            foreachRow(eval, rs)
        } else 
            Applicative.point()


    /// Note - arg order is inconsistent with List.foldLeft etc. and probably should be changed.
    pub def foldAllRows(step: (b, a) -> b \ ef, start: b, eval: RowEvaluator[r, a, a], rs: ResultSet[r]): DbMonad[r, ka, b] \ {ef, Write(r)} = 
        let* more  = rsNext(rs);
        if (more) {
            let* a = rsEval(eval, rs);
            foldAllRows(step, step(start, a), eval, rs)
        } else 
            Applicative.point(start)

/*
    pub def localConnection(r: Region[r], url: String, ma: DbMonad[r, a]): DbMonad[r, a] \ { r, IO } =
        use BasicDb/Internal/Prim.{dmGetConnection, closeConnection};
        DbMonad(_ -> 
            match (dmGetConnection(r, url) as \ r) {
                case Err(e)   => Err(e)
                case Ok(conn) => {
                    let ans1 = apply1(ma, conn);
                    /// ensure conn is closed whether or not previous line is `Ok`
                    discard closeConnection(r, conn);
                    ans1
                }
            }
        ) as \ IO

    pub def localSQLiteConnection(r: Region[r], path: FilePath, ma: DbMonad[r, a]): DbMonad[r, a] \ { r, IO } = 
        use Basis/System/FilePath.{normalize};
        let url = "jdbc:sqlite:${normalize(path)}";
        localConnection(r, url, ma)

    pub def localDuckDBConnection(r: Region[r], path: FilePath, ma: DbMonad[r, a]): DbMonad[r, a] \ { r, IO } =
        use Basis/System/FilePath.{normalize};
        let url = "jdbc:duckdb:${normalize(path)}";
        localConnection(r, url, ma)
*/

/*


    pub def continue(ma: DbMonad[r, a], fk: String -> DbMonad[r, b], sk: a -> DbMonad[r, b]): DbMonad[r, b] = 
        DbMonad((conn) -> match apply1(ma, conn) { 
            case Ok(a) => apply1(sk(a), conn)
            case Err(e) => apply1(fk(e), conn)
        })




    pub def alt(ma: DbMonad[r, a], mb: DbMonad[r, a]): DbMonad[r, a] =
        DbMonad(conn -> match apply1(ma, conn) { 
            case Ok(a) => Ok(a)
            case Err(_) => apply1(mb, conn)
        })

    pub def optional(ma: DbMonad[r, a]): DbMonad[r, Option[a]] = 
        alt(map(Some, ma), point(None))

    pub def tryWithDefault(ma: DbMonad[r, a], d: a): DbMonad[r, a] = 
        alt(ma, point(d))

    pub def testM(ma: DbMonad[r, a]): DbMonad[r, Bool] =
        DbMonad(conn -> match apply1(ma, conn) { 
            case Ok(_) => Ok(true)
            case Err(_) => Ok(false)
        })

    ///
    /// Expose the result of operation `ma`.
    ///
    /// By definition this never fails.
    ///
    pub def result(ma: DbMonad[r, a]): DbMonad[r, Result[a, String]] = 
        DbMonad(conn -> match apply1(ma, conn) {
            case Ok(a) => Ok(Ok(a))
            case Err(e) => Ok(Err(e))
        })

    pub def guard(x: Bool): DbMonad[r, Unit] = match x { 
        case true => point()
        case false => throwError("guard")
    }

    pub def whenTrue(x: Bool, ma: DbMonad[r, a]): DbMonad[r, Option[a]] = match x { 
        case true => map(Some, ma)
        case false => point(None)
    }

    pub def whenFalse(x: Bool, ma: DbMonad[r, a]): DbMonad[r, Option[a]] = match x { 
        case true => point(None)
        case false => map(Some, ma)
    }

    pub def whenTrueM(mx: DbMonad[r, Bool], ma: DbMonad[r, a]): DbMonad[r, Option[a]] = 
        bind(mx, x -> whenTrue(x, ma))

    pub def whenFalseM(mx: DbMonad[r, Bool], ma: DbMonad[r, a]): DbMonad[r, Option[a]] = 
        bind(mx, x -> whenFalse(x, ma))


    pub def whenSome(x: Option[a], f: a -> DbMonad[r, b]): DbMonad[r, Option[b]] = match x { 
        case Some(a) => map(Some, f(a))
        case None => point(None)
    }

    pub def whenNone(x: Option[a], ma: DbMonad[r, b]): DbMonad[r, Option[b]] = match x { 
        case Some(_) => point(None)
        case None => map(Some, ma)
    }

    pub def whenSomeM(mx: DbMonad[r, Option[a]], f: a -> DbMonad[r, b]): DbMonad[r, Option[b]] = 
        bind(mx, x -> whenSome(x, f))
            

    pub def whenNoneM(mx: DbMonad[r, Option[a]], ma: DbMonad[r, b]): DbMonad[r, Option[b]] = 
        bind(mx, x -> whenNone(x, ma))


    pub def ifSomeM(mx: DbMonad[r, Option[a]], mthen: a -> DbMonad[r, b], melse: DbMonad[r, b]): DbMonad[r, b] = 
        bind(mx, x -> match x { 
            case Some(a) => mthen(a)
            case None => melse
        })
            

    pub def ifNoneM(mx: DbMonad[r, Option[a]], mthen: DbMonad[r, b], melse: DbMonad[r, b]): DbMonad[r, b] = 
        bind(mx, x -> match x { 
            case Some(_) => mthen
            case None => melse
        })



    pub def liftOption(x: Option[a], errMsg: String): DbMonad[r, a] = match x {
        case Some(x1) => point(x1)
        case None => throwError(errMsg)
    }

    pub def liftResult(x: Result[a, String]): DbMonad[r, a] = match x { 
        case Ok(x1)   => point(x1)
        case Err(msg) => throwError(msg)
    }

    pub def liftResult1(x: Result[a, e], makeErrMsg: e -> String): DbMonad[r, a] = match x { 
        case Ok(x1) => point(x1)
        case Err(e) => throwError(makeErrMsg(e))
    }

    pub def liftValidation(x: Validation[a, e], makeErrMsg: List[e] -> String): DbMonad[r, a] = match x { 
        case Success(x1) => point(x1)
        case Failure(es) => throwError(makeErrMsg(Nec.toList(es)))
    }

*/

/*
    /// TODO 

    pub def mapM(mf: a -> DbMonad[r, b] \ ef, xs: List[a]): DbMonad[r, List[b]] \ ef =
        DbMonad(conn ->
            mapMHelper(conn, mf, xs, e -> Err(e), ks -> Ok(ks))
        ) as \ ef

    ///
    /// Helper function for `mapM`.
    ///
    def mapMHelper(conn: ##java.sql.Connection, 
                   mf: a -> DbMonad[r, b] \ ef, 
                   xs: List[a], 
                   fk: String -> Result[List[b], String], 
                   sk: List[b] -> Result[List[b], String]): Result[List[b], String] \ r =
        match xs {
            case Nil => sk(Nil)
            case x :: rs => {
                let ma = mf(x) as \ r;
                match apply1(ma, conn) {
                    case Err(e) => fk(e)
                    case Ok(x1) => mapMHelper(conn, mf, rs, fk, ks -> sk(x1 :: ks))
                }
            }
        }


    pub def mapX(mf: a -> DbMonad[r, b] \ ef, xs: List[a]): DbMonad[r, Unit] \ ef =
        DbMonad(conn ->
            mapXHelper(conn, mf, xs, e -> Err(e), _ -> Ok())
        ) as \ ef

    def mapXHelper(conn: ##java.sql.Connection, 
                   mf: a -> DbMonad[r, b] \ ef, 
                   xs: List[a], 
                   fk: String -> Result[Unit, String], 
                   sk: Unit -> Result[Unit, String]): Result[Unit, String] \ r =
        match xs {
            case Nil => sk()
            case x :: rs => {
                let ma = mf(x) as \ r;
                match apply1(ma, conn) {
                    case Err(e) => fk(e)
                    case Ok(_) => mapXHelper(conn, mf, rs, fk, sk)
                }
            }
        }


    pub def mapWithIndexM(mf: (a, Int32) -> DbMonad[r, b] \ ef, xs: List[a]): DbMonad[r, List[b]] \ ef =
        DbMonad(conn ->
            mapWithIndexMHelper(conn, mf, 0, xs, e -> Err(e), ks -> Ok(ks))
        ) as \ ef

    ///
    /// Helper function for `mapM`.
    ///
    def mapWithIndexMHelper(conn: ##java.sql.Connection, 
                            mf: (a, Int32) -> DbMonad[r, b] \ ef, 
                            ix : Int32, 
                            xs: List[a], 
                            fk: String -> Result[List[b], String], 
                            sk: List[b] -> Result[List[b], String]): Result[List[b], String] \ r =
        match xs {
            case Nil => sk(Nil)
            case x :: rs => {
                let ma = mf(x, ix) as \ r;
                match apply1(ma, conn) {
                    case Err(e) => fk(e)
                    case Ok(x1) => mapWithIndexMHelper(conn, mf, ix + 1, rs, fk, ks -> sk(x1 :: ks))
                }
            }
        }

    pub def mapWithIndexX(mf: (a, Int32) -> DbMonad[r, b] \ ef, xs: List[a]): DbMonad[r, Unit] \ ef =
        DbMonad(conn ->
            mapWithIndexXHelper(conn, mf, 0, xs, e -> Err(e), _ -> Ok())
        ) as \ ef

    def mapWithIndexXHelper(conn: ##java.sql.Connection, 
                            mf: (a, Int32) -> DbMonad[r, b] \ ef,
                            ix: Int32, 
                            xs: List[a], 
                            fk: String -> Result[Unit, String], 
                            sk: Unit -> Result[Unit, String]): Result[Unit, String] \ r =
        match xs {
            case Nil => sk()
            case x :: rs => {
                let ma = mf(x, ix) as \ r;
                match apply1(ma, conn) {
                    case Err(e) => fk(e)
                    case Ok(_) => mapWithIndexXHelper(conn, mf, ix + 1, rs, fk, sk)
                }
            }
        }


    pub def sequence(xs: List[DbMonad[r, a]]): DbMonad[r, List[a]] =
        DbMonad(conn ->
            sequenceHelper(conn, xs, e -> Err(e), ks -> Ok(ks))
        )

    ///
    /// Helper function for `sequence`.
    ///
    def sequenceHelper(conn: ##java.sql.Connection,
                       xs: List[DbMonad[r, a]],
                       fk: String -> Result[List[a], String],
                       sk: List[a] -> Result[List[a], String]): Result[List[a], String] \ r =
        match xs {
            case Nil => sk(Nil)
            case mx :: rs => match apply1(mx, conn) {
                case Err(e) => fk(e)
                case Ok(x) => sequenceHelper(conn, rs, fk, ks -> sk(x :: ks))
            }
        }


    ///
    /// Returns `(v1 :: v2 :: ... v :: vn)` if each of `f(xs_i)` is successful.
    /// Otherwise fails with the first error encountered.
    ///
    /// `traverse` is a synonym for `mapM`.
    ///
    pub def traverse(f: a -> DbMonad[r, b] \ ef, xs: List[a]): DbMonad[r, List[b]] \ ef = mapM(f, xs)

    ///
    /// `traverseX` is a synonym for `mapX`.
    ///
    pub def traverseX(f: a -> DbMonad[r, b] \ ef, xs: List[a]): DbMonad[r, Unit] \ ef = mapX(f, xs)

    ///
    /// `forM` is `mapM` with its arguments flipped.
    ///
    pub def forM(xs: List[a], f: a -> DbMonad[r, b] \ ef): DbMonad[r, List[b]] \ ef = mapM(f, xs)

    ///
    /// `forX` is `mapX` with its arguments flipped.
    ///
    pub def forX(xs: List[a], f: a -> DbMonad[r, b] \ ef): DbMonad[r, Unit] \ ef = mapX(f, xs)


    pub def foldLeftM(mf: (b, a) -> DbMonad[r, b] \ ef, start: b, xs: List[a]): DbMonad[r, b] \ ef =
        DbMonad(conn ->
            foldLeftMHelper(conn, mf, start, xs, e -> Err(e), ac -> Ok(ac))
        ) as \ ef

    def foldLeftMHelper(conn: ##java.sql.Connection, 
                    mf: (b, a) -> DbMonad[r, b] \ ef,
                    acc: b, 
                    xs: List[a], 
                    fk: String -> Result[b, String], 
                    sk: b -> Result[b, String]): Result[b, String] \ r =
        match xs {
            case Nil => sk(acc)
            case x :: rs => {
                let ma = mf(acc, x) as \ r;
                match apply1(ma, conn) {
                    case Err(e)   => fk(e)
                    case Ok(acc1) => foldLeftMHelper(conn, mf, acc1, rs, fk, sk)
                }
            }
        }


    /// Note `foldRightM` does not short-circuit on failure as it has to traverse the list
    /// to start at the right.
    pub def foldRightM(mf: (a, b) -> DbMonad[r, b] \ ef, start: b, xs: List[a]): DbMonad[r, b] \ { r, ef } = 
        foldRightMHelper(mf, point(start), xs, ms -> ms as \ ef)

    ///
    /// Helper function for `foldRightM`.
    ///
    def foldRightMHelper(f: (a, b) -> DbMonad[r, b] \ ef, 
                            s: DbMonad[r, b], 
                            xs: List[a], 
                            k: DbMonad[r, b] -> DbMonad[r, b] \ ef): DbMonad[r, b] \ { r, ef }= 
        match xs {
            case Nil => k(s)
            case x :: rs => foldRightMHelper(f, s, rs, ms -> k(bind(ms, s1 -> f(x, s1))))
        }
 
    
    pub def mapAccumM(mf: (ac, a) -> DbMonad[r, (ac, b)], start: ac, xs: List[a]): DbMonad[r, (ac, List[b])] =
        DbMonad(conn ->
            mapAccumMHelper(conn, mf, start, xs, e -> Err(e), (ac, ks) -> Ok((ac, ks)))
        )

    def mapAccumMHelper(conn: ##java.sql.Connection,
                        mf: (ac, a) -> DbMonad[r, (ac, b)] \ ef,
                        ac: ac,
                        xs: List[a],
                        fk: String -> Result[(ac, List[b]), String],
                        sk: (ac, List[b]) -> Result[(ac, List[b]), String]): Result[(ac, List[b]), String] \ r=
        match xs {
            case Nil => sk(ac, Nil)
            case x :: rs => {
                let ma = mf(ac, x) as \ r;
                match apply1(ma, conn) {
                    case Err(e)        => fk(e)
                    case Ok((ac1, x1)) => mapAccumMHelper(conn, mf, ac1, rs, fk, (ac2, ks) -> sk(ac2, x1 :: ks))
                }
            }
        }

    ///
    /// `mapAccumX` is a synonym for `foldM`.
    ///
    pub def mapAccumX(mf: (ac, a) -> DbMonad[r, ac] \ ef, start: ac, xs: List[a]): DbMonad[r, ac] \ ef = foldLeftM(mf, start, xs)


    pub def filterMapM(mf: a -> DbMonad[r, Option[b]] \ ef, xs: List[a]): DbMonad[r, List[b]] \ ef =
        DbMonad(conn ->
            filterMapMHelper(conn, mf, xs, e -> Err(e), ks -> Ok(ks))
        ) as \ ef

    ///
    /// Helper function for `filterMapM`.
    ///
    def filterMapMHelper(conn: ##java.sql.Connection,
                         mf: a -> DbMonad[r, Option[b]] \ ef,
                         xs: List[a],
                         fk: String -> Result[List[b], String],
                         sk: List[b] -> Result[List[b], String]): Result[List[b], String] \ r =
        match xs {
            case Nil => sk(Nil)
            case x :: rs => {
                let ma = mf(x) as \ r; 
                match apply1(ma, conn) {
                    case Err(e) => fk(e)
                    case Ok(ans) => match ans { 
                        case None => filterMapMHelper(conn, mf, rs, fk, sk)
                        case Some(a1) => filterMapMHelper(conn, mf, rs, fk, ks -> sk(a1 :: ks))
                    }
                }
            }
        }



    pub def replicateM(n: Int32, ma: DbMonad[r, a]): DbMonad[r, List[a]] =
        DbMonad(conn ->
            replicateMHelper(conn, ma, n, e -> Err(e), ks -> Ok(ks))
        )

    def replicateMHelper(conn: ##java.sql.Connection,
                         ma: DbMonad[r, a],
                         n: Int32,
                         fk: String -> Result[List[a], String],
                         sk: List[a] -> Result[List[a], String]): Result[List[a], String] \ r =
        if (n <= 0) 
            sk(Nil)
        else 
            match apply1(ma, conn) {
                case Err(e) => fk(e)
                case Ok(a)  => replicateMHelper(conn, ma, n - 1, fk, ks -> sk(a :: ks))
            }


   pub def replicateX(n: Int32, ma: DbMonad[r, a]): DbMonad[r, Unit] =
        DbMonad(conn ->
            replicateXHelper(conn, ma, n, e -> Err(e), _ -> Ok())
        )

    def replicateXHelper(conn: ##java.sql.Connection,
                         ma: DbMonad[r, a],
                         n: Int32,
                         fk: String -> Result[Unit, String],
                         sk: Unit -> Result[Unit, String]): Result[Unit, String] \ r =
        if (n <= 0) 
            sk()
        else 
            match apply1(ma, conn) {
                case Err(e) => fk(e)
                case Ok(_)  => replicateXHelper(conn, ma, n - 1, fk, sk)
            }        

*/

}

