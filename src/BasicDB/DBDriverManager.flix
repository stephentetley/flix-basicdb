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



pub mod BasicDB.DBDriverManager {
    
    use EffectExtras.Fail.Fail
    use BasicDB.DBDriverManager
    use BasicDB.DBConnection.DBConnection
    use BasicDB.DBConnection.ConnectionHandle
    use IoError.ErrorKind
    use IoError.IoError

    import java.sql.{SQLException => JSQLException}
    import java.sql.DriverManager

    pub eff DBDriverManager {
        def getConnection(url: String): ConnectionHandle
        def closeConnection(conn: ConnectionHandle): Unit
    }

    pub def handle(f: a -> b \ ef): a -> b \ {ef + IO + Fail} - DBDriverManager = x -> 
        run {
            f(x)
        } with handler DBDriverManager {
            
            def getConnection(url, k) = 
                try {
                    let ans = DriverManager.getConnection(url);
                    k(ConnectionHandle.ConnectionHandle(ans))
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }


            def closeConnection(conn, k) = 
                try {
                    let ConnectionHandle.ConnectionHandle(jconn) = conn;
                    jconn.close();
                    k()
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }

        }

    pub def runWithIO(f: Unit -> a \ ef): a \ {ef + Fail + IO} - DBDriverManager = 
        handle(f)()


    pub def runWithIOAndFail(f: Unit -> a \ ef): Result[IoError, a] \ {IO + ef} - DBDriverManager - Fail =
        run {
             runWithIO(f)
        } with EffectExtras.Fail.runWithResultOfIoError

    pub def execDBConnection(url: String, 
                                f: Unit -> a \ DBConnection + ef): a \ {Fail + ef + DBDriverManager} - DBConnection = 
        let conn = DBDriverManager.getConnection(url);
        let ans = run {
            f()
        } with BasicDB.DBConnection.runDBConnection(conn);
        DBDriverManager.closeConnection(conn);
        ans

}