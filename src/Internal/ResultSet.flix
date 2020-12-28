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

namespace BasicDb/Internal/ResultSet {

    pub def close(x: ##java.sql.ResultSet): Result[Unit, String] & Impure =
        import java.sql.ResultSet.close();
        try {
            let ans = x.close();
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("close")
        }

    pub def next(x: ##java.sql.ResultSet): Result[Bool, String] & Impure =
        import java.sql.ResultSet.next();
        try {
            let ans = x.next();
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("next")
        }

    pub def getStringAt(x: ##java.sql.ResultSet, ix: Int32): Result[String, String] & Impure =
        import java.sql.ResultSet.getString(Int32);
        try {
            let ans = x.getString(ix);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("getStringAt")
        }

    pub def getStringNamed(x: ##java.sql.ResultSet, label: String): Result[String, String] & Impure =
        import java.sql.ResultSet.getString(String);
        try {
            let ans = x.getString(label);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("getStringNamed")
        }

    pub def getBoolAt(x: ##java.sql.ResultSet, ix: Int32): Result[Bool, String] & Impure =
        import java.sql.ResultSet.getBoolean(Int32);
        try {
            let ans = x.getBoolean(ix);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("getBoolAt")
        }

    pub def getBoolNamed(x: ##java.sql.ResultSet, label: String): Result[Bool, String] & Impure =
        import java.sql.ResultSet.getBoolean(String);
        try {
            let ans = x.getBoolean(label);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("getBoolNamed")
        }

    pub def getInt8At(x: ##java.sql.ResultSet, ix: Int32): Result[Int8, String] & Impure =
        import java.sql.ResultSet.getByte(Int32);
        try {
            let ans = x.getByte(ix);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("getInt8At")
        }

    pub def getInt8Named(x: ##java.sql.ResultSet, label: String): Result[Int8, String] & Impure =
        import java.sql.ResultSet.getByte(String);
        try {
            let ans = x.getByte(label);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("getInt8Named")
        }

    pub def getInt16At(x: ##java.sql.ResultSet, ix: Int32): Result[Int16, String] & Impure =
        import java.sql.ResultSet.getShort(Int32);
        try {
            let ans = x.getShort(ix);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("getInt16At")
        }

    pub def getInt16Named(x: ##java.sql.ResultSet, label: String): Result[Int16, String] & Impure =
        import java.sql.ResultSet.getShort(String);
        try {
            let ans = x.getShort(label);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("getInt16Named")
        }

    pub def getInt32At(x: ##java.sql.ResultSet, ix: Int32): Result[Int32, String] & Impure =
        import java.sql.ResultSet.getInt(Int32);
        try {
            let ans = x.getInt(ix);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("getInt32At")
        }

    pub def getInt32Named(x: ##java.sql.ResultSet, label: String): Result[Int32, String] & Impure =
        import java.sql.ResultSet.getInt(String);
        try {
            let ans = x.getInt(label);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("getInt32Named")
        }

    pub def getInt64At(x: ##java.sql.ResultSet, ix: Int32): Result[Int64, String] & Impure =
        import java.sql.ResultSet.getLong(Int32);
        try {
            let ans = x.getLong(ix);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("getInt64At")
        }

    pub def getInt64Named(x: ##java.sql.ResultSet, label: String): Result[Int64, String] & Impure =
        import java.sql.ResultSet.getLong(String);
        try {
            let ans = x.getLong(label);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("getInt64Named")
        }

    pub def getFloat32At(x: ##java.sql.ResultSet, ix: Int32): Result[Float32, String] & Impure =
        import java.sql.ResultSet.getFloat(Int32);
        try {
            let ans = x.getFloat(ix);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("getFloat32At")
        }

    pub def getFloat32Named(x: ##java.sql.ResultSet, label: String): Result[Float32, String] & Impure =
        import java.sql.ResultSet.getFloat(String);
        try {
            let ans = x.getFloat(label);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("getFloat32Named")
        }

    pub def getFloat64At(x: ##java.sql.ResultSet, ix: Int32): Result[Float64, String] & Impure =
        import java.sql.ResultSet.getDouble(Int32);
        try {
            let ans = x.getDouble(ix);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("getFloat64At")
        }

    pub def getFloat64Named(x: ##java.sql.ResultSet, label: String): Result[Float64, String] & Impure =
        import java.sql.ResultSet.getDouble(String);
        try {
            let ans = x.getDouble(label);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("getFloat64Named")
        }


}

