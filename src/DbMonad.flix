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

/// DbMonad has a cache of prepared statements

namespace BasicDb {

    pub opaque type DbMonad[a] = ##java.sql.Connection -> Map[String, PreparedStatement] ~> Result[(Map[String, PreparedStatement], a), String]

    pub opaque type PreparedStatement = ##java.sql.PreparedStatement

    pub opaque type Statement = ##java.sql.Statement

    pub opaque type ResultSet = ##java.sql.ResultSet

}

namespace BasicDb/DbMonad {

        
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

    pub def runDbMonad(ma: DbMonad[a], url: String): Result[a, String] & Impure = 
        use BasicDb/Internal/Prim.{dmGetConnection, closeConnection};
        match dmGetConnection(url) {
            case Err(e) => Err(e)
            case Ok(conn) => {
                let ans    = apply1(ma, conn, Map.empty()) |> Result.map(snd);
                /// ensure conn is closed whether or not previous line is `Ok`
                closeConnection(conn);
                ans
            }
        }
        

    pub def runSQLite(ma: DbMonad[a], path: System.FilePath): Result[a, String] & Impure = 
        use System/FilePath.{normalize};
        let url = "jdbc:sqlite:${normalize(path)}";
        runDbMonad(ma, url)

    pub def runDuckDB(ma: DbMonad[a], path: System.FilePath): Result[a, String] & Impure = 
        use System/FilePath.{normalize};
        let url = "jdbc:duckdb:${normalize(path)}";
        runDbMonad(ma, url)


