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

use BasicDb.ResultsMonad;
use BasicDb.ResultsMonad.{ResultsMonad};

use BasicDb.RowEvaluator;
use BasicDb.RowEvaluator.{RowEvaluator};

namespace BasicDb {

    pub opaque type ResultsMonad[a] = ##java.sql.ResultSet ~> Result[a, System.Error]

}

namespace BasicDb/ResultsMonad {

        
    pub def runResultsMonad(ma: ResultsMonad[a], results: ##java.sql.ResultSet): Result[a, System.Error] & Impure = apply1(ma, results)

    def apply1(ma: ResultsMonad[a], results: ##java.sql.ResultSet): Result[a, System.Error] & Impure = 
        let ResultsMonad(x1) = ma;
        x1(results)

    pub def return(x: a): ResultsMonad[a] = 
        ResultsMonad(_ -> Ok(x) as & Impure)

    pub def fail(e: System.Error): ResultsMonad[a] = 
        ResultsMonad(_ -> Err(e) as & Impure)


    pub def map(fn: a -> b, ma: ResultsMonad[a]): ResultsMonad[b] = 
        ResultsMonad(rs -> 
            match apply1(ma, rs) { 
                case Ok(a) => Ok(fn(a))
                case Err(e) => Err(e)
            }
        )

    pub def ap(mf: ResultsMonad[a -> b], ma: ResultsMonad[a]): ResultsMonad[b] = 
        ResultsMonad(rs -> 
            match apply1(mf, rs) { 
                case Ok(f) => match apply1(ma, rs) { 
                    case Ok(a) => Ok(f(a))
                    case Err(e) => Err(e)
                }
                case Err(e) => Err(e)
            }
        )

    pub def bind(ma: ResultsMonad[a], fn: a -> ResultsMonad[b]): ResultsMonad[b] = 
        ResultsMonad(rs -> 
            match apply1(ma, rs) { 
                case Ok(a) => apply1(fn(a), rs)
                case Err(e) => Err(e)
            }
        )

    pub def flatMap(fn: a -> ResultsMonad[b], ma: ResultsMonad[a]): ResultsMonad[b] = bind(ma, fn)

    def liftResultSetPrim(fn: ##java.sql.ResultSet ~> Result[a, System.Error]): ResultsMonad[a] = 
        ResultsMonad(rs -> fn(rs))

    pub def liftAction(fn: Unit ~> a): ResultsMonad[a] = 
        ResultsMonad(_ -> { let a = fn(); Ok(a) })

    pub def liftActionResult(fn: Unit ~> Result[a, System.Error]): ResultsMonad[a] = 
        ResultsMonad(_ -> fn())

    // DB operations
    pub def close(): ResultsMonad[Unit] =
        use BasicDb/Internal/ResultSet.{close};
        liftResultSetPrim(x -> x.close())
 
    pub def next(): ResultsMonad[Bool] =
        use BasicDb/Internal/ResultSet.{next};
        liftResultSetPrim(x -> x.next())

    pub def evalRow(eval: RowEvaluator[a]): ResultsMonad[a] =
        let RowEvaluator(f) = eval;
        liftResultSetPrim(x -> f(x))

    pub def allRows(eval: RowEvaluator[a]): ResultsMonad[List[a]] = 
        ResultsMonad(rs -> allRowsHelper(rs, eval, e -> Err(e), xs -> Ok(xs)))

    /// Start with `next`
    def allRowsHelper(rs: ##java.sql.ResultSet, 
                      eval: RowEvaluator[a], 
                      fk: System.Error -> Result[List[a], System.Error],
                      sk: List[a] -> Result[List[a], System.Error]): Result[List[a], System.Error] & Impure = 
        match apply1(next(), rs) {
            case Ok(false) => sk(Nil)
            case Ok(true) => match apply1(evalRow(eval), rs) {
                case Ok(x) => allRowsHelper(rs, eval, fk, ks -> sk(x :: ks))
                case Err(e) => fk(e)
            }
            case Err(e) => fk(e)
        }


    pub def allRowsX(eval: RowEvaluator[a]): ResultsMonad[Unit] = 
        ResultsMonad(rs -> allRowsXHelper(rs, eval, e -> Err(e)))

    /// Start with `next`
    def allRowsXHelper(rs: ##java.sql.ResultSet, 
                      eval: RowEvaluator[a], 
                      fk: System.Error -> Result[Unit, System.Error]): Result[Unit, System.Error] & Impure = 
        match apply1(next(), rs) {
            case Ok(false) => Ok()
            case Ok(true) => match apply1(evalRow(eval), rs) {
                case Ok(_) => allRowsXHelper(rs, eval, fk)
                case Err(e) => fk(e)
            }
            case Err(e) => fk(e)
        }
}

