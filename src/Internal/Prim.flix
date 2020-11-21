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

use System.Error.{Generic};

namespace BasicDb/Internal/Prim {


    pub def dmGetConnection(url: String): Result[##java.sql.Connection, System.Error] & Impure = 
        import java.sql.DriverManager:getConnection(String);
        try {
            let ans = getConnection(url);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err(Generic("dmGetConnection")) 
        }

    
    pub def closeConnection(conn: ##java.sql.Connection): Result[Unit, System.Error] & Impure = 
        import java.sql.Connection.close();
        try {
            conn.close();
            Ok()
        } catch {
            case _: ##java.sql.SQLException => Err(Generic("closeConnection"))
        }

    pub def setAutoCommit(conn: ##java.sql.Connection, autoCommit: Bool): Result[Unit, System.Error] & Impure = 
        import java.sql.Connection.setAutoCommit(Bool);
        try {
            conn.setAutoCommit(autoCommit);
            Ok()
        } catch {
            case _: ##java.sql.SQLException => Err(Generic("setAutoCommit"))
        }

    pub def commit(conn: ##java.sql.Connection): Result[Unit, System.Error] & Impure = 
        import java.sql.Connection.commit();
        try {
            conn.commit();
            Ok()
        } catch {
            case _: ##java.sql.SQLException => Err(Generic("commit"))
        }


    pub def createStatement(conn: ##java.sql.Connection): Result[ ##java.sql.Statement, System.Error] & Impure = 
        import java.sql.Connection.createStatement();
        try {
            let ans = conn.createStatement();
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err(Generic("createStatement"))
        }

    pub def closeStatement(stmt: ##java.sql.Statement): Result[Unit, System.Error] & Impure = 
        import java.sql.Statement.close();
        try {
            stmt.close();
            Ok()
        } catch {
            case _: ##java.sql.SQLException => Err(Generic("closeStatement"))
        }

    pub def executeStatement(stmt: ##java.sql.Statement, sql: String): Result[Bool, System.Error] & Impure = 
        import java.sql.Statement.execute(String);
        try {
            let ans = stmt.execute(sql);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err(Generic("executeStatement"))
        }

    pub def executeQuery(stmt: ##java.sql.Statement, sql: String): Result[##java.sql.ResultSet, System.Error] & Impure = 
        import java.sql.Statement.executeQuery(String);
        try {
            let ans = stmt.executeQuery(sql);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err(Generic("executeQuery"))
        }

    pub def executeUpdate(stmt: ##java.sql.Statement, sql: String): Result[Int32, System.Error] & Impure = 
        import java.sql.Statement.executeUpdate(String);
        try {
            let ans = stmt.executeUpdate(sql);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err(Generic("executeUpdate"))
        }


    pub def prepareStatement(conn: ##java.sql.Connection, sql: String): Result[##java.sql.PreparedStatement, System.Error] & Impure = 
        import java.sql.Connection.prepareStatement(String);
        try {
            let ans = conn.prepareStatement(sql);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err(Generic("prepareStatement"))
        }

}    