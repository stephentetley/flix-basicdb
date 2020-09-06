use BasicDb.DbMonad;
use BasicDb.ResultsMonad;
use BasicDb.RowEvaluator;
use BasicDb.PreparedStatementSetter;

use BasicDb/DbMonad.{runSQLite, execute, prepareStatement, setAutoCommit, commit, executeUpdate, evalResults};


def test1(): DbMonad[Bool] = 
    use BasicDb/DbMonad.{flatMap, return};
    let* _      = execute("DROP TABLE IF EXISTS dbms;");
    let* _      = execute("CREATE TABLE IF NOT EXISTS dbms (name text PRIMARY KEY NOT NULL, year int);");
    let* pstmt  = prepareStatement("INSERT INTO dbms(name, year) VALUES(?,?)");
    let* _      = setAutoCommit(false);
    let* _      = executeUpdate(pstmt, setPStmt!("SQLite", 2000));
    let* _      = executeUpdate(pstmt, setPStmt!("DuckDB", 2019));
    let* _      = executeUpdate(pstmt, setPStmt!("MonetDB", 2002));
    let* _      = executeUpdate(pstmt, setPStmt!("PostgresSQL", 1996));
    let* _      = commit();
    let* _      = evalResults("SELECT name, year FROM dbms ORDER BY year", BasicDb/ResultsMonad.allRowsX(dbmsEval()));
    return(true)

def setPStmt!(name: String, year: Int32): PreparedStatementSetter[Unit] = 
    use BasicDb/PreparedStatementSetter.{flatMap, return, putString!, putInt32!};
    let* _ = putString!(0,  name);
    let* _ = putInt32!( 1,  year);
    return()

def dbmsEval(): RowEvaluator[Unit] = 
    use BasicDb/RowEvaluator.{flatMap, return, getString, getInt32, liftAction};
    let* name   = getString(0);
    let* year   = getInt32(1);
    let* _      = liftAction(_ -> Console.printLine(name + ", " + Int32.toString(year)));
    return()


def main(): Unit & Impure = 
    match runSQLite(test1(), System/FilePath.new("e:/coding/flix/flix-basicdb/data/dbms1.sqlite")) {
        case Err(e) => Console.printLine(System/Error.toString(e))
        case Ok(_) => ()
    }