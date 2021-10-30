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


    pub def dmGetConnection(url: String): Result[##java.sql.Connection, String] & Impure = 
        import java.sql.DriverManager:getConnection(String);
        try {
            let ans = getConnection(url);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("dmGetConnection")
        }

    
    pub def closeConnection(conn: ##java.sql.Connection): Result[Unit, String] & Impure = 
        import java.sql.Connection.close();
        try {
            close(conn);
            Ok()
        } catch {
            case _: ##java.sql.SQLException => Err("closeConnection")
        }

    pub def setAutoCommit(conn: ##java.sql.Connection, autoCommit: Bool): Result[Unit, String] & Impure = 
        import java.sql.Connection.setAutoCommit(Bool);
        try {
            setAutoCommit(conn, autoCommit);
            Ok()
        } catch {
            case _: ##java.sql.SQLException => Err("setAutoCommit")
        }

    pub def commit(conn: ##java.sql.Connection): Result[Unit, String] & Impure = 
        import java.sql.Connection.commit();
        try {
            commit(conn);
            Ok()
        } catch {
            case _: ##java.sql.SQLException => Err("commit")
        }


    pub def createStatement(conn: ##java.sql.Connection): Result[ ##java.sql.Statement, String] & Impure = 
        import java.sql.Connection.createStatement();
        try {
            let ans = createStatement(conn);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("createStatement")
        }

    pub def closeStatement(stmt: ##java.sql.Statement): Result[Unit, String] & Impure = 
        import java.sql.Statement.close();
        try {
            close(stmt);
            Ok()
        } catch {
            case _: ##java.sql.SQLException => Err("closeStatement")
        }

    pub def executeStatement(stmt: ##java.sql.Statement, sql: String): Result[Bool, String] & Impure = 
        import java.sql.Statement.execute(String);
        try {
            let ans = execute(stmt, sql);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("executeStatement")
        }

    pub def executeQuery(stmt: ##java.sql.Statement, sql: String): Result[##java.sql.ResultSet, String] & Impure = 
        import java.sql.Statement.executeQuery(String);
        try {
            let ans = executeQuery(stmt, sql);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("executeQuery")
        }

    pub def executeUpdate(stmt: ##java.sql.Statement, sql: String): Result[Int32, String] & Impure = 
        import java.sql.Statement.executeUpdate(String);
        try {
            let ans = executeUpdate(stmt, sql);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("executeUpdate")
        }


    pub def prepareStatement(conn: ##java.sql.Connection, sql: String): Result[##java.sql.PreparedStatement, String] & Impure = 
        import java.sql.Connection.prepareStatement(String);
        try {
            let ans = prepareStatement(conn, sql);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("prepareStatement")
        }

}    
