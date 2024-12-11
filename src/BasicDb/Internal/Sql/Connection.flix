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

    import java.sql.{Connection => JConnection}

    /// Mutable

    pub struct Connection[rc: Region]{
        connection: JConnection
    }


}

mod BasicDb.Internal.Sql.Connection {

    use BasicDb.Internal.Sql.Connection
    use BasicDb.Internal.Sql.PreparedStatement
    use BasicDb.Internal.Sql.Statement


    pub def closeConnection(conn: Connection[r]): Result[String, Unit] \ IO + r = 
        Result.tryCatch(_ -> {
            let connection1 = conn->connection;
            checked_ecast(connection1.close())
        })


    /// This modifies the session connection - we've decided that is in IO
    pub def setAutoCommit(autoCommit: Bool, conn: Connection[r]): Result[String, Unit] \ {IO, r}  = 
        Result.tryCatch(_ -> {
            let connection1 = conn->connection;
            checked_ecast(connection1.setAutoCommit(autoCommit))
        })

    /// Modifies DB hence IO
    pub def commit(conn: Connection[r]): Result[String, Unit] \ {IO, r} = 
        Result.tryCatch(_ -> {
            let connection1 = conn->connection;
            checked_ecast(connection1.commit())
        })


    pub def createStatement(rc: Region[r1], conn: Connection[r]): Result[String, Statement[r1]] \ {IO, r, r1} = 
        Result.tryCatch(_ -> {
            let connection1 = conn->connection;
            let ans = checked_ecast(connection1.createStatement());
            new Statement @ rc { statement = ans }
        })

    /// Creates a PreparedStatement
    pub def prepareStatement(rc: Region[r1], 
                                sql: String, 
                                conn: Connection[r]): Result[String, PreparedStatement[r1]] \ {IO, r, r1} = 
        Result.tryCatch(_ -> {
            let connection1 = conn->connection;
            let ans = checked_ecast(connection1.prepareStatement(sql));
            new PreparedStatement @ rc {preparedStatement = ans}
        })

}    
