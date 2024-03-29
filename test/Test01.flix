/// This is expected to be run with the sqlite-jdbc jar in the classpath, e.g on Windows:
/// 
/// > java -cp "./lib/*;../bin/flix-master.jar" ca.uwaterloo.flix.Main test
///

mod Test01 {


    use BasicDb.DbMonad
    use BasicDb.RowEvaluator
    use BasicDb.PreparedStatementSetter

    use GradedApplicative.{point}
    use GradedMonad.{>>=}


    @test
    def test01(): Int32 \ IO = region rc {
        let path1 = Basis.NIO.File.Path.newPath("e:/coding/flix/flix-basicdb/data/dbms1.sqlite") 
                        |> Result.getWithDefault(Basis.NIO.File.Path.empty());
        match BasicDb.DbMonad.runSQLite(rc, action1(rc), path1) {
            case Err(e) => {println("Error: ${e}"); 1}
            case Ok(_)  => 0
        }
    }

    def action1(rc: Region[r1]): DbMonad[r, ka, r + r1 + IO, Bool] = 
        BasicDb.DbMonad.executeSql!(rc, "DROP TABLE IF EXISTS dbms;")                                                   >>= _       ->
        BasicDb.DbMonad.executeSql!(rc, "CREATE TABLE IF NOT EXISTS dbms (name text PRIMARY KEY NOT NULL, year int);")  >>= _       ->
        BasicDb.DbMonad.prepareStatement!(rc, "INSERT INTO dbms(name, year) VALUES(?,?)")                           >>= pstmt   ->
        BasicDb.DbMonad.setAutoCommit!(false)                                                                       >>= _       ->
        BasicDb.DbMonad.psExecuteUpdate!(pstmt, setPStmt!("SQLite", 2000))                                          >>= _       ->
        BasicDb.DbMonad.psExecuteUpdate!(pstmt, setPStmt!("DuckDB", 2019))                                          >>= _       ->
        BasicDb.DbMonad.psExecuteUpdate!(pstmt, setPStmt!("MonetDB", 2002))                                         >>= _       ->
        BasicDb.DbMonad.psExecuteUpdate!(pstmt, setPStmt!("PostgresSQL", 1996))                                     >>= _       ->
        BasicDb.DbMonad.commit!()                                                                                   >>= _       ->
        BasicDb.DbMonad.createStatement!(rc)                                                                        >>= stmt    ->
        BasicDb.DbMonad.executeQuery!(rc, "SELECT name, year FROM dbms ORDER BY year", stmt)                        >>= rs      -> 
        BasicDb.DbMonad.foreachRow(rsEvalRow(), rs)                                                                 >>= _       ->
        BasicDb.DbMonad.rsClose!(rs)                                                                                >>= _       ->
        point(true)

    def setPStmt!(name: String, year: Int32): PreparedStatementSetter[r, ka, r, Unit] = 
        use BasicDb.PreparedStatementSetter.{putStringAt!, putInt32At!};
        putStringAt!(0,  name)  >>= _ -> 
        putInt32At!( 1,  year)  >>= _ -> 
        point()

    def rsEvalRow(): RowEvaluator[r, ka, r + IO, Unit] = 
        use BasicDb.RowEvaluator.{getStringAt, getInt32At, liftAction};
        getStringAt(0)                                                  >>= name    -> 
        getInt32At(1)                                                   >>= year    ->
        liftAction(_ -> println(name + ", " + Int32.toString(year)))    >>= _       -> 
        point()

}
