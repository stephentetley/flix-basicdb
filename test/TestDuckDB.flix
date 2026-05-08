

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
    use BasicDB.RowReader.RowReader


    def duckdb_action1(): Unit \ Fail + DBConnection =
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
            let _ = run {
                def loop() = {
                    let more = DBResultSet.next();
                    if (more) {
                        match run {reader()} with BasicDB.RowReader.runWithIO(rs) {
                            case Ok((n, y)) => println("DB: ${n}, year: ${y}")
                            case Err(err) => println("error: ${err}")
                        };
                        loop()
                    } else ()
                };
                loop()
            } with BasicDB.DBResultSet.runWithIO(rs);
            DBStatement.close()
        } with BasicDB.DBStatement.runWithIO(stmt2);
        ()


     def setter(name: String, year: Int32): Unit \ PreparedStatementSetterWithAlt = checked_ecast({
        PreparedStatementSetter.setString(0, name);
        PreparedStatementSetter.setInt32(1, year)
     })

     def reader(): (String, Int32) \ RowReader = {
        let name = RowReader.getStringByName("name");
        let year = RowReader.getInt32ByName("year");
        (name, year)
     }


    @Test
    def test01(): Unit \ {Assert + IO} = 
        let ans:Result[IoError, Bool] = run {
            let a1 = BasicDB.runDuckDBInMemory(duckdb_action1);
            Result.map(_ -> true, a1)
        } with FileWrite.runWithIO;
        assertEq(expected = Ok(true), ans)



}

    