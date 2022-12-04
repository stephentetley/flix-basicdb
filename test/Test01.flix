/// This is expected to be run with the sqlite-jdbc jar in the classpath, e.g on Windows:
/// 
/// > java -cp "./lib/*;../bin/flix.jar" ca.uwaterloo.flix.Main test
///

namespace Test01 {


    use BasicDb.DbMonad
    use BasicDb.RowEvaluator
    use BasicDb.PreparedStatementSetter



    @test
    def test01(): Int32 \ IO = 
        region r1 {
            let path1 = Basis/NIO/File/Path.newPath("e:/coding/flix/flix-basicdb/data/dbms1.sqlite") |> Result.getWithDefault(Basis/NIO/File/Path.empty());
            match BasicDb/DbMonad.runSQLite(r1, action1(), path1) {
                case Err(e) => {println("Error: ${e}"); 1}
                case Ok(_)  => 0
            }
        }

    def action1(): DbMonad[r, ka, Bool] \ { Write(r), IO }= 
        use BasicDb/DbMonad.{flatMap, point};
        let* _      = BasicDb/DbMonad.executeSql!("DROP TABLE IF EXISTS dbms;");
        let* _      = BasicDb/DbMonad.executeSql!("CREATE TABLE IF NOT EXISTS dbms (name text PRIMARY KEY NOT NULL, year int);");
        let* pstmt  = BasicDb/DbMonad.prepareStatement!("INSERT INTO dbms(name, year) VALUES(?,?)");
        let* _      = BasicDb/DbMonad.setAutoCommit!(false);
        let* _      = BasicDb/DbMonad.psExecuteUpdate!(pstmt, setPStmt!("SQLite", 2000));
        let* _      = BasicDb/DbMonad.psExecuteUpdate!(pstmt, setPStmt!("DuckDB", 2019));
        let* _      = BasicDb/DbMonad.psExecuteUpdate!(pstmt, setPStmt!("MonetDB", 2002));
        let* _      = BasicDb/DbMonad.psExecuteUpdate!(pstmt, setPStmt!("PostgresSQL", 1996));
        let* _      = BasicDb/DbMonad.commit!();
        let* stmt   = BasicDb/DbMonad.createStatement!();
        let* rs     = BasicDb/DbMonad.executeQuery!("SELECT name, year FROM dbms ORDER BY year", stmt);
        let* _      = BasicDb/DbMonad.foreachRow(rsEvalRow(), rs);
        let* _      = BasicDb/DbMonad.rsClose!(rs);
        point(true)

    def setPStmt!(name: String, year: Int32): PreparedStatementSetter[r, ka, Unit] \ Write(r) = 
        use BasicDb/PreparedStatementSetter.{flatMap, point, putStringAt!, putInt32At!};
        let* _ = putStringAt!(0,  name);
        let* _ = putInt32At!( 1,  year);
        point()

    def rsEvalRow(): RowEvaluator[r, ka, Unit] \ { Read(r), IO} = 
        use BasicDb/RowEvaluator.{flatMap, point, getStringAt, getInt32At, liftAction};
        let* name   = getStringAt(0);
        let* year   = getInt32At(1);
        let* _      = liftAction(_ -> println(name + ", " + Int32.toString(year)));
        point()



}
