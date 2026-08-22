/*
 * Copyright 2025 Stephen Tetley
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



pub mod BasicDB.PreparedStatementSetter {


    use EffectExtras.Alt.Alt
    use EffectExtras.Alt.Alternative
    use EffectExtras.Fail.Fail
    
    use BasicDB.DBPreparedStatement
    use BasicDB.{PreparedStatement}


    import java.sql.{SQLException => JSQLException}
    import java.sql.{PreparedStatement => JPreparedStatement}

    pub eff PreparedStatementSetter {
        def setNull(paramIx: Int32, sqlType: Int32): Unit
        def setBool(paramIx: Int32, value: Bool): Unit
        def setInt8(paramIx: Int32, value: Int8): Unit
        def setInt16(paramIx: Int32, value: Int16): Unit
        def setInt32(paramIx: Int32, value: Int32): Unit
        def setInt64(paramIx: Int32, value: Int64): Unit
        def setFloat32(paramIx: Int32, value: Float32): Unit
        def setFloat64(paramIx: Int32, value: Float64): Unit
        def setBigDecimal(paramIx: Int32, value: BigDecimal): Unit
        def setString(paramIx: Int32, value: String): Unit
    }



    pub def handle(stmt: PreparedStatement, 
                    f: a -> b \ ef): a -> b \ ef + Fail - PreparedStatementSetter = x -> {
        let jstmt = ToJava.toJava(stmt);
        run {
            f(x)
        } with handler PreparedStatementSetter {
        
            def setNull(paramIx, sqlType, k) = 
                try {
                    unsafe IO as {ef + Fail - PreparedStatementSetter} { jstmt.setNull(paramIx + 1, sqlType) };
                    k()
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }
            
            def setBool(paramIx, value, k) = 
                try {
                    unsafe IO as {ef + Fail - PreparedStatementSetter} { jstmt.setBoolean(paramIx + 1, value) };
                    k()
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }
            
            def setInt8(paramIx, value, k) = 
                try {
                    unsafe IO as {ef + Fail - PreparedStatementSetter} { jstmt.setByte(paramIx + 1, value) };
                    k()
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }
            
            def setInt16(paramIx, value, k) = 
                try {
                    unsafe IO as {ef + Fail - PreparedStatementSetter} { jstmt.setShort(paramIx + 1, value) };
                    k()
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }
            
            def setInt32(paramIx, value, k) = 
                try {
                    unsafe IO as {ef + Fail - PreparedStatementSetter} { jstmt.setInt(paramIx + 1, value) };
                    k()
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }
            
            def setInt64(paramIx, value, k) = 
                try {
                    unsafe IO as {ef + Fail - PreparedStatementSetter} { jstmt.setLong(paramIx + 1, value) };
                    k()
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }
            
            def setFloat32(paramIx, value, k) = 
                try {
                    unsafe IO as {ef + Fail - PreparedStatementSetter} { jstmt.setFloat(paramIx + 1, value) };
                    k()
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }
                        
            def setFloat64(paramIx, value, k) = 
                try {
                    unsafe IO as {ef + Fail - PreparedStatementSetter} { jstmt.setDouble(paramIx + 1, value) };
                    k()
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }

            def setBigDecimal(paramIx, value, k) = 
                try {
                    unsafe IO as {ef + Fail - PreparedStatementSetter} { jstmt.setBigDecimal(paramIx + 1, value) };
                    k()
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }

            def setString(paramIx, value, k) = 
                try {
                    unsafe IO as {ef + Fail - PreparedStatementSetter} { jstmt.setString(paramIx + 1, value) };
                    k()
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }
        }
    }

    pub def runPreparedStatementSetter(stmt: PreparedStatement, 
                                        f: Unit -> a \ ef): a \ ef + Fail - PreparedStatementSetter - Alt = 
        run { handle(stmt, f)() } with runWithFail

    pub def runPreparedStatementSetter1(f: Unit -> a \ ef): a \ ef + Fail + DBPreparedStatement - PreparedStatementSetter - Alt = 
        let stmt = DBPreparedStatement.getPreparedStatement();
        run { handle(stmt, f)() } with runWithFail

    // To be added to EffectExtras...
    def runWithFail(f: Unit -> a \ ef): a \ ef - Alternative + Fail = 
        match EffectExtras.Alt.runWithResult(f) {
            case Ok(a)    => a
            case Err(msg) => Fail.report(msg)
        }

}