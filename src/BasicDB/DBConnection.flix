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
    use BasicDB.PreparedStatementSetter.PreparedStatementHandle
    use BasicDB.PreparedStatementSetter.PreparedStatementSetterWithAlt
    use BasicDB.DBPreparedStatement.DBPreparedStatement
    use BasicDB.DBStatement.StatementHandle
    use BasicDB.DBStatement.StatementHandle.StatementHandle
    use BasicDB.DBConnection
    use IoError.ErrorKind
    use IoError.IoError
    
    import java.sql.{Connection => JConnection}
    import java.sql.{Statement => JStatement}
    import java.sql.{SQLException => JSQLException}

    import java.sql.{Connection => JConnection}


    pub eff DBConnection {
        // `ConnectionHandle` should not be used in user code
        // It is a hack until we can run local effects polymorphically
        def askDBConnectionHandle(): ConnectionHandle
        def createStatement(): StatementHandle
        def prepareStatement(sql: String): PreparedStatementHandle
        def nativeSQL(sql: String): String
        def setAutoCommit(autoCommit: Bool): Unit
        def getAutoCommit(): Bool
        def commit(): Unit
        def rollback(): Unit
        def close(): Unit
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

    pub def handle(conn: ConnectionHandle, f: a -> b \ ef): a -> Result[IoError, b] \ (ef - DBConnection) = x -> {
        let ConnectionHandle.ConnectionHandle(jconn) = conn;
        run {
            Ok(f(x))
        } with handler DBConnection {
        
            def askDBConnectionHandle(k) = k(conn)

            def createStatement(k) = 
                try {
                    let ans = unsafe IO as {ef - DBConnection} { jconn.createStatement() };
                    k(StatementHandle.StatementHandle(ans))
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def prepareStatement(sql, k) = 
                try {
                    let ans = unsafe IO as {ef - DBConnection} { jconn.prepareStatement(sql) };
                    k(PreparedStatementHandle.PreparedStatementHandle(ans))
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def nativeSQL(sql, k) = 
                try {
                    let ans = unsafe IO as {ef - DBConnection} { jconn.nativeSQL(sql) };
                    k(ans)
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def setAutoCommit(ac, k) = 
                try {
                    unsafe IO as {ef - DBConnection} { jconn.setAutoCommit(ac) };
                    k()
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def getAutoCommit(k) = 
                try {
                    let ans = unsafe IO as {ef - DBConnection} { jconn.getAutoCommit() };
                    k(ans)
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def commit(k) = 
                try {
                    unsafe IO as {ef - DBConnection} { jconn.commit() };
                    k()
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def rollback(k) = 
                try {
                    unsafe IO as {ef - DBConnection} { jconn.rollback() };
                    k()
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }


            def isClosed(k) = 
                try {
                    let ans = unsafe IO as {ef - DBConnection} { jconn.isClosed() };
                    k(ans)
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def isValid(timeout, k) = 
                try {
                    let ans = unsafe IO as {ef - DBConnection} { jconn.isValid(timeout) };
                    k(ans)
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def isReadOnly(k) = 
                try {
                    let ans = unsafe IO as {ef - DBConnection} { jconn.isReadOnly() };
                    k(ans)
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def setReadOnly(ro, k) = 
                try {
                    unsafe IO as {ef - DBConnection} { jconn.setReadOnly(ro) };
                    k()
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def getCatalog(k) = 
                try {
                    let ans = unsafe IO as {ef - DBConnection} { jconn.getCatalog() };
                    k(ans)
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def setCatalog(c, k) = 
                try {
                    unsafe IO as {ef - DBConnection} { jconn.setCatalog(c) };
                    k()
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def getTransactionIsolation(k) = 
                try {
                    let ans = unsafe IO as {ef - DBConnection} { jconn.getTransactionIsolation() };
                    k(ans)
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def setTransactionIsolation(l, k) = 
                try {
                    unsafe IO as {ef - DBConnection} { jconn.setTransactionIsolation(l) };
                    k()
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }
        }
    }


    
    pub def runDBConnection(conn: ConnectionHandle, f: Unit -> a \ ef): a \ {ef + Fail - DBConnection} =
        handle(conn, f)()

    pub def execDBPreparedStatement(sql: String,
                                        f: Unit -> a \ PreparedStatementSetterWithAlt + ef): a \ {Fail + ef + DBConnection} - DBPreparedStatement =
        let stmt = DBConnection.prepareStatement(sql);
        let ans = run {
            f()
        } with BasicDB.DBPreparedStatement.runDBPreparedStatement(stmt);
        DBConnection.closePreparedStatement(stmt);
        ans


}
