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


pub mod BasicDb.DbConnection {

    use BasicDb.PreparedStatementSetter.PreparedStatementHandle
    use BasicDb.DbStatement.StatementHandle
    use BasicDb.DbStatement.StatementHandle.StatementHandle
    use BasicDb.DbConnection
    use IoError.ErrorKind
    use IoError.IoError
    
    import java.sql.{Connection => JConnection}
    import java.sql.{Statement => JStatement}
    import java.sql.{SQLException => JSQLException}

    import java.sql.{Connection => JConnection}


    pub eff DbConnection {
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

    pub def handle(conn: ConnectionHandle, f: a -> b \ ef): a -> Result[IoError, b] \ (ef - DbConnection) = x -> {
        let ConnectionHandle.ConnectionHandle(jconn) = conn;
        run {
            Ok(f(x))
        } with handler DbConnection {
        
            def createStatement(k) = 
                try {
                    let ans = unsafe IO as {ef - DbConnection} { jconn.createStatement() };
                    k(StatementHandle.StatementHandle(ans))
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def prepareStatement(sql, k) = 
                try {
                    let ans = unsafe IO as {ef - DbConnection} { jconn.prepareStatement(sql) };
                    k(PreparedStatementHandle.PreparedStatementHandle(ans))
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def nativeSQL(sql, k) = 
                try {
                    let ans = unsafe IO as {ef - DbConnection} { jconn.nativeSQL(sql) };
                    k(ans)
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def setAutoCommit(ac, k) = 
                try {
                    unsafe IO as {ef - DbConnection} { jconn.setAutoCommit(ac) };
                    k()
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def getAutoCommit(k) = 
                try {
                    let ans = unsafe IO as {ef - DbConnection} { jconn.getAutoCommit() };
                    k(ans)
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def commit(k) = 
                try {
                    unsafe IO as {ef - DbConnection} { jconn.commit() };
                    k()
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def rollback(k) = 
                try {
                    unsafe IO as {ef - DbConnection} { jconn.rollback() };
                    k()
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def close(k) = 
                try {
                    unsafe IO as {ef - DbConnection} { jconn.close() };
                    k()
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def isClosed(k) = 
                try {
                    let ans = unsafe IO as {ef - DbConnection} { jconn.isClosed() };
                    k(ans)
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def isValid(timeout, k) = 
                try {
                    let ans = unsafe IO as {ef - DbConnection} { jconn.isValid(timeout) };
                    k(ans)
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def isReadOnly(k) = 
                try {
                    let ans = unsafe IO as {ef - DbConnection} { jconn.isReadOnly() };
                    k(ans)
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def setReadOnly(ro, k) = 
                try {
                    unsafe IO as {ef - DbConnection} { jconn.setReadOnly(ro) };
                    k()
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def getCatalog(k) = 
                try {
                    let ans = unsafe IO as {ef - DbConnection} { jconn.getCatalog() };
                    k(ans)
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def setCatalog(c, k) = 
                try {
                    unsafe IO as {ef - DbConnection} { jconn.setCatalog(c) };
                    k()
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def getTransactionIsolation(k) = 
                try {
                    let ans = unsafe IO as {ef - DbConnection} { jconn.getTransactionIsolation() };
                    k(ans)
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def setTransactionIsolation(l, k) = 
                try {
                    unsafe IO as {ef - DbConnection} { jconn.setTransactionIsolation(l) };
                    k()
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }
        }
    }


    
    pub def runWithIO(conn: ConnectionHandle, f: Unit -> a \ ef): Result[IoError, a] \ (ef - DbConnection) = 
        handle(conn, f)()


}
