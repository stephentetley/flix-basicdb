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
    use GradedMonad.{>>=};
    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;
    
    pub type alias RowSetter[r: Region, row: Type, ef: Bool, a: Type] = row -> PreparedStatementSetter[r, a, ef, a]



    pub def store(sqlstrings: {prepStmt = String, tableActions = List[String]}, 
                    setter: RowSetter[r, row, ef, a], 
                    rows: t[row]): DbMonad[r, ka, r and ef and Impure, Int32] with GradedFoldable[t] =
        use BasicDb/DbMonad.{flatMap, point};
        let* _          = BasicDb/DbMonad.setAutoCommit!(false);
        let* _          = GradedFoldable.forEachM(BasicDb/DbMonad.executeSql!, sqlstrings.tableActions);
        let* stmt       = BasicDb/DbMonad.prepareStatement!(sqlstrings.prepStmt);
        let* nrows      = GradedFoldable.foldLeftM((ac, x) -> 
                                {let* n = BasicDb/DbMonad.psExecuteUpdate!(stmt, setter(x)); point(ac+n)}, 0, rows);
        let* _          = BasicDb/DbMonad.commit!();
        point(nrows)


    pub def storeList(sqlstrings: {prepStmt = String, tableActions = List[String]}, 
                    setter: RowSetter[r, row, ef, a], 
                    rows: List[row]): DbMonad[r, ka, r and ef and Impure, Int32] =
        use BasicDb/DbMonad.{flatMap, point};
        let* _          = BasicDb/DbMonad.setAutoCommit!(false);
        let* _          = GradedFoldable.forEachM(BasicDb/DbMonad.executeSql!, sqlstrings.tableActions);
        let* stmt       = BasicDb/DbMonad.prepareStatement!(sqlstrings.prepStmt);
        let* nrows      = GradedFoldable.foldLeftM((ac, x) -> 
                                {let* n = BasicDb/DbMonad.psExecuteUpdate!(stmt, setter(x)); point(ac+n)}, 0, rows);
        let* _          = BasicDb/DbMonad.commit!();
        point(nrows)

    pub def storeArray(sqlstrings: {prepStmt = String, tableActions = List[String]}, 
                    setter: RowSetter[r, row, ef, a], 
                    rows: Array[row, r2]): DbMonad[r, ka, r and r2 and ef and Impure, Int32] =
        BasicDb/DbMonad.liftAction(_ -> Array.toList(rows)) >>= store(sqlstrings, setter)


    // pub def storeRelations(sqlstrings: {prepStmt = String, tableActions = List[String]}, 
    //                 setter: RowSetter[r, row, ef, a], 
    //                 extractor: {| rr} -> Array[row, r2] \ Write(r),
    //                 reln: {| rr}): DbMonad[r, ka, ef, Int32] \ {IO, ef, Write(r), Write(r2)} =
    //     BasicDb/DbMonad.liftAction(_ -> (extractor(reln) |> Array.toList)) >>= store(sqlstrings, setter)
        
/*
    /// Note - Foldable.foldLeftM uses Monad not GradedMonad...
    pub def foldLeftM[m: Bool -> Type -> Type, ef: Bool, ef1: Bool, a: Type, b: Type]
                        (f: (b, a) -> m[ef, b] \ ef1, s: b, l: List[a]): m[ef and ef1, b] with GradedMonad[m] = 
        foldLeftMHelper(f, GradedApplicative.point(s), l)

    def foldLeftMHelper[m: Bool -> Type -> Type, ef: Bool, ef1: Bool, a: Type, b: Type]
                        (f: (b, a) -> m[ef, b] \ ef1,
                        acc: m[ef and ef1, b], 
                        xs: List[a]): m[ef and ef1, b] with GradedMonad[m] =
        match xs {
            case Nil     => acc
            case x :: rs => {let ms1 = GradedMonad.flatMap(s -> f(s, x), acc); foldLeftMHelper(f, ms1, rs) }
        }

    /// `append` versions without tableActions?

*/
}

