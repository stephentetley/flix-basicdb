

mod TestDuckDB {

    use Assert.{assertEq}
    
    use Fs.FileWrite
    use Fs.WriteFile

    use EffectExtras.Fail.Fail
    use BasicDB.DBConnection.DBConnection
    use BasicDB.DBStatement.DBStatement
    use BasicDB.DBPreparedStatement.DBPreparedStatement
    use BasicDB.DBResultSet.DBResultSet
    use BasicDB.PreparedStatementSetter.PreparedStatementSetterWithAlt
    use BasicDB.PreparedStatementSetter.PreparedStatementSetter
    use BasicDB.RowReader.RowReaderWithAlt
    use BasicDB.RowReader.RowReader


    def duckdb_action1(): Unit \ IO + ef + DBConnection + Fail - DBPreparedStatement - DBStatement - DBResultSet =
        BasicDB.DBConnection.execDBStatement(() -> {
            discard DBStatement.execute("CREATE SCHEMA IF NOT EXISTS facts;");
            discard DBStatement.execute("CREATE TABLE IF NOT EXISTS facts.databases (name VARCHAR NOT NULL, year INTEGER, PRIMARY KEY(name));");
            discard DBStatement.execute("DELETE FROM facts.databases;")
        });
        BasicDB.DBConnection.execDBPreparedStatement(
                "INSERT INTO facts.databases (name, year) VALUES (?,?);",
                () -> {
                    BasicDB.DBPreparedStatement.execPreparedStatementSetter(_ -> setter("SQLite", 2000));
                    DBPreparedStatement.addBatch();
                    BasicDB.DBPreparedStatement.execPreparedStatementSetter(_ -> setter("DuckDB", 2019));
                    DBPreparedStatement.addBatch();
                    DBPreparedStatement.executeBatch()
        });
        let stmt2 = DBConnection.createStatement();
        let _ = run { 
            let rs = DBStatement.executeQuery("SELECT * FROM facts.databases;");
            run {
                def loop() = {
                    let more = DBResultSet.next();
                    if (more) {
                        match BasicDB.RowReader.runRowReaderWithAlt(rs, reader) {
                            case Ok((n, y)) => println("DB: ${n}, year: ${y}")
                            case Err(err) => println("error: ${err}")
                        };
                        loop()
                    } else ()
                };
                loop()
            } with BasicDB.DBResultSet.runDBResultSet(rs)
        } with BasicDB.DBStatement.runDBStatement(stmt2);
        DBConnection.closeStatement(stmt2)



     def setter(name: String, year: Int32): Unit \ PreparedStatementSetterWithAlt = checked_ecast({
        PreparedStatementSetter.setString(0, name);
        PreparedStatementSetter.setInt32(1, year)
     })

     def reader(): (String, Int32) \ RowReaderWithAlt = checked_ecast({
        let name = RowReader.getStringByName("name");
        let year = RowReader.getInt32ByName("year");
        (name, year)
     })


    @Test
    def test01(): Unit \ {Assert + IO} = 
        let ans:Result[IoError, Bool] = run {
            let a1 = BasicDB.runDuckDBInMemory(duckdb_action1);
            Result.map(_ -> true, a1)
        } with FileWrite.runWithIO;
        assertEq(expected = Ok(true), ans)



}

    