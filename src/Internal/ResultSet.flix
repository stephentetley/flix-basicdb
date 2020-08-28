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




namespace BasicDb/Internal/ResultSet {

    pub def close(x: ##java.sql.ResultSet): Result[Unit, System.Error] & Impure =
        import java.sql.ResultSet.close();
        try {
            let ans = x.close();
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err(Generic("ResultSet.close"))
        }

    pub def next(x: ##java.sql.ResultSet): Result[Bool, System.Error] & Impure =
        import java.sql.ResultSet.next();
        try {
            let ans = x.next();
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err(Generic("ResultSet.close"))
        }

    pub def getString(x: ##java.sql.ResultSet, ix: Int32): Result[String, System.Error] & Impure =
        import java.sql.ResultSet.getString(Int32);
        try {
            let ans = x.getString(ix);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err(Generic("ResultSet.getString"))
        }

    pub def getBool(x: ##java.sql.ResultSet, ix: Int32): Result[Bool, System.Error] & Impure =
        import java.sql.ResultSet.getBoolean(Int32);
        try {
            let ans = x.getBoolean(ix);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err(Generic("ResultSet.getBool"))
        }

    pub def getInt8(x: ##java.sql.ResultSet, ix: Int32): Result[Int8, System.Error] & Impure =
        import java.sql.ResultSet.getByte(Int32);
        try {
            let ans = x.getByte(ix);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err(Generic("ResultSet.getInt8"))
        }

    pub def getInt16(x: ##java.sql.ResultSet, ix: Int32): Result[Int16, System.Error] & Impure =
        import java.sql.ResultSet.getShort(Int32);
        try {
            let ans = x.getShort(ix);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err(Generic("ResultSet.getInt16"))
        }

    pub def getInt32(x: ##java.sql.ResultSet, ix: Int32): Result[Int32, System.Error] & Impure =
        import java.sql.ResultSet.getInt(Int32);
        try {
            let ans = x.getInt(ix);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err(Generic("ResultSet.getInt32"))
        }

    pub def getInt64(x: ##java.sql.ResultSet, ix: Int32): Result[Int64, System.Error] & Impure =
        import java.sql.ResultSet.getLong(Int32);
        try {
            let ans = x.getLong(ix);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err(Generic("ResultSet.getInt64"))
        }

    pub def getFloat32(x: ##java.sql.ResultSet, ix: Int32): Result[Float32, System.Error] & Impure =
        import java.sql.ResultSet.getFloat(Int32);
        try {
            let ans = x.getFloat(ix);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err(Generic("ResultSet.getFloat32"))
        }

    pub def getFloat64(x: ##java.sql.ResultSet, ix: Int32): Result[Float64, System.Error] & Impure =
        import java.sql.ResultSet.getDouble(Int32);
        try {
            let ans = x.getDouble(ix);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err(Generic("ResultSet.getFloat64"))
        }




}

