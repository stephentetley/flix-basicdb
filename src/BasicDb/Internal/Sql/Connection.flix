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


mod BasicDb.Internal.Sql {

    /// Mutable

    pub enum Connection[_: Region](##java.sql.Connection)

}

mod BasicDb.Internal.Sql.Connection {

    use BasicDb.Internal.Sql.Connection
    use BasicDb.Internal.Sql.Connection.{Connection}
    use BasicDb.Internal.Sql.PreparedStatement
    use BasicDb.Internal.Sql.PreparedStatement.{PreparedStatement}
    use BasicDb.Internal.Sql.Statement
    use BasicDb.Internal.Sql.Statement.{Statement}


    pub def closeConnection!(conn: Connection[r]): Result[String, Unit] \ r = 
        import java.sql.Connection.close(): Unit \ r;
        Result.tryCatch(_ -> {
            let Connection(conn1) = conn;
            close(conn1)
        })


    /// This modifies the session connection - we've decided that is in IO
    pub def setAutoCommit!(autoCommit: Bool, conn: Connection[r]): Result[String, Unit] \ {IO, r}  = 
        import java.sql.Connection.setAutoCommit(Bool): Unit \ {r, IO};
        Result.tryCatch(_ -> {
            let Connection(conn1) = conn;
            setAutoCommit(conn1, autoCommit)
        })

    /// Modifies DB hence IO
    pub def commit!(conn: Connection[r]): Result[String, Unit] \ {IO, r} = 
        import java.sql.Connection.commit(): Unit \ {IO, r};
        Result.tryCatch(_ -> {
            let Connection(conn1) = conn;
            commit(conn1)
        })


    pub def createStatement!(_: Region[r1], conn: Connection[r]): Result[String, Statement[r1]] \ {r, r1} = 
        import java.sql.Connection.createStatement(): ##java.sql.Statement \ {r, r1};
        Result.tryCatch(_ -> {
            let Connection(conn1) = conn;
            createStatement(conn1) |> Statement
        })

    /// Creates a PreparedStatement
    pub def prepareStatement!(_: Region[r1], 
                                sql: String, 
                                conn: Connection[r]): Result[String, PreparedStatement[r1]] \ {r, r1} = 
        Result.tryCatch(_ -> {
            import java.sql.Connection.prepareStatement(String): ##java.sql.PreparedStatement \ {r, r1};
            let Connection(conn1) = conn;
            prepareStatement(conn1, sql) |> PreparedStatement
        })

}    
