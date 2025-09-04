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

    use BasicDb.DbDriverManager
    use BasicDb.DbConnection
    use IoError.IoError

    import java.lang.Class

    pub def runSQLite(path: String, f: Unit -> a \ ef): Result[IoError, a] \ (ef - DbConnection - DbDriverManager) + {IO} = 
        Result.flatten(run {
            let url = "jdbc:sqlite:${path}";
            Class.forName("org.sqlite.JDBC");
            let conn = DbDriverManager.getConnection(url);
            run {
                let ans = f();
                DbConnection.close();
                ans
            } with DbConnection.runWithIO(conn)
        } with DbDriverManager.runWithIO)
    

    pub def runDuckDb(path: String, f: Unit -> a \ ef): Result[IoError, a] \ (ef - DbConnection - DbDriverManager) + {IO} = 
        Result.flatten(run {
            let url = "jdbc:duckdb:${path}";
            Class.forName("org.duckdb.DuckDBDriver");
            let conn = DbDriverManager.getConnection(url);
            run {
                let ans = f();
                DbConnection.close();
                ans
            } with DbConnection.runWithIO(conn)
        } with DbDriverManager.runWithIO)


}
