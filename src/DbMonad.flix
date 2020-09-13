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



namespace BasicDb {

    pub opaque type DbMonad[a] = ##java.sql.Connection ~> Result[a, System.Error]

    pub opaque type PreparedStatement = ##java.sql.PreparedStatement

    pub opaque type Statement = ##java.sql.Statement

    pub opaque type ResultSet = ##java.sql.ResultSet

}

namespace BasicDb/DbMonad {

    pub def runDbMonad(ma: DbMonad[a], url: String): Result[a, System.Error] & Impure = 
        use BasicDb/Internal/Prim.{dmGetConnection, closeConnection};
        use Result.{flatMap};
        match dmGetConnection(url) { 
            case Err(e) => Err(e)
            case Ok(conn) => {
                let ans = apply1(ma, conn);
                let* _ = closeConnection(conn);
                ans         
            }
        }
        

    pub def runSQLite(ma: DbMonad[a], path: System.FilePath): Result[a, System.Error] & Impure = 
        use System/FilePath.{toString};
        let url = "jdbc:sqlite:" + path.toString();
        runDbMonad(ma, url)

    pub def runDuckDB(ma: DbMonad[a], path: System.FilePath): Result[a, System.Error] & Impure = 
        use System/FilePath.{toString};
        let url = "jdbc:duckdb:" + path.toString();
        runDbMonad(ma, url)


    def apply1(ma: DbMonad[a], conn: ##java.sql.Connection): Result[a, System.Error] & Impure = 
        let DbMonad(x1) = ma;
        x1(conn)

    pub def return(x: a): DbMonad[a] = 
        DbMonad(_ -> Ok(x) as & Impure)

    pub def throwError(msg: String): DbMonad[a] =
        DbMonad(_ -> Err(System/Error.Generic(msg)) as & Impure)

    pub def map(fn: a -> b, ma: DbMonad[a]): DbMonad[b] = 
        DbMonad(conn -> 
            match apply1(ma, conn) { 
                case Ok(a) => Ok(fn(a))
                case Err(e) => Err(e)
            }
        )

    pub def ap(mf: DbMonad[a -> b], ma: DbMonad[a]): DbMonad[b] = 
        DbMonad(conn -> 
            match apply1(mf, conn) { 
                case Ok(f) => match apply1(ma, conn) { 
                    case Ok(a) => Ok(f(a))
                    case Err(e) => Err(e)
                }
                case Err(e) => Err(e)
            }
        )

    pub def bind(ma: DbMonad[a], fn: a -> DbMonad[b]): DbMonad[b] = 
        DbMonad(conn -> 
            match apply1(ma, conn) { 
                case Ok(a) => apply1(fn(a), conn)
                case Err(e) => Err(e)
            }
        )

    pub def flatMap(fn: a -> DbMonad[b], ma: DbMonad[a]): DbMonad[b] = bind(ma, fn)


    pub def alt(ma: DbMonad[a], mb: DbMonad[a]): DbMonad[a] =
        DbMonad(conn -> 
            match apply1(ma, conn) { 
                case Ok(a) => Ok(a)
                case Err(_) => apply1(mb, conn)
            }
        )

    pub def optional(ma: DbMonad[a]): DbMonad[Option[a]] = 
        alt(map(Some, ma), return(None))


    def liftConnectionPrim(fn: ##java.sql.Connection ~> Result[a, System.Error]): DbMonad[a] = 
        DbMonad(conn -> fn(conn))

    pub def liftAction(fn: Unit ~> a): DbMonad[a] = 
        DbMonad(_ -> { let a = fn(); Ok(a) })

    pub def liftActionResult(fn: Unit ~> Result[a, System.Error]): DbMonad[a] = 
        DbMonad(_ -> fn())

    // DB operations

    pub def execute(sql: String): DbMonad[Bool] = 
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
        liftConnectionPrim(x1 -> { let ans = x1.prepareStatement(sql); Result.map(PreparedStatement, ans)})

    pub def psExecuteQuery(stmt: PreparedStatement, setter: PreparedStatementSetter[a]): DbMonad[ResultSet] =
        let PreparedStatementSetter(setter1) = setter;
        let PreparedStatement(stmt1) = stmt;
        let* _  = liftActionResult(_ -> BasicDb/Internal/PreparedStatement.clearParameters!(stmt1));
        let* _  = liftActionResult(_ -> setter1(stmt1));
        let* rs = liftActionResult(_ -> BasicDb/Internal/PreparedStatement.executeQuery(stmt1));
        return(ResultSet(rs))

    pub def psExecuteUpdate(stmt: PreparedStatement, setter: PreparedStatementSetter[a]): DbMonad[Int32] =
        let PreparedStatementSetter(setter1) = setter;
        let PreparedStatement(stmt1) = stmt;
        let* _ = liftActionResult(_ -> BasicDb/Internal/PreparedStatement.clearParameters!(stmt1));
        let* _ = liftActionResult(_ -> setter1(stmt1));
        let* n = liftActionResult(_ -> BasicDb/Internal/PreparedStatement.executeUpdate(stmt1));
        return(n)


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
                      eval: ##java.sql.ResultSet ~> Result[a, System.Error],
                      fk: System.Error -> Result[List[a], System.Error],
                      sk: List[a] -> Result[List[a], System.Error]): Result[List[a], System.Error] & Impure = 
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
                      eval: ##java.sql.ResultSet ~> Result[a, System.Error],
                      fk: System.Error -> Result[Unit, System.Error]): Result[Unit, System.Error] & Impure = 
        use BasicDb/Internal/ResultSet.{next};                      
        match rs.next() {
            case Ok(false) => Ok()
            case Ok(true) => match rs.eval() {
                case Ok(_) => allRowsXHelper(rs, eval, fk)
                case Err(e) => fk(e)
            }
            case Err(e) => fk(e)
        }


