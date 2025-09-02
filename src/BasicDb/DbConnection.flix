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

    use BasicDb.StatementHandle

    pub eff DbConnection {
        def createStatement(): StatementHandle
        def close(): Unit
        def commit(): Unit
        def rollback(): Unit
        def isValid(timeout: Int32): Bool
        def getAutoCommit(): Bool
        def setAutoCommit(autoCommit: Bool): Unit
        def isReadOnly(): Bool
        def setReadOnly(readOnly: Bool): Unit
        def getCatalog(): String
        def setCatalog(catalog: String): Unit
        def getTransactionIsolation(): Int32
        def setTransactionIsolation(level: Int32): Unit
    }


}

mod BasicDb.DbConnection {

    use BasicDb.ConnectionHandle
    use BasicDb.ConnectionHandle.ConnectionHandle
    use BasicDb.StatementHandle
    use BasicDb.StatementHandle.StatementHandle
    use BasicDb.DbConnection
    use IoError.ErrorKind
    use IoError.IoError
    
    import java.sql.{Connection => JConnection}
    import java.sql.{Statement => JStatement}
    import java.sql.SQLException


    pub def handle(conn: ConnectionHandle, f: a -> b \ ef): a -> Result[IoError, b] \ (ef - DbConnection + IO) =
        x -> run {
            Ok(f(x))
        } with handler DbConnection {
            
            def createStatement(k) = try {
                let ConnectionHandle(jconn) = conn;
                let ans = StatementHandle(jconn.createStatement());
                k(ans)
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

            def close(k) = try {
                let ConnectionHandle(jconn) = conn;
                jconn.close();
                k()
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

            def commit(k) = try {
                let ConnectionHandle(jconn) = conn;
                jconn.commit();
                k()
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

            def rollback(k) = try {
                let ConnectionHandle(jconn) = conn;
                jconn.rollback();
                k()
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

            def isValid(t, k) = try {
                let ConnectionHandle(jconn) = conn;
                let ans = jconn.isValid(t);
                k(ans)
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

            def getAutoCommit(k) = try {
                let ConnectionHandle(jconn) = conn;
                let ans = jconn.getAutoCommit();
                k(ans)
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

            def setAutoCommit(ac, k) = try {
                let ConnectionHandle(jconn) = conn;
                jconn.setAutoCommit(ac);
                k()
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

            def isReadOnly(k) = try {
                let ConnectionHandle(jconn) = conn;
                let ans = jconn.isReadOnly();
                k(ans)
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

            def setReadOnly(ro, k) = try {
                let ConnectionHandle(jconn) = conn;
                jconn.setReadOnly(ro);
                k()
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

            def getCatalog(k) = try {
                let ConnectionHandle(jconn) = conn;
                let ans = jconn.getCatalog();
                k(ans)
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

            def setCatalog(c, k) = try {
                let ConnectionHandle(jconn) = conn;
                jconn.setCatalog(c);
                k()
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

            def getTransactionIsolation(k) = try {
                let ConnectionHandle(jconn) = conn;
                let ans = jconn.getTransactionIsolation();
                k(ans)
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

            def setTransactionIsolation(l, k) = try {
                let ConnectionHandle(jconn) = conn;
                jconn.setTransactionIsolation(l);
                k()
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }
        }

    // pub def withConnection(f: JConnection -> a \ IO): a \ DbConnection =
    //     let conn = BasicDb.DbConnection.currentConnection();
    //     match Result.tryCatch(_ -> {unsafe f(conn)}) {
    //         case Ok(a)    => a
    //         case Err(msg) => BasicDb.DbConnection.fail(msg)
    //     }


    // pub def close(): Unit \ DbConnection = 
    //     withConnection(conn -> conn.close())



    // /// This modifies the session connection
    // pub def setAutoCommit(autoCommit: Bool): Unit \ DbConnection = 
    //     withConnection(conn -> conn.setAutoCommit(autoCommit))


    // pub def getAutoCommit(): Bool \ DbConnection = 
    //     withConnection(conn -> conn.getAutoCommit())

    // pub def getSchema(): String \ DbConnection = 
    //     withConnection(conn -> conn.getSchema())

    // // Maybe should be in IO as well as DbConnection...
    // pub def commit(): Unit \ DbConnection = 
    //     withConnection(conn -> conn.commit())


    // pub def execute(sql: String): Bool \ DbConnection = 
    //     withConnection(conn -> 
    //         let stmt = conn.createStatement();
    //         stmt.execute(sql)
    //     )

    // pub def executeUpdate(sql: String): Int32 \ DbConnection = 
    //     withConnection(conn -> 
    //         let stmt = conn.createStatement();
    //         stmt.executeUpdate(sql)
    //     )


    // // /// Creates a PreparedStatement
    // // pub def prepareStatement(rc: Region[r1], 
    // //                             sql: String, 
    // //                             conn: Connection[r]): Result[String, PreparedStatement[r1]] \ {IO, r, r1} = 
    // //     Result.tryCatch(_ -> {
    // //         let connection1 = conn->connection;
    // //         let ans = connection1.prepareStatement(sql);
    // //         new PreparedStatement @ rc {preparedStatement = ans}
    // //     })
    
    pub def runWithIO(conn: ConnectionHandle, f: Unit -> a \ ef): Result[IoError, a] \ (ef - DbConnection) + {IO} = 
        handle(conn, f)()


}
