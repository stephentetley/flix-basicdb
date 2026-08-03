// Previously this needed running with classpath pointing to the 
// sqlite / duckDB jars, but it seems that is unnecessary now we
// call `Class.forName("org.duckDB.DuckDBDriver");` in the run 
// function. However we can avoid a warning by enabling native access: 
// 
// > java --enable-native-access=ALL-UNNAMED -jar ../bin/flix.0.61.0.jar test


mod TestSQLite {

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


    def sqlite_action1(): Unit \ Fail + DBConnection =
        BasicDB.DBConnection.execDBStatement(() -> { 
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
                ans <- BasicDB.runSQLite(path, sqlite_action1)
            ) yield ans
        } with WriteFile.runWithFileWrite;
        assertOk(ans)        

    // @Test
    // def test02(): Unit \ {Assert + IO} = 
    //     def readLangs() = {
    //         let stmt = DBConnection.createStatement();
    //         let sql = "SELECT * FROM langs";
    //         let rset = BasicDB.DBStatement.runDBStatement(stmt, DBStatement.executeQuery(sql));
    //         BasicDB.DBResultSet.runDBResultSet(rset, BasicDB.DBResultSet.forEach(() -> {
    //             let lang = RowReader.getStringByName("name");
    //             println(lang)
    //         }))
    //     };
    //     let path = "../data/langs.sqlite";
    //     let _ans = BasicDB.runSQLite(path, readLangs );
    //     assertOk(Ok(1))


}

    