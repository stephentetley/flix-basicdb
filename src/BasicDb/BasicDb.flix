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

    pub def runSQLite(path: String, f: Unit -> a \ ef): Result[IoError, a] \ (ef - DbConnection) + {IO} = 
        let url = "jdbc:sqlite:${path}";
        println(url);
        Class.forName("org.sqlite.JDBC");
        match DbDriverManager.runWithIO(_ -> DbDriverManager.getConnection(url)) {
            case Ok(conn) => DbConnection.runWithIO(conn, f)
            case Err(err) => Err(err)
        }
    
    pub def runDuckDb(path: String, f: Unit -> a \ ef): Result[IoError, a] \ (ef - DbConnection) + {IO} = 
        let url = "jdbc:duckdb:${path}";
        println(url);
        Class.forName("org.duckdb.DuckDBDriver");
        match DbDriverManager.runWithIO(_ -> DbDriverManager.getConnection(url)) {
            case Ok(conn) => DbConnection.runWithIO(conn, f)
            case Err(err) => Err(err)
        }
}
