/*
 * Copyright 2025 Stephen Tetley
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

    use BasicDb.ConnectionHandle

    pub eff DbDriverManager {
        def getConnection(url: String): ConnectionHandle
    }

}

mod BasicDb.DbDriverManager {
    

    use BasicDb.DbDriverManager
    use BasicDb.ConnectionHandle.ConnectionHandle
    use IoError.ErrorKind
    use IoError.IoError

    import java.sql.SQLException
    import java.sql.DriverManager

    pub def handle(f: a -> b \ ef): a -> Result[IoError, b] \ (ef - DbDriverManager + IO) =
        x -> run {
            Ok(f(x))
        } with handler DbDriverManager {            
            
            def getConnection(url, k) = try {
                let ans = ConnectionHandle(DriverManager.getConnection(url));
                k(ans)
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

        }

    pub def runWithIO(f: Unit -> a \ ef): Result[IoError, a] \ (ef - DbDriverManager) + {IO} = 
        handle(f)()
}