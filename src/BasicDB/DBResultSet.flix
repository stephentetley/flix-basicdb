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



pub mod BasicDB.DBResultSet {
    

    use EffectExtras.Fail.Fail
    use BasicDB.{ResultSet, ResultSetRow}
    use BasicDB.RowReader.RowReaderWithAlt

    import java.sql.{SQLException => JSQLException}
    import java.sql.{ResultSet => JResultSet}

    pub eff DBResultSet {
        // `askResultSet` should not be used in user code
        // It is a hack until we can run local effects polymorphically
        def getResultSetRow(): ResultSetRow
        def next(): Bool
        def wasNull(): Bool
        def findColumn(label: String): Int32
        def isBeforeFirst(): Bool
        def isAfterLast(): Bool
        def isFirst(): Bool
        def isLast(): Bool
        def first(): Unit
        def last(): Unit
        def getRow(): Int32
        def absolute(row: Int32): Bool
        def relative(rows: Int32): Bool
        def setFetchSize(rows: Int32): Unit
        def getFetchSize(): Int32
    }

    
    
    pub def handle(results: ResultSet, 
                    f: a -> b \ ef): a -> b \ (ef + Fail - DBResultSet) = x -> {
        let jresults = ToJava.toJava(results);
        run {
            f(x)
        } with handler DBResultSet {
        
            def getResultSetRow(k) = k(ToFlix.toFlix(jresults))


            def next(k) = 
                try {
                    let ans = unsafe IO as {ef + Fail - DBResultSet} { jresults.next() };
                    k(ans)
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }
            
            def wasNull(k) = 
                try {
                    let ans = unsafe IO as {ef + Fail - DBResultSet} { jresults.wasNull() };
                    k(ans)
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }

            def findColumn(label, k) = 
                try {
                    let ans = unsafe IO as {ef + Fail - DBResultSet} { jresults.findColumn(label) };
                    k(ans)
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }

            def isBeforeFirst(k) = 
                try {
                    let ans = unsafe IO as {ef + Fail - DBResultSet} { jresults.isBeforeFirst() };
                    k(ans)
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }

            def isAfterLast(k) = 
                try {
                    let ans = unsafe IO as {ef + Fail - DBResultSet} { jresults.isAfterLast() };
                    k(ans)
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }

            def isFirst(k) = 
                try {
                    let ans = unsafe IO as {ef + Fail - DBResultSet} { jresults.isFirst() };
                    k(ans)
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }

            def isLast(k) = 
                try {
                    let ans = unsafe IO as {ef + Fail - DBResultSet} { jresults.isLast() };
                    k(ans)
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }

            def first(k) = 
                try {
                    unsafe IO as {ef + Fail - DBResultSet} { discard jresults.first() };
                    k()
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }

            def last(k) = 
                try {
                    unsafe IO as {ef + Fail - DBResultSet} { discard jresults.last() };
                    k()
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }

            def getRow(k) = 
                try {
                    let ans = unsafe IO as {ef + Fail - DBResultSet} { jresults.getRow() };
                    k(ans)
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }

            def absolute(row, k) = 
                try {
                    let ans = unsafe IO as {ef + Fail - DBResultSet} { jresults.absolute(row) };
                    k(ans)
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }
            
            def relative(rows, k) = 
                try {
                    let ans = unsafe IO as {ef + Fail - DBResultSet} { jresults.relative(rows) };
                    k(ans)
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }

            def setFetchSize(rows, k) = 
                try {
                    unsafe IO as {ef + Fail - DBResultSet} { jresults.setFetchSize(rows) };
                    k()
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }
            
            def getFetchSize(k) = 
                try {
                    let ans = unsafe IO as {ef + Fail - DBResultSet} { jresults.getFetchSize() };
                    k(ans)
                } catch {
                    case ex: JSQLException => Fail.report(ex.getMessage())
                }

        }

    }
        
    pub def runDBResultSet(results: ResultSet, f: Unit -> a \ ef):  a \ (ef + Fail - DBResultSet) = 
        handle(results, f)()

    pub def execRowReader(f: Unit -> a \ ef): a \ {ef + Fail + DBResultSet} - RowReaderWithAlt =
        let row = DBResultSet.getResultSetRow();
        BasicDB.RowReader.runRowReader(row, f)

    // forEach

    // Note - doesn't close resultset even though it will be exhausted
    pub def forEach(f: Unit -> Unit \ ef): Unit \ {ef + Fail + DBResultSet} - RowReaderWithAlt =
        def loop(fk, sk) = {
            let more = DBResultSet.next();
            if (more) {
                let rowAnswer = EffectExtras.Fail.runWithResult(_ -> execRowReader(f));
                match rowAnswer {
                    case Ok()     => loop(fk, sk)
                    case Err(err) => fk(err)
                }
            } else sk()
        };
        loop(e -> Fail.report(e), a -> a)

    // fold
    pub def fold(f: s -> s \ ef, st: s): s \ {ef + Fail + DBResultSet} - RowReaderWithAlt =
        def loop(acc, fk, sk) = {
            let more = DBResultSet.next();
            if (more) {
                let rowAnswer = EffectExtras.Fail.runWithResult(_ -> execRowReader(_ -> f(acc)));
                match rowAnswer {
                    case Ok(acc1) => loop(acc1, fk, sk)
                    case Err(err) => fk(err)
                }
            } else sk(acc)
        };
        loop(st, e -> Fail.report(e), a -> a)

    pub def firstResult(f: ResultSetRow -> a \ ef, results: ResultSet): a \ ef + Fail - DBResultSet = 
        runDBResultSet(results, _ -> {
            let more = DBResultSet.next();
            if (more) {
                let row = DBResultSet.getResultSetRow();
                f(row)
            } else Fail.report("firstResult - empty resultset")
        })


}