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

    pub def close(_: Region[r], x: ##java.sql.ResultSet): Result[Unit, String] \ Write(r) =
        import java.sql.ResultSet.close(): Unit \ r;
        try {
            let ans = close(x);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def next(_: Region[r], x: ##java.sql.ResultSet): Result[Bool, String] \ Write(r) =
        import java.sql.ResultSet.next(): Bool \ r;
        try {
            let ans = next(x);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def getStringAt(_: Region[r], ix: Int32, x: ##java.sql.ResultSet): Result[String, String] \ Read(r) =
        import java.sql.ResultSet.getString(Int32): String \ r;
        try {
            let ans = getString(x, ix);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def getStringNamed(_: Region[r], label: String, x: ##java.sql.ResultSet): Result[String, String] \ Read(r) =
        import java.sql.ResultSet.getString(String): String \ r;
        try {
            let ans = getString(x, label);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def getBoolAt(_: Region[r], ix: Int32, x: ##java.sql.ResultSet): Result[Bool, String] \ Read(r) =
        import java.sql.ResultSet.getBoolean(Int32): Bool \ r;
        try {
            let ans = getBoolean(x, ix);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def getBoolNamed(_: Region[r], label: String, x: ##java.sql.ResultSet): Result[Bool, String] \ Read(r) =
        import java.sql.ResultSet.getBoolean(String): Bool \ r;
        try {
            let ans = getBoolean(x, label);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def getInt8At(_: Region[r], ix: Int32, x: ##java.sql.ResultSet): Result[Int8, String] \ Read(r) =
        import java.sql.ResultSet.getByte(Int32): Int8 \ r;
        try {
            let ans = getByte(x, ix);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def getInt8Named(_: Region[r], label: String, x: ##java.sql.ResultSet): Result[Int8, String] \ Read(r) =
        import java.sql.ResultSet.getByte(String): Int8 \ r;
        try {
            let ans = getByte(x, label);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def getInt16At(_: Region[r], ix: Int32, x: ##java.sql.ResultSet): Result[Int16, String] \ Read(r) =
        import java.sql.ResultSet.getShort(Int32): Int16 \ r;
        try {
            let ans = getShort(x, ix);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def getInt16Named(_: Region[r], label: String, x: ##java.sql.ResultSet): Result[Int16, String] \ Read(r) =
        import java.sql.ResultSet.getShort(String): Int16 \ r;
        try {
            let ans = getShort(x, label);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def getInt32At(_: Region[r], ix: Int32, x: ##java.sql.ResultSet): Result[Int32, String] \ Read(r) =
        import java.sql.ResultSet.getInt(Int32): Int32 \ r;
        try {
            let ans = getInt(x, ix);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def getInt32Named(_: Region[r], label: String, x: ##java.sql.ResultSet): Result[Int32, String] \ Read(r) =
        import java.sql.ResultSet.getInt(String): Int32 \ r;
        try {
            let ans = getInt(x, label);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def getInt64At(_: Region[r], ix: Int32, x: ##java.sql.ResultSet): Result[Int64, String] \ Read(r) =
        import java.sql.ResultSet.getLong(Int32): Int64 \ r;
        try {
            let ans = getLong(x, ix);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def getInt64Named(_: Region[r], label: String, x: ##java.sql.ResultSet): Result[Int64, String] \ Read(r) =
        import java.sql.ResultSet.getLong(String): Int64 \ r;
        try {
            let ans = getLong(x, label);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def getFloat32At(_: Region[r], ix: Int32, x: ##java.sql.ResultSet): Result[Float32, String] \ Read(r) =
        import java.sql.ResultSet.getFloat(Int32): Float32 \ r;
        try {
            let ans = getFloat(x, ix);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("getFloat32At")
        }

    pub def getFloat32Named(_: Region[r], label: String, x: ##java.sql.ResultSet): Result[Float32, String] \ Read(r) =
        import java.sql.ResultSet.getFloat(String): Float32 \ r;
        try {
            let ans = getFloat(x, label);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def getFloat64At(_: Region[r], ix: Int32, x: ##java.sql.ResultSet): Result[Float64, String] \ Read(r) =
        import java.sql.ResultSet.getDouble(Int32): Float64 \ r;
        try {
            let ans = getDouble(x, ix);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def getFloat64Named(_: Region[r], label: String, x: ##java.sql.ResultSet): Result[Float64, String] \ Read(r) =
        import java.sql.ResultSet.getDouble(String): Float64 \ r;
        try {
            let ans = getDouble(x, label);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }


}

