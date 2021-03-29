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




namespace BasicDb/DbMonadCursor {

    use Cursor/Internal.Step;
    use Cursor/Internal.Step.{Skip, Yield, Done};

    use BasicDb.DbMonad;

    /// To use a Cursor a monad needs a suite of terminal functions

    ///
    /// Applies `f` to every element of `s`.
    ///
    pub def foreach(f: a -> DbMonad[Unit], s: Cursor[a]): DbMonad[Unit] =
        use BasicDb/DbMonad.{flatMap, return, liftAction};
        let generate1 = Cursor.getGenerator(s);
        let finalize1 = Cursor.getFinalizer(s);
        let* sf = liftAction(_ -> generate1());
        let* ans = foreachHelper(f, sf, mx -> mx);
        let* _ = liftAction(_ -> finalize1());
        return(ans)

    ///
    /// Helper function for `foreach`.
    /// 
    /// Warning: is this properly tail recursive?
    ///
    def foreachHelper(f: a -> DbMonad[Unit], sf : Unit ~> Step[a], k: DbMonad[Unit] -> DbMonad[Unit]): DbMonad[Unit] =
        use BasicDb/DbMonad.{bind, return, liftAction};
        bind(liftAction(_ -> sf()), x1 -> match x1 { 
            case Done => k(return())
            case Skip => foreachHelper(f, sf, k)
            case Yield(a) => foreachHelper(f, sf, _ -> k(bind(f(a), _ -> return())))
        })


}

