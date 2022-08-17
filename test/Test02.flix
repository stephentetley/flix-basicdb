/// This is expected to be run with the sqlite-jdbc jar in the classpath, e.g on Windows:
/// 
/// > java -cp "./lib/*;../bin/flix-working.jar" ca.uwaterloo.flix.Main test
///

namespace Test02 {

    use BasicDb.DbMonad;
    use BasicDb.ResultsMonad;
    use BasicDb.RowEvaluator;
    use BasicDb.PreparedStatementSetter;

    use BasicDb/DbMonad.{runSQLite, execute, createStatement, prepareStatement, 
            setAutoCommit, commit, psExecuteUpdate, executeQuery, allRowsX, rsClose};


    @test
    def testRead01(): Int32 & Impure = 
        region r1 {
            let path = Basis/System/FilePath.filePath("e:/coding/flix/flix-basicdb/data/langs.sqlite") |> Result.getWithDefault(Basis/System/FilePath.empty());
            match runSQLite(r1, query1(), path) {
                case Err(e) => {println("Error: ${e}"); 1}
                case Ok(_) => 0
            }
        }

    def query1(): DbMonad[r, Bool] \ { Write(r), Impure }= 
        use BasicDb/DbMonad.{flatMap, point};
        let* stmt   = createStatement();
        let* rs     = executeQuery(stmt, "SELECT name, year FROM langs ORDER BY year");
        let* _      = allRowsX(rs, rsEvalRow());
        let* _      = rsClose(rs);
        point(true)


    def rsEvalRow(): RowEvaluator[r, Unit] \ { Read(r), Impure} = 
        use BasicDb/RowEvaluator.{flatMap, point, getStringAt, getInt32At, liftAction};
        let* name   = getStringAt(0);
        let* year   = getInt32At(1);
        let* _      = liftAction(_ -> println(name + ", " + Int32.toString(year)));
        point()


}