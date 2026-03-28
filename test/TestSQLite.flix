// Previously this needed running with classpath pointing to the 
// sqlite / duckdb jars, but it seems that is unnecessary now we
// call `Class.forName("org.duckdb.DuckDBDriver");` in the run 
// function. However we can avoid a warning by enabling native access: 
// 
// > java --enable-native-access=ALL-UNNAMED -jar ../bin/flix.0.61.0.jar test


mod TestSQLite {

    use Assert.{assertEq, assertOk}
    use Fs.FileRead
    use Fs.FileWrite
    use Fs.ReadFile
    use Fs.WriteFile

    use BasicDb.DbConnection.DbConnection
    use BasicDb.DbStatement.DbStatement
    use BasicDb.DbPreparedStatement
    use BasicDb.DbResultSet
    use BasicDb.PreparedStatementSetter
    use BasicDb.RowReader


    def sqlite_action1(): Unit -> Unit \ DbConnection +  {IO} = _ ->
        let stmt = DbConnection.createStatement();
        let _ = BasicDb.DbStatement.runWithIO(stmt, () -> { 
            let _ = DbStatement.execute("DROP TABLE IF EXISTS facts_databases;");
            let _ = DbStatement.execute("CREATE TABLE IF NOT EXISTS facts_databases (name VARCHAR PRIMARY KEY NOT NULL, year int);");
            ()
            });         
        ()



    @Test
    def test01(): Unit \ {Assert + FileWrite + IO} = 
        let ans = run {
            forM (
                dir <- FileWrite.mkTempDir("flix-sqlite");
                path <- Ok("${dir}/test-db-67890.sqlite");
                ans <- BasicDb.runSQLite(path, sqlite_action1())
            ) yield ans
        } with WriteFile.runWithFileWrite;
        assertOk(ans)        

}

    