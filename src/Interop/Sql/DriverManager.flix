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


mod Interop.Sql.DriverManager {

    use Interop.Sql.Connection;
    use Interop.Sql.Connection.{Connection};


    pub def getConnection(_: Region[r], url: String): Result[String, Connection[r]] \ {IO, r} = 
        import static java.sql.DriverManager.getConnection(String): ##java.sql.Connection \ {IO, r};
        Result.tryCatch(_ -> {
            getConnection(url) |> Connection
        })

}    
