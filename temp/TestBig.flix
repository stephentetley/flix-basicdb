/// This is expected to be run with the sqlite-jdbc jar in the classpath, e.g on Windows:
/// 
/// > java -cp "./lib/*;../bin/flix.jar" ca.uwaterloo.flix.Main test
///

mod TestBig {

    use GradedApplicative.{point, *>}
    use GradedMonad.{>>=}

    use BasicDb.DbMonad
    use BasicDb.RowEvaluator
    use BasicDb.PreparedStatementSetter



    @test
    def test01(): Int32 \ IO = 
        region r1 {
            let path1 = Basis.NIO.File.Path.newPath("e:/coding/flix/flix-basicdb/data/numbers.sqlite") 
                            |> Result.getWithDefault(Basis.NIO.File.Path.empty());
            match BasicDb.DbMonad.runSQLite(r1, storeNumbers(1000, "small"), path1) {
                case Err(e) => println("Error: ${e}")
                case Ok(b)  => println("Ok: ${b}")
            };
            match BasicDb.DbMonad.runSQLite(r1, storeNumbers(100000, "medium"), path1) {
                case Err(e) => println("Error: ${e}")
                case Ok(b)  => println("Ok: ${b}")
            };
            match BasicDb.DbMonad.runSQLite(r1, storeNumbers(1000000, "large"), path1) {
                case Err(e) => println("Error: ${e}")
                case Ok(b)  => println("Ok: ${b}")
            };
            0
        }

    def storeNumbers(n: Int32, tableName: String): DbMonad[r, ka, ef, Int32] \ {IO, r} = 
        BasicDb.DbMonad.executeSql!("DROP TABLE IF EXISTS ${tableName};")                                                           >>= _ ->
        BasicDb.DbMonad.executeSql!("CREATE TABLE IF NOT EXISTS ${tableName} (integer_value int PRIMARY KEY NOT NULL, accum int);") >>= _ ->
        BasicDb.DbMonad.prepareStatement!("INSERT INTO ${tableName}(integer_value, accum) VALUES(?, ?)")                            >>= pstmt ->
        BasicDb.DbMonad.setAutoCommit!(false)                                                                                       >>= _ ->
        List.range(0, n)                                                                                                            >>= nums ->
        Foldable.foldLeftM((acc, i) -> BasicDb.DbMonad.psExecuteUpdate!(pstmt, setPStmt!(i, acc)) *> point(acc+1), 0 , nums)        >>= _ -> ans ->
        BasicDb.DbMonad.commit!()                                                                                                   >>= _ ->
        point(ans)

    def setPStmt!(ival: Int32, acc: Int32): PreparedStatementSetter[r, ka, r, Unit] = 
        use BasicDb.PreparedStatementSetter.{putInt32At!};
        putInt32At!(0, ival) *> putInt32At!(1, acc) *> point()

}
