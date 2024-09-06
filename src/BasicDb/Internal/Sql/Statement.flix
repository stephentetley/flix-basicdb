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

    import java.sql.{Statement => JStatement}

    /// Mutable

    pub struct Statement[rc: Region]{
        statement: JStatement
    }

}

mod BasicDb.Internal.Sql.Statement {

    use BasicDb.Internal.Sql.Statement
    use BasicDb.Internal.Sql.ResultSet
    
    pub def close(stmt: Statement[r]): Result[String, Unit] \ IO + r = 
        Result.tryCatch(_ -> {
            let statement1 = stmt->statement;
            statement1.close()
        })

    pub def execute(sql: String, stmt: Statement[r]): Result[String, Bool] \ {IO, r} =
        Result.tryCatch(_ -> {
            let statement1 = stmt->statement;
            statement1.execute(sql)
        })

    pub def executeQuery(rc: Region[r1], sql: String, stmt: Statement[r]): Result[String, ResultSet[r1]] \ {IO, r, r1} = 
        Result.tryCatch(_ -> {
            let statement1 = stmt->statement;
            let ans = statement1.executeQuery(sql);
            new ResultSet @ rc { resultset = ans }
        })

    pub def executeUpdate(sql: String, stmt: Statement[r]): Result[String, Int32] \ {IO, r} = 
        Result.tryCatch(_ -> {
            let statement1 = stmt->statement;
            statement1.executeUpdate(sql)
        })

}    
