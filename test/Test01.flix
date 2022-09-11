/// This is expected to be run with the sqlite-jdbc jar in the classpath, e.g on Windows:
/// 
/// > java -cp "./lib/*;../bin/flix.jar" ca.uwaterloo.flix.Main test
///

namespace Test01 {

/*
    use BasicDb.DbMonad;
    use BasicDb.ResultsMonad;
    use BasicDb.RowEvaluator;
    use BasicDb.PreparedStatementSetter;

    use BasicDb/DbMonad.{runSQLite, execute, createStatement, prepareStatement, 
            setAutoCommit, commit, psExecuteUpdate, executeQuery, allRowsX, rsClose};


    @test
    def test01(): Int32 \ IO = 
        region r1 {
            let path1 = Basis/System/FilePath.filePath("e:/coding/flix/flix-basicdb/data/dbms1.sqlite") |> Result.getWithDefault(Basis/System/FilePath.empty());
            match runSQLite(r1, action1(), path1) {
                case Err(e) => {println("Error: ${e}"); 1}
                case Ok(_) => 0
            }
        }

    def action1(): DbMonad[r, Bool, Bool] \ { Write(r), IO }= 
        use BasicDb/DbMonad.{flatMap, point};
        let* _      = execute("DROP TABLE IF EXISTS dbms;");
        let* _      = execute("CREATE TABLE IF NOT EXISTS dbms (name text PRIMARY KEY NOT NULL, year int);");
        let* pstmt  = prepareStatement("INSERT INTO dbms(name, year) VALUES(?,?)");
        let* _      = setAutoCommit(false);
        let* _      = psExecuteUpdate(pstmt, setPStmt!("SQLite", 2000));
        let* _      = psExecuteUpdate(pstmt, setPStmt!("DuckDB", 2019));
        let* _      = psExecuteUpdate(pstmt, setPStmt!("MonetDB", 2002));
        let* _      = psExecuteUpdate(pstmt, setPStmt!("PostgresSQL", 1996));
        let* _      = commit();
        let* stmt   = createStatement();
        let* rs     = executeQuery(stmt, "SELECT name, year FROM dbms ORDER BY year");
        let* _      = allRowsX(rs, rsEvalRow());
        let* _      = rsClose(rs);
        point(true)

    def setPStmt!(name: String, year: Int32): PreparedStatementSetter[r, Unit] \ Write(r) = 
        use BasicDb/PreparedStatementSetter.{flatMap, point, putStringAt!, putInt32At!};
        let* _ = putStringAt!(0,  name);
        let* _ = putInt32At!( 1,  year);
        point()

    def rsEvalRow(): RowEvaluator[r, Unit] \ { Read(r), IO} = 
        use BasicDb/RowEvaluator.{flatMap, point, getStringAt, getInt32At, liftAction};
        let* name   = getStringAt(0);
        let* year   = getInt32At(1);
        let* _      = liftAction(_ -> println(name + ", " + Int32.toString(year)));
        point()

*/

}
