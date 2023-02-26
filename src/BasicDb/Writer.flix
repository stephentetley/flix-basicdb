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

namespace BasicDb/Writer {
    
    use GradedMonad.{>>=}
    use BasicDb.DbMonad
    use BasicDb.PreparedStatementSetter
    
    pub type alias RowSetter[r: Region, row: Type, ef: Bool, a: Type] = row -> PreparedStatementSetter[r, a, ef, a]



    pub def store(rc: Region[r1], 
                    sqlstrings: {prepStmt = String, tableActions = List[String]}, 
                    setter: RowSetter[r1, row, ef, a], 
                    rows: t[row]): DbMonad[r, ka, r and r1 and ef and Impure, Int32] with GradedFoldable[t] =
        use BasicDb/DbMonad.{flatMap, point};
        let* _          = BasicDb/DbMonad.setAutoCommit!(false);
        let* _          = GradedFoldable.forEachM(BasicDb/DbMonad.executeSql!, sqlstrings.tableActions);
        let* stmt       = BasicDb/DbMonad.prepareStatement!(rc, sqlstrings.prepStmt);
        let* nrows      = GradedFoldable.foldLeftM((ac, x) -> 
                                {let* n = BasicDb/DbMonad.psExecuteUpdate!(stmt, setter(x)); point(ac+n)}, 0, rows);
        let* _          = BasicDb/DbMonad.commit!();
        point(nrows)


    pub def storeList(rc: Region[r1], 
                        sqlstrings: {prepStmt = String, tableActions = List[String]}, 
                        setter: RowSetter[r1, row, ef, a], 
                        rows: List[row]): DbMonad[r, ka, r and r1 and ef and Impure, Int32] =
        use BasicDb/DbMonad.{flatMap, point};
        let* _          = BasicDb/DbMonad.setAutoCommit!(false);
        let* _          = GradedFoldable.forEachM(BasicDb/DbMonad.executeSql!, sqlstrings.tableActions);
        let* stmt       = BasicDb/DbMonad.prepareStatement!(rc, sqlstrings.prepStmt);
        let* nrows      = GradedFoldable.foldLeftM((ac, x) -> 
                                {let* n = BasicDb/DbMonad.psExecuteUpdate!(stmt, setter(x)); point(ac+n)}, 0, rows);
        let* _          = BasicDb/DbMonad.commit!();
        point(nrows)

    pub def storeArray(rc: Region[r1], 
                        sqlstrings: {prepStmt = String, tableActions = List[String]}, 
                        setter: RowSetter[r1, row, ef, a], 
                        rows: Array[row, r2]): DbMonad[r, ka, r and r1 and r2 and ef and Impure, Int32] =
        BasicDb/DbMonad.liftAction(_ -> Array.toList(rows)) >>= store(rc, sqlstrings, setter)


        

}