    pub def mapM(mf: a -> DbMonad[b], xs: List[a]): DbMonad[List[b]] =
        DbMonad(conn ->
            mapMHelper(conn, mf, xs, e -> Err(e), ys -> Ok(ys))
        )

    ///
    /// Helper function for `mapM`.
    ///
    def mapMHelper(conn: ##java.sql.Connection, 
                   mf: a -> DbMonad[b], 
                   xs: List[a], 
                   fk: System.Error -> Result[List[b], System.Error], 
                   sk: List[b] -> Result[List[b], System.Error]): Result[List[b], System.Error] & Impure =
        match xs {
            case Nil => sk(Nil)
            case x :: rs => {
                let ma = mf(x);
                match apply1(ma, conn) {
                    case Err(e) => fk(e)
                    case Ok(x1) => mapMHelper(conn, mf, rs, fk, ks -> sk(x1 :: ks))
                }
            }
        }

    pub def mapX(mf: a -> DbMonad[b], xs: List[a]): DbMonad[Unit] =
        DbMonad(conn ->
            mapXHelper(conn, mf, xs, e -> Err(e), _ -> Ok())
        )

    def mapXHelper(conn: ##java.sql.Connection, 
                   mf: a -> DbMonad[b], 
                   xs: List[a], 
                   fk: System.Error -> Result[Unit, System.Error], 
                   sk: Unit -> Result[Unit, System.Error]): Result[Unit, System.Error] & Impure =
        match xs {
            case Nil => sk()
            case x :: rs => {
                let ma = mf(x);
                match apply1(ma, conn) {
                    case Err(e) => fk(e)
                    case Ok(_) => mapXHelper(conn, mf, rs, fk, sk)
                }
            }
        }

    pub def mapWithIndexM(mf: (a, Int32) -> DbMonad[b], xs: List[a]): DbMonad[List[b]] =
        DbMonad(conn ->
            mapWithIndexMHelper(conn, mf, 0, xs, e -> Err(e), ys -> Ok(ys))
        )

