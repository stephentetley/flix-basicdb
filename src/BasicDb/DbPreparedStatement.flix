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

    use BasicDb.ResultSetHandle

    eff DbPreparedStatement {
        def close(): Unit
        def execute(): Bool
    }

}

mod BasicDb.DbPreparedStatement {
    
    use BasicDb.PreparedStatementHandle
    use BasicDb.PreparedStatementHandle.PreparedStatementHandle
    use BasicDb.ResultSetHandle
    use BasicDb.ResultSetHandle.ResultSetHandle
    use BasicDb.DbPreparedStatement
    use IoError.ErrorKind
    use IoError.IoError

    import java.sql.SQLException

    pub def handle(stmt: PreparedStatementHandle, f: a -> b \ ef): a -> Result[IoError, b] \ (ef - DbPreparedStatement + IO) =
        x -> run {
            Ok(f(x))
        } with handler DbPreparedStatement {
            
                        
            def close(k) = try {
                let PreparedStatementHandle(jstmt) = stmt;
                jstmt.close();
                k()
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

            def execute(k) = try {
                let PreparedStatementHandle(jstmt) = stmt;
                let ans = jstmt.execute();
                k(ans)
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }
       }
}