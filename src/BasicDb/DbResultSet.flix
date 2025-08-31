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

    eff DbResultSet {
        def close(): Unit
    }

}

mod BasicDb.DbResultSet {
    
    use BasicDb.ResultSetHandle
    use BasicDb.ResultSetHandle.ResultSetHandle
    use BasicDb.DbResultSet
    use IoError.ErrorKind
    use IoError.IoError

    import java.sql.SQLException

    pub def handle(results: ResultSetHandle, f: a -> b \ ef): a -> Result[IoError, b] \ (ef - DbResultSet + IO) =
        x -> run {
            Ok(f(x))
        } with handler DbResultSet {
            
            
            def close(k) = try {
                let ResultSetHandle(jresults) = results;
                jresults.close();
                k()
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

        }
}