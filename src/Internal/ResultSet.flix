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
        import java.sql.ResultSet.close(): Unit & Impure;
        try {
            let ans = close(x);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("close")
        }

    pub def next(x: ##java.sql.ResultSet): Result[Bool, String] & Impure =
        import java.sql.ResultSet.next(): Bool & Impure;
        try {
            let ans = next(x);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("next")
        }

    pub def getStringAt(x: ##java.sql.ResultSet, ix: Int32): Result[String, String] & Impure =
        import java.sql.ResultSet.getString(Int32): String & Impure;
        try {
            let ans = getString(x, ix);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("getStringAt")
        }

    pub def getStringNamed(x: ##java.sql.ResultSet, label: String): Result[String, String] & Impure =
        import java.sql.ResultSet.getString(String): String & Impure;
        try {
            let ans = getString(x, label);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("getStringNamed")
        }

    pub def getBoolAt(x: ##java.sql.ResultSet, ix: Int32): Result[Bool, String] & Impure =
        import java.sql.ResultSet.getBoolean(Int32): Bool & Impure;
        try {
            let ans = getBoolean(x, ix);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("getBoolAt")
        }

    pub def getBoolNamed(x: ##java.sql.ResultSet, label: String): Result[Bool, String] & Impure =
        import java.sql.ResultSet.getBoolean(String): Bool & Impure;
        try {
            let ans = getBoolean(x, label);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("getBoolNamed")
        }

    pub def getInt8At(x: ##java.sql.ResultSet, ix: Int32): Result[Int8, String] & Impure =
        import java.sql.ResultSet.getByte(Int32): Int8 & Impure;
        try {
            let ans = getByte(x, ix);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("getInt8At")
        }

    pub def getInt8Named(x: ##java.sql.ResultSet, label: String): Result[Int8, String] & Impure =
        import java.sql.ResultSet.getByte(String): Int8 & Impure;
        try {
            let ans = getByte(x, label);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("getInt8Named")
        }

    pub def getInt16At(x: ##java.sql.ResultSet, ix: Int32): Result[Int16, String] & Impure =
        import java.sql.ResultSet.getShort(Int32): Int16 & Impure;
        try {
            let ans = getShort(x, ix);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("getInt16At")
        }

    pub def getInt16Named(x: ##java.sql.ResultSet, label: String): Result[Int16, String] & Impure =
        import java.sql.ResultSet.getShort(String): Int16 & Impure;
        try {
            let ans = getShort(x, label);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("getInt16Named")
        }

    pub def getInt32At(x: ##java.sql.ResultSet, ix: Int32): Result[Int32, String] & Impure =
        import java.sql.ResultSet.getInt(Int32): Int32 & Impure;
        try {
            let ans = getInt(x, ix);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("getInt32At")
        }

    pub def getInt32Named(x: ##java.sql.ResultSet, label: String): Result[Int32, String] & Impure =
        import java.sql.ResultSet.getInt(String): Int32 & Impure;
        try {
            let ans = getInt(x, label);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("getInt32Named")
        }

    pub def getInt64At(x: ##java.sql.ResultSet, ix: Int32): Result[Int64, String] & Impure =
        import java.sql.ResultSet.getLong(Int32): Int64 & Impure;
        try {
            let ans = getLong(x, ix);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("getInt64At")
        }

    pub def getInt64Named(x: ##java.sql.ResultSet, label: String): Result[Int64, String] & Impure =
        import java.sql.ResultSet.getLong(String): Int64 & Impure;
        try {
            let ans = getLong(x, label);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("getInt64Named")
        }

    pub def getFloat32At(x: ##java.sql.ResultSet, ix: Int32): Result[Float32, String] & Impure =
        import java.sql.ResultSet.getFloat(Int32): Float32 & Impure;
        try {
            let ans = getFloat(x, ix);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("getFloat32At")
        }

    pub def getFloat32Named(x: ##java.sql.ResultSet, label: String): Result[Float32, String] & Impure =
        import java.sql.ResultSet.getFloat(String): Float32 & Impure;
        try {
            let ans = getFloat(x, label);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("getFloat32Named")
        }

    pub def getFloat64At(x: ##java.sql.ResultSet, ix: Int32): Result[Float64, String] & Impure =
        import java.sql.ResultSet.getDouble(Int32): Float64 & Impure;
        try {
            let ans = getDouble(x, ix);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("getFloat64At")
        }

    pub def getFloat64Named(x: ##java.sql.ResultSet, label: String): Result[Float64, String] & Impure =
        import java.sql.ResultSet.getDouble(String): Float64 & Impure;
        try {
            let ans = getDouble(x, label);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("getFloat64Named")
        }


}

