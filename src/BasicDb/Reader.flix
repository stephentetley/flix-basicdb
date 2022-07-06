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



    pub def allRows(eval: RowEvaluator[r, a], sqlquery: String): DbMonad[r, List[a]] \ Write(r) =
        use BasicDb/DbMonad.{flatMap, point}; 
        let* stmt   = BasicDb/DbMonad.createStatement();
        let* rs     = BasicDb/DbMonad.executeQuery(stmt, sqlquery);
        let* rows   = BasicDb/DbMonad.allRows(rs, eval);
        let* _      = BasicDb/DbMonad.rsClose(rs);
        point(rows)


    /// TODO `combine` should allow effects
    pub def foldAllRows(combine: (b, a) -> b, 
                        ac: b, 
                        eval: RowEvaluator[r, a], sqlquery: String): DbMonad[r, b] \ Write(r) =
        use BasicDb/DbMonad.{flatMap, point}; 
        let* stmt   = BasicDb/DbMonad.createStatement();
        let* rs     = BasicDb/DbMonad.executeQuery(stmt, sqlquery);
        let* b      = BasicDb/DbMonad.foldAllRows(rs, combine, ac, eval);
        let* _      = BasicDb/DbMonad.rsClose(rs);
        point(b)


    pub def allRelations(eval: RowEvaluator[r, #{| reln}], sqlquery: String): DbMonad[r, #{| reln}] \ Write(r) =
        foldAllRows((ac, x) -> ac <+> x, #{}, eval, sqlquery)


}

