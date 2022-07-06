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
    
    pub type alias RowSetter[r: Region, a: Type] = a -> PreparedStatementSetter[r, Unit]



    pub def store(sqlstrings: {prepStmt :: String, tableActions :: List[String]}, 
                    setter: RowSetter[r, a], 
                    rows: t[a]): DbMonad[r, Int32] \ Write(r) with Foldable[t] =
        use BasicDb/DbMonad.{flatMap, point, setAutoCommit, execute, prepareStatement, psExecuteUpdate, commit};
        let* _          = setAutoCommit(false);
        let* _          = Foldable.foreachM(execute, sqlstrings.tableActions);
        let* stmt       = prepareStatement(sqlstrings.prepStmt);
        let* nrows      = Foldable.foldLeftM((ac, x) -> 
                                {let* n = psExecuteUpdate(stmt, setter(x)); point(ac+n)}, 0, rows);
        let* _          = commit();
        point(nrows)

    pub def storeArray(sqlstrings: {prepStmt :: String, tableActions :: List[String]}, 
                    setter: RowSetter[r, a], 
                    rows: Array[a, r]): DbMonad[r, Int32] \ {Write(r), Read(r) } =
        use BasicDb/DbMonad.{flatMap, point, liftAction};
        liftAction(_ -> Array.toList(rows)) >>= store(sqlstrings, setter)


    pub def storeRelation(sqlstrings: {prepStmt :: String, tableActions :: List[String]}, 
                    setter: RowSetter[r, a], 
                    extractor: {| rr} -> Array[a, r] \ Write(r),
                    reln: {| rr}): DbMonad[r, Int32] \ {Write(r), Read(r) } =
        use BasicDb/DbMonad.{flatMap, point, liftAction};
        liftAction(_ -> (extractor(reln) |> Array.toList)) >>= store(sqlstrings, setter)
        

    /// `append` versions without tableActions?


}

