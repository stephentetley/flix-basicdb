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



pub mod BasicDb.DbPreparedStatement {
    
    use BasicDb.PreparedStatementSetter
    use BasicDb.PreparedStatementSetter.PreparedStatementHandle
    use BasicDb.DbResultSet.ResultSetHandle
    use BasicDb.DbPreparedStatement
    use BasicDb.PreparedStatementSetter
    use IoError.ErrorKind
    use IoError.IoError

    import java.sql.{SQLException => JSQLException}

    pub eff DbPreparedStatement {
        def close(): Unit
        def execute(): Bool
        def addBatch(): Unit
        def executeBatch(): Unit
        def executeQuery(): ResultSetHandle
        def executeUpdate(): Int32
        def clearParameters(): Unit
    }

    pub def handle(stmt: PreparedStatementHandle, 
                    f: a -> b \ ef): a -> Result[IoError, b] \ (ef - DbPreparedStatement) = x -> {
        let PreparedStatementHandle.PreparedStatementHandle(jstmt) = stmt;
        run {
            Ok(f(x))
        } with handler DbPreparedStatement {
        
            def close(k) = 
                try {
                    unsafe IO as {ef - DbPreparedStatement} { jstmt.close() };
                    k()
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def execute(k) = 
                try {
                    let ans = unsafe IO as {ef - DbPreparedStatement} { jstmt.execute() };
                    k(ans)
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def addBatch(k) = 
                try {
                    unsafe IO as {ef - DbPreparedStatement} { jstmt.addBatch() };
                    k()
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def executeBatch(k) = 
                try {
                    unsafe IO as {ef - DbPreparedStatement} { discard jstmt.executeBatch() };
                    k()
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def executeQuery(k) = 
                try { 
                    let ans = unsafe IO as {ef - DbPreparedStatement} { jstmt.executeQuery() };
                    k(ResultSetHandle.ResultSetHandle(ans))
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def executeUpdate(k) = 
                try {
                    let ans = unsafe IO as {ef - DbPreparedStatement} { jstmt.executeUpdate() };
                    k(ans)
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

            def clearParameters(k) = 
                try {
                    unsafe IO as {ef - DbPreparedStatement} { jstmt.clearParameters() };
                    k()
                } catch {
                    case ex: JSQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }
        }
    }

    pub def runWithIO(stmt: PreparedStatementHandle, f: Unit -> a \ ef): Result[IoError, a] \ (ef - DbPreparedStatement) = 
        handle(stmt, f)()       
}