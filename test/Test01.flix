use BasicDb.JdbcMonad;
use BasicDb/JdbcMonad.{runSQLite, executeStatement};


def test1(): JdbcMonad[Bool] = 
    use BasicDb/JdbcMonad.{flatMap};
    let* _ = executeStatement("DROP TABLE IF EXISTS dbms;");
    executeStatement("CREATE TABLE IF NOT EXISTS dbms (name text PRIMARY KEY NOT NULL, year int);")


def main(): Unit & Impure = 
    match runSQLite(test1(), System/FilePath.new("e:/coding/flix/flix-basicdb/data/dbms1.sqlite")) {
        case Err(e) => Console.printLine(System/Error.toString(e))
        case Ok(_) => ()
    }