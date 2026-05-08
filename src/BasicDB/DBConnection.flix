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


pub mod BasicDB.DBConnection {

    use EffectExtras.Fail.Fail
    use BasicDB.DBPreparedStatement.PreparedStatementHandle
    use BasicDB.PreparedStatementSetter.PreparedStatementSetterWithAlt
    use BasicDB.DBPreparedStatement.DBPreparedStatement
    use BasicDB.DBStatement.DBStatement
    use BasicDB.DBStatement.StatementHandle
    use BasicDB.DBConnection
    use IoError.ErrorKind
    use IoError.IoError
    
    import java.sql.{Connection => JConnection}
    import java.sql.{Statement => JStatement}
    import java.sql.{SQLException => JSQLException}

    import java.sql.{Connection => JConnection}


    pub eff DBConnection {
        def createStatement(): StatementHandle
        def closeStatement(stmt: StatementHandle): Unit
        def prepareStatement(sql: String): PreparedStatementHandle
        def closePreparedStatement(stmt: PreparedStatementHandle): Unit
        def nativeSQL(sql: String): String
        def setAutoCommit(autoCommit: Bool): Unit
        def getAutoCommit(): Bool
        def commit(): Unit
        def rollback(): Unit
        def isClosed(): Bool
        def isValid(timeout: Int32): Bool
        def isReadOnly(): Bool
        def setReadOnly(readOnly: Bool): Unit
        def getCatalog(): String
        def setCatalog(catalog: String): Unit
        def getTransactionIsolation(): Int32
        def setTransactionIsolation(level: Int32): Unit
    }

    pub enum ConnectionHandle (JConnection)

    pub def handle(conn: ConnectionHandle, f: a -> b \ ef): a -> b \ {ef + Fail - DBConnection} = x -> {
        let ConnectionHandle.ConnectionHandle(jconn) = conn;
        run {
            f(x)
        } with handler DBConnection {
        
            def createStatement(k) = 
                try {
                    let ans = unsafe IO as {ef + Fail - DBConnection} { jconn.createStatement() };
                    k(StatementHandle.StatementHandle(ans))
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }

            def closeStatement(stmt, k) = 
                try {
                    let StatementHandle.StatementHandle(jstmt) = stmt;
                    unsafe IO as {ef + Fail - DBConnection} { jstmt.close() };
                    k()
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }

            def prepareStatement(sql, k) = 
                try {
                    let ans = unsafe IO as {ef + Fail - DBConnection} { jconn.prepareStatement(sql) };
                    k(PreparedStatementHandle.PreparedStatementHandle(ans))
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }

            def closePreparedStatement(stmt, k) = 
                try {
                    let PreparedStatementHandle.PreparedStatementHandle(jstmt) = stmt;
                    unsafe IO as {ef + Fail - DBConnection} { jstmt.close() };
                    k()
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }

            def nativeSQL(sql, k) = 
                try {
                    let ans = unsafe IO as {ef + Fail - DBConnection} { jconn.nativeSQL(sql) };
                    k(ans)
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }

            def setAutoCommit(ac, k) = 
                try {
                    unsafe IO as {ef + Fail - DBConnection} { jconn.setAutoCommit(ac) };
                    k()
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }

            def getAutoCommit(k) = 
                try {
                    let ans = unsafe IO as {ef + Fail - DBConnection} { jconn.getAutoCommit() };
                    k(ans)
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }

            def commit(k) = 
                try {
                    unsafe IO as {ef + Fail - DBConnection} { jconn.commit() };
                    k()
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }

            def rollback(k) = 
                try {
                    unsafe IO as {ef + Fail - DBConnection} { jconn.rollback() };
                    k()
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }


            def isClosed(k) = 
                try {
                    let ans = unsafe IO as {ef + Fail - DBConnection} { jconn.isClosed() };
                    k(ans)
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }

            def isValid(timeout, k) = 
                try {
                    let ans = unsafe IO as {ef + Fail - DBConnection} { jconn.isValid(timeout) };
                    k(ans)
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }

            def isReadOnly(k) = 
                try {
                    let ans = unsafe IO as {ef + Fail - DBConnection} { jconn.isReadOnly() };
                    k(ans)
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }

            def setReadOnly(ro, k) = 
                try {
                    unsafe IO as {ef + Fail - DBConnection} { jconn.setReadOnly(ro) };
                    k()
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }

            def getCatalog(k) = 
                try {
                    let ans = unsafe IO as {ef + Fail - DBConnection} { jconn.getCatalog() };
                    k(ans)
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }

            def setCatalog(c, k) = 
                try {
                    unsafe IO as {ef + Fail - DBConnection} { jconn.setCatalog(c) };
                    k()
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }

            def getTransactionIsolation(k) = 
                try {
                    let ans = unsafe IO as {ef + Fail - DBConnection} { jconn.getTransactionIsolation() };
                    k(ans)
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }

            def setTransactionIsolation(l, k) = 
                try {
                    unsafe IO as {ef + Fail - DBConnection} { jconn.setTransactionIsolation(l) };
                    k()
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }
        }
    }


    
    pub def runDBConnection(conn: ConnectionHandle, f: Unit -> a \ ef): a \ {ef + Fail - DBConnection} =
        handle(conn, f)()

    pub def execDBStatement(f: Unit -> a \ DBStatement + ef): a \ {Fail + ef + DBConnection} - DBStatement =
        let stmt = DBConnection.createStatement();
        let ans = BasicDB.DBStatement.runDBStatement(stmt, f);
        DBConnection.closeStatement(stmt);
        ans

    pub def execDBPreparedStatement(sql: String,
                                        f: Unit -> a \ DBPreparedStatement + ef): a \ {Fail + ef + DBConnection} - DBPreparedStatement =
        let stmt = DBConnection.prepareStatement(sql);
        let ans = BasicDB.DBPreparedStatement.runDBPreparedStatement(stmt, f);
        DBConnection.closePreparedStatement(stmt);
        ans

}
