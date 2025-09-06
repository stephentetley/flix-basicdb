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

    pub eff RowReader {
        def getStringByIndex(ix: Int32): String
        def getStringByName(name: String): String
        def getBoolByIndex(ix: Int32): Bool
        def getBoolByName(name: String): Bool
        def getInt8ByIndex(ix: Int32): Int8
        def getInt8ByName(name: String): Int8
        def getInt16ByIndex(ix: Int32): Int16
        def getInt16ByName(name: String): Int16
        def getInt32ByIndex(ix: Int32): Int32
        def getInt32ByName(name: String): Int32
        def getInt64ByIndex(ix: Int32): Int64
        def getInt64ByName(name: String): Int64
        def getFloat32ByIndex(ix: Int32): Float32
        def getFloat32ByName(name: String): Float32
        def getFloat64ByIndex(ix: Int32): Float64
        def getFloat64ByName(name: String): Float64
        def getBigDecimalByIndex(ix: Int32): BigDecimal
        def getBigDecimalByName(name: String): BigDecimal
        
    }

}

mod BasicDb.RowReader {
    
    use BasicDb.ResultSetHandle
    use BasicDb.ResultSetHandle.ResultSetHandle
    use BasicDb.RowReader
    use IoError.ErrorKind
    use IoError.IoError

    import java.sql.SQLException

    pub def handle(results: ResultSetHandle, f: a -> b \ ef): a -> Result[IoError, b] \ (ef - RowReader + IO) =
        x -> {
            let ResultSetHandle(jresults) = results;
            run {
                Ok(f(x))
            } with handler RowReader {
            
                def getStringByIndex(ix, k) = try {
                    let ans = jresults.getString(ix - 1);
                    k(ans)
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

                def getStringByName(name, k) = try {
                    let ans = jresults.getString(name);
                    k(ans)
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }
                
                def getBoolByIndex(ix, k) = try {
                    let ans = jresults.getBoolean(ix - 1);
                    k(ans)
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }
                
                def getBoolByName(name, k) = try {
                    let ans = jresults.getBoolean(name);
                    k(ans)
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }


                def getInt8ByIndex(ix, k) = try {
                    let ans = jresults.getByte(ix - 1);
                    k(ans)
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

                def getInt8ByName(name, k) = try {
                    let ans = jresults.getByte(name);
                    k(ans)
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

                def getInt16ByIndex(ix, k) = try {
                    let ans = jresults.getShort(ix - 1);
                    k(ans)
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

                def getInt16ByName(name, k) = try {
                    let ans = jresults.getShort(name);
                    k(ans)
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

                def getInt32ByIndex(ix, k) = try {
                    let ans = jresults.getInt(ix - 1);
                    k(ans)
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

                def getInt32ByName(name, k) = try {
                    let ans = jresults.getInt(name);
                    k(ans)
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

                def getInt64ByIndex(ix, k) = try {
                    let ans = jresults.getLong(ix - 1);
                    k(ans)
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

                def getInt64ByName(name, k) = try {
                    let ans = jresults.getLong(name);
                    k(ans)
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

                def getFloat32ByIndex(ix, k) = try {
                    let ans = jresults.getFloat(ix - 1);
                    k(ans)
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

                def getFloat32ByName(name, k) = try {
                    let ans = jresults.getFloat(name);
                    k(ans)
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

                def getFloat64ByIndex(ix, k) = try {
                    let ans = jresults.getDouble(ix - 1);
                    k(ans)
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

                def getFloat64ByName(name, k) = try {
                    let ans = jresults.getDouble(name);
                    k(ans)
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

                def getBigDecimalByIndex(ix, k) = try {
                    let ans = jresults.getBigDecimal(ix - 1);
                    k(ans)
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }

                def getBigDecimalByName(name, k) = try {
                    let ans = jresults.getBigDecimal(name);
                    k(ans)
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }
            }

        }

    pub def runWithIO(rset: ResultSetHandle, f: Unit -> a \ ef): Result[IoError, a] \ (ef - RowReader) + {IO} = 
        handle(rset, f)()

}