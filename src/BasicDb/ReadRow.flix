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
    
    import java.sql.{ResultSet => JResultSet}

    pub eff ReadRow {
        pub def currentRow(): JResultSet
        pub def fail(msg: String): Void
    }



}

mod BasicDb.ReadRow {

    use BasicDb.ReadRow
    import java.sql.{ResultSet => JResultSet}



    pub def run(row: JResultSet, action: Unit -> a \ {ReadRow, ef}): Result[String, a] \ ef = 
        try {
            Ok(action())
        } with ReadRow {
            def currentRow(k) = {
                k(row)
            }
            def fail(msg, _k) = {
                checked_ecast(Err(msg))
            }
        }



    pub def optional(p: Unit -> a \ {ReadRow, ef}): Option[a] \ {ReadRow, ef} = 
        let row = do BasicDb.ReadRow.currentRow();
        match run(row, p) {
            case Ok(a)  => Some(a)
            case Err(_) => None
        }

    pub def alt(p: Unit -> a \ {ReadRow, ef}, q: Unit -> a \ {ReadRow, ef}): a \ {ReadRow, ef} = 
        let row = do BasicDb.ReadRow.currentRow();
        match run(row, p) {
            case Ok(a) => a
            case Err(_) => match run(row, q) {
                case Ok(a) => a
                case Err(_) => do BasicDb.ReadRow.fail("alt")
            }
        }


    pub def liftResult(x: Result[String, a]): a \ ReadRow = match x { 
        case Ok(x1)   => x1
        case Err(msg) => do BasicDb.ReadRow.fail(msg)
    }


    // Note - the Java.Sql's getX functions index from 1.

    pub def withRow(f: JResultSet -> a \ IO): a \ ReadRow =
        let row = do BasicDb.ReadRow.currentRow();
        match Result.tryCatch(_ -> {unsafe f(row)}) {
            case Ok(a)    => a
            case Err(msg) => do BasicDb.ReadRow.fail(msg)
        }

    /// This is "null safe" - if the internal result is null it is converted to the empty String.
    pub def getStringAt(ix: Int32): String \ ReadRow =
        let s = withRow(row -> row.getString(ix));
        if (Object.isNull(s)) "" else s

    /// This is "null safe" - if the internal result is null it is converted to the empty String.
    pub def getStringNamed(label: String): String \ ReadRow =
        let s = withRow(row -> row.getString(label));
        if (Object.isNull(s)) "" else s


    // // See Javadocs for how a bool value is interpreted...
    pub def getBoolAt(ix: Int32): Bool \ ReadRow =
        withRow(row -> row.getBoolean(ix))

    // // See Javadocs for how a bool value is interpreted...
    pub def getBoolNamed(label: String): Bool \ ReadRow =
        withRow(row -> row.getBoolean(label))

    pub def getInt8At(ix: Int32): Int8 \ ReadRow =
        withRow(row -> row.getByte(ix))

    pub def getInt8Named(label: String): Int8 \ ReadRow =
        withRow(row -> row.getByte(label))

    pub def getInt16At(ix: Int32): Int16 \ ReadRow =
        withRow(row -> row.getShort(ix))

    pub def getInt16Named(label: String): Int16 \ ReadRow =
        withRow(row -> row.getShort(label))

    pub def getInt32At(ix: Int32): Int32 \ ReadRow =
        withRow(row -> row.getInt(ix))

    pub def getInt32Named(label: String): Int32 \ ReadRow =
        withRow(row -> row.getInt(label))

    pub def getInt64At(ix: Int32): Int64 \ ReadRow =
        withRow(row -> row.getLong(ix))

    pub def getInt64Named(label: String): Int64 \ ReadRow =
        withRow(row -> row.getLong(label))

    pub def getFloat32At(ix: Int32): Float32 \ ReadRow =
        withRow(row -> row.getFloat(ix))
    
    pub def getFloat32Named(label: String): Float32 \ ReadRow =
        withRow(row -> row.getFloat(label))

    pub def getFloat64At(ix: Int32): Float64 \ ReadRow =
        withRow(row -> row.getDouble(ix))
    

    pub def getFloat64Named(label: String): Float64 \ ReadRow =
        withRow(row -> row.getDouble(label))


    /// Cell has type String...
    pub def getLocalDateStringAt(ix: Int32): Time.LocalDate \ ReadRow =
        let s = getStringAt(ix);
        let fmt = Time.Format.DateTimeFormatter.iso_local_date();
        liftResult(Time.LocalDate.parse(fmt, s))
    

    /// Cell has type String...
    pub def getLocalDateStringNamed(label: String): Time.LocalDate \ ReadRow =
        let s = getStringNamed(label);
        let fmt = Time.Format.DateTimeFormatter.iso_local_date();
        liftResult(Time.LocalDate.parse(fmt, s))

    /// Cell has type String...
    pub def getLocalDateTimeStringAt(ix: Int32): Time.LocalDateTime \ ReadRow =
        let s = getStringAt(ix);
        let fmt = Time.Format.DateTimeFormatter.iso_local_date_time();
        liftResult(Time.LocalDateTime.parse(fmt, s))
    

    /// Cell has type String...
    pub def getLocalDateTimeStringNamed(label: String): Time.LocalDateTime \ ReadRow =
        let s = getStringNamed(label);
        let fmt = Time.Format.DateTimeFormatter.iso_local_date_time();
        liftResult(Time.LocalDateTime.parse(fmt, s))

    /// Cell has type String...
    pub def getLocalTimeStringAt(ix: Int32): Time.LocalTime \ ReadRow =
        let s = getStringAt(ix);
        let fmt = Time.Format.DateTimeFormatter.iso_local_time();
        liftResult(Time.LocalTime.parse(fmt, s))
    

    /// Cell has type String...
    pub def getLocalTimeStringNamed(label: String): Time.LocalTime \ ReadRow =
        let s = getStringNamed(label);
        let fmt = Time.Format.DateTimeFormatter.iso_local_time();
        liftResult(Time.LocalTime.parse(fmt, s))

}

