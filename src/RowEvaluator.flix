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

use BasicDb.RowEvaluator;
use BasicDb.RowEvaluator.{RowEvaluator};

namespace BasicDb {

    pub opaque type RowEvaluator[a] = ##java.sql.ResultSet ~> Result[a, System.Error]

}

namespace BasicDb/RowEvaluator {

    pub def return(x: a): RowEvaluator[a] =
        RowEvaluator(_ -> Ok(x) as & Impure)

    def apply1(x: RowEvaluator[a], r: ##java.sql.ResultSet): Result[a, System.Error] & Impure =
        let RowEvaluator(f) = x;
        f(r)

    pub def map(f: a -> b & ef, x: RowEvaluator[a]): RowEvaluator[b] =
        RowEvaluator(r ->
            match apply1(x, r) {
                case Ok(a) => {
                    let ans = f(a) as & Impure;
                    Ok(ans)
                }
                case Err(e) => Err(e)
            }
        )

    pub def ap(mf: RowEvaluator[a -> b & ef], ma: RowEvaluator[a]): RowEvaluator[b] =
        RowEvaluator(r ->
            match apply1(mf, r) {
                case Ok(f) => {
                    match apply1(ma, r) {
                        case Ok(a) => Ok(f(a) as & Impure)
                        case Err(e2) => Err(e2)
                    }
                }
                case Err(e1) => Err(e1)
            }
        )

    pub def seqLeft(ma: RowEvaluator[a], mb: RowEvaluator[b]): RowEvaluator[a] = 
        RowEvaluator(r ->
            match apply1(ma, r) { 
                case Ok(a) => match apply1(mb, r) {
                    case Ok(_) => Ok(a)
                    case Err(e) => Err(e)
                }
                case Err(e) => Err(e)
            }
        )

    pub def seqRight(ma: RowEvaluator[a], mb: RowEvaluator[b]): RowEvaluator[b] = 
        RowEvaluator(r ->
            match apply1(ma, r) { 
                case Ok(_) => apply1(mb, r)
                case Err(e) => Err(e)
            }
        )

    pub def bind(x: RowEvaluator[a], k: a -> RowEvaluator[b]): RowEvaluator[b] =
        RowEvaluator(r ->
            match apply1(x, r) {
                case Ok(a) => { let ans = k(a); apply1(ans, r) }
                case Err(e) => Err(e)
            }
        )

    pub def flatMap(k: a -> RowEvaluator[b], x: RowEvaluator[a]): RowEvaluator[b] = bind(x, k)

    pub def kleisliLeft(f1: a -> RowEvaluator[b], f2: b -> RowEvaluator[c], x: a): RowEvaluator[c] =
        RowEvaluator(r -> 
            match apply1(f1(x), r) { 
                case Ok(b) => apply1(f2(b), r)
                case Err(e) => Err(e)
            }
        )

    pub def kleisliRight(f1: b -> RowEvaluator[c], f2: a -> RowEvaluator[b], x: a): RowEvaluator[c] =
        kleisliLeft(f2, f1, x)
        
    pub def optional(x: RowEvaluator[a]): RowEvaluator[Option[a]] =
        RowEvaluator(r ->
            match apply1(x, r) {
                case Ok(a) => Ok(Some(a))
                case Err(_) => Ok(None)
            }
        )


    pub def alt(ma: RowEvaluator[a], mb: RowEvaluator[a]): RowEvaluator[a] =
        RowEvaluator(r ->
            match apply1(ma, r) {
                case Ok(a) => Ok(a)
                case Err(_) => apply1(mb, r) 
            }
        )

        
    def liftPrim(ask: ##java.sql.ResultSet ~> Result[a, System.Error]): RowEvaluator[a] =
        RowEvaluator(r -> ask(r))


    pub def liftAction(fn: Unit ~> a): RowEvaluator[a] =
        RowEvaluator(_ -> let x = fn(); Ok(x))
    
    pub def liftResult(fn: Unit -> Result[a, System.Error]): RowEvaluator[a] = 
        RowEvaluator(_ -> { fn() as & Impure })
        
    pub def liftActionResult(fn: Unit ~> Result[a, System.Error]): RowEvaluator[a] =
        RowEvaluator(_ -> fn())


    // // Note - the primitive getX and setX! functions index from 1, we add 1 to calls
    // // so FactIO's API indexes from 0.

    /// This is "null safe" - if the internal result is null it is converted to the empty String.
    pub def getStringAt(ix: Int32): RowEvaluator[String] =
        let* x1     = liftPrim(x -> BasicDb/Internal/ResultSet.getStringAt(x, ix + 1));
        let ans     = if (Object.isNull(x1)) "" else x1;
        return(ans)

    /// This is "null safe" - if the internal result is null it is converted to the empty String.
    pub def getStringNamed(label: String): RowEvaluator[String] =
        let* x1     = liftPrim(x -> BasicDb/Internal/ResultSet.getStringNamed(x, label));
        let ans     = if (Object.isNull(x1)) "" else x1;
        return(ans)

    // See Javadocs for how a bool value is interpreted...
    pub def getBoolAt(ix: Int32): RowEvaluator[Bool] =
        liftPrim(x -> BasicDb/Internal/ResultSet.getBoolAt(x, ix + 1))

    // See Javadocs for how a bool value is interpreted...
    pub def getBoolNamed(label: String): RowEvaluator[Bool] =
        liftPrim(x -> BasicDb/Internal/ResultSet.getBoolNamed(x, label))

    pub def getInt8At(ix: Int32): RowEvaluator[Int8] =
        liftPrim(x -> BasicDb/Internal/ResultSet.getInt8At(x, ix + 1))

    pub def getInt8Named(label: String): RowEvaluator[Int8] =
        liftPrim(x -> BasicDb/Internal/ResultSet.getInt8Named(x, label))

    pub def getInt16At(ix: Int32): RowEvaluator[Int16] =
        liftPrim(x -> BasicDb/Internal/ResultSet.getInt16At(x, ix + 1))

    pub def getInt16Named(label: String): RowEvaluator[Int16] =
        liftPrim(x -> BasicDb/Internal/ResultSet.getInt16Named(x, label))

    pub def getInt32At(ix: Int32): RowEvaluator[Int32] =
        liftPrim(x -> BasicDb/Internal/ResultSet.getInt32At(x, ix + 1))

    pub def getInt32Named(label: String): RowEvaluator[Int32] =
        liftPrim(x -> BasicDb/Internal/ResultSet.getInt32Named(x, label))

    pub def getInt64At(ix: Int32): RowEvaluator[Int64] =
        liftPrim(x -> BasicDb/Internal/ResultSet.getInt64At(x, ix + 1))

    pub def getInt64Named(label: String): RowEvaluator[Int64] =
        liftPrim(x -> BasicDb/Internal/ResultSet.getInt64Named(x, label))

    pub def getFloat32At(ix: Int32): RowEvaluator[Float32] =
        liftPrim(x -> BasicDb/Internal/ResultSet.getFloat32At(x, ix + 1))
    
    pub def getFloat32Named(label: String): RowEvaluator[Float32] =
        liftPrim(x -> BasicDb/Internal/ResultSet.getFloat32Named(x, label))

    pub def getFloat64At(ix: Int32): RowEvaluator[Float64] =
        liftPrim(x -> BasicDb/Internal/ResultSet.getFloat64At(x, ix + 1))

    pub def getFloat64Named(label: String): RowEvaluator[Float64] =
        liftPrim(x -> BasicDb/Internal/ResultSet.getFloat64Named(x, label))

    ///
    /// Applies the binary function `f` to the values in `o1` and `o2`.
    ///
    /// Returns an error if either `o1` or `o2` are errors.
    ///
    pub def lift2(f: (t1, t2) -> u & ef, 
                  o1: RowEvaluator[t1], 
                  o2: RowEvaluator[t2]): RowEvaluator[u] =
        ap(map(f, o1), o2)

    ///
    /// Applies the ternary function `f` to the values in `o1`, `o2` and `o3`.
    ///
    /// Returns an error if any of `o1`, `o2` and `o3` are errors.
    ///
    pub def lift3(f: (t1, t2, t3) -> u & ef, 
                  o1: RowEvaluator[t1], 
                  o2: RowEvaluator[t2], 
                  o3: RowEvaluator[t3]): RowEvaluator[u] =
        ap(lift2(f, o1, o2), o3)

    ///
    /// Applies the 4-ary function `f` to the values in `o1`, `o2`, `o3` and `o4`.
    ///
    /// Returns an error if any of `o1`, `o2`, `o3` and `o4` are errors.
    ///
    pub def lift4(f: (t1, t2, t3, t4) -> u & ef, 
                  o1: RowEvaluator[t1], 
                  o2: RowEvaluator[t2], 
                  o3: RowEvaluator[t3], 
                  o4: RowEvaluator[t4]): RowEvaluator[u] =
        ap(lift3(f, o1, o2, o3), o4)

    ///
    /// Applies the 5-ary function `f` to the values in `o1`, `o2`, ... `o5`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o5` are errors.
    ///
    pub def lift5(f: (t1, t2, t3, t4, t5) -> u & ef, 
                  o1: RowEvaluator[t1], 
                  o2: RowEvaluator[t2], 
                  o3: RowEvaluator[t3], 
                  o4: RowEvaluator[t4], 
                  o5: RowEvaluator[t5]): RowEvaluator[u] =
        ap(lift4(f, o1, o2, o3, o4), o5)

    ///
    /// Applies the 6-ary function `f` to the values in `o1`, `o2`, ... `o6`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o6` are errors.
    ///
    pub def lift6(f: (t1, t2, t3, t4, t5, t6) -> u & ef, 
                  o1: RowEvaluator[t1], 
                  o2: RowEvaluator[t2], 
                  o3: RowEvaluator[t3],
                  o4: RowEvaluator[t4], 
                  o5: RowEvaluator[t5], 
                  o6: RowEvaluator[t6]): RowEvaluator[u] =
        ap(lift5(f, o1, o2, o3, o4, o5), o6)

    ///
    /// Applies the 7-ary function `f` to the values in `o1`, `o2`, ... `o7`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o7` are errors.
    ///
    pub def lift7(f: (t1, t2, t3, t4, t5, t6, t7) -> u & ef, 
                  o1: RowEvaluator[t1], 
                  o2: RowEvaluator[t2], 
                  o3: RowEvaluator[t3], 
                  o4: RowEvaluator[t4], 
                  o5: RowEvaluator[t5], 
                  o6: RowEvaluator[t6], 
                  o7: RowEvaluator[t7]): RowEvaluator[u] =
        ap(lift6(f, o1, o2, o3, o4, o5, o6), o7)

    ///
    /// Applies the 8-ary function `f` to the values in `o1`, `o2`, ... `o8`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o8` are errors.
    ///
    pub def lift8(f: (t1, t2, t3, t4, t5, t6, t7, t8) -> u & ef, 
                  o1: RowEvaluator[t1], 
                  o2: RowEvaluator[t2], 
                  o3: RowEvaluator[t3], 
                  o4: RowEvaluator[t4], 
                  o5: RowEvaluator[t5], 
                  o6: RowEvaluator[t6], 
                  o7: RowEvaluator[t7], 
                  o8: RowEvaluator[t8]): RowEvaluator[u] =
        ap(lift7(f, o1, o2, o3, o4, o5, o6, o7), o8)

    ///
    /// Applies the 9-ary function `f` to the values in `o1`, `o2`, ... `o9`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o9` are errors.
    ///
    pub def lift9(f: (t1, t2, t3, t4, t5, t6, t7, t8, t9) -> u & ef, 
                  o1: RowEvaluator[t1], 
                  o2: RowEvaluator[t2], 
                  o3: RowEvaluator[t3], 
                  o4: RowEvaluator[t4], 
                  o5: RowEvaluator[t5], 
                  o6: RowEvaluator[t6], 
                  o7: RowEvaluator[t7], 
                  o8: RowEvaluator[t8], 
                  o9: RowEvaluator[t9]): RowEvaluator[u] =
        ap(lift8(f, o1, o2, o3, o4, o5, o6, o7, o8), o9)

    ///
    /// Applies the 10-ary function `f` to the values in `o1`, `o2`, ... `o10`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o10` are errors.
    ///
    pub def lift10(f: (t1, t2, t3, t4, t5, t6, t7, t8, t9, t10) -> u & ef, 
                   o1: RowEvaluator[t1], 
                   o2: RowEvaluator[t2], 
                   o3: RowEvaluator[t3], 
                   o4: RowEvaluator[t4], 
                   o5: RowEvaluator[t5], 
                   o6: RowEvaluator[t6], 
                   o7: RowEvaluator[t7], 
                   o8: RowEvaluator[t8], 
                   o9: RowEvaluator[t9], 
                   o10: RowEvaluator[t10]): RowEvaluator[u] =
        ap(lift9(f, o1, o2, o3, o4, o5, o6, o7, o8, o9), o10)


    ///
    /// Returns a 2 element tuple with the results of applying the evaluators `o1` and `o2`.
    ///
    /// Returns an error if evaluating either `o1` or `o2` is an error.
    ///
    pub def tuple2(o1: RowEvaluator[t1], o2: RowEvaluator[t2]): RowEvaluator[(t1, t2)] =
        lift2((x,y) -> (x,y), o1, o2)

    ///
    /// Returns a 3 element tuple with the results of applying the evaluators `o1`, `o2` and `o3`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2` and `o3` is an error.
    ///
    pub def tuple3(o1: RowEvaluator[t1], 
                   o2: RowEvaluator[t2], 
                   o3: RowEvaluator[t3]): RowEvaluator[(t1, t2, t3)] =
        lift3((x1, x2, x3) -> (x1, x2, x3), o1, o2, o3)

    ///
    /// Returns a 4 element tuple with the results of applying the evaluators `o1`, `o2`, `o3` and `o4`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, `o3` and `o4` is an error.
    ///
    pub def tuple4(o1: RowEvaluator[t1], 
                   o2: RowEvaluator[t2], 
                   o3: RowEvaluator[t3], 
                   o4: RowEvaluator[t4]): RowEvaluator[(t1, t2, t3, t4)]  =
        lift4((x1, x2, x3, x4) -> (x1, x2, x3, x4), o1, o2, o3, o4)

    ///
    /// Returns a 5 element tuple with the results of applying the evaluators `o1`, `o2`, ... `o5`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, ... `o5` is an error.
    ///
    pub def tuple5(o1: RowEvaluator[t1], 
                   o2: RowEvaluator[t2], 
                   o3: RowEvaluator[t3], 
                   o4: RowEvaluator[t4], 
                   o5: RowEvaluator[t5]): RowEvaluator[(t1, t2, t3, t4, t5)]  =
        lift5((x1, x2, x3, x4, x5) -> (x1, x2, x3, x4, x5), o1, o2, o3, o4, o5)

    ///
    /// Returns a 6 element tuple with the results of applying the evaluators `o1`, `o2`, ... `o6`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, ... `o6` is an error.
    ///
    pub def tuple6(o1: RowEvaluator[t1], 
                   o2: RowEvaluator[t2], 
                   o3: RowEvaluator[t3], 
                   o4: RowEvaluator[t4], 
                   o5: RowEvaluator[t5], 
                   o6: RowEvaluator[t6]): RowEvaluator[(t1, t2, t3, t4, t5, t6)]  =
        lift6((x1, x2, x3, x4, x5, x6) -> (x1, x2, x3, x4, x5, x6), o1, o2, o3, o4, o5, o6)

    ///
    /// Returns a 7 element tuple with the results of applying the evaluators `o1`, `o2`, ... `o7`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, ... `o7` is an error.
    ///
    pub def tuple7(o1: RowEvaluator[t1], 
                   o2: RowEvaluator[t2], 
                   o3: RowEvaluator[t3], 
                   o4: RowEvaluator[t4], 
                   o5: RowEvaluator[t5], 
                   o6: RowEvaluator[t6], 
                   o7: RowEvaluator[t7]): RowEvaluator[(t1, t2, t3, t4, t5, t6, t7)]  =
        lift7((x1, x2, x3, x4, x5, x6, x7) -> (x1, x2, x3, x4, x5, x6, x7), 
                o1, o2, o3, o4, o5, o6, o7)

    ///
    /// Returns a 8 element tuple with the results of applying the evaluators `o1`, `o2`, ... `o8`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, ... `o8` is an error.
    ///
    pub def tuple8(o1: RowEvaluator[t1], 
                   o2: RowEvaluator[t2], 
                   o3: RowEvaluator[t3], 
                   o4: RowEvaluator[t4], 
                   o5: RowEvaluator[t5], 
                   o6: RowEvaluator[t6], 
                   o7: RowEvaluator[t7], 
                   o8: RowEvaluator[t8]): RowEvaluator[(t1, t2, t3, t4, t5, t6, t7, t8)]  =
        lift8((x1, x2, x3, x4, x5, x6, x7, x8) -> (x1, x2, x3, x4, x5, x6, x7, x8), 
                o1, o2, o3, o4, o5, o6, o7, o8)

    ///
    /// Returns a 9 element tuple with the results of applying the evaluators `o1`, `o2`, ... `o9`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, ... `o9` is an error.
    ///
    pub def tuple9(o1: RowEvaluator[t1], 
                   o2: RowEvaluator[t2], 
                   o3: RowEvaluator[t3], 
                   o4: RowEvaluator[t4], 
                   o5: RowEvaluator[t5], 
                   o6: RowEvaluator[t6], 
                   o7: RowEvaluator[t7], 
                   o8: RowEvaluator[t8], 
                   o9: RowEvaluator[t9]): RowEvaluator[(t1, t2, t3, t4, t5, t6, t7, t8, t9)]  =
        lift9((x1, x2, x3, x4, x5, x6, x7, x8, x9) -> (x1, x2, x3, x4, x5, x6, x7, x8, x9), 
                o1, o2, o3, o4, o5, o6, o7, o8, o9)

    ///
    /// Returns a 10 element tuple with the results of applying the evaluators `o1`, `o2`, ... `o10`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, ... `o10` is an error.
    ///
    pub def tuple10(o1: RowEvaluator[t1], 
                    o2: RowEvaluator[t2], 
                    o3: RowEvaluator[t3], 
                    o4: RowEvaluator[t4], 
                    o5: RowEvaluator[t5], 
                    o6: RowEvaluator[t6], 
                    o7: RowEvaluator[t7], 
                    o8: RowEvaluator[t8], 
                    o9: RowEvaluator[t9], 
                    o10: RowEvaluator[t10]): RowEvaluator[(t1, t2, t3, t4, t5, t6, t7, t8, t9, t10)]  =
        lift10((x1, x2, x3, x4, x5, x6, x7, x8, x9, x10) -> (x1, x2, x3, x4, x5, x6, x7, x8, x9, x10), 
                o1, o2, o3, o4, o5, o6, o7, o8, o9, o10)

    /// Alias for `seqRight`
    pub def *>(p1: RowEvaluator[a], p2: RowEvaluator[b]): RowEvaluator[b] = seqRight(p1, p2)

    /// Alias for `seqLeft`
    pub def <*(p1: RowEvaluator[a], p2: RowEvaluator[b]): RowEvaluator[a] = seqLeft(p1, p2)

    // Haskell's <$>
    pub def <&>(f: a -> b, p2: RowEvaluator[a]): RowEvaluator[b] =
        map(f, p2)

    pub def <&(x: b, p2: RowEvaluator[a]): RowEvaluator[b] =
        p2 *> return(x)

    /// Alias for `bind`
    pub def >>=(ma: RowEvaluator[a], k: a -> RowEvaluator[b]): RowEvaluator[b] = 
        bind(ma, k)

    /// Alias for `flatMap` (flipped `bind`)
    pub def =<<(k: a -> RowEvaluator[b], ma: RowEvaluator[a]): RowEvaluator[b] = 
        flatMap(k, ma)


    // Haskell's ap <*>
    pub def <*>(mf: RowEvaluator[a -> b], p2: RowEvaluator[a]): RowEvaluator[b] =
        ap(mf, p2)

    /// Alias for `kleisliLeft`
    pub def >=>(f1: a -> RowEvaluator[b], f2: b -> RowEvaluator[c]): a -> RowEvaluator[c] = 
        x -> kleisliLeft(f1, f2, x)

    /// Alias for `kleisliRight`
    pub def <=<(f1: b -> RowEvaluator[c], f2: a -> RowEvaluator[b]): a -> RowEvaluator[c] = 
        x -> kleisliRight(f1, f2, x)

}

