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

    eff DbResultSet {
        def close(): Unit
        def next(): Unit
        def wasNull(): Bool
        def isBeforeFirst(): Bool
        def isAfterLast(): Bool
        def isFirst(): Bool
        def isLast(): Bool
        def first(): Unit
        def last(): Unit
        def getRow(): Int32
        def getStringByIndex(ix: Int32): String
        def getStringByName(name: String): String
        def getBooleanByIndex(ix: Int32): Bool
        def getBooleanByName(name: String): Bool
        def getByteByIndex(ix: Int32): Int8
        def getByteByName(name: String): Int8
        def getShortByIndex(ix: Int32): Int16
        def getShortByName(name: String): Int16
        def getIntByIndex(ix: Int32): Int32
        def getIntByName(name: String): Int32
        def getLongByIndex(ix: Int32): Int64
        def getLongByName(name: String): Int64
        def getFloatByIndex(ix: Int32): Float32
        def getFloatByName(name: String): Float32
        def getDoubleByIndex(ix: Int32): Float64
        def getDoubleByName(name: String): Float64
    }

}

mod BasicDb.DbResultSet {
    
    use BasicDb.ResultSetHandle
    use BasicDb.ResultSetHandle.ResultSetHandle
    use BasicDb.DbResultSet
    use IoError.ErrorKind
    use IoError.IoError

    import java.sql.SQLException

    pub def handle(results: ResultSetHandle, f: a -> b \ ef): a -> Result[IoError, b] \ (ef - DbResultSet + IO) =
        x -> run {
            Ok(f(x))
        } with handler DbResultSet {
            
            
            def close(k) = try {
                let ResultSetHandle(jresults) = results;
                jresults.close();
                k()
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

            def next(k) = try {
                let ResultSetHandle(jresults) = results;
                jresults.next();
                k()
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }
            
            def wasNull(k) = try {
                let ResultSetHandle(jresults) = results;
                let ans = jresults.wasNull();
                k(ans)
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

            def isBeforeFirst(k) = try {
                let ResultSetHandle(jresults) = results;
                let ans = jresults.isBeforeFirst();
                k(ans)
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

            def isAfterLast(k) = try {
                let ResultSetHandle(jresults) = results;
                let ans = jresults.isAfterLast();
                k(ans)
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

            def isFirst(k) = try {
                let ResultSetHandle(jresults) = results;
                let ans = jresults.isFirst();
                k(ans)
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

            def isLast(k) = try {
                let ResultSetHandle(jresults) = results;
                let ans = jresults.isLast();
                k(ans)
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

            def first(k) = try {
                let ResultSetHandle(jresults) = results;
                jresults.first();
                k()
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

            def last(k) = try {
                let ResultSetHandle(jresults) = results;
                jresults.last();
                k()
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

            def getRow(k) = try {
                let ResultSetHandle(jresults) = results;
                let ans = jresults.getRow();
                k(ans)
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

            def getStringByIndex(ix, k) = try {
                let ResultSetHandle(jresults) = results;
                let ans = jresults.getString(ix);
                k(ans)
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }
            
            def getStringByName(name, k) = try {
                let ResultSetHandle(jresults) = results;
                let ans = jresults.getString(name);
                k(ans)
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }
            
            def getBooleanByIndex(ix, k) = try {
                let ResultSetHandle(jresults) = results;
                let ans = jresults.getBoolean(ix);
                k(ans)
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }
            
            def getBooleanByName(name, k) = try {
                let ResultSetHandle(jresults) = results;
                let ans = jresults.getBoolean(name);
                k(ans)
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }


            def getByteByIndex(ix, k) = try {
                let ResultSetHandle(jresults) = results;
                let ans = jresults.getByte(ix);
                k(ans)
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

            def getByteByName(name, k) = try {
                let ResultSetHandle(jresults) = results;
                let ans = jresults.getByte(name);
                k(ans)
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

            def getShortByIndex(ix, k) = try {
                let ResultSetHandle(jresults) = results;
                let ans = jresults.getShort(ix);
                k(ans)
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

            def getShortByName(name, k) = try {
                let ResultSetHandle(jresults) = results;
                let ans = jresults.getShort(name);
                k(ans)
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

            def getIntByIndex(ix, k) = try {
                let ResultSetHandle(jresults) = results;
                let ans = jresults.getInt(ix);
                k(ans)
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

            def getIntByName(name, k) = try {
                let ResultSetHandle(jresults) = results;
                let ans = jresults.getInt(name);
                k(ans)
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

            def getLongByIndex(ix, k) = try {
                let ResultSetHandle(jresults) = results;
                let ans = jresults.getLong(ix);
                k(ans)
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

            def getLongByName(name, k) = try {
                let ResultSetHandle(jresults) = results;
                let ans = jresults.getLong(name);
                k(ans)
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

            def getFloatByIndex(ix, k) = try {
                let ResultSetHandle(jresults) = results;
                let ans = jresults.getFloat(ix);
                k(ans)
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

            def getFloatByName(name, k) = try {
                let ResultSetHandle(jresults) = results;
                let ans = jresults.getFloat(name);
                k(ans)
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

            def getDoubleByIndex(ix, k) = try {
                let ResultSetHandle(jresults) = results;
                let ans = jresults.getDouble(ix);
                k(ans)
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

            def getDoubleByName(name, k) = try {
                let ResultSetHandle(jresults) = results;
                let ans = jresults.getDouble(name);
                k(ans)
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }


        }
}