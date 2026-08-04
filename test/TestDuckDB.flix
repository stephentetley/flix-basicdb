

pub mod TestDuckDB {

    use Assert.{assertOk}
    
    use Fs.FileWrite
    use Fs.WriteFile

    use EffectExtras.Fail.Fail
    use BasicDB.DBConnection.DBConnection
    use BasicDB.DBStatement.DBStatement
    use BasicDB.DBPreparedStatement.DBPreparedStatement
    use BasicDB.DBResultSet.DBResultSet
    use BasicDB.PreparedStatementSetter.PreparedStatementSetter
    use BasicDB.RowReader.RowReader

    def create_facts_table(): Unit \ Fail + DBConnection =
        BasicDB.DBStatement.runDBStatement1(() -> {
            discard DBStatement.execute("CREATE SCHEMA IF NOT EXISTS facts;");
            discard DBStatement.execute("CREATE TABLE IF NOT EXISTS facts.databases (name VARCHAR NOT NULL, year INTEGER, PRIMARY KEY(name));");
            discard DBStatement.execute("DELETE FROM facts.databases;");
            ()
        })

    def insert_facts_data(): Unit \ Fail + DBConnection =
        let sql = "INSERT INTO facts.databases (name, year) VALUES (?,?);";
        BasicDB.DBPreparedStatement.runDBPreparedStatement1(sql, () -> {
            BasicDB.PreparedStatementSetter.runPreparedStatementSetter1(_ -> setter("SQLite", 2000));
            DBPreparedStatement.addBatch();
            BasicDB.PreparedStatementSetter.runPreparedStatementSetter1(_ -> setter("DuckDB", 2019));
            DBPreparedStatement.addBatch();
            DBPreparedStatement.executeBatch();
            ()
        })

     def setter(name: String, year: Int32): Unit \ PreparedStatementSetter = {
        PreparedStatementSetter.setString(0, name);
        PreparedStatementSetter.setInt32(1, year)
     }


    def duckdb_action1(): Unit \ IO + ef + DBConnection + Fail - DBPreparedStatement - DBStatement - DBResultSet =
        create_facts_table();
        insert_facts_data();
        let stmt2 = DBConnection.createStatement();
        let _ = run { 
            let rs = DBStatement.executeQuery("SELECT * FROM facts.databases;");
            run {
                def loop() = {
                    let more = DBResultSet.next();
                    if (more) {
                        let row = DBResultSet.getResultSetRow();
                        match run { BasicDB.RowReader.runRowReader(row, reader) } with EffectExtras.Fail.runWithResult {
                            case Ok((n, y)) => println("DB: ${n}, year: ${y}")
                            case Err(err)   => println("error: ${err}")
                        };
                        loop()
                    } else ()
                };
                loop()
            } with BasicDB.DBResultSet.runDBResultSet(rs)
        } with BasicDB.DBStatement.runDBStatement(stmt2);
        DBConnection.closeStatement(stmt2)




     def reader(): (String, Int32) \ RowReader = {
        let name = RowReader.getStringByName("name");
        let year = RowReader.getInt32ByName("year");
        (name, year)
     }


    @Test
    def test01(): Unit \ {Assert + IO} = 
        let ans = BasicDB.runDuckDBInMemory(duckdb_action1);
        assertOk(ans)



}

    