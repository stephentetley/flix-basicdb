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

    pub def bind(x: RowEvaluator[a], k: a -> RowEvaluator[b]): RowEvaluator[b] =
        RowEvaluator(r ->
            match apply1(x, r) {
                case Ok(a) => { let ans = k(a); apply1(ans, r) }
                case Err(e) => Err(e)
            }
        )

    pub def flatMap(k: a -> RowEvaluator[b], x: RowEvaluator[a]): RowEvaluator[b] = bind(x, k)

    def liftPrim(ask: ##java.sql.ResultSet ~> Result[a, System.Error]): RowEvaluator[a] =
        RowEvaluator(r -> ask(r))


    pub def liftAction(fn: Unit ~> a): RowEvaluator[a] =
        RowEvaluator(_ -> let x = fn(); Ok(x))

    pub def liftActionResult(fn: Unit ~> Result[a, System.Error]): RowEvaluator[a] =
        RowEvaluator(_ -> fn())


    // // Note - the primitive setX! functions index from 1, we add 1 to calls
    // // so FactIO's API indexes from 0.

    
    pub def getString(ix: Int32): RowEvaluator[String] =
        liftPrim(x -> BasicDb/Internal/ResultSet.getString(x, ix + 1))

    // pub def putBool!(ix: Int32, b: Bool): RowEvaluator[Unit] =
    //     liftPrim(x -> BasicDb/Internal/PreparedStatement.setBool!(x, ix + 1, b))

    // pub def putInt8!(ix: Int32, n: Int8): RowEvaluator[Unit] =
    //     liftPrim(x -> BasicDb/Internal/PreparedStatement.setInt8!(x, ix + 1, n))

    // pub def putInt16!(ix: Int32, n: Int16): RowEvaluator[Unit] =
    //     liftPrim(x -> BasicDb/Internal/PreparedStatement.setInt16!(x, ix + 1, n))

    pub def getInt32(ix: Int32): RowEvaluator[Int32] =
        liftPrim(x -> BasicDb/Internal/ResultSet.getInt32(x, ix + 1))

    // pub def putInt64!(ix: Int32, n: Int64): RowEvaluator[Unit] =
    //     liftPrim(x -> BasicDb/Internal/PreparedStatement.setInt64!(x, ix + 1, n))

    // pub def putFloat32!(ix: Int32, n: Float32): RowEvaluator[Unit] =
    //     liftPrim(x -> BasicDb/Internal/PreparedStatement.setFloat32!(x, ix + 1, n))

    // pub def putFloat64!(ix: Int32, n: Float64): RowEvaluator[Unit] =
    //     liftPrim(x -> BasicDb/Internal/PreparedStatement.setFloat64!(x, ix + 1, n))



    // pub def putOptionString!(ix: Int32, x: Option[String]): RowEvaluator[Unit] = match x {
    //     case Some(s) => putString!(ix, s)
    //     case None => putNull!(ix)
    // }

    // pub def putOptionBool!(ix: Int32, x: Option[Bool]): RowEvaluator[Unit] = match x {
    //     case Some(b) => putBool!(ix, b)
    //     case None => putNull!(ix)
    // }

    // pub def putOptionInt8!(ix: Int32, x: Option[Int8]): RowEvaluator[Unit] = match x {
    //     case Some(n) => putInt8!(ix, n)
    //     case None => putNull!(ix)
    // }

    // pub def putOptionInt16!(ix: Int32, x: Option[Int16]): RowEvaluator[Unit] = match x {
    //     case Some(n) => putInt16!(ix, n)
    //     case None => putNull!(ix)
    // }

    // pub def putOptionInt32!(ix: Int32, x: Option[Int32]): RowEvaluator[Unit] = match x {
    //     case Some(n) => putInt32!(ix, n)
    //     case None => putNull!(ix)
    // }

    // pub def putOptionInt64!(ix: Int32, x: Option[Int64]): RowEvaluator[Unit] = match x {
    //     case Some(n) => putInt64!(ix, n)
    //     case None => putNull!(ix)
    // }

    // pub def putOptionFloat32!(ix: Int32, x: Option[Float32]): RowEvaluator[Unit] = match x {
    //     case Some(n) => putFloat32!(ix, n)
    //     case None => putNull!(ix)
    // }

    // pub def putOptionFloat64!(ix: Int32, x: Option[Float64]): RowEvaluator[Unit] = match x {
    //     case Some(n) => putFloat64!(ix, n)
    //     case None => putNull!(ix)
    // }


    ///
    /// Applies the binary function `f` to the values in `o1` and `o2`.
    ///
    /// Returns an error if either `o1` or `o2` are errors.
    ///
    pub def lift2(f: (t1, t2) -> u & ef, o1: RowEvaluator[t1], o2: RowEvaluator[t2]): RowEvaluator[u] =
        ap(map(f, o1), o2)

    ///
    /// Applies the ternary function `f` to the values in `o1`, `o2` and `o3`.
    ///
    /// Returns an error if any of `o1`, `o2` and `o3` are errors.
    ///
    pub def lift3(f: (t1, t2, t3) -> u & ef, o1: RowEvaluator[t1], o2: RowEvaluator[t2], o3: RowEvaluator[t3]): RowEvaluator[u] =
        ap(lift2(f, o1, o2), o3)

    ///
    /// Applies the 4-ary function `f` to the values in `o1`, `o2`, `o3` and `o4`.
    ///
    /// Returns an error if any of `o1`, `o2`, `o3` and `o4` are errors.
    ///
    pub def lift4(f: (t1, t2, t3, t4) -> u & ef, o1: RowEvaluator[t1], o2: RowEvaluator[t2], o3: RowEvaluator[t3], o4: RowEvaluator[t4]): RowEvaluator[u] =
        ap(lift3(f, o1, o2, o3), o4)

    ///
    /// Applies the 5-ary function `f` to the values in `o1`, `o2`, ... `o5`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o5` are errors.
    ///
    pub def lift5(f: (t1, t2, t3, t4, t5) -> u & ef, o1: RowEvaluator[t1], o2: RowEvaluator[t2], o3: RowEvaluator[t3], o4: RowEvaluator[t4], o5: RowEvaluator[t5]): RowEvaluator[u] =
        ap(lift4(f, o1, o2, o3, o4), o5)

    ///
    /// Applies the 6-ary function `f` to the values in `o1`, `o2`, ... `o6`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o6` are errors.
    ///
    pub def lift6(f: (t1, t2, t3, t4, t5, t6) -> u & ef, o1: RowEvaluator[t1], o2: RowEvaluator[t2], o3: RowEvaluator[t3], o4: RowEvaluator[t4], o5: RowEvaluator[t5], o6: RowEvaluator[t6]): RowEvaluator[u] =
        ap(lift5(f, o1, o2, o3, o4, o5), o6)

    ///
    /// Applies the 7-ary function `f` to the values in `o1`, `o2`, ... `o7`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o7` are errors.
    ///
    pub def lift7(f: (t1, t2, t3, t4, t5, t6, t7) -> u & ef, o1: RowEvaluator[t1], o2: RowEvaluator[t2], o3: RowEvaluator[t3], o4: RowEvaluator[t4], o5: RowEvaluator[t5], o6: RowEvaluator[t6], o7: RowEvaluator[t7]): RowEvaluator[u] =
        ap(lift6(f, o1, o2, o3, o4, o5, o6), o7)

    ///
    /// Applies the 8-ary function `f` to the values in `o1`, `o2`, ... `o8`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o8` are errors.
    ///
    pub def lift8(f: (t1, t2, t3, t4, t5, t6, t7, t8) -> u & ef, o1: RowEvaluator[t1], o2: RowEvaluator[t2], o3: RowEvaluator[t3], o4: RowEvaluator[t4], o5: RowEvaluator[t5], o6: RowEvaluator[t6], o7: RowEvaluator[t7], o8: RowEvaluator[t8]): RowEvaluator[u] =
        ap(lift7(f, o1, o2, o3, o4, o5, o6, o7), o8)

    ///
    /// Applies the 9-ary function `f` to the values in `o1`, `o2`, ... `o9`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o9` are errors.
    ///
    pub def lift9(f: (t1, t2, t3, t4, t5, t6, t7, t8, t9) -> u & ef, o1: RowEvaluator[t1], o2: RowEvaluator[t2], o3: RowEvaluator[t3], o4: RowEvaluator[t4], o5: RowEvaluator[t5], o6: RowEvaluator[t6], o7: RowEvaluator[t7], o8: RowEvaluator[t8], o9: RowEvaluator[t9]): RowEvaluator[u] =
        ap(lift8(f, o1, o2, o3, o4, o5, o6, o7, o8), o9)

    ///
    /// Applies the 10-ary function `f` to the values in `o1`, `o2`, ... `o10`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o10` are errors.
    ///
    pub def lift10(f: (t1, t2, t3, t4, t5, t6, t7, t8, t9, t10) -> u & ef, o1: RowEvaluator[t1], o2: RowEvaluator[t2], o3: RowEvaluator[t3], o4: RowEvaluator[t4], o5: RowEvaluator[t5], o6: RowEvaluator[t6], o7: RowEvaluator[t7], o8: RowEvaluator[t8], o9: RowEvaluator[t9], o10: RowEvaluator[t10]): RowEvaluator[u] =
        ap(lift9(f, o1, o2, o3, o4, o5, o6, o7, o8, o9), o10)


}
