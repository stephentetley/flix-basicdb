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



pub mod BasicDB.DBPreparedStatement {
    use BasicDB.PreparedStatementSetter
    
    use IoError.ErrorKind
    use IoError.IoError
    use EffectExtras.Fail.Fail
    use BasicDB.PreparedStatementSetter.PreparedStatementSetterWithAlt
    use BasicDB.DBResultSet.ResultSetHandle
    use BasicDB.DBPreparedStatement


    import java.sql.{SQLException => JSQLException}
    import java.sql.{PreparedStatement => JPreparedStatement}

    pub eff DBPreparedStatement {
        // `askPreparedStatementHandle` should not be used in user code
        // It is a hack until we can run local effects polymorphically
        def askPreparedStatementHandle(): PreparedStatementHandle
        def execute(): Bool
        def addBatch(): Unit
        def executeBatch(): Unit
        def executeQuery(): ResultSetHandle
        def executeUpdate(): Int32
        def clearParameters(): Unit
    }

    pub enum PreparedStatementHandle (JPreparedStatement)

    pub def handle(stmt: PreparedStatementHandle, 
                    f: a -> b \ ef): a -> b \ {ef + Fail - DBPreparedStatement} = x -> {
        let PreparedStatementHandle.PreparedStatementHandle(jstmt) = stmt;
        run {
            f(x)
        } with handler DBPreparedStatement {
        
            def askPreparedStatementHandle(k) = k(stmt)
            
            def execute(k) = 
                try {
                    let ans = unsafe IO as {ef + Fail - DBPreparedStatement} { jstmt.execute() };
                    k(ans)
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }

            def addBatch(k) = 
                try {
                    unsafe IO as {ef + Fail - DBPreparedStatement} { jstmt.addBatch() };
                    k()
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }

            def executeBatch(k) = 
                try {
                    unsafe IO as {ef + Fail - DBPreparedStatement} { discard jstmt.executeBatch() };
                    k()
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }

            def executeQuery(k) = 
                try { 
                    let ans = unsafe IO as {ef + Fail - DBPreparedStatement} { jstmt.executeQuery() };
                    k(ResultSetHandle.ResultSetHandle(ans))
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }

            def executeUpdate(k) = 
                try {
                    let ans = unsafe IO as {ef + Fail - DBPreparedStatement} { jstmt.executeUpdate() };
                    k(ans)
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }

            def clearParameters(k) = 
                try {
                    unsafe IO as {ef + Fail - DBPreparedStatement} { jstmt.clearParameters() };
                    k()
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }
        }
    }

    pub def runDBPreparedStatement(stmt: PreparedStatementHandle, 
                                    f: Unit -> a \ ef): a \ (ef + Fail - DBPreparedStatement) = 
        handle(stmt, f)()

    pub def execPreparedStatementSetter(f: Unit -> a \ ef): a \ {Fail + ef + DBPreparedStatement} - PreparedStatementSetterWithAlt =
        let stmt = DBPreparedStatement.askPreparedStatementHandle();
        BasicDB.PreparedStatementSetter.runPreparedStatementSetter(stmt, f)

}