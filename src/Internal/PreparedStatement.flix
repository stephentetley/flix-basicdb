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

namespace BasicDb/Internal/PreparedStatement {

    pub def sql_type_null(): Int32 =
        import get java.sql.Types:NULL as get_NULL;
        get_NULL() as & Pure

    pub def clearParameters!(x: ##java.sql.PreparedStatement): Result[Unit, String] & Impure =
        import java.sql.PreparedStatement.clearParameters();
        try {
            clearParameters(x);
            Ok()
        } catch {
            case _: ##java.sql.SQLException => Err("clearParameters!")
        }


    pub def executeQuery(x: ##java.sql.PreparedStatement): Result[##java.sql.ResultSet, String] & Impure =
        import java.sql.PreparedStatement.executeQuery();
        try {
            let ans = executeQuery(x);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("executeQuery")
        }

    pub def executeUpdate(x: ##java.sql.PreparedStatement): Result[Int32, String] & Impure =
        import java.sql.PreparedStatement.executeUpdate();
        try {
            let ans = executeUpdate(x);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("executeUpdate")
        }



    pub def setNull!(x: ##java.sql.PreparedStatement, ix: Int32, sqlType: Int32): Result[Unit, String] & Impure =
        import java.sql.PreparedStatement.setNull(Int32, Int32);
        try {
            setNull(x, ix, sqlType);
            Ok()
        } catch {
            case _: ##java.sql.SQLException => Err("setNull!")
        }

    pub def setString!(x: ##java.sql.PreparedStatement, ix: Int32, str: String): Result[Unit, String] & Impure =
        import java.sql.PreparedStatement.setString(Int32, String);
        try {
            setString(x, ix, str);
            Ok()
        } catch {
            case _: ##java.sql.SQLException => Err("setString!")
        }

    pub def setBool!(x: ##java.sql.PreparedStatement, ix: Int32, b: Bool): Result[Unit, String] & Impure =
        import java.sql.PreparedStatement.setBoolean(Int32, Bool);
        try {
            setBoolean(x, ix, b);
            Ok()
        } catch {
            case _: ##java.sql.SQLException => Err("setBool!")
        }

    pub def setInt8!(x: ##java.sql.PreparedStatement, ix: Int32, n: Int8): Result[Unit, String] & Impure =
        import java.sql.PreparedStatement.setByte(Int32, Int8);
        try {
            setByte(x, ix, n);
            Ok()
        } catch {
            case _: ##java.sql.SQLException => Err("setInt8!")
        }

    pub def setInt16!(x: ##java.sql.PreparedStatement, ix: Int32, n: Int16): Result[Unit, String] & Impure =
        import java.sql.PreparedStatement.setShort(Int32, Int16);
        try {
            setShort(x, ix, n);
            Ok()
        } catch {
            case _: ##java.sql.SQLException => Err("setInt16!")
        }

    pub def setInt32!(x: ##java.sql.PreparedStatement, ix: Int32, n: Int32): Result[Unit, String] & Impure =
        import java.sql.PreparedStatement.setInt(Int32, Int32);
        try {
            setInt(x, ix, n);
            Ok()
        } catch {
            case _: ##java.sql.SQLException => Err("setInt32!")
        }

    pub def setInt64!(x: ##java.sql.PreparedStatement, ix: Int32, n: Int64): Result[Unit, String] & Impure =
        import java.sql.PreparedStatement.setLong(Int32, Int64);
        try {
            setLong(x, ix, n);
            Ok()
        } catch {
            case _: ##java.sql.SQLException => Err("setInt64!")
        }

    pub def setFloat32!(x: ##java.sql.PreparedStatement, ix: Int32, d: Float32): Result[Unit, String] & Impure =
        import java.sql.PreparedStatement.setFloat(Int32, Float32);
        try {
            setFloat(x, ix, d);
            Ok()
        } catch {
            case _: ##java.sql.SQLException => Err("setFloat32!")
        }

    pub def setFloat64!(x: ##java.sql.PreparedStatement, ix: Int32, d: Float64): Result[Unit, String] & Impure =
        import java.sql.PreparedStatement.setDouble(Int32, Float64);
        try {
            setDouble(x, ix, d);
            Ok()
        } catch {
            case _: ##java.sql.SQLException => Err("setFloat64!")
        }

}

