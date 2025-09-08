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

    pub eff DuckDBAppender {
        def beginRow(): Unit
        def endRow(): Unit
        def flush(): Unit
        def appendBool(value: Bool): Unit
        def appendInt8(value: Int8): Unit
        def appendInt16(value: Int16): Unit
        def appendInt32(value: Int32): Unit
        def appendInt64(value: Int64): Unit
        def appendFloat32(value: Int32): Unit
        def appendFloat64(value: Int64): Unit
        def appendString(value: String): Unit
        // def finalize(): Unit
        def close(): Unit
    }
}

mod BasicDb.DuckDBAppender {

    use BasicDb.DuckDBAppenderHandle
    use BasicDb.DuckDBAppenderHandle.DuckDBAppenderHandle
    use BasicDb.DuckDBAppender
    use IoError.ErrorKind
    use IoError.IoError

    import java.sql.SQLException
    import java.lang.Throwable

    pub def handle(appender: DuckDBAppenderHandle, f: a -> b \ ef): a -> Result[IoError, b] \ (ef - DuckDBAppender + IO) =
        x -> {
            let DuckDBAppenderHandle(jappender) = appender;
            run {
                Ok(f(x))
            } with handler DuckDBAppender {

                def beginRow(k) = try {
                    jappender.beginRow();
                    k()
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }
                
                def endRow(k) = try {
                    jappender.endRow();
                    k()
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }
                
                def flush(k) = try {
                    jappender.flush();
                    k()
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

                def appendBool(value, k) = try {
                    jappender.append(value);
                    k()
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

                def appendInt8(value, k) = try {
                    jappender.append(value);
                    k()
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

                def appendInt16(value, k) = try {
                    jappender.append(value);
                    k()
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

                def appendInt32(value, k) = try {
                    jappender.append(value);
                    k()
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

                def appendInt64(value, k) = try {
                    jappender.append(value);
                    k()
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

                def appendFloat32(value, k) = try {
                    jappender.append(value);
                    k()
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

                def appendFloat64(value, k) = try {
                    jappender.append(value);
                    k()
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

                def appendString(value, k) = try {
                    jappender.append(value);
                    k()
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

                // def finalize(k) = try {
                //     jappender.finalize();
                //     k()
                // } catch {
                //     case ex: Throwable => Err(IoError(ErrorKind.Other, ex.getMessage()))
                // }

                def close(k) = try {
                    jappender.close();
                    k()
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }
            }
        }

    pub def runWithIO(appender: DuckDBAppenderHandle, f: Unit -> a \ ef): Result[IoError, a] \ (ef - DuckDBAppender) + {IO} = 
        handle(appender, f)()

}
