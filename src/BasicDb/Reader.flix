/*
 * Copyright 2022 Stephen Tetley
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

namespace BasicDb/Reader {


    use BasicDb.DbMonad;
    use BasicDb.RowEvaluator;
    use BasicDb.RowEvaluator.{RowEvaluator};

    use GradedApplicative.{point}
    use GradedMonad.{>>=}

    pub def allRows(rc: Region[r1], sql: String, eval: RowEvaluator[r1, a, ef, a]): DbMonad[r, a, r and r1 and ef and Impure, List[a]] =        
        BasicDb/DbMonad.createStatement!(rc)            >>= stmt    ->
        BasicDb/DbMonad.executeQuery!(rc, sql, stmt)    >>= rs      -> 
        BasicDb/DbMonad.allRows(eval, rs)               >>= rows    ->
        BasicDb/DbMonad.rsClose!(rs)                    >>= _       -> 
        point(rows)

    /// `combine` should allow effects
    pub def foldAllRows(rc: Region[r1], 
                        combine: (b, a) -> b \ ef1, 
                        ac: b, 
                        sql: String, 
                        eval: RowEvaluator[r1, a, ef, a]): DbMonad[r, a, r and r1 and ef and ef1 and Impure, b] =
        BasicDb/DbMonad.createStatement!(rc)                >>= stmt    ->
        BasicDb/DbMonad.executeQuery!(rc, sql, stmt)        >>= rs      -> 
        BasicDb/DbMonad.foldAllRows(combine, ac, eval, rs)  >>= b       -> 
        BasicDb/DbMonad.rsClose!(rs)                        >>= _       -> 
        point(b)


    pub def allRelations(rc: Region[r1], sql: String, eval: RowEvaluator[r1, #{| reln}, ef, #{| reln}]): DbMonad[r, #{| reln}, r and r1 and ef and Impure, #{| reln}] =
        foldAllRows(rc, (ac, x) -> ac <+> x, #{}, sql, eval)



}

