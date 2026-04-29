

mod TestDuckDB {

    use Assert.{assertEq}
    
    use Fs.FileWrite
    use Fs.WriteFile

    use BasicDb.DbConnection.DbConnection
    use BasicDb.DbStatement.DbStatement
    use BasicDb.DbPreparedStatement.DbPreparedStatement
    use BasicDb.DbResultSet.DbResultSet
    use BasicDb.PreparedStatementSetter.PreparedStatementSetter
    use BasicDb.RowReader.RowReader


    def duckdb_action1(): Unit -> Unit \ DbConnection + {IO} = _ ->
        let stmt1 = DbConnection.createStatement();
        let _ = run { 
            discard DbStatement.execute("CREATE SCHEMA IF NOT EXISTS facts;");
            discard DbStatement.execute("CREATE TABLE IF NOT EXISTS facts.databases (name VARCHAR NOT NULL, year INTEGER, PRIMARY KEY(name));");
            discard DbStatement.execute("DELETE FROM facts.databases;");
            DbStatement.close()
        } with BasicDb.DbStatement.runWithIO(stmt1);
        let pstmt = DbConnection.prepareStatement("INSERT INTO facts.databases (name, year) VALUES (?,?);");
        let _ = run {
            let _ = run {setter("SQLite", 2000)} with BasicDb.PreparedStatementSetter.runWithIO(pstmt);
            DbPreparedStatement.addBatch();
            let _ = run {setter("DuckDB", 2019)} with BasicDb.PreparedStatementSetter.runWithIO(pstmt);
            DbPreparedStatement.addBatch();
            DbPreparedStatement.executeBatch();
            DbPreparedStatement.close()
        }  with BasicDb.DbPreparedStatement.runWithIO(pstmt);
        let stmt2 = DbConnection.createStatement();
        let _ = run { 
            let rs = DbStatement.executeQuery("SELECT * FROM facts.databases;");
            let _ = run {
                def loop() = {
                    let more = DbResultSet.next();
                    if (more) {
                        match run {reader()} with BasicDb.RowReader.runWithIO(rs) {
                            case Ok((n, y)) => println("db: ${n}, year: ${y}")
                            case Err(err) => println("error: ${err}")
                        };
                        loop()
                    } else ()
                };
                loop()
            } with BasicDb.DbResultSet.runWithIO(rs);
            DbStatement.close()
        } with BasicDb.DbStatement.runWithIO(stmt2);
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
        assertEq(
            expected = Ok(true),
            run {
                forM (
                    dir <- FileWrite.mkTempDir("flix-duckdb");
                    path <- Ok("${dir}/test-db-12345.duckdb");
                    _ <- BasicDb.runDuckDb(path, duckdb_action1())
                ) yield true
            } with FileWrite.runWithIO
        )



}

    