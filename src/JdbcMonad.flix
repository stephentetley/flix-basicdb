/*
 * Copyright 2020 Stephen Tetley
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

use BasicDb.JdbcMonad;
use BasicDb.JdbcMonad.{JdbcMonad};

namespace BasicDb {

    pub opaque type JdbcMonad[a] = ##java.sql.Connection ~> Result[a, System.Error]

}

namespace BasicDb/JdbcMonad {

    pub def runJdbcMonad(ma: JdbcMonad[a], url: String): Result[a, System.Error] & Impure = 
        use BasicDb/Internal/Prim.{dmGetConnection, closeConnection};
        use Result.{flatMap};
        match dmGetConnection(url) { 
            case Err(e) => Err(e)
            case Ok(conn) => {
                let ans = apply1(ma, conn);
                let* _ = closeConnection(conn);
                ans         
            }
        }
        

    pub def runSQLite(ma: JdbcMonad[a], path: System.FilePath): Result[a, System.Error] & Impure = 
        use System/FilePath.{toString};
        let url = "jdbc:sqlite:" + path.toString();
        runJdbcMonad(ma, url)

    pub def runDuckDB(ma: JdbcMonad[a], path: System.FilePath): Result[a, System.Error] & Impure = 
        use System/FilePath.{toString};
        let url = "jdbc:duckdb:" + path.toString();
        runJdbcMonad(ma, url)


    def apply1(ma: JdbcMonad[a], conn: ##java.sql.Connection): Result[a, System.Error] & Impure = 
        let JdbcMonad(x1) = ma;
        x1(conn)

    pub def return(x: a): JdbcMonad[a] = 
        JdbcMonad(_ -> Ok(x) as & Impure)

    pub def map(fn: a -> b, ma: JdbcMonad[a]): JdbcMonad[b] = 
        JdbcMonad(conn -> 
            match apply1(ma, conn) { 
                case Ok(a) => Ok(fn(a))
                case Err(e) => Err(e)
            }
        )

    pub def ap(mf: JdbcMonad[a -> b], ma: JdbcMonad[a]): JdbcMonad[b] = 
        JdbcMonad(conn -> 
            match apply1(mf, conn) { 
                case Ok(f) => match apply1(ma, conn) { 
                    case Ok(a) => Ok(f(a))
                    case Err(e) => Err(e)
                }
                case Err(e) => Err(e)
            }
        )

    pub def bind(ma: JdbcMonad[a], fn: a -> JdbcMonad[b]): JdbcMonad[b] = 
        JdbcMonad(conn -> 
            match apply1(ma, conn) { 
                case Ok(a) => apply1(fn(a), conn)
                case Err(e) => Err(e)
            }
        )

    pub def flatMap(fn: a -> JdbcMonad[b], ma: JdbcMonad[a]): JdbcMonad[b] = bind(ma, fn)

    def liftConnectionPrim(fn: ##java.sql.Connection ~> Result[a, System.Error]): JdbcMonad[a] = 
        JdbcMonad(conn -> fn(conn))

    pub def liftAction(fn: Unit ~> a): JdbcMonad[a] = 
        JdbcMonad(_ -> { let a = fn(); Ok(a) })

    pub def liftActionResult(fn: Unit ~> Result[a, System.Error]): JdbcMonad[a] = 
        JdbcMonad(_ -> fn())



    pub def executeStatement(sql: String): JdbcMonad[Bool] = 
        use BasicDb/Internal/Prim.{createStatement, executeStatement => execute, closeStatement};
        let* stmt   = liftConnectionPrim(createStatement);
        let* ans    = liftActionResult(_ -> execute(stmt, sql));
        let* _      = liftActionResult(_ -> closeStatement(stmt));
        return(ans)

}