    def apply1(ma: DbMonad[a], conn: ##java.sql.Connection, pstmts: Map[String, PreparedStatement]): Result[(Map[String, PreparedStatement], a), String] & Impure = 
        let DbMonad(x1) = ma;
        x1(conn, pstmts)

    pub def return(x: a): DbMonad[a] = 
        DbMonad((_, s1) -> Ok((s1, x)) as & Impure)

    pub def throwError(msg: String): DbMonad[a] =
        DbMonad((_, _) -> Err(msg) as & Impure)


    pub def swapError(ma: DbMonad[a], msg: String): DbMonad[a] =
        DbMonad((conn, s1) -> match apply1(ma, conn, s1) { 
            case Ok((s2, a)) => Ok((s2, a))
            case Err(_) => Err(msg)
        })

    
    pub def catchError(ma: DbMonad[a], handle: String -> DbMonad[a]): DbMonad[a] =
        DbMonad((conn, s1) -> match apply1(ma, conn, s1) { 
            case Ok((s2, a)) => Ok((s2, a))
            case Err(e) => apply1(handle(e), conn, s1)
        })

    


    pub def mapError(f: String -> String, ma: DbMonad[a]): DbMonad[a] =
        DbMonad((conn, s1) -> match apply1(ma, conn, s1) { 
            case Ok((s2, a)) => Ok((s2, a))
            case Err(e) => Err(f(e))
        })

    /// Needs to allow allow effects (e.g create / access arrays)
    pub def map(fn: a -> b & ef, ma: DbMonad[a]): DbMonad[b] = 
        DbMonad((conn, s1) -> match apply1(ma, conn, s1) { 
            case Ok((s2, a)) => {let ans = fn(a) as & Impure; Ok((s2, ans))}
            case Err(e) => Err(e)
        })

    pub def ap(mf: DbMonad[a -> b & ef], ma: DbMonad[a]): DbMonad[b] = 
        DbMonad((conn, s1) -> match apply1(mf, conn, s1) { 
            case Ok((s2, f)) => match apply1(ma, conn, s2) { 
                case Ok((s3, a)) => {let ans = f(a) as & Impure; Ok((s3, ans))}
                case Err(e) => Err(e)
            }
            case Err(e) => Err(e)
        })

    pub def seqLeft(ma: DbMonad[a], mb: DbMonad[b]): DbMonad[a] = 
        DbMonad((conn, s1) -> match apply1(ma, conn, s1) { 
            case Ok((s2, a)) => match apply1(mb, conn, s2) {
                case Ok((s3, _)) => Ok(s3, a)
                case Err(e) => Err(e)
            }
            case Err(e) => Err(e)
        })

    pub def seqRight(ma: DbMonad[a], mb: DbMonad[b]): DbMonad[b] = 
        DbMonad((conn, s1) -> match apply1(ma, conn, s1) { 
            case Ok((s2, _)) => apply1(mb, conn, s2)
            case Err(e) => Err(e)
        })


    pub def bind(ma: DbMonad[a], fn: a -> DbMonad[b]): DbMonad[b] = 
        DbMonad((conn, s1) -> match apply1(ma, conn, s1) { 
            case Ok((s2, a)) => apply1(fn(a), conn, s2)
            case Err(e) => Err(e)
        })

    pub def flatMap(fn: a -> DbMonad[b], ma: DbMonad[a]): DbMonad[b] = bind(ma, fn)



    pub def continue(ma: DbMonad[a], fk: String -> DbMonad[b], sk: a -> DbMonad[b]): DbMonad[b] = 
        DbMonad((conn, s1) -> match apply1(ma, conn, s1) { 
            case Ok((s2, a)) => apply1(sk(a), conn, s2)
            case Err(e) => apply1(fk(e), conn, s1)
        })



    pub def kleisliLeft(f1: a -> DbMonad[b], f2: b -> DbMonad[c], x: a): DbMonad[c] =
        DbMonad((conn, s1) -> match apply1(f1(x), conn, s1) { 
            case Ok((s2, b)) => apply1(f2(b), conn, s2)
            case Err(e) => Err(e)
        })

    pub def kleisliRight(f1: b -> DbMonad[c], f2: a -> DbMonad[b], x: a): DbMonad[c] =
        kleisliLeft(f2, f1, x)


    pub def alt(ma: DbMonad[a], mb: DbMonad[a]): DbMonad[a] =
        DbMonad((conn, s1) -> match apply1(ma, conn, s1) { 
            case Ok((s2, a)) => Ok((s2, a))
            case Err(_) => apply1(mb, conn, s1)
        })

    pub def optional(ma: DbMonad[a]): DbMonad[Option[a]] = 
        alt(map(Some, ma), return(None))

    pub def tryWithDefault(ma: DbMonad[a], d: a): DbMonad[a] = 
        alt(ma, return(d))

    pub def testM(ma: DbMonad[a]): DbMonad[Bool] =
        DbMonad((conn, s1) -> match apply1(ma, conn, s1) { 
            case Ok((s2, _)) => Ok((s2, true))
            case Err(_) => Ok((s1, false))
        })

    ///
    /// Expose the result of operation `ma`.
    ///
    /// By definition this never fails.
    ///
    pub def result(ma: DbMonad[a]): DbMonad[Result[a, String]] = 
        DbMonad((conn, s1) -> match apply1(ma, conn, s1) {
            case Ok((s2, a)) => Ok((s2, Ok(a)))
            case Err(e) => Ok((s1, Err(e)))
        })

    pub def guard(x: Bool): DbMonad[Unit] = match x { 
        case true => return()
        case false => throwError("guard")
    }

    pub def whenTrue(x: Bool, ma: DbMonad[a]): DbMonad[Option[a]] = match x { 
        case true => map(Some, ma)
        case false => return(None)
    }

    pub def whenFalse(x: Bool, ma: DbMonad[a]): DbMonad[Option[a]] = match x { 
        case true => return(None)
        case false => map(Some, ma)
    }

    pub def whenTrueM(mx: DbMonad[Bool], ma: DbMonad[a]): DbMonad[Option[a]] = 
        bind(mx, x -> whenTrue(x, ma))

    pub def whenFalseM(mx: DbMonad[Bool], ma: DbMonad[a]): DbMonad[Option[a]] = 
        bind(mx, x -> whenFalse(x, ma))


    pub def whenSome(x: Option[a], f: a -> DbMonad[b]): DbMonad[Option[b]] = match x { 
        case Some(a) => map(Some, f(a))
        case None => return(None)
    }

    pub def whenNone(x: Option[a], ma: DbMonad[b]): DbMonad[Option[b]] = match x { 
        case Some(_) => return(None)
        case None => map(Some, ma)
    }

    pub def whenSomeM(mx: DbMonad[Option[a]], f: a -> DbMonad[b]): DbMonad[Option[b]] = 
        bind(mx, x -> whenSome(x, f))
            

    pub def whenNoneM(mx: DbMonad[Option[a]], ma: DbMonad[b]): DbMonad[Option[b]] = 
        bind(mx, x -> whenNone(x, ma))


    pub def ifSomeM(mx: DbMonad[Option[a]], mthen: a -> DbMonad[b], melse: DbMonad[b]): DbMonad[b] = 
        bind(mx, x -> match x { 
            case Some(a) => mthen(a)
            case None => melse
        })
            

    pub def ifNoneM(mx: DbMonad[Option[a]], mthen: DbMonad[b], melse: DbMonad[b]): DbMonad[b] = 
        bind(mx, x -> match x { 
            case Some(_) => mthen
            case None => melse
        })


    def liftConnectionPrim(fn: ##java.sql.Connection ~> Result[a, String]): DbMonad[a] = 
        DbMonad((conn, s1) -> match fn(conn) {
            case Ok(a) => Ok((s1, a))
            case Err(e) => Err(e)
        })

    pub def liftAction(fn: Unit ~> a): DbMonad[a] = 
        DbMonad((_, s1) -> {let a = fn(); Ok((s1, a))})

    pub def liftOption(x: Option[a], errMsg: String): DbMonad[a] = match x {
        case Some(x1) => return(x1)
        case None => throwError(errMsg)
    }

    pub def liftResult(x: Result[a, String]): DbMonad[a] = match x { 
        case Ok(x1) => return(x1)
        case Err(msg) => throwError(msg)
    }

    pub def liftActionResult(fn: Unit ~> Result[a, String]): DbMonad[a] = 
        DbMonad((_, s1) -> match fn() { 
            case Ok(a) => Ok((s1, a))
            case Err(e) => Err(e)
        })

    // DB operations

    pub def execute(sql: String): DbMonad[Bool] = 
        executeHelper(sql) `swapError` "execute('${sql}')"

    def executeHelper(sql: String): DbMonad[Bool] = 
        use BasicDb/Internal/Prim.{createStatement, executeStatement, closeStatement};
        let* stmt   = liftConnectionPrim(createStatement);
        let* ans    = liftActionResult(_ -> executeStatement(stmt, sql));
        let* _      = liftActionResult(_ -> closeStatement(stmt));
        return(ans)


    pub def setAutoCommit(autoCommit: Bool): DbMonad[Unit] =
        use BasicDb/Internal/Prim.{setAutoCommit};
        liftConnectionPrim(x -> x.setAutoCommit(autoCommit))

    pub def commit(): DbMonad[Unit] =
        use BasicDb/Internal/Prim.{commit};
        liftConnectionPrim(x -> x.commit())


    pub def createStatement(): DbMonad[Statement] =
        use BasicDb/Internal/Prim.{createStatement};
        liftConnectionPrim(x1 -> { let ans = x1.createStatement(); Result.map(Statement, ans)})



    pub def executeQuery(stmt: Statement, sql: String): DbMonad[ResultSet] =
        let Statement(stmt1) = stmt;
        let* rs = liftActionResult(_ -> BasicDb/Internal/Prim.executeQuery(stmt1, sql));
        return(ResultSet(rs))

    pub def executeUpdate(stmt: Statement, sql: String): DbMonad[Int32] =
        let Statement(stmt1) = stmt;
        let* n = liftActionResult(_ -> BasicDb/Internal/Prim.executeUpdate(stmt1, sql));
        return(n)



    pub def prepareStatement(sql: String): DbMonad[PreparedStatement] =
        use BasicDb/Internal/Prim.{prepareStatement};
        swapError( 
            liftConnectionPrim(x1 -> { let ans = x1.prepareStatement(sql); Result.map(PreparedStatement, ans)})
        , "prepareStatement(`${sql}`)"
        )
        
    pub def cachePreparedStatement(name: String, sql: String): DbMonad[Unit] =
        let* pstmt = prepareStatement(sql);
        addPreparedStatement(name, pstmt)

    def addPreparedStatement(name: String, pstmt: PreparedStatement): DbMonad[Unit] =
        DbMonad((_, s1) -> Ok((Map.insert(name, pstmt, s1), ())) as & Impure)

    pub def getPreparedStatement(name: String): DbMonad[PreparedStatement] =
        DbMonad((_, s1) -> match Map.get(name, s1) {
            case Some(pstmt) => Ok((s1, pstmt)) as & Impure
            case None => Err("getPreparedStatement('${name}') missing") as & Impure
        })


    pub def psExecuteQuery(stmt: PreparedStatement, setter: PreparedStatementSetter[a]): DbMonad[ResultSet] =
        let PreparedStatementSetter(setter1) = setter;
        let PreparedStatement(stmt1) = stmt;
        let* _  = liftActionResult(_ -> BasicDb/Internal/PreparedStatement.clearParameters!(stmt1));
        let* _  = liftActionResult(_ -> setter1(stmt1));
        let* rs = liftActionResult(_ -> BasicDb/Internal/PreparedStatement.executeQuery(stmt1));
        return(ResultSet(rs))

    pub def psExecuteCachedQuery(statementName: String, setter: PreparedStatementSetter[a]): DbMonad[ResultSet] =
        let* pstmt = getPreparedStatement(statementName);
        psExecuteQuery(pstmt, setter)

    pub def psExecuteUpdate(stmt: PreparedStatement, setter: PreparedStatementSetter[a]): DbMonad[Int32] =
        let PreparedStatementSetter(setter1) = setter;
        let PreparedStatement(stmt1) = stmt;
        let* _ = liftActionResult(_ -> BasicDb/Internal/PreparedStatement.clearParameters!(stmt1));
        let* _ = liftActionResult(_ -> setter1(stmt1));
        let* n = liftActionResult(_ -> BasicDb/Internal/PreparedStatement.executeUpdate(stmt1));
        return(n)

    pub def psExecuteCachedUpdate(statementName: String, setter: PreparedStatementSetter[a]): DbMonad[Int32] =
        let* pstmt = getPreparedStatement(statementName);
        psExecuteUpdate(pstmt, setter)
        
    /// ResultSet

    pub def rsClose(rs: ResultSet): DbMonad[Unit] =
        use BasicDb/Internal/ResultSet.{close};
        let ResultSet(rs1) = rs;
        liftActionResult(_ -> rs1.close())
 
    pub def rsNext(rs: ResultSet): DbMonad[Bool] =
        use BasicDb/Internal/ResultSet.{next};
        let ResultSet(rs1) = rs;
        liftActionResult(_ -> rs1.next())

    pub def rsEval(rs: ResultSet, eval: RowEvaluator[a]): DbMonad[a] =
        let RowEvaluator(f) = eval;
        let ResultSet(rs1) = rs;
        liftActionResult(_ -> f(rs1))


    pub def firstRow(rs: ResultSet, eval: RowEvaluator[a]): DbMonad[a] = 
        let* more   = rsNext(rs);
        if (more) rsEval(rs, eval) else throwError("firstRow - resultset is empty")

    pub def allRows(rs: ResultSet, eval: RowEvaluator[a]): DbMonad[List[a]] = 
        let RowEvaluator(f) = eval;
        let ResultSet(rs1) = rs;        
        liftActionResult(_ -> allRowsHelper(rs1, f, e -> Err(e), xs -> Ok(xs)))

    /// Start with `next`
    /// This is optimized to avoid repeated unwrapping.
    def allRowsHelper(rs: ##java.sql.ResultSet, 
                      eval: ##java.sql.ResultSet ~> Result[a, String],
                      fk: String -> Result[List[a], String],
                      sk: List[a] -> Result[List[a], String]): Result[List[a], String] & Impure = 
        use BasicDb/Internal/ResultSet.{next};                      
        match rs.next() {
            case Ok(false) => sk(Nil)
            case Ok(true) => match rs.eval() {
                case Ok(x) => allRowsHelper(rs, eval, fk, ks -> sk(x :: ks))
                case Err(e) => fk(e)
            }
            case Err(e) => fk(e)
        }

    pub def allRowsX(rs: ResultSet, eval: RowEvaluator[a]): DbMonad[Unit] = 
        let RowEvaluator(f) = eval;
        let ResultSet(rs1) = rs;        
        liftActionResult(_ -> allRowsXHelper(rs1, f, e -> Err(e)))

    /// Start with `next`
    def allRowsXHelper(rs: ##java.sql.ResultSet, 
                      eval: ##java.sql.ResultSet ~> Result[a, String],
                      fk: String -> Result[Unit, String]): Result[Unit, String] & Impure = 
        use BasicDb/Internal/ResultSet.{next};                      
        match rs.next() {
            case Ok(false) => Ok()
            case Ok(true) => match rs.eval() {
                case Ok(_) => allRowsXHelper(rs, eval, fk)
                case Err(e) => fk(e)
            }
            case Err(e) => fk(e)
        }

    /// Note - arg order is inconsistent with List.foldLeft etc. and probably should be changed.
    pub def foldAllRows(rs: ResultSet, step: (b,a) -> b, start: b, eval: RowEvaluator[a]): DbMonad[b] = 
        let RowEvaluator(f) = eval;
        let ResultSet(rs1) = rs;        
        liftActionResult(_ -> foldAllRowsHelper(rs1, f, step, start))

    /// Start with `next`
    /// This is optimized to avoid repeated unwrapping.
    def foldAllRowsHelper(rs: ##java.sql.ResultSet, 
                      eval: ##java.sql.ResultSet ~> Result[a, String],
                      step: (b, a) -> b,
                      ac: b): Result[b, String] & Impure = 
        use BasicDb/Internal/ResultSet.{next};                      
        match rs.next() {
            case Ok(false) => Ok(ac)
            case Ok(true) => match rs.eval() {
                case Ok(x) => foldAllRowsHelper(rs, eval, step, step(ac, x))
                case Err(e) => Err(e)
            }
            case Err(e) => Err(e)
        }


    pub def mapM(mf: a -> DbMonad[b], xs: List[a]): DbMonad[List[b]] =
        DbMonad((conn, s1) ->
            mapMHelper(conn, mf, s1, xs, e -> Err(e), (s2, ys) -> Ok((s2, ys)))
        )

    ///
    /// Helper function for `mapM`.
    ///
    def mapMHelper(conn: ##java.sql.Connection, 
                   mf: a -> DbMonad[b], 
                   s1: PSCache,
                   xs: List[a], 
                   fk: String -> Result[(PSCache, List[b]), String], 
                   sk: (PSCache, List[b]) -> Result[(PSCache, List[b]), String]): Result[(PSCache, List[b]), String] & Impure =
        match xs {
            case Nil => sk(s1, Nil)
            case x :: rs => {
                let ma = mf(x);
                match apply1(ma, conn, s1) {
                    case Err(e) => fk(e)
                    case Ok((s2, x1)) => mapMHelper(conn, mf, s2, rs, fk, (s3, ks) -> sk(s3, x1 :: ks))
                }
            }
        }

    pub def mapX(mf: a -> DbMonad[b], xs: List[a]): DbMonad[Unit] =
        DbMonad((conn, s1) ->
            mapXHelper(conn, mf, s1, xs, e -> Err(e), s2 -> Ok((s2, ())))
        )

    def mapXHelper(conn: ##java.sql.Connection, 
                   mf: a -> DbMonad[b], 
                   s1: PSCache,
                   xs: List[a], 
                   fk: String -> Result[(PSCache, Unit), String], 
                   sk: PSCache -> Result[(PSCache, Unit), String]): Result[(PSCache, Unit), String] & Impure =
        match xs {
            case Nil => sk(s1)
            case x :: rs => {
                let ma = mf(x);
                match apply1(ma, conn, s1) {
                    case Err(e) => fk(e)
                    case Ok(_) => mapXHelper(conn, mf, s1, rs, fk, sk)
                }
            }
        }

    pub def mapWithIndexM(mf: (a, Int32) -> DbMonad[b], xs: List[a]): DbMonad[List[b]] =
        DbMonad((conn, s1) ->
            mapWithIndexMHelper(conn, mf, s1, 0, xs, e -> Err(e), (s2, ys) -> Ok((s2, ys)))
        )

    ///
    /// Helper function for `mapM`.
    ///
    def mapWithIndexMHelper(conn: ##java.sql.Connection, 
                            mf: (a, Int32) -> DbMonad[b], 
                            s1: PSCache,
                            ix : Int32, 
                            xs: List[a], 
                            fk: String -> Result[(PSCache, List[b]), String], 
                            sk: (PSCache, List[b]) -> Result[(PSCache, List[b]), String]): Result[(PSCache, List[b]), String] & Impure =
        match xs {
            case Nil => sk(s1, Nil)
            case x :: rs => {
                let ma = mf(x, ix);
                match apply1(ma, conn, s1) {
                    case Err(e) => fk(e)
                    case Ok((s2, x1)) => mapWithIndexMHelper(conn, mf, s2, ix + 1, rs, fk, (s3, ks) -> sk(s3, x1 :: ks))
                }
            }
        }

    pub def mapWithIndexX(mf: (a, Int32) -> DbMonad[b], xs: List[a]): DbMonad[Unit] =
        DbMonad((conn, s1) ->
            mapWithIndexXHelper(conn, mf, s1, 0, xs, e -> Err(e), s2 -> Ok((s2, ())))
        )

    def mapWithIndexXHelper(conn: ##java.sql.Connection, 
                            mf: (a, Int32) -> DbMonad[b],
                            s1: PSCache,
                            ix: Int32, 
                            xs: List[a], 
                            fk: String -> Result[(PSCache, Unit), String], 
                            sk: PSCache -> Result[(PSCache, Unit), String]): Result[(PSCache, Unit), String] & Impure =
        match xs {
            case Nil => sk(s1)
            case x :: rs => {
                let ma = mf(x, ix);
                match apply1(ma, conn, s1) {
                    case Err(e) => fk(e)
                    case Ok((s2, _)) => mapWithIndexXHelper(conn, mf, s2, ix + 1, rs, fk, sk)
                }
            }
        }


    pub def sequence(xs: List[DbMonad[a]]): DbMonad[List[a]] =
        DbMonad((conn, s1) ->
            sequenceHelper(conn, s1, xs, e -> Err(e), (s2, ks) -> Ok((s2, ks)))
        )

    ///
    /// Helper function for `sequence`.
    ///
    def sequenceHelper(conn: ##java.sql.Connection,
                       s1: PSCache,
                       xs: List[DbMonad[a]],
                       fk: String -> Result[(PSCache, List[a]), String],
                       sk: (PSCache, List[a]) -> Result[(PSCache, List[a]), String]): Result[(PSCache, List[a]), String] & Impure =
        match xs {
            case Nil => sk(s1, Nil)
            case mx :: rs => match apply1(mx, conn, s1) {
                case Err(e) => fk(e)
                case Ok((s2, x)) => sequenceHelper(conn, s2, rs, fk, (s3, ks) -> sk(s3, x :: ks))
            }
        }

    ///
    /// Returns `(v1 :: v2 :: ... v :: vn)` if each of `f(xs_i)` is successful.
    /// Otherwise fails with the first error encountered.
    ///
    /// `traverse` is a synonym for `mapM`.
    ///
    pub def traverse(f: a -> DbMonad[b], xs: List[a]): DbMonad[List[b]] = mapM(f, xs)

    ///
    /// `traverseX` is a synonym for `mapX`.
    ///
    pub def traverseX(f: a -> DbMonad[b], xs: List[a]): DbMonad[Unit] = mapX(f, xs)

    ///
    /// `forM` is `mapM` with its arguments flipped.
    ///
    pub def forM(xs: List[a], f: a -> DbMonad[b]): DbMonad[List[b]] = mapM(f, xs)

    ///
    /// `forX` is `mapX` with its arguments flipped.
    ///
    pub def forX(xs: List[a], f: a -> DbMonad[b]): DbMonad[Unit] = mapX(f, xs)


    pub def foldLeftM(mf: (b, a) -> DbMonad[b], start: b, xs: List[a]): DbMonad[b] =
        DbMonad((conn, s1) ->
            foldLeftMHelper(conn, mf, s1, start, xs, e -> Err(e), (s2, ac) -> Ok((s2, ac)))
        )

    def foldLeftMHelper(conn: ##java.sql.Connection, 
                    mf: (b, a) -> DbMonad[b], 
                    s1: PSCache,
                    acc: b, 
                    xs: List[a], 
                    fk: String -> Result[(PSCache, b), String], 
                    sk: (PSCache, b) -> Result[(PSCache, b), String]): Result[(PSCache, b), String] & Impure =
        match xs {
            case Nil => sk(s1, acc)
            case x :: rs => {
                let ma = mf(acc, x);
                match apply1(ma, conn, s1) {
                    case Err(e) => fk(e)
                    case Ok((s2, acc1)) => foldLeftMHelper(conn, mf, s2, acc1, rs, fk, sk)
                }
            }
        }

    
    /// Note `foldRightM` does not short-circuit on failure as it has to traverse the list
    /// to start at the right.
    pub def foldRightM(mf: (a, b) -> DbMonad[b], start: b, xs: List[a]): DbMonad[b] = 
        foldRightMHelper(mf, return(start), xs, ms -> ms)

    ///
    /// Helper function for `foldRightM`.
    ///
    def foldRightMHelper(f: (a, b) -> DbMonad[b], s: DbMonad[b], xs: List[a], k: DbMonad[b] -> DbMonad[b]): DbMonad[b] = 
        match xs {
            case Nil => k(s)
            case x :: rs => foldRightMHelper(f, s, rs, ms -> k(bind(ms, s1 -> f(x, s1))))
        }
    
    pub def mapAccumM(mf: (ac, a) -> DbMonad[(ac, b)], start: ac, xs: List[a]): DbMonad[(ac, List[b])] =
        DbMonad((conn, s1) ->
            mapAccumMHelper(conn, mf, s1, start, xs, e -> Err(e), (s2, ac, ks) -> Ok((s2, (ac, ks))))
        )

    def mapAccumMHelper(conn: ##java.sql.Connection,
                        mf: (ac, a) -> DbMonad[(ac, b)],
                        s1: PSCache,
                        ac: ac,
                        xs: List[a],
                        fk: String -> Result[(PSCache, (ac, List[b])), String],
                        sk: (PSCache, ac, List[b]) -> Result[(PSCache, (ac, List[b])), String]): Result[(Map[String, PreparedStatement], (ac, List[b])), String] & Impure =
        match xs {
            case Nil => sk(s1, ac, Nil)
            case x :: rs => {
                let ma = mf(ac, x);
                match apply1(ma, conn, s1) {
                    case Err(e) => fk(e)
                    case Ok((s2, (ac1, x1))) => mapAccumMHelper(conn, mf, s2, ac1, rs, fk, (s3, ac2, ks) -> sk(s3, ac2, x1 :: ks))
                }
            }
        }

    ///
    /// `mapAccumX` is a synonym for `foldM`.
    ///
    pub def mapAccumX(mf: (ac, a) -> DbMonad[ac], start: ac, xs: List[a]): DbMonad[ac] = foldLeftM(mf, start, xs)


    pub def filterMapM(mf: a -> DbMonad[Option[b]], xs: List[a]): DbMonad[List[b]] =
        DbMonad((conn, s1) ->
            filterMapMHelper(conn, mf, s1, xs, e -> Err(e), (s2, ks) -> Ok((s2, ks)))
        )

    ///
    /// Helper function for `filterMapM`.
    ///
    def filterMapMHelper(conn: ##java.sql.Connection,
                         mf: a -> DbMonad[Option[b]],
                         s1: PSCache, 
                         xs: List[a],
                         fk: String -> Result[(PSCache, List[b]), String],
                         sk: (PSCache, List[b]) -> Result[(PSCache, List[b]), String]): Result[(PSCache, List[b]), String] & Impure =
        match xs {
            case Nil => sk(s1, Nil)
            case x :: rs => {
                let ma = mf(x); 
                match apply1(ma, conn, s1) {
                    case Err(e) => fk(e)
                    case Ok((s2, ans)) => match ans { 
                        case None => filterMapMHelper(conn, mf, s2, rs, fk, sk)
                        case Some(a1) => filterMapMHelper(conn, mf, s2, rs, fk, (s3, ks) -> sk(s3, a1 :: ks))
                    }
                }
            }
        }


    pub def replicateM(n: Int32, ma: DbMonad[a]): DbMonad[List[a]] =
        DbMonad((conn, s1) ->
            replicateMHelper(conn, ma, s1, n, e -> Err(e), (s2, ks) -> Ok((s2, ks)))
        )

    def replicateMHelper(conn: ##java.sql.Connection,
                         ma: DbMonad[a],
                         s1: PSCache, 
                         n: Int32,
                         fk: String -> Result[(PSCache, List[a]), String],
                         sk: (PSCache, List[a]) -> Result[(PSCache, List[a]), String]): Result[(PSCache, List[a]), String] & Impure =
        if (n <= 0) 
            sk(s1, Nil)
        else 
            match apply1(ma, conn, s1) {
                case Err(e) => fk(e)
                case Ok((s2, a)) => replicateMHelper(conn, ma, s2, n - 1, fk, (s3, ks) -> sk(s3, a :: ks))
            }
            
        
   pub def replicateX(n: Int32, ma: DbMonad[a]): DbMonad[Unit] =
        DbMonad((conn, s1) ->
            replicateXHelper(conn, ma, s1, n, e -> Err(e), s2 -> Ok((s2, ())))
        )

    def replicateXHelper(conn: ##java.sql.Connection,
                         ma: DbMonad[a],
                         s1: PSCache, 
                         n: Int32,
                         fk: String -> Result[(PSCache, Unit), String],
                         sk: PSCache -> Result[(PSCache, Unit), String]): Result[(PSCache, Unit), String] & Impure =
        if (n <= 0) 
            sk(s1)
        else 
            match apply1(ma, conn, s1) {
                case Err(e) => fk(e)
                case Ok((s2, _)) => replicateXHelper(conn, ma, s2, n - 1, fk, sk)
            }        


    /// Alias for `seqRight`
    pub def *>(p1: DbMonad[a], p2: DbMonad[b]): DbMonad[b] = seqRight(p1, p2)

    /// Alias for `seqLeft`
    pub def <*(p1: DbMonad[a], p2: DbMonad[b]): DbMonad[a] = seqLeft(p1, p2)

    /// Haskell's <|>
    pub def <!>(p1: DbMonad[a], p2: DbMonad[a]): DbMonad[a] =
        alt(p1, p2)

    // Haskell's <$>
    pub def <&>(f: a -> b, p2: DbMonad[a]): DbMonad[b] =
        map(f, p2)

    pub def <&(x: b, p2: DbMonad[a]): DbMonad[b] =
        p2 *> return(x)

    /// Alias for `bind`
    pub def >>=(ma: DbMonad[a], k: a -> DbMonad[b]): DbMonad[b] = bind(ma, k)

    /// Alias for `flatMap` (flipped `bind`)
    pub def =<<(k: a -> DbMonad[b], ma: DbMonad[a]): DbMonad[b] = flatMap(k, ma)


    // Haskell's ap <*>
    pub def <*>(mf: DbMonad[a -> b], p2: DbMonad[a]): DbMonad[b] =
        ap(mf, p2)

    /// Alias for `kleisliLeft`
    pub def >=>(f1: a -> DbMonad[b], f2: b -> DbMonad[c]): a -> DbMonad[c] = x -> kleisliLeft(f1, f2, x)

    /// Alias for `kleisliRight`
    pub def <=<(f1: b -> DbMonad[c], f2: a -> DbMonad[b]): a -> DbMonad[c] = x -> kleisliRight(f1, f2, x)


    ///
    /// Applies the binary function `f` to the values in `o1` and `o2`.
    ///
    /// Returns an error if either `o1` or `o2` are errors.
    ///
    pub def lift2(f: (t1, t2) -> u & ef, 
                  o1: DbMonad[t1], 
                  o2: DbMonad[t2]): DbMonad[u] =
        ap(map(f, o1), o2)


    ///
    /// Applies the ternary function `f` to the values in `o1`, `o2` and `o3`.
    ///
    /// Returns an error if any of `o1`, `o2` and `o3` are errors.
    ///
    pub def lift3(f: (t1, t2, t3) -> u & ef, 
                  o1: DbMonad[t1], 
                  o2: DbMonad[t2], 
                  o3: DbMonad[t3]): DbMonad[u] =
        ap(lift2(f, o1, o2), o3)

    ///
    /// Applies the 4-ary function `f` to the values in `o1`, `o2`, `o3` and `o4`.
    ///
    /// Returns an error if any of `o1`, `o2`, `o3` and `o4` are errors.
    ///
    pub def lift4(f: (t1, t2, t3, t4) -> u & ef, 
                  o1: DbMonad[t1], 
                  o2: DbMonad[t2], 
                  o3: DbMonad[t3], 
                  o4: DbMonad[t4]): DbMonad[u] =
        ap(lift3(f, o1, o2, o3), o4)

    ///
    /// Applies the 5-ary function `f` to the values in `o1`, `o2`, ... `o5`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o5` are errors.
    ///
    pub def lift5(f: (t1, t2, t3, t4, t5) -> u & ef, 
                  o1: DbMonad[t1], 
                  o2: DbMonad[t2], 
                  o3: DbMonad[t3], 
                  o4: DbMonad[t4], 
                  o5: DbMonad[t5]): DbMonad[u] =
        ap(lift4(f, o1, o2, o3, o4), o5)

    ///
    /// Applies the 6-ary function `f` to the values in `o1`, `o2`, ... `o6`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o6` are errors.
    ///
    pub def lift6(f: (t1, t2, t3, t4, t5, t6) -> u & ef, 
                  o1: DbMonad[t1], 
                  o2: DbMonad[t2], 
                  o3: DbMonad[t3],
                  o4: DbMonad[t4], 
                  o5: DbMonad[t5], 
                  o6: DbMonad[t6]): DbMonad[u] =
        ap(lift5(f, o1, o2, o3, o4, o5), o6)

    ///
    /// Applies the 7-ary function `f` to the values in `o1`, `o2`, ... `o7`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o7` are errors.
    ///
    pub def lift7(f: (t1, t2, t3, t4, t5, t6, t7) -> u & ef, 
                  o1: DbMonad[t1], 
                  o2: DbMonad[t2], 
                  o3: DbMonad[t3], 
                  o4: DbMonad[t4], 
                  o5: DbMonad[t5], 
                  o6: DbMonad[t6], 
                  o7: DbMonad[t7]): DbMonad[u] =
        ap(lift6(f, o1, o2, o3, o4, o5, o6), o7)

    ///
    /// Applies the 8-ary function `f` to the values in `o1`, `o2`, ... `o8`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o8` are errors.
    ///
    pub def lift8(f: (t1, t2, t3, t4, t5, t6, t7, t8) -> u & ef, 
                  o1: DbMonad[t1], 
                  o2: DbMonad[t2], 
                  o3: DbMonad[t3], 
                  o4: DbMonad[t4], 
                  o5: DbMonad[t5], 
                  o6: DbMonad[t6], 
                  o7: DbMonad[t7], 
                  o8: DbMonad[t8]): DbMonad[u] =
        ap(lift7(f, o1, o2, o3, o4, o5, o6, o7), o8)

    ///
    /// Applies the 9-ary function `f` to the values in `o1`, `o2`, ... `o9`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o9` are errors.
    ///
    pub def lift9(f: (t1, t2, t3, t4, t5, t6, t7, t8, t9) -> u & ef, 
                  o1: DbMonad[t1], 
                  o2: DbMonad[t2], 
                  o3: DbMonad[t3], 
                  o4: DbMonad[t4], 
                  o5: DbMonad[t5], 
                  o6: DbMonad[t6], 
                  o7: DbMonad[t7], 
                  o8: DbMonad[t8], 
                  o9: DbMonad[t9]): DbMonad[u] =
        ap(lift8(f, o1, o2, o3, o4, o5, o6, o7, o8), o9)

    ///
    /// Applies the 10-ary function `f` to the values in `o1`, `o2`, ... `o10`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o10` are errors.
    ///
    pub def lift10(f: (t1, t2, t3, t4, t5, t6, t7, t8, t9, t10) -> u & ef, 
                   o1: DbMonad[t1], 
                   o2: DbMonad[t2], 
                   o3: DbMonad[t3], 
                   o4: DbMonad[t4], 
                   o5: DbMonad[t5], 
                   o6: DbMonad[t6], 
                   o7: DbMonad[t7], 
                   o8: DbMonad[t8], 
                   o9: DbMonad[t9], 
                   o10: DbMonad[t10]): DbMonad[u] =
        ap(lift9(f, o1, o2, o3, o4, o5, o6, o7, o8, o9), o10)


    ///
    /// Returns a 2 element tuple with the results of applying the evaluators `o1` and `o2`.
    ///
    /// Returns an error if evaluating either `o1` or `o2` is an error.
    ///
    pub def tuple2(o1: DbMonad[t1], o2: DbMonad[t2]): DbMonad[(t1, t2)] =
        lift2((x,y) -> (x,y), o1, o2)

    ///
    /// Returns a 3 element tuple with the results of applying the evaluators `o1`, `o2` and `o3`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2` and `o3` is an error.
    ///
    pub def tuple3(o1: DbMonad[t1], 
                   o2: DbMonad[t2], 
                   o3: DbMonad[t3]): DbMonad[(t1, t2, t3)] =
        lift3((x1, x2, x3) -> (x1, x2, x3), o1, o2, o3)

    ///
    /// Returns a 4 element tuple with the results of applying the evaluators `o1`, `o2`, `o3` and `o4`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, `o3` and `o4` is an error.
    ///
    pub def tuple4(o1: DbMonad[t1], 
                   o2: DbMonad[t2], 
                   o3: DbMonad[t3], 
                   o4: DbMonad[t4]): DbMonad[(t1, t2, t3, t4)]  =
        lift4((x1, x2, x3, x4) -> (x1, x2, x3, x4), o1, o2, o3, o4)

    ///
    /// Returns a 5 element tuple with the results of applying the evaluators `o1`, `o2`, ... `o5`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, ... `o5` is an error.
    ///
    pub def tuple5(o1: DbMonad[t1], 
                   o2: DbMonad[t2], 
                   o3: DbMonad[t3], 
                   o4: DbMonad[t4], 
                   o5: DbMonad[t5]): DbMonad[(t1, t2, t3, t4, t5)]  =
        lift5((x1, x2, x3, x4, x5) -> (x1, x2, x3, x4, x5), o1, o2, o3, o4, o5)

    ///
    /// Returns a 6 element tuple with the results of applying the evaluators `o1`, `o2`, ... `o6`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, ... `o6` is an error.
    ///
    pub def tuple6(o1: DbMonad[t1], 
                   o2: DbMonad[t2], 
                   o3: DbMonad[t3], 
                   o4: DbMonad[t4], 
                   o5: DbMonad[t5], 
                   o6: DbMonad[t6]): DbMonad[(t1, t2, t3, t4, t5, t6)]  =
        lift6((x1, x2, x3, x4, x5, x6) -> (x1, x2, x3, x4, x5, x6), o1, o2, o3, o4, o5, o6)

    ///
    /// Returns a 7 element tuple with the results of applying the evaluators `o1`, `o2`, ... `o7`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, ... `o7` is an error.
    ///
    pub def tuple7(o1: DbMonad[t1], 
                   o2: DbMonad[t2], 
                   o3: DbMonad[t3], 
                   o4: DbMonad[t4], 
                   o5: DbMonad[t5], 
                   o6: DbMonad[t6], 
                   o7: DbMonad[t7]): DbMonad[(t1, t2, t3, t4, t5, t6, t7)]  =
        lift7((x1, x2, x3, x4, x5, x6, x7) -> (x1, x2, x3, x4, x5, x6, x7), 
                o1, o2, o3, o4, o5, o6, o7)

    ///
    /// Returns a 8 element tuple with the results of applying the evaluators `o1`, `o2`, ... `o8`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, ... `o8` is an error.
    ///
    pub def tuple8(o1: DbMonad[t1], 
                   o2: DbMonad[t2], 
                   o3: DbMonad[t3], 
                   o4: DbMonad[t4], 
                   o5: DbMonad[t5], 
                   o6: DbMonad[t6], 
                   o7: DbMonad[t7], 
                   o8: DbMonad[t8]): DbMonad[(t1, t2, t3, t4, t5, t6, t7, t8)]  =
        lift8((x1, x2, x3, x4, x5, x6, x7, x8) -> (x1, x2, x3, x4, x5, x6, x7, x8), 
                o1, o2, o3, o4, o5, o6, o7, o8)

    ///
    /// Returns a 9 element tuple with the results of applying the evaluators `o1`, `o2`, ... `o9`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, ... `o9` is an error.
    ///
    pub def tuple9(o1: DbMonad[t1], 
                   o2: DbMonad[t2], 
                   o3: DbMonad[t3], 
                   o4: DbMonad[t4], 
                   o5: DbMonad[t5], 
                   o6: DbMonad[t6], 
                   o7: DbMonad[t7], 
                   o8: DbMonad[t8], 
                   o9: DbMonad[t9]): DbMonad[(t1, t2, t3, t4, t5, t6, t7, t8, t9)]  =
        lift9((x1, x2, x3, x4, x5, x6, x7, x8, x9) -> (x1, x2, x3, x4, x5, x6, x7, x8, x9), 
                o1, o2, o3, o4, o5, o6, o7, o8, o9)

    ///
    /// Returns a 10 element tuple with the results of applying the evaluators `o1`, `o2`, ... `o10`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, ... `o10` is an error.
    ///
    pub def tuple10(o1: DbMonad[t1], 
                    o2: DbMonad[t2], 
                    o3: DbMonad[t3], 
                    o4: DbMonad[t4], 
                    o5: DbMonad[t5], 
                    o6: DbMonad[t6], 
                    o7: DbMonad[t7], 
                    o8: DbMonad[t8], 
                    o9: DbMonad[t9], 
                    o10: DbMonad[t10]): DbMonad[(t1, t2, t3, t4, t5, t6, t7, t8, t9, t10)]  =
        lift10((x1, x2, x3, x4, x5, x6, x7, x8, x9, x10) -> (x1, x2, x3, x4, x5, x6, x7, x8, x9, x10), 
                o1, o2, o3, o4, o5, o6, o7, o8, o9, o10)



}

