/*
 * Copyright 2022 Stephen Tetley
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

namespace Interop/Sql {

    /// Mutable

    pub enum ResultSet[_: Region](##java.sql.ResultSet)

    instance Scoped[ResultSet] {
        pub def regionOf(_: ResultSet[r]): Region[r] = () as Region[r]
    }

}

namespace Interop/Sql/ResultSet {

    use Interop/Sql.ResultSet;
    use Interop/Sql.ResultSet.{ResultSet};


    pub def getHH(rs: ResultSet[r]): ##java.sql.ResultSet =
        let ResultSet(rs1) = rs;
        rs1

    pub def close!(rs: ResultSet[r]): Result[Unit, String] \ Write(r) =
        try {
            import java.sql.ResultSet.close(): Unit \ r;
            let ResultSet(rs1) = rs;
            let ans = close(rs1);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def next(rs: ResultSet[r]): Result[Bool, String] \ Write(r) =
        try {
            import java.sql.ResultSet.next(): Bool \ r;
            let ResultSet(rs1) = rs;
            let ans = next(rs1);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def getStringAt(ix: Int32, rs: ResultSet[r]): Result[String, String] \ Read(r) =
        try {
            import java.sql.ResultSet.getString(Int32): String \ r;
            let ResultSet(rs1) = rs;
            let ans = getString(rs1, ix);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def getStringNamed(label: String, rs: ResultSet[r]): Result[String, String] \ Read(r) =
        try {
            import java.sql.ResultSet.getString(String): String \ r;
            let ResultSet(rs1) = rs;
            let ans = getString(rs1, label);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def getBoolAt(ix: Int32, rs: ResultSet[r]): Result[Bool, String] \ Read(r) =
        try {
            import java.sql.ResultSet.getBoolean(Int32): Bool \ r;
            let ResultSet(rs1) = rs;
            let ans = getBoolean(rs1, ix);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def getBoolNamed(label: String, rs: ResultSet[r]): Result[Bool, String] \ Read(r) =
        try {
            import java.sql.ResultSet.getBoolean(String): Bool \ r;
            let ResultSet(rs1) = rs;
            let ans = getBoolean(rs1, label);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def getInt8At(ix: Int32, rs: ResultSet[r]): Result[Int8, String] \ Read(r) =
        try {
            import java.sql.ResultSet.getByte(Int32): Int8 \ r;
            let ResultSet(rs1) = rs;
            let ans = getByte(rs1, ix);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def getInt8Named(label: String, rs: ResultSet[r]): Result[Int8, String] \ Read(r) =
        try {
            import java.sql.ResultSet.getByte(String): Int8 \ r;
            let ResultSet(rs1) = rs;
            let ans = getByte(rs1, label);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def getInt16At(ix: Int32, rs: ResultSet[r]): Result[Int16, String] \ Read(r) =
        try {
            import java.sql.ResultSet.getShort(Int32): Int16 \ r;
            let ResultSet(rs1) = rs;
            let ans = getShort(rs1, ix);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def getInt16Named(label: String, rs: ResultSet[r]): Result[Int16, String] \ Read(r) =
        try {
            import java.sql.ResultSet.getShort(String): Int16 \ r;
            let ResultSet(rs1) = rs;
            let ans = getShort(rs1, label);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def getInt32At(ix: Int32, rs: ResultSet[r]): Result[Int32, String] \ Read(r) =
        try {
            import java.sql.ResultSet.getInt(Int32): Int32 \ r;
            let ResultSet(rs1) = rs;
            let ans = getInt(rs1, ix);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def getInt32Named(label: String, rs: ResultSet[r]): Result[Int32, String] \ Read(r) =
        try {
            import java.sql.ResultSet.getInt(String): Int32 \ r;
            let ResultSet(rs1) = rs;
            let ans = getInt(rs1, label);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def getInt64At(ix: Int32, rs: ResultSet[r]): Result[Int64, String] \ Read(r) =
        try {
            import java.sql.ResultSet.getLong(Int32): Int64 \ r;
            let ResultSet(rs1) = rs;
            let ans = getLong(rs1, ix);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def getInt64Named(label: String, rs: ResultSet[r]): Result[Int64, String] \ Read(r) =
        try {
            import java.sql.ResultSet.getLong(String): Int64 \ r;
            let ResultSet(rs1) = rs;
            let ans = getLong(rs1, label);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def getFloat32At(ix: Int32, rs: ResultSet[r]): Result[Float32, String] \ Read(r) =
        try {
            import java.sql.ResultSet.getFloat(Int32): Float32 \ r;
            let ResultSet(rs1) = rs;
            let ans = getFloat(rs1, ix);
            Ok(ans)
        } catch {
            case _: ##java.sql.SQLException => Err("getFloat32At")
        }

    pub def getFloat32Named(label: String, rs: ResultSet[r]): Result[Float32, String] \ Read(r) =
        try {
            import java.sql.ResultSet.getFloat(String): Float32 \ r;
            let ResultSet(rs1) = rs;
            let ans = getFloat(rs1, label);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def getFloat64At(ix: Int32, rs: ResultSet[r]): Result[Float64, String] \ Read(r) =
        try {
            import java.sql.ResultSet.getDouble(Int32): Float64 \ r;
            let ResultSet(rs1) = rs;
            let ans = getDouble(rs1, ix);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }

    pub def getFloat64Named(label: String, rs: ResultSet[r]): Result[Float64, String] \ Read(r) =
        try {
            import java.sql.ResultSet.getDouble(String): Float64 \ r;
            let ResultSet(rs1) = rs;
            let ans = getDouble(rs1, label);
            Ok(ans)
        } catch {
            case ex: ##java.lang.Exception => 
                import java.lang.Throwable.getMessage(): String \ r;                
                Err(getMessage(ex))
        }


}

