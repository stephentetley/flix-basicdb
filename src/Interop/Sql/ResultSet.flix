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

mod Interop.Sql {

    /// Mutable

    pub enum ResultSet[_: Region](##java.sql.ResultSet)


}

mod Interop.Sql.ResultSet {

    use Interop.Sql.ResultSet;
    use Interop.Sql.ResultSet.{ResultSet};


    pub def getHH(rs: ResultSet[r]): ##java.sql.ResultSet =
        let ResultSet(rs1) = rs;
        rs1

    pub def close!(rs: ResultSet[r]): Result[String, Unit] \ Write(r) =
        Result.tryCatch(_ -> {
            import java.sql.ResultSet.close(): Unit \ r;
            let ResultSet(rs1) = rs;
            close(rs1)
        })

    pub def next!(rs: ResultSet[r]): Result[String, Bool] \ Write(r) =
        Result.tryCatch(_ -> {
            import java.sql.ResultSet.next(): Bool \ r;
            let ResultSet(rs1) = rs;
            next(rs1)
        })

    pub def getStringAt(ix: Int32, rs: ResultSet[r]): Result[String, String] \ Read(r) =
        Result.tryCatch(_ -> {
            import java.sql.ResultSet.getString(Int32): String \ r;
            let ResultSet(rs1) = rs;
            getString(rs1, ix)
        })

    pub def getStringNamed(label: String, rs: ResultSet[r]): Result[String, String] \ Read(r) =
        Result.tryCatch(_ -> {
            import java.sql.ResultSet.getString(String): String \ r;
            let ResultSet(rs1) = rs;
            getString(rs1, label)
        })

    pub def getBoolAt(ix: Int32, rs: ResultSet[r]): Result[String, Bool] \ Read(r) =
        Result.tryCatch(_ -> {
            import java.sql.ResultSet.getBoolean(Int32): Bool \ r;
            let ResultSet(rs1) = rs;
            getBoolean(rs1, ix)
        })

    pub def getBoolNamed(label: String, rs: ResultSet[r]): Result[String, Bool] \ Read(r) =
        Result.tryCatch(_ -> {
            import java.sql.ResultSet.getBoolean(String): Bool \ r;
            let ResultSet(rs1) = rs;
            getBoolean(rs1, label)
        })

    pub def getInt8At(ix: Int32, rs: ResultSet[r]): Result[String, Int8] \ Read(r) =
        Result.tryCatch(_ -> {
            import java.sql.ResultSet.getByte(Int32): Int8 \ r;
            let ResultSet(rs1) = rs;
            getByte(rs1, ix)
        })

    pub def getInt8Named(label: String, rs: ResultSet[r]): Result[String, Int8] \ Read(r) =
        Result.tryCatch(_ -> {
            import java.sql.ResultSet.getByte(String): Int8 \ r;
            let ResultSet(rs1) = rs;
            getByte(rs1, label)
        })

    pub def getInt16At(ix: Int32, rs: ResultSet[r]): Result[String, Int16] \ Read(r) =
        Result.tryCatch(_ -> {
            import java.sql.ResultSet.getShort(Int32): Int16 \ r;
            let ResultSet(rs1) = rs;
            getShort(rs1, ix)
        })

    pub def getInt16Named(label: String, rs: ResultSet[r]): Result[String, Int16] \ Read(r) =
        Result.tryCatch(_ -> {
            import java.sql.ResultSet.getShort(String): Int16 \ r;
            let ResultSet(rs1) = rs;
            getShort(rs1, label)
        })

    pub def getInt32At(ix: Int32, rs: ResultSet[r]): Result[String, Int32] \ Read(r) =
        Result.tryCatch(_ -> {
            import java.sql.ResultSet.getInt(Int32): Int32 \ r;
            let ResultSet(rs1) = rs;
            getInt(rs1, ix)
        })

    pub def getInt32Named(label: String, rs: ResultSet[r]): Result[String, Int32] \ Read(r) =
        Result.tryCatch(_ -> {
            import java.sql.ResultSet.getInt(String): Int32 \ r;
            let ResultSet(rs1) = rs;
            getInt(rs1, label)
        })

    pub def getInt64At(ix: Int32, rs: ResultSet[r]): Result[String, Int64] \ Read(r) =
        Result.tryCatch(_ -> {
            import java.sql.ResultSet.getLong(Int32): Int64 \ r;
            let ResultSet(rs1) = rs;
            getLong(rs1, ix)
        })

    pub def getInt64Named(label: String, rs: ResultSet[r]): Result[String, Int64] \ Read(r) =
        Result.tryCatch(_ -> {
            import java.sql.ResultSet.getLong(String): Int64 \ r;
            let ResultSet(rs1) = rs;
            getLong(rs1, label)
        })

    pub def getFloat32At(ix: Int32, rs: ResultSet[r]): Result[String, Float32] \ Read(r) =
        Result.tryCatch(_ -> {
            import java.sql.ResultSet.getFloat(Int32): Float32 \ r;
            let ResultSet(rs1) = rs;
            getFloat(rs1, ix)
        })

    pub def getFloat32Named(label: String, rs: ResultSet[r]): Result[String, Float32] \ Read(r) =
        Result.tryCatch(_ -> {
            import java.sql.ResultSet.getFloat(String): Float32 \ r;
            let ResultSet(rs1) = rs;
            getFloat(rs1, label)
        })

    pub def getFloat64At(ix: Int32, rs: ResultSet[r]): Result[String, Float64] \ Read(r) =
        Result.tryCatch(_ -> {
            import java.sql.ResultSet.getDouble(Int32): Float64 \ r;
            let ResultSet(rs1) = rs;
            getDouble(rs1, ix)
        })

    pub def getFloat64Named(label: String, rs: ResultSet[r]): Result[String, Float64] \ Read(r) =
        Result.tryCatch(_ -> {
            import java.sql.ResultSet.getDouble(String): Float64 \ r;
            let ResultSet(rs1) = rs;
            getDouble(rs1, label)
        })


}

