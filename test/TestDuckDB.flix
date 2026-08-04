

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
        def setter(name: String, year: Int32): Unit \ PreparedStatementSetter = {
            PreparedStatementSetter.setString(0, name);
            PreparedStatementSetter.setInt32(1, year)
        };
        let sql = "INSERT INTO facts.databases (name, year) VALUES (?,?);";
        BasicDB.DBPreparedStatement.runDBPreparedStatement1(sql, () -> {
            BasicDB.PreparedStatementSetter.runPreparedStatementSetter1(_ -> setter("SQLite", 2000));
            DBPreparedStatement.addBatch();
            BasicDB.PreparedStatementSetter.runPreparedStatementSetter1(_ -> setter("DuckDB", 2019));
            DBPreparedStatement.addBatch();
            DBPreparedStatement.executeBatch();
            ()
        })



    def duckdb_action1(): Unit \ IO + DBConnection + Fail =
        create_facts_table();
        insert_facts_data();
        run {
            BasicDB.DBStatement.forEachQuery("SELECT * FROM facts.databases;", row -> {
                BasicDB.RowReader.runRowReader(row,  () -> {
                    let name = RowReader.getStringByName("name");
                    let year = RowReader.getInt32ByName("year");
                    println("DB: ${name}, year: ${year}")
                })
            })
        } with BasicDB.DBStatement.runDBStatement1



    @Test
    def test01(): Unit \ {Assert + IO} = 
        let ans = BasicDB.runDuckDBInMemory(duckdb_action1);
        assertOk(ans)



}

    