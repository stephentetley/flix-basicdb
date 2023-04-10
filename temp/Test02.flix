/// This is expected to be run with the sqlite-jdbc jar in the classpath, e.g on Windows:
/// 
/// > java -cp "./lib/*;../bin/flix.jar" ca.uwaterloo.flix.Main test
///

mod Test02 {


    use BasicDb.DbMonad
    use BasicDb.RowEvaluator
    use BasicDb.PreparedStatementSetter



    @test
    def testRead01(): Int32 \ IO = 
        region r1 {
            let path = Basis.NIO.File.Path.newPath("e:/coding/flix/flix-basicdb/data/langs.sqlite") 
                            |> Result.getWithDefault(Basis.NIO.File.Path.empty());
            match BasicDb.DbMonad.runSQLite(r1, query1(), path) {
                case Err(e) => {println("Error: ${e}"); 1}
                case Ok(_)  => 0
            }
        }

    def query1(): DbMonad[r, ka, Bool] \ { Write(r), IO }= 
        use BasicDb.DbMonad.{flatMap, point};
        let* stmt   = BasicDb.DbMonad.createStatement!();
        let* rs     = BasicDb.DbMonad.executeQuery!("SELECT name, year FROM langs ORDER BY year", stmt);
        let* _      = BasicDb.DbMonad.foreachRow(rsEvalRow(), rs);
        let* _      = BasicDb.DbMonad.rsClose!(rs);
        point(true)


    def rsEvalRow(): RowEvaluator[r, ka, Unit] \ { Read(r), IO} = 
        use BasicDb.RowEvaluator.{flatMap, point, getStringAt, getInt32At, liftAction};
        let* name   = getStringAt(0);
        let* year   = getInt32At(1);
        let* _      = liftAction(_ -> println(name + ", " + Int32.toString(year)));
        point()


}
