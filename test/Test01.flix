// Previously this needed running with classpath pointing to the 
// sqlite / duckdb jars, but it seems that is unnecessary now we
// call `Class.forName("org.duckdb.DuckDBDriver");` in the run 
// function. However we can avoid a warning by enabling native access: 
// 
// > java --enable-native-access=ALL-UNNAMED -jar ../bin/flix.0.61.0.jar test


mod Test01 {


    use BasicDb.DbConnection
    use BasicDb.DbStatement
    use BasicDb.DbPreparedStatement
    use BasicDb.DbResultSet
    use BasicDb.PreparedStatementSetter
    use BasicDb.RowReader


    def duckdb_action1(): Unit -> Unit \ DbConnection +  {IO} = _ ->
        let stmt1 = DbConnection.createStatement();
        let _ = run { 
            DbStatement.execute("CREATE SCHEMA IF NOT EXISTS facts;");
            DbStatement.execute("CREATE TABLE IF NOT EXISTS facts.databases (name VARCHAR NOT NULL, year INTEGER, PRIMARY KEY(name));");
            DbStatement.execute("DELETE FROM facts.databases;");
            DbStatement.close()
        } with DbStatement.runWithIO(stmt1);
        let pstmt = DbConnection.prepareStatement("INSERT INTO facts.databases (name, year) VALUES (?,?);");
        let _ = run {
            let _ = run {setter("SQLite", 2000)} with PreparedStatementSetter.runWithIO(pstmt);
            DbPreparedStatement.addBatch();
            let _ = run {setter("DuckDB", 2019)} with PreparedStatementSetter.runWithIO(pstmt);
            DbPreparedStatement.addBatch();
            DbPreparedStatement.executeBatch();
            DbPreparedStatement.close()
        }  with DbPreparedStatement.runWithIO(pstmt);
        let stmt2 = DbConnection.createStatement();
        let _ = run { 
            let rs = DbStatement.executeQuery("SELECT * FROM facts.databases;");
            let _ = run {
                def loop() = {
                    let more = DbResultSet.next();
                    if (more) {
                        match run {reader()} with RowReader.runWithIO(rs) {
                            case Ok((n, y)) => println("db: ${n}, year: ${y}")
                            case Err(err) => println("error: ${err}")
                        };
                        loop()
                    } else ()
                };
                loop()
            } with DbResultSet.runWithIO(rs);
            DbStatement.close()
        } with DbStatement.runWithIO(stmt2);
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
            let path = "${dir}/test-db-12345.duckdb";
            println(path);
            match BasicDb.runDuckDb(path, duckdb_action1()) {
                case Err(err) => {println(err); Err(err) }
                case Ok(_) => Ok(true)
            }
            ) == Ok(Ok(true))

    @test
    def test02(): Bool \ IO = 
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

    