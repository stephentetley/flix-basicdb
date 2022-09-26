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
    use Monad.{>>=};
    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;
    
    pub type alias RowSetter[r: Region, row: Type, a: Type, ef: Bool] = row -> PreparedStatementSetter[r, a, a] \ ef



    pub def store(sqlstrings: {prepStmt = String, tableActions = List[String]}, 
                    setter: RowSetter[r, row, a, ef], 
                    rows: t[row]): DbMonad[r, ka, Int32] \ {IO, ef, Write(r)} with Foldable[t] =
        use BasicDb/DbMonad.{flatMap, point};
        let* _          = BasicDb/DbMonad.setAutoCommit!(false);
        let* _          = Foldable.foreachM(BasicDb/DbMonad.executeSql!, sqlstrings.tableActions);
        let* stmt       = BasicDb/DbMonad.prepareStatement!(sqlstrings.prepStmt);
        let* nrows      = Foldable.foldLeftM((ac, x) -> 
                                {let* n = BasicDb/DbMonad.psExecuteUpdate!(stmt, setter(x)); point(ac+n)}, 0, rows);
        let* _          = BasicDb/DbMonad.commit!();
        point(nrows)


    pub def storeList(sqlstrings: {prepStmt = String, tableActions = List[String]}, 
                    setter: RowSetter[r, row, a, ef], 
                    rows: List[row]): DbMonad[r, ka, Int32] \ {IO, ef, Write(r)} =
        use BasicDb/DbMonad.{flatMap, point};
        let* _          = BasicDb/DbMonad.setAutoCommit!(false);
        let* _          = Foldable.foreachM(BasicDb/DbMonad.executeSql!, sqlstrings.tableActions);
        let* stmt       = BasicDb/DbMonad.prepareStatement!(sqlstrings.prepStmt);
        let* nrows      = foldLeftM((ac, x) -> 
                                {let* n = BasicDb/DbMonad.psExecuteUpdate!(stmt, setter(x)); point(ac+n)}, 0, rows);
        let* _          = BasicDb/DbMonad.commit!();
        point(nrows)

    pub def storeArray(sqlstrings: {prepStmt = String, tableActions = List[String]}, 
                    setter: RowSetter[r, row, a, ef], 
                    rows: Array[row, r2]): DbMonad[r, ka, Int32] \ {IO, ef, Write(r), Read(r2)} =
        BasicDb/DbMonad.liftAction(_ -> Array.toList(rows)) >>= store(sqlstrings, setter)


    pub def storeRelations(sqlstrings: {prepStmt = String, tableActions = List[String]}, 
                    setter: RowSetter[r, row, a, ef], 
                    extractor: {| rr} -> Array[row, r2] \ Write(r),
                    reln: {| rr}): DbMonad[r, ka, Int32] \ {IO, ef, Write(r), Write(r2)} =
        BasicDb/DbMonad.liftAction(_ -> (extractor(reln) |> Array.toList)) >>= store(sqlstrings, setter)
        

    /// is tail-recursive flatMap good enough? No this has stack overflow
    // def listFoldLeftM(f: (b, a) -> m[b] \ ef, s: b, l: List[a]): m[b] \ ef with Monad[m] = 
    //     use Applicative.{point};
    //     match l {
    //         case Nil     => point(s)
    //         case x :: xs => f(s, x) >>= ans -> listFoldLeftM(f, ans, xs)
    //     }

    pub def foldLeftM(f: (b, a) -> m[b] \ ef, s: b, l: List[a]): m[b] \ ef with Monad[m] = 
        foldLeftMHelper(f, Applicative.point(s), l)

    def foldLeftMHelper(f: (b, a) -> m[b] \ ef,
                        ms: m[b], 
                        xs: List[a]): m[b] \ ef with Monad[m] =
        match xs {
            case Nil     => ms
            case x :: rs => {let ms1 = Monad.flatMap(s -> f(s, x), ms); foldLeftMHelper(f, ms1, rs) }
        }

    /// `append` versions without tableActions?


}

