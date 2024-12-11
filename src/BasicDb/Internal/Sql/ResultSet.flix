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

mod BasicDb.Internal.Sql {

    import java.sql.{ResultSet => JResultSet}

    /// Mutable

    pub enum ResultSet[_: Region](JResultSet)


}

mod BasicDb.Internal.Sql.ResultSet {

    use BasicDb.Internal.Sql.ResultSet



    pub def close(rs: ResultSet[r]): Result[String, Unit] \ IO + r =
        Result.tryCatch(_ -> {
            let ResultSet(rs1) = rs;
            checked_ecast(rs1.close())
        })

    pub def next(rs: ResultSet[r]): Result[String, Bool] \ IO + r =
        Result.tryCatch(_ -> {
            let ResultSet(rs1) = rs;
            checked_ecast(rs1.next())
        })

    pub def getStringAt(ix: Int32, rs: ResultSet[r]): Result[String, String] \ IO + r =
        Result.tryCatch(_ -> {
            let ResultSet(rs1) = rs;
            checked_ecast(rs1.getString(ix))
        })

    pub def getStringNamed(label: String, rs: ResultSet[r]): Result[String, String] \ IO + r =
        Result.tryCatch(_ -> {
            let ResultSet(rs1) = rs;
            checked_ecast(rs1.getString(label))
        })

    pub def getBoolAt(ix: Int32, rs: ResultSet[r]): Result[String, Bool] \ IO + r =
        Result.tryCatch(_ -> {
            let ResultSet(rs1) = rs;
            checked_ecast(rs1.getBoolean(ix))
        })

    pub def getBoolNamed(label: String, rs: ResultSet[r]): Result[String, Bool] \ IO + r =
        Result.tryCatch(_ -> {
            let ResultSet(rs1) = rs;
            checked_ecast(rs1.getBoolean(label))
        })

    pub def getInt8At(ix: Int32, rs: ResultSet[r]): Result[String, Int8] \ IO + r =
        Result.tryCatch(_ -> {
            let ResultSet(rs1) = rs;
            checked_ecast(rs1.getByte(ix))
        })

    pub def getInt8Named(label: String, rs: ResultSet[r]): Result[String, Int8] \ IO + r =
        Result.tryCatch(_ -> {
            let ResultSet(rs1) = rs;
            checked_ecast(rs1.getByte(label))
        })

    pub def getInt16At(ix: Int32, rs: ResultSet[r]): Result[String, Int16] \ IO + r =
        Result.tryCatch(_ -> {
            let ResultSet(rs1) = rs;
            checked_ecast(rs1.getShort(ix))
        })

    pub def getInt16Named(label: String, rs: ResultSet[r]): Result[String, Int16] \ IO + r =
        Result.tryCatch(_ -> {
            let ResultSet(rs1) = rs;
            checked_ecast(rs1.getShort(label))
        })

    pub def getInt32At(ix: Int32, rs: ResultSet[r]): Result[String, Int32] \ IO + r =
        Result.tryCatch(_ -> {
            let ResultSet(rs1) = rs;
            checked_ecast(rs1.getInt(ix))
        })

    pub def getInt32Named(label: String, rs: ResultSet[r]): Result[String, Int32] \ IO + r =
        Result.tryCatch(_ -> {
            let ResultSet(rs1) = rs;
            checked_ecast(rs1.getInt(label))
        })

    pub def getInt64At(ix: Int32, rs: ResultSet[r]): Result[String, Int64] \ IO + r =
        Result.tryCatch(_ -> {
            let ResultSet(rs1) = rs;
            checked_ecast(rs1.getLong(ix))
        })

    pub def getInt64Named(label: String, rs: ResultSet[r]): Result[String, Int64] \ IO + r =
        Result.tryCatch(_ -> {
            let ResultSet(rs1) = rs;
            checked_ecast(rs1.getLong(label))
        })

    pub def getFloat32At(ix: Int32, rs: ResultSet[r]): Result[String, Float32] \ IO + r =
        Result.tryCatch(_ -> {
            let ResultSet(rs1) = rs;
            checked_ecast(rs1.getFloat(ix))
        })

    pub def getFloat32Named(label: String, rs: ResultSet[r]): Result[String, Float32] \ IO + r =
        Result.tryCatch(_ -> {
            let ResultSet(rs1) = rs;
            checked_ecast(rs1.getFloat(label))
        })

    pub def getFloat64At(ix: Int32, rs: ResultSet[r]): Result[String, Float64] \ IO + r =
        Result.tryCatch(_ -> {
            let ResultSet(rs1) = rs;
            checked_ecast(rs1.getDouble(ix))
        })

    pub def getFloat64Named(label: String, rs: ResultSet[r]): Result[String, Float64] \ IO + r =
        Result.tryCatch(_ -> {
            let ResultSet(rs1) = rs;
            checked_ecast(rs1.getDouble(label))
        })


}