    ///
    /// Helper function for `mapM`.
    ///
    def mapWithIndexMHelper(conn: ##java.sql.Connection, 
                            mf: (a, Int32) -> DbMonad[b], 
                            ix : Int32, 
                            xs: List[a], 
                            fk: System.Error -> Result[List[b], System.Error], 
                            sk: List[b] -> Result[List[b], System.Error]): Result[List[b], System.Error] & Impure =
        match xs {
            case Nil => sk(Nil)
            case x :: rs => {
                let ma = mf(x, ix);
                match apply1(ma, conn) {
                    case Err(e) => fk(e)
                    case Ok(x1) => mapWithIndexMHelper(conn, mf, ix + 1, rs, fk, ks -> sk(x1 :: ks))
                }
            }
        }

    pub def mapWithIndexX(mf: (a, Int32) -> DbMonad[b], xs: List[a]): DbMonad[Unit] =
        DbMonad(conn ->
            mapWithIndexXHelper(conn, mf, 0, xs, e -> Err(e), _ -> Ok())
        )

    def mapWithIndexXHelper(conn: ##java.sql.Connection, 
                            mf: (a, Int32) -> DbMonad[b],
                            ix: Int32, 
                            xs: List[a], 
                            fk: System.Error -> Result[Unit, System.Error], 
                            sk: Unit -> Result[Unit, System.Error]): Result[Unit, System.Error] & Impure =
        match xs {
            case Nil => sk()
            case x :: rs => {
                let ma = mf(x, ix);
                match apply1(ma, conn) {
                    case Err(e) => fk(e)
                    case Ok(_) => mapWithIndexXHelper(conn, mf, ix + 1, rs, fk, sk)
                }
            }
        }


    pub def sequence(xs: List[DbMonad[a]]): DbMonad[List[a]] =
        DbMonad(conn ->
            sequenceHelper(conn, xs, e -> Err(e), ks -> Ok(ks))
        )

    ///
    /// Helper function for `sequence`.
    ///
    def sequenceHelper(conn: ##java.sql.Connection, xs: List[DbMonad[a]], fk: System.Error -> Result[List[a], System.Error], sk: List[a] -> Result[List[a], System.Error]): Result[List[a], System.Error] & Impure =
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


    pub def foldM(mf: (b, a) -> DbMonad[b], start: b, xs: List[a]): DbMonad[b] =
        DbMonad(conn ->
            foldMHelper(conn, mf, start, xs, e -> Err(e), ac -> Ok(ac))
        )

    def foldMHelper(conn: ##java.sql.Connection, 
                    mf: (b, a) -> DbMonad[b], 
                    acc: b, 
                    xs: List[a], 
                    fk: System.Error -> Result[b, System.Error], 
                    sk: b -> Result[b, System.Error]): Result[b, System.Error] & Impure =
        match xs {
            case Nil => sk(acc)
            case x :: rs => {
                let ma = mf(acc, x);
                match apply1(ma, conn) {
                    case Err(e) => fk(e)
                    case Ok(acc1) => foldMHelper(conn, mf, acc1, rs, fk, sk)
                }
            }
        }

    pub def mapAccumM(mf: (ac, a) -> DbMonad[(ac, b)], start: ac, xs: List[a]): DbMonad[(ac, List[b])] =
        DbMonad(conn ->
            mapAccumMHelper(conn, mf, start, xs, e -> Err(e), (ac, ks) -> Ok((ac, ks)))
        )

    def mapAccumMHelper(conn: ##java.sql.Connection,
                        mf: (ac, a) -> DbMonad[(ac, b)],
                        ac: ac,
                        xs: List[a],
                        fk: System.Error -> Result[(ac, List[b]), System.Error],
                        sk: (ac, List[b]) -> Result[(ac, List[b]), System.Error]): Result[(ac, List[b]), System.Error] & Impure =
        match xs {
            case Nil => sk(ac, Nil)
            case x :: rs => {
                let ma = mf(ac, x);
                match apply1(ma, conn) {
                    case Err(e) => fk(e)
                    case Ok((ac1, x1)) => mapAccumMHelper(conn, mf, ac1, rs, fk, (ac2, ks) -> sk(ac2, x1 :: ks))
                }
            }
        }

    ///
    /// `mapAccumX` is a synonym for `foldM`.
    ///
    pub def mapAccumX(mf: (ac, a) -> DbMonad[ac], start: ac, xs: List[a]): DbMonad[ac] = foldM(mf, start, xs)



}

