


pub mod TestSQLite {

    use Assert.{assertEq, assertOk}
    use Fs.FileRead
    use Fs.FileWrite
    use Fs.ReadFile
    use Fs.WriteFile

    use EffectExtras.Fail.Fail
    use BasicDB.Connection
    use BasicDB.DBConnection.DBConnection
    use BasicDB.DBStatement.DBStatement
    use BasicDB.DBPreparedStatement
    use BasicDB.DBResultSet
    use BasicDB.PreparedStatementSetter
    use BasicDB.RowReader


    def create_facts_table(): Unit \ Fail + DBConnection =
        run {
            discard DBStatement.execute("DROP TABLE IF EXISTS facts_databases;");
            discard DBStatement.execute("CREATE TABLE IF NOT EXISTS facts_databases (name VARCHAR PRIMARY KEY NOT NULL, year int);")
        } with BasicDB.DBConnection.execDBStatement
    

    @Test
    def test01(): Unit \ Assert + FileWrite + IO = 
        let ans = run {
            let dir = FileWrite.mkTempDir("flix-sqlite") |> Fail.fromResult;
            let path = "${dir}/test-DB-67890.sqlite";
            BasicDB.execSQLite(path, create_facts_table)
        } with WriteFile.runWithFileWrite
          with Fail.runWithIO;
        assertOk(ans)

    @Test
    def test02(): Unit \ {Assert + IO} = 
        def readLangs() = {
            let sql = "SELECT * FROM langs";
            run {
                BasicDB.DBStatement.forEachQuery(sql, row -> 
                    BasicDB.RowReader.runRowReader(row,  () -> {
                        let lang = RowReader.getStringByName("name");
                        println(lang)
                    })
                )
            } with BasicDB.DBConnection.execDBStatement
        };
        let path = "./data/langs.sqlite";
        let ans = BasicDB.execSQLite(path, readLangs);
        assertOk(ans)

}

