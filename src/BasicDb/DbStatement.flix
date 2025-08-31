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

    eff DbStatement {
        def close(): Unit
        def cancel(): Unit
        def execute(sql: String): Bool
    }

}

mod BasicDb.DbStatement {
    
    use BasicDb.StatementHandle
    use BasicDb.StatementHandle.StatementHandle
    use BasicDb.DbStatement
    use IoError.ErrorKind
    use IoError.IoError

    import java.sql.SQLException

    pub def handle(stmt: StatementHandle, f: a -> b \ ef): a -> Result[IoError, b] \ (ef - DbStatement + IO) =
        x -> run {
            Ok(f(x))
        } with handler DbStatement {
            
            
            def close(k) = try {
                let StatementHandle(jstmt) = stmt;
                jstmt.close();
                k()
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

            def cancel(k) = try {
                let StatementHandle(jstmt) = stmt;
                jstmt.cancel();
                k()
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }
            
            def execute(sql, k) = try {
                let StatementHandle(jstmt) = stmt;
                let ans = jstmt.execute(sql);
                k(ans)
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }
 
        }
}