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

    eff DbStatement {
        def close(): Unit
        def getMaxRows(): Int32
        def setMaxRows(maxRows: Int32): Unit
        def cancel(): Unit
        def execute(sql: String): Bool
        def executeUpdate(sql: String): Int32
        def executeLargeUpdate(sql: String): Int64
        def getResultSet(): ResultSetHandle
        def enquoteLiteral(sql: String): String
        def isClosed(): Bool
        def isCloseOnCompletion(): Bool
    }

}

mod BasicDb.DbStatement {
    
    use BasicDb.StatementHandle
    use BasicDb.StatementHandle.StatementHandle
    use BasicDb.ResultSetHandle
    use BasicDb.ResultSetHandle.ResultSetHandle
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

            def getMaxRows(k) = try {
                let StatementHandle(jstmt) = stmt;
                let ans = jstmt.getMaxRows();
                k(ans)
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

            def setMaxRows(maxRows, k) = try {
                let StatementHandle(jstmt) = stmt;
                jstmt.setMaxRows(maxRows);
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
            
            def executeUpdate(sql, k) = try {
                let StatementHandle(jstmt) = stmt;
                let ans = jstmt.executeUpdate(sql);
                k(ans)
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }
            
            def executeLargeUpdate(sql, k) = try {
                let StatementHandle(jstmt) = stmt;
                let ans = jstmt.executeLargeUpdate(sql);
                k(ans)
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

            def getResultSet(k) = try {
                let StatementHandle(jstmt) = stmt;
                let ans = ResultSetHandle(jstmt.getResultSet());
                k(ans)
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

            def enquoteLiteral(sql, k) = try {
                let StatementHandle(jstmt) = stmt;
                let ans = jstmt.enquoteLiteral(sql);
                k(ans)
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

            def isClosed(k) = try {
                let StatementHandle(jstmt) = stmt;
                let ans = jstmt.isClosed();
                k(ans)
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }
 
            def isCloseOnCompletion(k) = try {
                let StatementHandle(jstmt) = stmt;
                let ans = jstmt.isCloseOnCompletion();
                k(ans)
            } catch {
                case ex: SQLException => Err(IoError(ErrorKind.Other, ex.getMessage()))
            }

        }
}