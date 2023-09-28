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

    pub enum Statement[_: Region](##java.sql.Statement)


}

mod BasicDb.Internal.Sql.Statement {

    use BasicDb.Internal.Sql.Statement
    use BasicDb.Internal.Sql.Statement.{Statement}

    use BasicDb.Internal.Sql.PreparedStatement
    use BasicDb.Internal.Sql.PreparedStatement.{PreparedStatement}
    use BasicDb.Internal.Sql.ResultSet
    use BasicDb.Internal.Sql.ResultSet.{ResultSet}



    pub def close!(stmt: Statement[r]): Result[String, Unit] \ r = 
        Result.tryCatch(_ -> {
            import java.sql.Statement.close(): Unit \ r;
            let Statement(stmt1) = stmt;
            close(stmt1)
        })

    pub def execute!(sql: String, stmt: Statement[r]): Result[String, Bool] \ {IO, r} =
        Result.tryCatch(_ -> {
            import java.sql.Statement.execute(String): Bool \ {IO, r};
            let Statement(stmt1) = stmt;
            execute(stmt1, sql)
        })

    pub def executeQuery!(_: Region[r1], sql: String, stmt: Statement[r]): Result[String, ResultSet[r1]] \ {IO, r} = 
        Result.tryCatch(_ -> {
            import java.sql.Statement.executeQuery(String): ##java.sql.ResultSet \ {IO, r, r1};
            let Statement(stmt1) = stmt;
            executeQuery(stmt1, sql) |> ResultSet
        })

    pub def executeUpdate!(sql: String, stmt: Statement[r]): Result[String, Int32] \ {IO, r} = 
        Result.tryCatch(_ -> {
            import java.sql.Statement.executeUpdate(String): Int32 \ {IO, r};
            let Statement(stmt1) = stmt;
            executeUpdate(stmt1, sql)
        })

}    
