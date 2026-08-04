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
    
    
    use EffectExtras.Fail.Fail
    
    use BasicDB.{PreparedStatement, ResultSet, ResultSetRow}
    use BasicDB.PreparedStatementSetter.PreparedStatementSetterWithAlt
    use BasicDB.DBConnection.DBConnection
    use BasicDB.DBResultSet.DBResultSet
    use BasicDB.RowReader.RowReaderWithAlt



    import java.sql.{SQLException => JSQLException}
    import java.sql.{PreparedStatement => JPreparedStatement}

    pub eff DBPreparedStatement {
        // `askPreparedStatement` should not be used in user code
        // It is a hack until we can run local effects polymorphically
        def askPreparedStatement(): PreparedStatement
        def execute(): Bool
        def addBatch(): Unit
        def executeBatch(): Unit
        def executeQuery(): ResultSet
        def closeResultSet(results: ResultSet): Unit
        def executeUpdate(): Int32
        def clearParameters(): Unit
    }

    pub def handle(stmt: PreparedStatement, 
                    f: a -> b \ ef): a -> b \ {ef + Fail - DBPreparedStatement} = x -> {
        let jstmt = ToJava.toJava(stmt);
        run {
            f(x)
        } with handler DBPreparedStatement {
        
            def askPreparedStatement(k) = k(stmt)
            
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
                    k(ToFlix.toFlix(ans))
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }


            def closeResultSet(results, k) = 
                try {
                    let jresults = ToJava.toJava(results);
                    unsafe IO as {ef + Fail - DBPreparedStatement} { jresults.close() };
                    k()
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

    pub def runDBPreparedStatement(stmt: PreparedStatement, 
                                    f: Unit -> a \ ef): a \ (ef + Fail - DBPreparedStatement) = 
        handle(stmt, f)()

    pub def runDBPreparedStatement1(sql: String, 
                                        f: Unit -> a \ ef): a \ {ef + Fail + DBConnection} - DBPreparedStatement = 
        let stmt = DBConnection.prepareStatement(sql);
        let ans = handle(stmt, f)();
        DBConnection.closePreparedStatement(stmt);
        ans


    // This is single row answer...
    pub def scalarQuery(f: ResultSetRow -> a \ ef): a \ ef + Fail + DBPreparedStatement - DBResultSet =
        let results = DBPreparedStatement.executeQuery();
        let ans = BasicDB.DBResultSet.firstResult(f, results);
        DBPreparedStatement.closeResultSet(results);
        ans

    pub def forEachQuery(f: Unit -> Unit \ ef): Unit \ {ef + Fail + DBPreparedStatement} - DBResultSet - RowReaderWithAlt = 
        let results = DBPreparedStatement.executeQuery();
        BasicDB.DBResultSet.runDBResultSet(results, _ -> BasicDB.DBResultSet.forEach(f));
        DBPreparedStatement.closeResultSet(results)

    pub def foldQuery(f: s -> s \ ef, st: s): s \ {ef + Fail + DBPreparedStatement} - DBResultSet - RowReaderWithAlt = 
        let results = DBPreparedStatement.executeQuery();
        let ans = BasicDB.DBResultSet.runDBResultSet(results, _ -> BasicDB.DBResultSet.fold(f, st));
        DBPreparedStatement.closeResultSet(results);
        ans

    pub def execPreparedStatementSetter(f: Unit -> a \ ef): a \ {Fail + ef + DBPreparedStatement} - PreparedStatementSetterWithAlt =
        let stmt = DBPreparedStatement.askPreparedStatement();
        BasicDB.PreparedStatementSetter.runPreparedStatementSetter(stmt, f)

}