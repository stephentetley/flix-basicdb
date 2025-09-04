// Previously this needed running with classpath pointing to the 
// sqlite / duckdb jars, but it seems that is unnecessary now we
// call `Class.forName("org.duckdb.DuckDBDriver");` in the run 
// function

mod Test01 {


    use BasicDb.DbConnection
    use BasicDb.DbStatement


    def duckdb_action1(): Unit -> Unit \ DbConnection +  {IO} = _ ->
        let stmt = DbConnection.createStatement();
        let _ = DbStatement.runWithIO(stmt, () -> { 
            let _ = DbStatement.execute("CREATE SCHEMA IF NOT EXISTS facts;");
            let _ = DbStatement.execute("CREATE TABLE IF NOT EXISTS facts.databases (name VARCHAR PRIMARY KEY NOT NULL, year int);");
            ()
            });         
        ()

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

    // // @test
    // def test01(): Int32 \ IO =
    //     let path1 = Basis.NIO.File.Path.newPath("e:/coding/flix/flix-basicdb/data/dbms1.sqlite") 
    //                     |> Result.getWithDefault(Basis.NIO.File.Path.empty());
    //     match BasicDb.DbMonad.runSQLite(rc, action1(rc), path1) {
    //         case Err(e) => {println("Error: ${e}"); 1}
    //         case Ok(_)  => 0
    //     }
    // }



    // def action1(rc: Region[r1]): DbMonad[r, ka, r + r1 + IO, Bool] = 
    //     BasicDb.DbMonad.executeSql!(rc, "DROP TABLE IF EXISTS dbms;")                                                   >>= _       ->
    //     BasicDb.DbMonad.executeSql!(rc, "CREATE TABLE IF NOT EXISTS dbms (name text PRIMARY KEY NOT NULL, year int);")  >>= _       ->
    //     BasicDb.DbMonad.prepareStatement!(rc, "INSERT INTO dbms(name, year) VALUES(?,?)")                           >>= pstmt   ->
    //     BasicDb.DbMonad.setAutoCommit!(false)                                                                       >>= _       ->
    //     BasicDb.DbMonad.psExecuteUpdate!(pstmt, setPStmt!("SQLite", 2000))                                          >>= _       ->
    //     BasicDb.DbMonad.psExecuteUpdate!(pstmt, setPStmt!("DuckDB", 2019))                                          >>= _       ->
    //     BasicDb.DbMonad.psExecuteUpdate!(pstmt, setPStmt!("MonetDB", 2002))                                         >>= _       ->
    //     BasicDb.DbMonad.psExecuteUpdate!(pstmt, setPStmt!("PostgresSQL", 1996))                                     >>= _       ->
    //     BasicDb.DbMonad.commit!()                                                                                   >>= _       ->
    //     BasicDb.DbMonad.createStatement!(rc)                                                                        >>= stmt    ->
    //     BasicDb.DbMonad.executeQuery!(rc, "SELECT name, year FROM dbms ORDER BY year", stmt)                        >>= rs      -> 
    //     BasicDb.DbMonad.foreachRow(rsEvalRow(), rs)                                                                 >>= _       ->
    //     BasicDb.DbMonad.rsClose!(rs)                                                                                >>= _       ->
    //     point(true)

    // def setPStmt!(name: String, year: Int32): PreparedStatementSetter[r, ka, r, Unit] = 
    //     use BasicDb.PreparedStatementSetter.{putStringAt!, putInt32At!};
    //     putStringAt!(0,  name)  >>= _ -> 
    //     putInt32At!( 1,  year)  >>= _ -> 
    //     point()

    // def rsEvalRow(): RowEvaluator[r, ka, r + IO, Unit] = 
    //     use BasicDb.RowEvaluator.{getStringAt, getInt32At, liftAction};
    //     getStringAt(0)                                                  >>= name    -> 
    //     getInt32At(1)                                                   >>= year    ->
    //     liftAction(_ -> println(name + ", " + Int32.toString(year)))    >>= _       -> 
    //     point()


