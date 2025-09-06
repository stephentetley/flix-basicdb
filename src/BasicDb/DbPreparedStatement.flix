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


mod BasicDb {

    use BasicDb.PreparedStatementSetter

    pub eff DbPreparedStatement {
        def close(): Unit
        def execute(): Bool
        def addBatch(): Unit
        def executeBatch(): Unit
        def executeQuery(): ResultSetHandle
        def executeUpdate(): Int32
        def clearParameters(): Unit
    }

}

mod BasicDb.DbPreparedStatement {
    
    use BasicDb.PreparedStatementHandle
    use BasicDb.PreparedStatementHandle.PreparedStatementHandle
    use BasicDb.ResultSetHandle
    use BasicDb.ResultSetHandle.ResultSetHandle
    use BasicDb.DbPreparedStatement
    use BasicDb.PreparedStatementSetter
    use IoError.ErrorKind
    use IoError.IoError

    import java.sql.{SQLException, SQLTimeoutException, SQLFeatureNotSupportedException}

    pub def handle(stmt: PreparedStatementHandle, f: a -> b \ ef): a -> Result[IoError, b] \ (ef - DbPreparedStatement + IO) =
        x -> {
            let PreparedStatementHandle(jstmt) = stmt;
            run {
                Ok(f(x))
            } with handler DbPreparedStatement {
            
                def close(k) = try {                    
                    jstmt.close();
                    k()
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

                def execute(k) = try {
                    let ans = jstmt.execute();
                    k(ans)
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

                def addBatch(k) = try {
                    jstmt.addBatch();
                    k()
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

                def executeBatch(k) = try {
                    let _ = jstmt.executeBatch();
                    k()
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

                def executeQuery(k) = try {
                    let ans = ResultSetHandle(jstmt.executeQuery());
                    k(ans)
                } catch {
                    case ex: SQLTimeoutException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

                def executeUpdate(k) = try {
                    let ans = jstmt.executeUpdate();
                    k(ans)
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

                def clearParameters(k) = try {
                    jstmt.clearParameters();
                    k()
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }
            }
       }

    pub def runWithIO(stmt: PreparedStatementHandle, f: Unit -> a \ ef): Result[IoError, a] \ (ef - DbPreparedStatement) + {IO} = 
        handle(stmt, f)()       
}