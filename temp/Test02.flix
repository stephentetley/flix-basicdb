/// This is expected to be run with the sqlite-jdbc jar in the classpath, e.g on Windows:
/// 
/// > java -cp "./lib/*;../bin/flix.jar" ca.uwaterloo.flix.Main test
///

mod Test02 {

    use GradedApplicative.{point}
    use GradedMonad.{>>=}

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

    def query1(): DbMonad[r, ka, Bool] \ {Write(r), IO}= 
        BasicDb.DbMonad.createStatement!()                                                  >>= stmt ->
        BasicDb.DbMonad.executeQuery!("SELECT name, year FROM langs ORDER BY year", stmt)   >>= rs   ->
        BasicDb.DbMonad.foreachRow(rsEvalRow(), rs)                                         >>= _    -> 
        BasicDb.DbMonad.rsClose!(rs)                                                        >>= _    ->
        point(true)


    def rsEvalRow(): RowEvaluator[r, ka, Unit] \ { Read(r), IO} = 
        use BasicDb.RowEvaluator.{getStringAt, getInt32At, liftAction};
        getStringAt(0)                                                  >>= name ->
        getInt32At(1)                                                   >>= year -> 
        liftAction(_ -> println(name + ", " + Int32.toString(year)))    >>= _ ->
        point()


}
