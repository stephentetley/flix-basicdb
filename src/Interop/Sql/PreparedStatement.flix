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

    pub enum PreparedStatement[_: Region](##java.sql.PreparedStatement)


}

mod Interop.Sql.PreparedStatement {

    use Interop.Sql.PreparedStatement;
    use Interop.Sql.PreparedStatement.{PreparedStatement};
    use Interop.Sql.ResultSet;
    use Interop.Sql.ResultSet.{ResultSet};


    pub def getHH(stmt: PreparedStatement[r]): ##java.sql.PreparedStatement =
        let PreparedStatement(stmt1) = stmt;
        stmt1

    pub def clearParameters!(stmt: PreparedStatement[r]): Result[String, Unit] \ Write(r) =
        Result.tryCatch(_ -> {
            import java.sql.PreparedStatement.clearParameters(): Unit \ r;
            let PreparedStatement(stmt1) = stmt;
            clearParameters(stmt1)
        })


    pub def executeQuery!(stmt: PreparedStatement[r]): Result[String, ResultSet[r]] \ { Write(r), IO } =
        Result.tryCatch(_ -> {
            import java.sql.PreparedStatement.executeQuery(): ##java.sql.ResultSet \ {r, IO};
            let PreparedStatement(stmt1) = stmt;
            executeQuery(stmt1) |> ResultSet
        })

    pub def executeUpdate!(stmt: PreparedStatement[r]): Result[String, Int32] \ { Write(r), IO } =
        Result.tryCatch(_ -> {
            import java.sql.PreparedStatement.executeUpdate(): Int32 \ {r, IO};
            let PreparedStatement(stmt1) = stmt;
            executeUpdate(stmt1)
        })



    pub def setNull!(ix: Int32, sqlType: Int32, stmt: PreparedStatement[r]): Result[String, Unit] \ Write(r) =
        Result.tryCatch(_ -> {
            import java.sql.PreparedStatement.setNull(Int32, Int32): Unit \ r;
            let PreparedStatement(stmt1) = stmt;
            setNull(stmt1, ix, sqlType)
        })

    pub def setString!(ix: Int32, str: String, stmt: PreparedStatement[r]): Result[String, Unit] \ Write(r) =
        Result.tryCatch(_ -> {
            import java.sql.PreparedStatement.setString(Int32, String): Unit \ r;
            let PreparedStatement(stmt1) = stmt;
            setString(stmt1, ix, str)
        })

    pub def setBool!(ix: Int32, b: Bool, stmt: PreparedStatement[r]): Result[String, Unit] \ Write(r) =
        Result.tryCatch(_ -> {
            import java.sql.PreparedStatement.setBoolean(Int32, Bool): Unit \ r;
            let PreparedStatement(stmt1) = stmt;
            setBoolean(stmt1, ix, b)
        })

    pub def setInt8!(ix: Int32, n: Int8, stmt: PreparedStatement[r]): Result[String, Unit] \ Write(r) =
        Result.tryCatch(_ -> {
            import java.sql.PreparedStatement.setByte(Int32, Int8): Unit \ r;
            let PreparedStatement(stmt1) = stmt;
            setByte(stmt1, ix, n)
        })

    pub def setInt16!(ix: Int32, n: Int16, stmt: PreparedStatement[r]): Result[String, Unit] \ Write(r) =
        Result.tryCatch(_ -> {
            import java.sql.PreparedStatement.setShort(Int32, Int16): Unit \ r;
            let PreparedStatement(stmt1) = stmt;
            setShort(stmt1, ix, n)
        })

    pub def setInt32!(ix: Int32, n: Int32, stmt: PreparedStatement[r]): Result[String, Unit] \ Write(r) =
        Result.tryCatch(_ -> {
            import java.sql.PreparedStatement.setInt(Int32, Int32): Unit \ r;        
            let PreparedStatement(stmt1) = stmt;
            setInt(stmt1, ix, n)
        })

    pub def setInt64!(ix: Int32, n: Int64, stmt: PreparedStatement[r]): Result[String, Unit] \ Write(r) =
        Result.tryCatch(_ -> {
            import java.sql.PreparedStatement.setLong(Int32, Int64): Unit \ r;
            let PreparedStatement(stmt1) = stmt;
            setLong(stmt1, ix, n)
        })

    pub def setFloat32!(ix: Int32, d: Float32, stmt: PreparedStatement[r]): Result[String, Unit] \ Write(r) =
        Result.tryCatch(_ -> {
            import java.sql.PreparedStatement.setFloat(Int32, Float32): Unit \ r;
            let PreparedStatement(stmt1) = stmt;
            setFloat(stmt1, ix, d)
        })

    pub def setFloat64!(ix: Int32, d: Float64, stmt: PreparedStatement[r]): Result[String, Unit] \ Write(r) =
        Result.tryCatch(_ -> {
            import java.sql.PreparedStatement.setDouble(Int32, Float64): Unit \ r;
            let PreparedStatement(stmt1) = stmt;
            setDouble(stmt1, ix, d)
        })

}

