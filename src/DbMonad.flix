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


}

