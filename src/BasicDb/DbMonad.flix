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

    /// TODO - codensity and pass a region so there aren't pure expressions that 
    /// the compiler might write...

    pub enum DbMonad[r: Region, a: Type](##java.sql.Connection -> Result[a, String] \ r)

    instance Functor[DbMonad[r]] { 
        pub def map(f: a -> b \ ef, x: DbMonad[r, a]): DbMonad[r, b] \ ef = 
            BasicDb/DbMonad.map(f, x)
    }

    instance Applicative[DbMonad[r]] { 
        pub def point(x: a): DbMonad[r, a] = 
            BasicDb/DbMonad.point(x)

        pub def ap(f: DbMonad[r, a -> b \ ef], x: DbMonad[r, a]): DbMonad[r, b] \ ef = 
            BasicDb/DbMonad.ap(f, x)
    }

    instance Monad[DbMonad[r]] { 
        pub def flatMap(k: a -> DbMonad[r, b] \ ef, x: DbMonad[r, a]): DbMonad[r, b] \ ef = 
            BasicDb/DbMonad.flatMap(k, x)
    }


    pub enum PreparedStatement(##java.sql.PreparedStatement)

    pub enum Statement(##java.sql.Statement)

    pub enum ResultSet(##java.sql.ResultSet)

}

namespace BasicDb/DbMonad {

    use Basis/System.FilePath;

    use BasicDb.DbMonad;
    use BasicDb.DbMonad.{DbMonad};

    use BasicDb.PreparedStatement;
    use BasicDb.PreparedStatement.{PreparedStatement};

    use BasicDb.PreparedStatementSetter;
    use BasicDb.PreparedStatementSetter.{PreparedStatementSetter};

    use BasicDb.ResultSet;
    use BasicDb.ResultSet.{ResultSet};

    use BasicDb.RowEvaluator;
    use BasicDb.RowEvaluator.{RowEvaluator};

    use BasicDb.Statement;
    use BasicDb.Statement.{Statement};

    type alias PSCache = Map[String, PreparedStatement]

    pub def runDbMonad(r: Region[r], ma: DbMonad[r, a], url: String): Result[a, String] \ { r, Impure } = 
        use BasicDb/Internal/Prim.{dmGetConnection, closeConnection};
        match dmGetConnection(r, url) {
            case Err(e) => Err(e)
            case Ok(conn) => {
                let ans    = apply1(ma, conn);
                /// ensure conn is closed whether or not previous line is `Ok`
                discard closeConnection(r, conn);
                ans
            }
        }
        

    pub def runSQLite(r: Region[r], ma: DbMonad[r, a], path: FilePath): Result[a, String] \ { r, Impure } = 
        use Basis/System/FilePath.{normalize};
        let url = "jdbc:sqlite:${normalize(path)}";
        runDbMonad(r, ma, url)

    pub def runDuckDB(r: Region[r], ma: DbMonad[r, a], path: FilePath): Result[a, String] \ { r, Impure } = 
        use Basis/System/FilePath.{normalize};
        let url = "jdbc:duckdb:${normalize(path)}";
        runDbMonad(r, ma, url)


    def apply1(ma: DbMonad[r, a], conn: ##java.sql.Connection): Result[a, String] \ r = 
        let DbMonad(x1) = ma;
        x1(conn)
    
    def getDbMonadRegion(): DbMonad[r, Region[r]] = 
        DbMonad(_ -> Ok(() as Region[r]) as \ r)


    pub def point(x: a): DbMonad[r, a] = DbMonad(_ -> Ok(x) as \ r)

    pub def throwError(msg: String): DbMonad[r, a] = DbMonad(_ -> Err(msg) as \ r)


    pub def swapError(ma: DbMonad[r, a], msg: String): DbMonad[r, a] =
        DbMonad(conn -> match apply1(ma, conn) { 
            case Ok(a)  => Ok(a)
            case Err(_) => Err(msg)
        })

    
    pub def catchError(ma: DbMonad[r, a], handle: String -> DbMonad[r, a]): DbMonad[r, a] =
        DbMonad(conn -> match apply1(ma, conn) { 
            case Ok(a) => Ok(a)
            case Err(e) => apply1(handle(e), conn)
        })


    pub def mapError(f: String -> String, ma: DbMonad[r, a]): DbMonad[r, a] =
        DbMonad(conn -> match apply1(ma, conn) { 
            case Ok(a) => Ok(a)
            case Err(e) => Err(f(e))
        })

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


    /// Needs to allow allow effects (e.g create / access arrays)
    pub def map(fn: a -> b \ ef, ma: DbMonad[r, a]): DbMonad[r, b] \ ef = 
        DbMonad(conn -> match apply1(ma, conn) { 
            case Ok(a) => {let ans = fn(a) as \ {}; Ok(ans)}
            case Err(e) => Err(e)
        }) as \ ef

    pub def ap(mf: DbMonad[r, a -> b \ ef], ma: DbMonad[r, a]): DbMonad[r, b] \ ef = 
        DbMonad(conn -> match apply1(mf, conn) { 
            case Ok(f) => match apply1(ma, conn) { 
                case Ok(a) => {let ans = f(a) as \ {}; Ok(ans)}
                case Err(e) => Err(e)
            }
            case Err(e) => Err(e)
        }) as \ ef




    pub def bind(ma: DbMonad[r, a], fn: a -> DbMonad[r, b] \ ef): DbMonad[r, b] \ ef = 
        DbMonad(conn -> match apply1(ma, conn) { 
            case Ok(a) => apply1(fn(a) as \ {}, conn)
            case Err(e) => Err(e)
        }) as \ ef

    pub def flatMap(fn: a -> DbMonad[r, b] \ ef, ma: DbMonad[r, a]): DbMonad[r, b] \ ef = bind(ma, fn)



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


    def liftConnectionPrim(fn: ##java.sql.Connection -> Result[a, String] \ ef): DbMonad[r, a] \ ef= 
        DbMonad(conn -> fn(conn) as \ r) as \ ef

    pub def liftAction(fn: Unit -> a \ ef): DbMonad[r, a] \ ef = 
        DbMonad(_ -> {let a = fn() as \ r; Ok(a)}) as \ ef

    pub def liftActionResult(fn: Unit -> Result[a, String] \ ef): DbMonad[r, a] \ ef= 
        DbMonad(_ -> fn() as \ r) as \ ef

    // DB operations

    pub def execute(sql: String): DbMonad[r, Bool] \ Write(r) = 
        mapError(msg -> "execute('${sql}')" + Environment.getLineSeparator() + msg, executeHelper(sql))

    def executeHelper(sql: String): DbMonad[r, Bool] \ Write(r) = 
        use BasicDb/Internal/Prim.{createStatement, executeStatement, closeStatement};
        let* r      = getDbMonadRegion();
        let* stmt   = liftConnectionPrim(createStatement(r));
        let* ans    = liftActionResult(_ -> executeStatement(r, stmt, sql));
        let* _      = liftActionResult(_ -> closeStatement(r, stmt));
        point(ans)



    pub def setAutoCommit(autoCommit: Bool): DbMonad[r, Unit] \ Write(r) =
        use BasicDb/Internal/Prim.{setAutoCommit};
        let* r = getDbMonadRegion();
        liftConnectionPrim(setAutoCommit(r, autoCommit))


    pub def commit(): DbMonad[r, Unit] \ Write(r) =
        use BasicDb/Internal/Prim.{commit};
        let* r = getDbMonadRegion();
        liftConnectionPrim(commit(r))


    pub def createStatement(): DbMonad[r, Statement] \ Write(r) =
        use BasicDb/Internal/Prim.{createStatement};
        let* r = getDbMonadRegion();
        liftConnectionPrim(x1 -> { let ans = createStatement(r, x1); Result.map(Statement, ans)})



    pub def executeQuery(stmt: Statement, sql: String): DbMonad[r, ResultSet] \ Write(r) =
        let body = () -> { 
            let Statement(stmt1) = stmt;
            let* r = getDbMonadRegion();
            let* rs = liftActionResult(_ -> BasicDb/Internal/Prim.executeQuery(r, stmt1, sql));
            point(ResultSet(rs))
        };
        swapError(body(), "executeQuery: ${sql}")

    pub def executeUpdate(stmt: Statement, sql: String): DbMonad[r, Int32] \ Write(r) =
        let body = () -> { 
            let Statement(stmt1) = stmt;
            let* r = getDbMonadRegion();
            let* n = liftActionResult(_ -> BasicDb/Internal/Prim.executeUpdate(r, stmt1, sql));
            point(n)
        };
        swapError(body(), "executeUpdate: ${sql}")


    pub def prepareStatement(sql: String): DbMonad[r, PreparedStatement] \ Write(r) =
        use BasicDb/Internal/Prim.{prepareStatement};
        let* r  = getDbMonadRegion();
        swapError( 
            liftConnectionPrim(conn -> { let ans = prepareStatement(r, conn, sql); Result.map(PreparedStatement, ans)})
        , "prepareStatement(`${sql}`)"
        )
        

    pub def psExecuteQuery(stmt: PreparedStatement, setter: PreparedStatementSetter[r, a]): DbMonad[r, ResultSet] \ Write(r) =
        let PreparedStatementSetter(setter1) = setter;
        let PreparedStatement(stmt1) = stmt;
        let* r  = getDbMonadRegion();
        let* _  = liftActionResult(_ -> BasicDb/Internal/PreparedStatement.clearParameters!(r, stmt1));
        let* _  = liftActionResult(_ -> setter1(stmt1));
        let* rs = liftActionResult(_ -> BasicDb/Internal/PreparedStatement.executeQuery(r, stmt1));
        point(ResultSet(rs))


        
    pub def psExecuteUpdate(stmt: PreparedStatement, setter: PreparedStatementSetter[r, a]): DbMonad[r, Int32] \ Write(r) =
        let PreparedStatementSetter(setter1) = setter;
        let PreparedStatement(stmt1) = stmt;
        let* r = getDbMonadRegion();
        let* _ = liftActionResult(_ -> BasicDb/Internal/PreparedStatement.clearParameters!(r, stmt1));
        let* _ = liftActionResult(_ -> setter1(stmt1));
        let* n = liftActionResult(_ -> BasicDb/Internal/PreparedStatement.executeUpdate(r, stmt1));
        point(n)


    /// ResultSet

    pub def rsClose(rs: ResultSet): DbMonad[r, Unit] \ Write(r) =
        use BasicDb/Internal/ResultSet.{close};
        let ResultSet(rs1) = rs;
        let* r = getDbMonadRegion();
        liftActionResult(_ -> close(r, rs1))
 
    pub def rsNext(rs: ResultSet): DbMonad[r, Bool] \ Write(r) =
        use BasicDb/Internal/ResultSet.{next};
        let ResultSet(rs1) = rs;
        let* r = getDbMonadRegion();
        liftActionResult(_ -> next(r, rs1))

    pub def rsEval(rs: ResultSet, eval: RowEvaluator[r, a]): DbMonad[r, a] \ r =
        let RowEvaluator(f) = eval;
        let ResultSet(rs1) = rs;
        liftActionResult(_ -> f(rs1))



    pub def firstRow(rs: ResultSet, eval: RowEvaluator[r, a]): DbMonad[r, a] \ Write(r) = 
        let* more   = rsNext(rs);
        if (more) rsEval(rs, eval) else throwError("firstRow - resultset is empty")

    pub def allRows(rs: ResultSet, eval: RowEvaluator[r, a]): DbMonad[r, List[a]] \ Write(r) = 
        let RowEvaluator(f) = eval;
        let ResultSet(rs1) = rs;
        let* r = getDbMonadRegion();
        liftActionResult(_ -> allRowsHelper(r, rs1, f, e -> Err(e) as \ Write(r), xs -> Ok(xs) as \ Write(r)))

    /// Start with `next`
    /// This is optimized to avoid repeated unwrapping.
    def allRowsHelper(r: Region[r], 
                        rs: ##java.sql.ResultSet, 
                        eval: ##java.sql.ResultSet -> Result[a, String] \ Write(r),
                        fk: String -> Result[List[a], String] \ Write(r),
                        sk: List[a] -> Result[List[a], String] \ Write(r)): Result[List[a], String] \ Write(r) = 
        use BasicDb/Internal/ResultSet.{next};                      
        match next(r, rs) {
            case Ok(false) => sk(Nil)
            case Ok(true)  => match eval(rs) {
                case Ok(x)  => allRowsHelper(r, rs, eval, fk, ks -> sk(x :: ks))
                case Err(e) => fk(e)
            }
            case Err(e) => fk(e)
        }

    pub def allRowsX(rs: ResultSet, eval: RowEvaluator[r, a]): DbMonad[r, Unit] \ Write(r) = 
        let RowEvaluator(f) = eval;
        let ResultSet(rs1) = rs;
        let* r = getDbMonadRegion();
        liftActionResult(_ -> allRowsXHelper(r, rs1, f, e -> Err(e) as \ Write(r)))

    /// Start with `next`
    def allRowsXHelper(r: Region[r], 
                        rs: ##java.sql.ResultSet, 
                        eval: ##java.sql.ResultSet -> Result[a, String] \ Write(r),
                        fk: String -> Result[Unit, String]\ Write(r)): Result[Unit, String] \ Write(r) = 
        use BasicDb/Internal/ResultSet.{next};                      
        match next(r, rs) {
            case Ok(false) => Ok()
            case Ok(true) => match eval(rs) {
                case Ok(_) => allRowsXHelper(r, rs, eval, fk)
                case Err(e) => fk(e)
            }
            case Err(e) => fk(e)
        }


    /// Note - arg order is inconsistent with List.foldLeft etc. and probably should be changed.
    pub def foldAllRows(rs: ResultSet, step: (b, a) -> b, start: b, eval: RowEvaluator[r, a]): DbMonad[r, b] \ Write(r) = 
        let RowEvaluator(f) = eval;
        let ResultSet(rs1) = rs;
        let* r = getDbMonadRegion();
        liftActionResult(_ -> foldAllRowsHelper(r, rs1, f, step, start))

    /// Start with `next`
    /// This is optimized to avoid repeated unwrapping.
    def foldAllRowsHelper(r: Region[r], rs: ##java.sql.ResultSet, 
                            eval: ##java.sql.ResultSet -> Result[a, String] \ Write(r),
                            step: (b, a) -> b,
                            ac: b): Result[b, String] \ Write(r) = 
        use BasicDb/Internal/ResultSet.{next};                      
        match next(r, rs) {
            case Ok(false) => Ok(ac)
            case Ok(true) => match eval(rs) {
                case Ok(x) => foldAllRowsHelper(r, rs, eval, step, step(ac, x))
                case Err(e) => Err(e)
            }
            case Err(e) => Err(e)
        }


    /// TODO 
    /// DbMonad should be rewritten in CPS and these functions put in a common library.

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



}

