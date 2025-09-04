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

    use BasicDb.ResultSetHandle

    pub eff DbPreparedStatement {
        def close(): Unit
        def execute(): Bool
        def executeQuery(): ResultSetHandle
        def executeUpdate(): Int32
        def setNull(paramIx: Int32, sqlType: Int32): Unit
        def setBoolean(paramIx: Int32, value: Bool): Unit
        def setByte(paramIx: Int32, value: Int8): Unit
        def setShort(paramIx: Int32, value: Int16): Unit
        def setInt(paramIx: Int32, value: Int32): Unit
        def setLong(paramIx: Int32, value: Int64): Unit
        def setFloat(paramIx: Int32, value: Float32): Unit
        def setDouble(paramIx: Int32, value: Float64): Unit
        def setBigDecimal(paramIx: Int32, value: BigDecimal): Unit
        def setString(paramIx: Int32, value: String): Unit
        def clearParameters(): Unit
    }

}

mod BasicDb.DbPreparedStatement {
    
    use BasicDb.PreparedStatementHandle
    use BasicDb.PreparedStatementHandle.PreparedStatementHandle
    use BasicDb.ResultSetHandle
    use BasicDb.ResultSetHandle.ResultSetHandle
    use BasicDb.DbPreparedStatement
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

                def setNull(paramIx, sqlType, k) = try {
                    jstmt.setNull(paramIx, sqlType);
                    k()
                } catch {
                    case ex: SQLFeatureNotSupportedException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }
                
                def setBoolean(paramIx, value, k) = try {
                    jstmt.setBoolean(paramIx, value);
                    k()
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }
                
                def setByte(paramIx, value, k) = try {
                    jstmt.setByte(paramIx, value);
                    k()
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }
                
                def setShort(paramIx, value, k) = try {
                    jstmt.setShort(paramIx, value);
                    k()
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }
                
                def setInt(paramIx, value, k) = try {
                    jstmt.setInt(paramIx, value);
                    k()
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }
                
                def setLong(paramIx, value, k) = try {
                    jstmt.setLong(paramIx, value);
                    k()
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }
                
                def setFloat(paramIx, value, k) = try {
                    jstmt.setFloat(paramIx, value);
                    k()
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }
                            
                def setDouble(paramIx, value, k) = try {
                    jstmt.setDouble(paramIx, value);
                    k()
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

                def setBigDecimal(paramIx, value, k) = try {
                    jstmt.setBigDecimal(paramIx, value);
                    k()
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

                def setString(paramIx, value, k) = try {
                    jstmt.setString(paramIx, value);
                    k()
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
}