

mod TestDuckDB {

    use Assert.{assertEq}
    
    use Fs.FileWrite
    use Fs.WriteFile

    use BasicDB.DBConnection.DBConnection
    use BasicDB.DBStatement.DBStatement
    use BasicDB.DBPreparedStatement.DBPreparedStatement
    use BasicDB.DBResultSet.DBResultSet
    use BasicDB.PreparedStatementSetter.PreparedStatementSetter
    use BasicDB.RowReader.RowReader


    def duckdb_action1(): Unit -> Unit \ DBConnection + {IO} = _ ->
        let stmt1 = DBConnection.createStatement();
        let _ = run { 
            discard DBStatement.execute("CREATE SCHEMA IF NOT EXISTS facts;");
            discard DBStatement.execute("CREATE TABLE IF NOT EXISTS facts.databases (name VARCHAR NOT NULL, year INTEGER, PRIMARY KEY(name));");
            discard DBStatement.execute("DELETE FROM facts.databases;");
            DBStatement.close()
        } with BasicDB.DBStatement.runWithIO(stmt1);
        let pstmt = DBConnection.prepareStatement("INSERT INTO facts.databases (name, year) VALUES (?,?);");
        let _ = run {
            let _ = run {setter("SQLite", 2000)} with BasicDB.PreparedStatementSetter.runPreparedStatementSetter(pstmt);
            DBPreparedStatement.addBatch();
            let _ = run {setter("DuckDB", 2019)} with BasicDB.PreparedStatementSetter.runPreparedStatementSetter(pstmt);
            DBPreparedStatement.addBatch();
            DBPreparedStatement.executeBatch();
            DBPreparedStatement.close()
        }  with BasicDB.DBPreparedStatement.runWithIO(pstmt);
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


     def setter(name: String, year: Int32): Unit \ PreparedStatementSetter = {
        PreparedStatementSetter.setString(0, name);
        PreparedStatementSetter.setInt32(1, year)
     }

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

    