// Previously this needed running with classpath pointing to the 
// sqlite / duckdb jars, but it seems that is unnecessary now we
// call `Class.forName("org.duckdb.DuckDBDriver");` in the run 
// function. However we can avoid a warning by enabling native access: 
// 
// > java --enable-native-access=ALL-UNNAMED -jar ../bin/flix.0.61.0.jar test


mod TestSQLite {


    use BasicDb.DbConnection
    use BasicDb.DbStatement
    use BasicDb.DbPreparedStatement
    use BasicDb.DbResultSet
    use BasicDb.PreparedStatementSetter
    use BasicDb.RowReader


    def sqlite_action1(): Unit -> Unit \ DbConnection +  {IO} = _ ->
        let stmt = DbConnection.createStatement();
        let _ = DbStatement.runWithIO(stmt, () -> { 
            let _ = DbStatement.execute("DROP TABLE IF EXISTS facts_databases;");
            let _ = DbStatement.execute("CREATE TABLE IF NOT EXISTS facts_databases (name VARCHAR PRIMARY KEY NOT NULL, year int);");
            ()
            });         
        ()



    @test
    def test01(): Bool \ IO = 
        FileWrite.runWithIO(_ -> 
            let dir = FileWrite.mkTempDir("flix");
            let path = "${dir}/test-db-67890.sqlite";
            println(path);
            match BasicDb.runSQLite(path, sqlite_action1()) {
                case Err(err) => {println(err); Err(err) }
                case Ok(_) => Ok(true)
            }
            ) == Ok(Ok(true))        

}

    