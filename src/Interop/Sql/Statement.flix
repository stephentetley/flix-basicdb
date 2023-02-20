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

    pub enum Statement[_: Region](##java.sql.Statement)


}

namespace Interop/Sql/Statement {

    use Interop/Sql.Statement;
    use Interop/Sql.Statement.{Statement};

    use Interop/Sql.PreparedStatement;
    use Interop/Sql.PreparedStatement.{PreparedStatement};
    use Interop/Sql.ResultSet;
    use Interop/Sql.ResultSet.{ResultSet};


    pub def getHH(stmt: Statement[r]): ##java.sql.Statement = 
        let Statement(stmt1) = stmt;
        stmt1



    pub def close!(stmt: Statement[r]): Result[String, Unit] \ Write(r) = 
        try {
            import java.sql.Statement.close(): Unit \ r;
            let Statement(stmt1) = stmt;
            close(stmt1);
            Ok()
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def execute!(sql: String, stmt: Statement[r]): Result[String, Bool] \ {IO, Write(r)} =
        try {
            import java.sql.Statement.execute(String): Bool \ {IO, r};
            let Statement(stmt1) = stmt;
            let ans = execute(stmt1, sql);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def executeQuery!(sql: String, stmt: Statement[r]): Result[String, ResultSet[r]] \ {IO, Write(r)} = 
        try {
            import java.sql.Statement.executeQuery(String): ##java.sql.ResultSet \ {IO, r};
            let Statement(stmt1) = stmt;
            executeQuery(stmt1, sql) |> ResultSet |> Ok
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def executeUpdate!(sql: String, stmt: Statement[r]): Result[String, Int32] \ {IO, Write(r)} = 
        try {
            import java.sql.Statement.executeUpdate(String): Int32 \ {IO, r};
            let Statement(stmt1) = stmt;
            let ans = executeUpdate(stmt1, sql);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

}    
