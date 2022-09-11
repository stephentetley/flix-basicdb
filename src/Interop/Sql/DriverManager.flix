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


namespace Interop/Sql/DriverManager {

    use Interop/Sql.Connection;
    use Interop/Sql.Connection.{Connection};


    pub def getConnection(_: Region[r], url: String): Result[Connection[r], String] \ { Write(r), IO } = 
        import static java.sql.DriverManager.getConnection(String): ##java.sql.Connection \ {r, IO};
        try {
            getConnection(url) |> Connection |> Ok
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;
                Err(getMessage(ex))
        }

}    
