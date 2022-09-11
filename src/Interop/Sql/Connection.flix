/*
 * Copyright 2022 Stephen Tetley
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


namespace Interop/Sql {

    /// Mutable

    pub enum Connection[_: Region](##java.sql.Connection)

    instance Scoped[Connection] {
        pub def regionOf(_: Connection[r]): Region[r] = () as Region[r]
    }

}

namespace Interop/Sql/Connection {

    use Interop/Sql.Connection;
    use Interop/Sql.Connection.{Connection};

    use Interop/Sql.PreparedStatement;
    use Interop/Sql.PreparedStatement.{PreparedStatement};
    use Interop/Sql.Statement;
    use Interop/Sql.Statement.{Statement};

    pub def getHH(conn: Connection[r]): ##java.sql.Connection = 
        let Connection(conn1) = conn;
        conn1

    
    pub def closeConnection!(conn: Connection[r]): Result[Unit, String] \ Write(r) = 
        import java.sql.Connection.close(): Unit \ r;
        try {
            let Connection(conn1) = conn;
            close(conn1);
            Ok()
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def setAutoCommit!(autoCommit: Bool, conn: Connection[r]): Result[Unit, String] \ Write(r)  = 
        import java.sql.Connection.setAutoCommit(Bool): Unit \ r;
        try {
            let Connection(conn1) = conn;
            setAutoCommit(conn1, autoCommit);
            Ok()
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def commit!(conn: Connection[r]): Result[Unit, String] \ Write(r) = 
        import java.sql.Connection.commit(): Unit \ r;
        try {
            let Connection(conn1) = conn;
            commit(conn1);
            Ok()
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }


    pub def createStatement!(conn: Connection[r]): Result[Statement[r], String] \ Write(r) = 
        import java.sql.Connection.createStatement(): ##java.sql.Statement \ r;
        try {
            let Connection(conn1) = conn;
            createStatement(conn1) |> Statement |> Ok
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def prepareStatement!(sql: String, 
                            conn: Connection[r]): Result[PreparedStatement[r], String] \ { Read(r), Write(r) } = 
        try {
            import java.sql.Connection.prepareStatement(String): ##java.sql.PreparedStatement \ r;
            let Connection(conn1) = conn;
            prepareStatement(conn1, sql) |> PreparedStatement |> Ok
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

}    
