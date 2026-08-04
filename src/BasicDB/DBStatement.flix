/*
 * Copyright 2025 Stephen Tetley
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



pub mod BasicDB.DBStatement {
    
    use IoError.ErrorKind
    use IoError.IoError
    use EffectExtras.Fail.Fail
    
    use BasicDB.{Statement, ResultSet, ResultSetRow}
    use BasicDB.DBConnection.DBConnection
    use BasicDB.DBResultSet.DBResultSet


    import java.sql.{SQLException => JSQLException}
    import java.sql.{Statement => JStatement}

    pub eff DBStatement {
        def getMaxRows(): Int32
        def setMaxRows(maxRows: Int32): Unit
        def cancel(): Unit
        def execute(sql: String): Bool
        def executeUpdate(sql: String): Int32
        def executeLargeUpdate(sql: String): Int64
        def executeQuery(sql: String): ResultSet
        def closeResultSet(results: ResultSet): Unit
        def getResultSet(): ResultSet
        def enquoteLiteral(sql: String): String
        def isClosed(): Bool
        def isCloseOnCompletion(): Bool
    }
    

    pub def handle(stmt: Statement, 
                    f: a -> b \ ef): a -> b \ {ef + Fail - DBStatement} = x -> {
        let jstmt = ToJava.toJava(stmt); 
        run {
            f(x)
        } with handler DBStatement {
        
            def getMaxRows(k) = 
                try {
                    let ans = unsafe IO as {ef + Fail - DBStatement} { jstmt.getMaxRows() };
                    k(ans)
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }

            def setMaxRows(maxRows, k) = 
                try {
                    unsafe IO as {ef + Fail - DBStatement} { jstmt.setMaxRows(maxRows) };
                    k()
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }

            def cancel(k) = 
                try {
                    unsafe IO as {ef + Fail - DBStatement} { jstmt.cancel() };
                    k()
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }
            
            def execute(sql, k) = 
                try {
                    let ans = unsafe IO as {ef + Fail - DBStatement} { jstmt.execute(sql) };
                    k(ans)
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }
                
            def executeUpdate(sql, k) = 
                try {
                    let ans = unsafe IO as {ef + Fail - DBStatement} { jstmt.executeUpdate(sql) };
                    k(ans)
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }
            
            def executeLargeUpdate(sql, k) = 
                try {
                    let ans = unsafe IO as {ef + Fail - DBStatement} { jstmt.executeLargeUpdate(sql) };
                    k(ans)
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }
            
            def executeQuery(sql, k) = 
                try {
                    let ans = unsafe IO as {ef + Fail - DBStatement} { jstmt.executeQuery(sql) };
                    k(ToFlix.toFlix(ans))
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }


            def closeResultSet(results, k) = 
                try {
                    let jresults = ToJava.toJava(results);
                    unsafe IO as {ef + Fail - DBStatement} { jresults.close() };
                    k()
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }

            def getResultSet(k) = 
                try {
                    let ans = unsafe IO as {ef + Fail - DBStatement} { jstmt.getResultSet() };
                    k(ToFlix.toFlix(ans))
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }

            def enquoteLiteral(sql, k) = 
                try {
                    let ans = unsafe IO as {ef + Fail - DBStatement} { jstmt.enquoteLiteral(sql) };
                    k(ans)
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }

            def isClosed(k) = 
                try {
                    let ans = unsafe IO as {ef + Fail - DBStatement} { jstmt.isClosed() };
                    k(ans)
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }
    
            def isCloseOnCompletion(k) = 
                try {
                    let ans = unsafe IO as {ef + Fail - DBStatement} { jstmt.isCloseOnCompletion() };
                    k(ans)
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }
        }
    }

    pub def runDBStatement(stmt: Statement, 
                            f: Unit -> a \ ef): a \ (ef + Fail - DBStatement)  = 
        handle(stmt, f)()


    pub def runDBStatement1(f: Unit -> a \ ef): a \ {ef + Fail + DBConnection} - DBStatement = 
        let stmt = DBConnection.createStatement();
        let ans = handle(stmt, f)();
        DBConnection.closeStatement(stmt);
        ans


    // This is single row answer...
    pub def scalarQuery(sql: String, 
                            f: ResultSetRow -> a \ ef): a \ ef + Fail + DBStatement - DBResultSet =
        let results = DBStatement.executeQuery(sql);
        let ans = BasicDB.DBResultSet.firstResult(f, results);
        DBStatement.closeResultSet(results);
        ans

    pub def forEachQuery(sql: String, 
                            f: ResultSetRow -> Unit \ ef): Unit \ ef + Fail + DBStatement - DBResultSet  = 
        let results = DBStatement.executeQuery(sql);
        let ans = BasicDB.DBResultSet.forEachRow(f, results);
        DBStatement.closeResultSet(results);
        ans

    pub def foldQuery(sql: String, f: ResultSetRow -> s -> s \ ef, st: s): s \ ef + Fail + DBStatement - DBResultSet = 
        let results = DBStatement.executeQuery(sql);
        let ans = BasicDB.DBResultSet.fold(f, st, results);
        DBStatement.closeResultSet(results);
        ans

}