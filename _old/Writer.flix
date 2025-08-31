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

mod BasicDb.Writer {
    
    use GradedApplicative.{point}
    use GradedMonad.{>>=}
    
    use BasicDb.DbMonad
    use BasicDb.PreparedStatementSetter
    

    
    pub type alias RowSetter[r: Region, row: Type, ef: Eff, a: Type] = row -> PreparedStatementSetter[r, a, ef, a]



    pub def store(rc: Region[r1], 
                    sqlstrings: {prepStmt = String, tableActions = List[String]}, 
                    setter: RowSetter[r1, row, ef, a], 
                    rows: t[row]): DbMonad[r, ka, r + r1 + ef + Impure, Int32] with GradedFoldable[t] =
        BasicDb.DbMonad.setAutoCommit!(false)                                                   >>= _       -> 
        GradedFoldable.forEachM(BasicDb.DbMonad.executeSql!(rc), sqlstrings.tableActions)       >>= _       -> 
        BasicDb.DbMonad.prepareStatement!(rc, sqlstrings.prepStmt)                              >>= stmt    ->
        GradedFoldable.foldLeftM((ac, x) -> 
            {BasicDb.DbMonad.psExecuteUpdate!(stmt, setter(x)) >>= n -> point(ac+n)}, 0, rows)  >>= nrows   -> 
        BasicDb.DbMonad.commit!()                                                               >>= _       -> 
        point(nrows)


    pub def storeList(rc: Region[r1], 
                        sqlstrings: {prepStmt = String, tableActions = List[String]}, 
                        setter: RowSetter[r1, row, ef, a], 
                        rows: List[row]): DbMonad[r, ka, r + r1 + ef + IO, Int32] =
        BasicDb.DbMonad.setAutoCommit!(false)                                                   >>= _       -> 
        GradedFoldable.forEachM(BasicDb.DbMonad.executeSql!(rc), sqlstrings.tableActions)       >>= _       -> 
        BasicDb.DbMonad.prepareStatement!(rc, sqlstrings.prepStmt)                              >>= stmt    -> 
        GradedFoldable.foldLeftM((ac, x) -> 
            {BasicDb.DbMonad.psExecuteUpdate!(stmt, setter(x)) >>= n -> point(ac+n)}, 0, rows)  >>= nrows   ->
        BasicDb.DbMonad.commit!()                                                               >>= _       ->
        point(nrows)

    pub def storeArray(rc: Region[r1], 
                        sqlstrings: {prepStmt = String, tableActions = List[String]}, 
                        setter: RowSetter[r1, row, ef, a], 
                        rows: Array[row, r2]): DbMonad[r, ka, r + r1 + r2 + ef + IO, Int32] =
        BasicDb.DbMonad.liftAction(_ -> Array.toList(rows)) >>= store(rc, sqlstrings, setter)


        

}

