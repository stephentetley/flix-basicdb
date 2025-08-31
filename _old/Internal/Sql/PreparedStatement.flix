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

    import java.sql.{PreparedStatement => JPreparedStatement}

    /// Mutable

    pub enum PreparedStatement[_: Region](JPreparedStatement)


}

mod BasicDb.Internal.Sql.PreparedStatement {

    use BasicDb.Internal.Sql.PreparedStatement
    use BasicDb.Internal.Sql.ResultSet
    use BasicDb.Internal.Sql.ResultSet.ResultSet



    pub def clearParameters(stmt: PreparedStatement[r]): Result[String, Unit] \ IO + r =
        Result.tryCatch(_ -> {
            let PreparedStatement(stmt1) = stmt;
            checked_ecast(stmt1.clearParameters())
        })


    pub def executeQuery(_: Region[r1], stmt: PreparedStatement[r]): Result[String, ResultSet[r1]] \ {IO, r, r1} =
        Result.tryCatch(_ -> {
            let PreparedStatement(stmt1) = stmt;
            let rs1 = unchecked_cast(stmt1.executeQuery() as _ \ r1);
            checked_ecast(ResultSet(rs1))
        })

    pub def executeUpdate(stmt: PreparedStatement[r]): Result[String, Int32] \ {IO, r} =
        Result.tryCatch(_ -> {
            let PreparedStatement(stmt1) = stmt;
            checked_ecast(stmt1.executeUpdate())
        })



    pub def setNull(ix: Int32, sqlType: Int32, stmt: PreparedStatement[r]): Result[String, Unit] \ IO + r =
        Result.tryCatch(_ -> {
            let PreparedStatement(stmt1) = stmt;
            checked_ecast(stmt1.setNull(ix, sqlType))
        })

    pub def setString(ix: Int32, str: String, stmt: PreparedStatement[r]): Result[String, Unit] \ IO + r =
        Result.tryCatch(_ -> {
            let PreparedStatement(stmt1) = stmt;
            checked_ecast(stmt1.setString(ix, str))
        })

    pub def setBool(ix: Int32, b: Bool, stmt: PreparedStatement[r]): Result[String, Unit] \ IO + r =
        Result.tryCatch(_ -> {
            let PreparedStatement(stmt1) = stmt;
            checked_ecast(stmt1.setBoolean(ix, b))
        })

    pub def setInt8(ix: Int32, n: Int8, stmt: PreparedStatement[r]): Result[String, Unit] \ IO + r =
        Result.tryCatch(_ -> {
            let PreparedStatement(stmt1) = stmt;
            checked_ecast(stmt1.setByte(ix, n))
        })

    pub def setInt16(ix: Int32, n: Int16, stmt: PreparedStatement[r]): Result[String, Unit] \ IO + r =
        Result.tryCatch(_ -> {
            let PreparedStatement(stmt1) = stmt;
            checked_ecast(stmt1.setShort(ix, n))
        })

    pub def setInt32(ix: Int32, n: Int32, stmt: PreparedStatement[r]): Result[String, Unit] \ IO + r =
        Result.tryCatch(_ -> {
            let PreparedStatement(stmt1) = stmt;
            checked_ecast(stmt1.setInt(ix, n))
        })

    pub def setInt64(ix: Int32, n: Int64, stmt: PreparedStatement[r]): Result[String, Unit] \ IO + r =
        Result.tryCatch(_ -> {
            let PreparedStatement(stmt1) = stmt;
            checked_ecast(stmt1.setLong(ix, n))
        })

    pub def setFloat32(ix: Int32, d: Float32, stmt: PreparedStatement[r]): Result[String, Unit] \ IO + r =
        Result.tryCatch(_ -> {
            let PreparedStatement(stmt1) = stmt;
            checked_ecast(stmt1.setFloat(ix, d))
        })

    pub def setFloat64(ix: Int32, d: Float64, stmt: PreparedStatement[r]): Result[String, Unit] \ IO + r =
        Result.tryCatch(_ -> {
            let PreparedStatement(stmt1) = stmt;
            checked_ecast(stmt1.setDouble(ix, d))
        })

}

