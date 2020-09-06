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




namespace BasicDb/Internal/PreparedStatement {

    pub def sql_type_null(): Int32 =
        import get java.sql.Types:NULL as get_NULL;
        get_NULL() as & Pure

    pub def clearParameters!(x: ##java.sql.PreparedStatement): Result[Unit, System.Error] & Impure =
        import java.sql.PreparedStatement.clearParameters();
        try {
            x.clearParameters();
            Ok()
        } catch {
            case _: ##java.sql.SQLException => Err(Generic("SQLException.clearParameters"))
        }


    pub def executeQuery(x: ##java.sql.PreparedStatement): Result[##java.sql.ResultSet, System.Error] & Impure =
        import java.sql.PreparedStatement.executeQuery();
        try {
            let ans = x.executeQuery();
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err(Generic("PreparedStatement.executeUpdate"))
        }

    pub def executeUpdate(x: ##java.sql.PreparedStatement): Result[Int32, System.Error] & Impure =
        import java.sql.PreparedStatement.executeUpdate();
        try {
            let ans = x.executeUpdate();
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err(Generic("PreparedStatement.executeUpdate"))
        }



    pub def setNull!(x: ##java.sql.PreparedStatement, ix: Int32, sqlType: Int32): Result[Unit, System.Error] & Impure =
        import java.sql.PreparedStatement.setNull(Int32, Int32);
        try {
            x.setNull(ix, sqlType);
            Ok()
        } catch {
            case _: ##java.sql.SQLException => Err(Generic("SQLException.setNull"))
        }

    pub def setString!(x: ##java.sql.PreparedStatement, ix: Int32, str: String): Result[Unit, System.Error] & Impure =
        import java.sql.PreparedStatement.setString(Int32, String);
        try {
            x.setString(ix, str);
            Ok()
        } catch {
            case _: ##java.sql.SQLException => Err(Generic("SQLException.setString"))
        }

    pub def setBool!(x: ##java.sql.PreparedStatement, ix: Int32, b: Bool): Result[Unit, System.Error] & Impure =
        import java.sql.PreparedStatement.setBoolean(Int32, Bool);
        try {
            x.setBoolean(ix, b);
            Ok()
        } catch {
            case _: ##java.sql.SQLException => Err(Generic("SQLException"))
        }

    pub def setInt8!(x: ##java.sql.PreparedStatement, ix: Int32, n: Int8): Result[Unit, System.Error] & Impure =
        import java.sql.PreparedStatement.setByte(Int32, Int8);
        try {
            x.setByte(ix, n);
            Ok()
        } catch {
            case _: ##java.sql.SQLException => Err(Generic("SQLException"))
        }

    pub def setInt16!(x: ##java.sql.PreparedStatement, ix: Int32, n: Int16): Result[Unit, System.Error] & Impure =
        import java.sql.PreparedStatement.setShort(Int32, Int16);
        try {
            x.setShort(ix, n);
            Ok()
        } catch {
            case _: ##java.sql.SQLException => Err(Generic("SQLException"))
        }

    pub def setInt32!(x: ##java.sql.PreparedStatement, ix: Int32, n: Int32): Result[Unit, System.Error] & Impure =
        import java.sql.PreparedStatement.setInt(Int32, Int32);
        try {
            x.setInt(ix, n);
            Ok()
        } catch {
            case _: ##java.sql.SQLException => Err(Generic("SQLException"))
        }

    pub def setInt64!(x: ##java.sql.PreparedStatement, ix: Int32, n: Int64): Result[Unit, System.Error] & Impure =
        import java.sql.PreparedStatement.setLong(Int32, Int64);
        try {
            x.setLong(ix, n);
            Ok()
        } catch {
            case _: ##java.sql.SQLException => Err(Generic("SQLException"))
        }

    pub def setFloat32!(x: ##java.sql.PreparedStatement, ix: Int32, d: Float32): Result[Unit, System.Error] & Impure =
        import java.sql.PreparedStatement.setFloat(Int32, Float32);
        try {
            x.setFloat(ix, d);
            Ok()
        } catch {
            case _: ##java.sql.SQLException => Err(Generic("SQLException"))
        }

    pub def setFloat64!(x: ##java.sql.PreparedStatement, ix: Int32, d: Float64): Result[Unit, System.Error] & Impure =
        import java.sql.PreparedStatement.setDouble(Int32, Float64);
        try {
            x.setDouble(ix, d);
            Ok()
        } catch {
            case _: ##java.sql.SQLException => Err(Generic("SQLException"))
        }



}

