/*
 * Copyright 2020 Stephen Tetley
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


namespace BasicDb/Internal/Prim {

    use BasicDb/Error.{getSQLExceptionMessage};

    /// This should be Impure - in Haskell it would be in IO 
    pub def dmGetConnection(_: Region[r], url: String): Result[##java.sql.Connection, String] \ { Write(r), IO } = 
        import static java.sql.DriverManager.getConnection(String): ##java.sql.Connection \ IO;
        try {
            let ans = getConnection(url);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;
                Err(getMessage(ex))
        }

    
    pub def closeConnection(_: Region[r], conn: ##java.sql.Connection): Result[Unit, String] \ Write(r) = 
        import java.sql.Connection.close(): Unit \ r;
        try {
            close(conn);
            Ok()
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def setAutoCommit(_: Region[r], autoCommit: Bool, conn: ##java.sql.Connection): Result[Unit, String] \ Write(r)  = 
        import java.sql.Connection.setAutoCommit(Bool): Unit \ r;
        try {
            setAutoCommit(conn, autoCommit);
            Ok()
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def commit(_: Region[r], conn: ##java.sql.Connection): Result[Unit, String] \ Write(r) = 
        import java.sql.Connection.commit(): Unit \ r;
        try {
            commit(conn);
            Ok()
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }


    pub def createStatement(_: Region[r], conn: ##java.sql.Connection): Result[##java.sql.Statement, String] \ Write(r) = 
        import java.sql.Connection.createStatement(): ##java.sql.Statement \ r;
        try {
            let ans = createStatement(conn);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def closeStatement(_: Region[r], stmt: ##java.sql.Statement): Result[Unit, String] \ Write(r) = 
        import java.sql.Statement.close(): Unit \ r;
        try {
            close(stmt);
            Ok()
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def executeStatement(_: Region[r], stmt: ##java.sql.Statement, sql: String): Result[Bool, String] \ Write(r) = 
        import java.sql.Statement.execute(String): Bool \ r;
        try {
            let ans = execute(stmt, sql);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def executeQuery(_: Region[r], stmt: ##java.sql.Statement, sql: String): Result[##java.sql.ResultSet, String] \ Write(r) = 
        import java.sql.Statement.executeQuery(String): ##java.sql.ResultSet \ r;
        try {
            let ans = executeQuery(stmt, sql);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def executeUpdate(_: Region[r], stmt: ##java.sql.Statement, sql: String): Result[Int32, String] \ Write(r) = 
        import java.sql.Statement.executeUpdate(String): Int32 \ r;
        try {
            let ans = executeUpdate(stmt, sql);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    /// In a region - conn is a mutable resource.
    pub def prepareStatement(_: Region[r], 
                            conn: ##java.sql.Connection, 
                            sql: String): Result[##java.sql.PreparedStatement, String] \ { Read(r), Write(r) } = 
        import java.sql.Connection.prepareStatement(String): ##java.sql.PreparedStatement \ r;
        try {
            let ans = prepareStatement(conn, sql);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

}    
