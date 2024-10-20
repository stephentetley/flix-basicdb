/*
 * Copyright 2024 Stephen Tetley
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


mod BasicDb {

    import java.sql.{PreparedStatement => JPreparedStatement}

    pub eff WritePreparedStatement {
        pub def currentPreparedStatement(): JPreparedStatement
        pub def fail(msg: String): Void
    }

}

mod BasicDb.WritePreparedStatement {

    use BasicDb.WritePreparedStatement
    import java.sql.{PreparedStatement => JPreparedStatement}

    pub def run(row: JPreparedStatement, action: Unit -> a \ {WritePreparedStatement, ef}): Result[String, a] \ ef = 
        try {
            Ok(action())
        } with WritePreparedStatement {
            def currentPreparedStatement(k) = {
                k(row)
            }
            def fail(msg, _k) = {
                checked_ecast(Err(msg))
            }
        }


    pub def putWith(f: JPreparedStatement-> Unit \ IO): Unit \ WritePreparedStatement =
        let row = BasicDb.WritePreparedStatement.currentPreparedStatement();
        match Result.tryCatch(_ -> {unsafe f(row)}) {
            case Ok()     => ()
            case Err(msg) => BasicDb.WritePreparedStatement.fail(msg)
        }


    pub def putNullAt(ix: Int32): Unit \ WritePreparedStatement = 
        putWith(ps -> ps.setNull(ix, BasicDb.Internal.Sql.Types.sql_type_null()))

    pub def putStringAt(ix: Int32, str: String): Unit \ WritePreparedStatement =
        putWith(ps -> ps.setString(ix, str))

    pub def putBoolAt(ix: Int32, b: Bool): Unit \ WritePreparedStatement = 
        putWith(ps -> ps.setBoolean(ix, b))

    pub def putInt8At(ix: Int32, n: Int8): Unit \ WritePreparedStatement = 
        putWith(ps -> ps.setByte(ix, n))

    pub def putInt16At(ix: Int32, n: Int16): Unit \ WritePreparedStatement = 
        putWith(ps -> ps.setShort(ix, n))

    pub def putInt32At(ix: Int32, n: Int32): Unit \ WritePreparedStatement = 
        putWith(ps -> ps.setInt(ix, n))

    pub def putInt64At(ix: Int32, n: Int64): Unit \ WritePreparedStatement = 
        putWith(ps -> ps.setLong(ix, n))

    pub def putFloat32At(ix: Int32, n: Float32): Unit \ WritePreparedStatement = 
        putWith(ps -> ps.setFloat(ix, n))

    pub def putFloat64At(ix: Int32, n: Float64): Unit \ WritePreparedStatement = 
        putWith(ps -> ps.setDouble(ix, n))


    pub def putIsoLocalDateStringAt(ix: Int32, d: Time.LocalDate): Unit \ WritePreparedStatement = 
        let fmt = Time.Format.DateTimeFormatter.iso_local_date();
        let s = Time.LocalDate.format(fmt, d);
        putStringAt(ix, s)

    pub def putIsoLocalDateTimeStringAt(ix: Int32, dt: Time.LocalDateTime): Unit \ WritePreparedStatement = 
        let fmt = Time.Format.DateTimeFormatter.iso_local_date_time();
        let s = Time.LocalDateTime.format(fmt, dt);
        putStringAt(ix, s)

    pub def putIsoLocalTimeStringAt(ix: Int32, dt: Time.LocalTime): Unit \ WritePreparedStatement = 
        let fmt = Time.Format.DateTimeFormatter.iso_local_time();
        let s = Time.LocalTime.format(fmt, dt);
        putStringAt(ix, s)

    pub def putOptionStringAt(ix: Int32, x: Option[String]): Unit \ WritePreparedStatement =  
        match x {
            case Some(s) => putStringAt(ix, s)
            case None    => putNullAt(ix)
        }

    pub def putOptionBool(ix: Int32, x: Option[Bool]): Unit \ WritePreparedStatement =  
        match x {
            case Some(b) => putBoolAt(ix, b)
            case None    => putNullAt(ix)
        }

    pub def putOptionInt8At(ix: Int32, x: Option[Int8]): Unit \ WritePreparedStatement =  
        match x {
            case Some(x1) => putInt8At(ix, x1)
            case None     => putNullAt(ix)
        }

    pub def putOptionInt16At(ix: Int32, x: Option[Int16]): Unit \ WritePreparedStatement =  
        match x {
            case Some(x1) => putInt16At(ix, x1)
            case None     => putNullAt(ix)
        }

    pub def putOptionInt32At(ix: Int32, x: Option[Int32]): Unit \ WritePreparedStatement =  
        match x {
            case Some(x1) => putInt32At(ix, x1)
            case None     => putNullAt(ix)
        }

    pub def putOptionInt64At(ix: Int32, x: Option[Int64]): Unit \ WritePreparedStatement =  
        match x {
            case Some(x1) => putInt64At(ix, x1)
            case None     => putNullAt(ix)
        }

    pub def putOptionFloat32At(ix: Int32, x: Option[Float32]): Unit \ WritePreparedStatement =  
        match x {
            case Some(x1) => putFloat32At(ix, x1)
            case None     => putNullAt(ix)
        }

    pub def putOptionFloat64At(ix: Int32, x: Option[Float64]): Unit \ WritePreparedStatement =  
        match x {
            case Some(x1) => putFloat64At(ix, x1)
            case None     => putNullAt(ix)
        }

    pub def putOptionIsoLocalDateStringAt(ix: Int32, x: Option[Time.LocalDate]): Unit \ WritePreparedStatement = 
        match x {
            case Some(x1) => putIsoLocalDateStringAt(ix, x1)
            case None     => putNullAt(ix)
        }

    pub def putOptionIsoLocalDateTimeStringAt(ix: Int32, x: Option[Time.LocalDateTime]): Unit \ WritePreparedStatement = 
        match x {
            case Some(x1) => putIsoLocalDateTimeStringAt(ix, x1)
            case None     => putNullAt(ix)
        }

    pub def putOptionIsoLocalTimeStringAt(ix: Int32, x: Option[Time.LocalTime]): Unit \ WritePreparedStatement = 
        match x {
            case Some(x1) => putIsoLocalTimeStringAt(ix, x1)
            case None     => putNullAt(ix)
        }

}

