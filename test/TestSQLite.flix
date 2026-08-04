


pub mod TestSQLite {

    use Assert.{assertEq, assertOk}
    use Fs.FileRead
    use Fs.FileWrite
    use Fs.ReadFile
    use Fs.WriteFile

    use EffectExtras.Fail.Fail
    use BasicDB.DBConnection.DBConnection
    use BasicDB.DBStatement.DBStatement
    use BasicDB.DBPreparedStatement
    use BasicDB.DBResultSet
    use BasicDB.PreparedStatementSetter
    use BasicDB.RowReader


    def create_facts_table(): Unit \ Fail + DBConnection =
        BasicDB.DBStatement.runDBStatement1(() -> {
            discard DBStatement.execute("DROP TABLE IF EXISTS facts_databases;");
            discard DBStatement.execute("CREATE TABLE IF NOT EXISTS facts_databases (name VARCHAR PRIMARY KEY NOT NULL, year int);");
            ()
        })



    @Test
    def test01(): Unit \ {Assert + FileWrite + IO} = 
        let ans = run {
            forM (
                dir <- FileWrite.mkTempDir("flix-sqlite");
                path <- Ok("${dir}/test-DB-67890.sqlite");
                ans <- BasicDB.runSQLite(path, create_facts_table)
            ) yield ans
        } with WriteFile.runWithFileWrite;
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
            } with BasicDB.DBStatement.runDBStatement1
        };
        let path = "./data/langs.sqlite";
        let ans = BasicDB.runSQLite(path, readLangs);
        assertOk(ans)


}

    