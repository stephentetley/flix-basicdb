/*
 * Copyright 2024 Stephen Tetley
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

    import java.sql.{Connection => JConnection}
    use BasicDb.Internal.Sql.Connection

    // [r: Region]
    eff DbConnection {
        def currentConnection(): JConnection
        def fail(msg: String): Void
    }


}

mod BasicDb.DbConnection {

    use BasicDb.Internal.Sql.Connection
    
    import java.sql.{Connection => JConnection}
    import java.sql.{Statement => JStatement}

    pub def withConnection(f: JConnection -> a \ IO): a \ DbConnection =
        let conn = BasicDb.DbConnection.currentConnection();
        match Result.tryCatch(_ -> {unsafe f(conn)}) {
            case Ok(a)    => a
            case Err(msg) => BasicDb.DbConnection.fail(msg)
        }


    pub def close(): Unit \ DbConnection = 
        withConnection(conn -> conn.close())



    /// This modifies the session connection
    pub def setAutoCommit(autoCommit: Bool): Unit \ DbConnection = 
        withConnection(conn -> conn.setAutoCommit(autoCommit))


    pub def getAutoCommit(): Bool \ DbConnection = 
        withConnection(conn -> conn.getAutoCommit())

    pub def getSchema(): String \ DbConnection = 
        withConnection(conn -> conn.getSchema())

    // Maybe should be in IO as well as DbConnection...
    pub def commit(): Unit \ DbConnection = 
        withConnection(conn -> conn.commit())


    pub def execute(sql: String): Bool \ DbConnection = 
        withConnection(conn -> 
            let stmt = conn.createStatement();
            stmt.execute(sql)
        )

    pub def executeUpdate(sql: String): Int32 \ DbConnection = 
        withConnection(conn -> 
            let stmt = conn.createStatement();
            stmt.executeUpdate(sql)
        )


    // /// Creates a PreparedStatement
    // pub def prepareStatement(rc: Region[r1], 
    //                             sql: String, 
    //                             conn: Connection[r]): Result[String, PreparedStatement[r1]] \ {IO, r, r1} = 
    //     Result.tryCatch(_ -> {
    //         let connection1 = conn->connection;
    //         let ans = connection1.prepareStatement(sql);
    //         new PreparedStatement @ rc {preparedStatement = ans}
    //     })

}
