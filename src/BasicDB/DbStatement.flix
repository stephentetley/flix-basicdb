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



pub mod BasicDb.DbStatement {
    
    use BasicDb.DbResultSet.ResultSetHandle
    use BasicDb.DbStatement
    use IoError.ErrorKind
    use IoError.IoError

    import java.sql.{SQLException => JSQLException}
    import java.sql.{Statement => JStatement}

    pub eff DbStatement {
        def close(): Unit
        def getMaxRows(): Int32
        def setMaxRows(maxRows: Int32): Unit
        def cancel(): Unit
        def execute(sql: String): Bool
        def executeUpdate(sql: String): Int32
        def executeLargeUpdate(sql: String): Int64
        def executeQuery(sql: String): ResultSetHandle
        def getResultSet(): ResultSetHandle
        def enquoteLiteral(sql: String): String
        def isClosed(): Bool
        def isCloseOnCompletion(): Bool
    }
    
    pub enum StatementHandle (JStatement)

    pub def handle(stmt: StatementHandle, 
                    f: a -> b \ ef): a -> Result[IoError, b] \ (ef - DbStatement) = x -> {
        let StatementHandle.StatementHandle(jstmt) = stmt; 
        run {
            Ok(f(x))
        } with handler DbStatement {
        
            def close(k) = 
                try {
                    unsafe IO as {ef - DbStatement} { jstmt.close() };
                    k()
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def getMaxRows(k) = 
                try {
                    let ans = unsafe IO as {ef - DbStatement} { jstmt.getMaxRows() };
                    k(ans)
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def setMaxRows(maxRows, k) = 
                try {
                    unsafe IO as {ef - DbStatement} { jstmt.setMaxRows(maxRows) };
                    k()
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def cancel(k) = 
                try {
                    unsafe IO as {ef - DbStatement} { jstmt.cancel() };
                    k()
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }
            
            def execute(sql, k) = 
                try {
                    let ans = unsafe IO as {ef - DbStatement} { jstmt.execute(sql) };
                    k(ans)
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }
                
            def executeUpdate(sql, k) = 
                try {
                    let ans = unsafe IO as {ef - DbStatement} { jstmt.executeUpdate(sql) };
                    k(ans)
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }
            
            def executeLargeUpdate(sql, k) = 
                try {
                    let ans = unsafe IO as {ef - DbStatement} { jstmt.executeLargeUpdate(sql) };
                    k(ans)
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }
            
            def executeQuery(sql, k) = 
                try {
                    let ans = unsafe IO as {ef - DbStatement} { jstmt.executeQuery(sql) };
                    k(ResultSetHandle.ResultSetHandle(ans))
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def getResultSet(k) = 
                try {
                    let ans = unsafe IO as {ef - DbStatement} { jstmt.getResultSet() };
                    k(ResultSetHandle.ResultSetHandle(ans))
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def enquoteLiteral(sql, k) = 
                try {
                    let ans = unsafe IO as {ef - DbStatement} { jstmt.enquoteLiteral(sql) };
                    k(ans)
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def isClosed(k) = 
                try {
                    let ans = unsafe IO as {ef - DbStatement} { jstmt.isClosed() };
                    k(ans)
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }
    
            def isCloseOnCompletion(k) = 
                try {
                    let ans = unsafe IO as {ef - DbStatement} { jstmt.isCloseOnCompletion() };
                    k(ans)
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }
        }
    }

    pub def runWithIO(stmt: StatementHandle, f: Unit -> a \ ef): Result[IoError, a] \ (ef - DbStatement)  = 
        handle(stmt, f)()
}