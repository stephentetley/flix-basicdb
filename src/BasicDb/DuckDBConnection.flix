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


    use BasicDb.DuckDBAppenderHandle

    pub eff DuckDBConnection {
        def createAppender(schemaName: String, tableName: String): DuckDBAppenderHandle
    }


}

mod BasicDb.DuckDBConnection {

    use BasicDb.DuckDBConnectionHandle
    use BasicDb.DuckDBConnectionHandle.DuckDBConnectionHandle
    use BasicDb.DuckDBAppenderHandle
    use BasicDb.DuckDBAppenderHandle.DuckDBAppenderHandle
    use BasicDb.DbConnection
    use BasicDb.ConnectionHandle.ConnectionHandle
    use BasicDb.DuckDBConnection
    use IoError.ErrorKind
    use IoError.IoError
    
    import java.sql.{Connection => JConnection}
    import java.sql.{Statement => JStatement}
    import java.sql.SQLException


    pub def handle(conn: DuckDBConnectionHandle, f: a -> b \ ef): a -> Result[IoError, b] \ (ef - DuckDBConnection + IO) =
        x -> {
            let DuckDBConnectionHandle(jconn) = conn;
            run {
                Ok(f(x))
            } with handler DuckDBConnection {
            
                def createAppender(schemaName, tableName, k) = try {
                    let ans = DuckDBAppenderHandle(jconn.createAppender(schemaName, tableName));
                    k(ans)
                } catch {
                    case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
                }
            }
        }
    
    pub def runWithIO(conn: DuckDBConnectionHandle, f: Unit -> a \ ef): Result[IoError, a] \ (ef - DuckDBConnection) + {IO} = 
        handle(conn, f)()

    pub def handleConnection(conn: DuckDBConnectionHandle, f: a -> b \ ef): a -> Result[IoError, b] \ ((ef - DuckDBConnection - DbConnection) + IO) =       
        x -> {
            let DuckDBConnectionHandle(dconn) = conn;
            let jconn: JConnection = checked_cast(dconn);
            let conn2 = ConnectionHandle(jconn);
            Result.flatten(
                run { 
                    f(x)
                } with runWithIO(conn)
                with DbConnection.runWithIO(conn2)
            )
        }
}
