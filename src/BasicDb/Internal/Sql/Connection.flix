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

    /// Mutable like StringBuilder

    pub enum Connection[_: Region](JConnection)


}

mod BasicDb.Internal.Sql.Connection {

    use BasicDb.Internal.Sql.Connection
    use BasicDb.Internal.Sql.PreparedStatement
    use BasicDb.Internal.Sql.PreparedStatement.PreparedStatement
    use BasicDb.Internal.Sql.Statement
    use BasicDb.Internal.Sql.Statement.Statement


    pub def closeConnection(conn: Connection[r]): Result[String, Unit] \ IO + r = 
        Result.tryCatch(_ -> {
            let Connection(conn1) = conn;
            checked_ecast(conn1.close())
        })


    /// This modifies the session connection - we've decided that is in IO
    pub def setAutoCommit(autoCommit: Bool, conn: Connection[r]): Result[String, Unit] \ {IO, r}  = 
        Result.tryCatch(_ -> {
            let Connection(conn1) = conn;
            checked_ecast(conn1.setAutoCommit(autoCommit))
        })

    /// Modifies DB hence IO
    pub def commit(conn: Connection[r]): Result[String, Unit] \ {IO, r} = 
        Result.tryCatch(_ -> {
            let Connection(conn1) = conn;
            checked_ecast(conn1.commit())
        })


    pub def createStatement(_: Region[r1], conn: Connection[r]): Result[String, Statement[r1]] \ {IO, r, r1} = 
        Result.tryCatch(_ -> {
            let Connection(conn1) = conn;
            let stmt1 = unchecked_cast(conn1.createStatement() as _ \ r1);
            checked_ecast(Statement(stmt1))
        })

    /// Creates a PreparedStatement
    pub def prepareStatement(_: Region[r1], 
                                sql: String, 
                                conn: Connection[r]): Result[String, PreparedStatement[r1]] \ {IO, r, r1} = 
        Result.tryCatch(_ -> {
            let Connection(conn1) = conn;
            let stmt1 = unchecked_cast(conn1.prepareStatement(sql) as _ \ r1);
            checked_ecast(PreparedStatement(stmt1))
        })

}    
