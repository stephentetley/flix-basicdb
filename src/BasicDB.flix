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


pub mod BasicDB {
    use IoError.IoError
    use EffectExtras.Fail.Fail
    use BasicDB.DBDriverManager.DBDriverManager
    use BasicDB.DBConnection.DBConnection

    import java.lang.Class

    pub def runSQLite(path: String, 
                        f: Unit -> a \ ef): Result[IoError, a] \ {ef + IO - Fail - DBConnection - DBDriverManager} = 
        run {
            let url = "jdbc:sqlite:${path}";
            Class.forName("org.sqlite.JDBC");
            let conn = DBDriverManager.getConnection(url);
            let ans = BasicDB.DBConnection.runDBConnection(conn, f);
            DBDriverManager.closeConnection(conn);
            ans
        } with BasicDB.DBDriverManager.runWithIOAndFail
    

    pub def runDuckDB(path: String, 
                    f: Unit -> a \ ef): Result[IoError, a] \ {ef + IO - Fail - DBConnection - DBDriverManager} = 
        let url = "jdbc:duckdb:${path}";
        runDuckDBHelper(url, f)
    
    pub def runDuckDBInMemory(f: Unit -> a \ ef): Result[IoError, a] \ {ef + IO - Fail - DBConnection - DBDriverManager} = 
        let url = "jdbc:duckdb:";
        runDuckDBHelper(url, f)


    def runDuckDBHelper(url: String, f: Unit -> a \ ef): Result[IoError, a] \ {ef + IO - Fail - DBConnection - DBDriverManager} = 
        run {
            Class.forName("org.duckdb.DuckDBDriver");
            let conn = DBDriverManager.getConnection(url);
            let ans = BasicDB.DBConnection.runDBConnection(conn, f);
            DBDriverManager.closeConnection(conn);
            ans
        } with BasicDB.DBDriverManager.runWithIOAndFail
    

}

