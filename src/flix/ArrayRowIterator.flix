/*
 * Copyright 2021 Stephen Tetley
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


/// BROKEN
/// To fix at some point...

namespace BasicDb/ArrayRowIterator {

    
    use BasicDb.DbMonad;


    ///
    ///
    pub def getArrayRowIterator(conn: ##java.sql.Connection, sql: String): Iterator[Result[##flix.runtime.spt.basicdb.ArrayRow, String]] & Impure =
        import flixspt.flixbasicdb.ArrayRowIterator:createRowIterator(##java.sql.Connection, String);
        import flixspt.flixbasicdb.ArrayRowIterator.hasNext();
        import flixspt.flixbasicdb.ArrayRowIterator.next();
        try {
            let primIter = createRowIterator(conn, sql);
            let iterDone = () -> if (hasNext(primIter)) false else true;
            let iterNext = () -> {
                try {
                    Ok(next(primIter))
                } catch {
                    case _: ##java.lang.Exception => Err("ArrayRowIterator[next]")
                }
            };
            Iterator(iterDone, iterNext)
        } catch {
            case _: ##java.lang.Exception => Iterator.repeat(Err("getArrayRowIterator"), 1)
        }


    /// To use a Cursor a monad needs a suite of terminal functions



}

