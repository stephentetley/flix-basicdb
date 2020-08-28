use BasicDb.DbMonad;
use BasicDb.ResultsMonad;
use BasicDb.RowEvaluator;
use BasicDb.RowWriter;

use BasicDb/DbMonad.{runSQLite, execute, prepareStatement, setAutoCommit, commit, writeRow, evalResults};


def test1(): DbMonad[Bool] = 
    use BasicDb/DbMonad.{flatMap, return};
    let* _      = execute("DROP TABLE IF EXISTS dbms;");
    let* _      = execute("CREATE TABLE IF NOT EXISTS dbms (name text PRIMARY KEY NOT NULL, year int);");
    let* stmt   = prepareStatement("INSERT INTO dbms(name, year) VALUES(?,?)");
    let* _      = setAutoCommit(false);
    let* _      = writeRow(stmt, dbmsWriter("SQLite", 2000));
    let* _      = writeRow(stmt, dbmsWriter("DuckDB", 2019));
    let* _      = writeRow(stmt, dbmsWriter("MonetDB", 2002));
    let* _      = writeRow(stmt, dbmsWriter("PostgresSQL", 1996));
    let* _      = commit();
    let* _      = evalResults("SELECT * from dbms", BasicDb/ResultsMonad.allRowsX(dbmsEval()));
    return(true)

def dbmsWriter(name: String, year: Int32): RowWriter[Unit] = 
    use BasicDb/RowWriter.{flatMap, return, putString!, putInt32!};
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