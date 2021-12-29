use BasicDb.DbMonad;
use BasicDb.ResultsMonad;
use BasicDb.RowEvaluator;
use BasicDb.PreparedStatementSetter;

use BasicDb/DbMonad.{runSQLite, execute, createStatement, prepareStatement, 
        setAutoCommit, commit, psExecuteUpdate, executeQuery, allRowsX, rsClose};


def test1(): DbMonad[Bool] = 
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

def setPStmt!(name: String, year: Int32): PreparedStatementSetter[Unit] = 
    use BasicDb/PreparedStatementSetter.{flatMap, point, putStringAt!, putInt32At!};
    let* _ = putStringAt!(0,  name);
    let* _ = putInt32At!( 1,  year);
    point()

def rsEvalRow(): RowEvaluator[Unit] = 
    use BasicDb/RowEvaluator.{flatMap, point, getStringAt, getInt32At, liftAction};
    let* name   = getStringAt(0);
    let* year   = getInt32At(1);
    let* _      = liftAction(_ -> println(name + ", " + Int32.toString(year)));
    point()


def main(_args: Array[String]): Int32 & Impure = 
    match runSQLite(test1(), System/FilePath.new("e:/coding/flix/flix-basicdb/data/dbms1.sqlite")) {
        case Err(e) => {println("Error: ${e}"); 1}
        case Ok(_) => 0
    }