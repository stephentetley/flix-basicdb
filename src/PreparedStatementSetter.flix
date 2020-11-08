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

use BasicDb.PreparedStatementSetter;
use BasicDb.PreparedStatementSetter.{PreparedStatementSetter};

namespace BasicDb {

    pub opaque type PreparedStatementSetter[a] = ##java.sql.PreparedStatement ~> Result[a, System.Error]

}

namespace BasicDb/PreparedStatementSetter {

    pub def return(x: a): PreparedStatementSetter[a] =
        PreparedStatementSetter(_ -> Ok(x) as & Impure)

    def apply1(x: PreparedStatementSetter[a], r: ##java.sql.PreparedStatement): Result[a, System.Error] & Impure =
        let PreparedStatementSetter(f) = x;
        f(r)

    pub def map(f: a -> b & ef, x: PreparedStatementSetter[a]): PreparedStatementSetter[b] =
        PreparedStatementSetter(r ->
            match apply1(x, r) {
                case Ok(a) => {
                    let ans = f(a) as & Impure;
                    Ok(ans)
                }
                case Err(e) => Err(e)
            }
        )

    pub def ap(mf: PreparedStatementSetter[a -> b & ef], ma: PreparedStatementSetter[a]): PreparedStatementSetter[b] =
        PreparedStatementSetter(r ->
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

    pub def bind(x: PreparedStatementSetter[a], k: a -> PreparedStatementSetter[b]): PreparedStatementSetter[b] =
        PreparedStatementSetter(r ->
            match apply1(x, r) {
                case Ok(a) => { let ans = k(a); apply1(ans, r) }
                case Err(e) => Err(e)
            }
        )

    pub def flatMap(k: a -> PreparedStatementSetter[b], x: PreparedStatementSetter[a]): PreparedStatementSetter[b] = bind(x, k)

    def liftPrim(update: ##java.sql.PreparedStatement ~> Result[a, System.Error]): PreparedStatementSetter[a] =
        PreparedStatementSetter(r -> update(r))


    pub def liftAction(fn: Unit ~> a): PreparedStatementSetter[a] = 
        PreparedStatementSetter(_ -> { let a = fn(); Ok(a) })

    pub def liftResult(fn: Unit -> Result[a, System.Error]): PreparedStatementSetter[a] = 
        PreparedStatementSetter(_ -> { fn() as & Impure })

    pub def liftActionResult(fn: Unit ~> Result[a, System.Error]): PreparedStatementSetter[a] = 
        PreparedStatementSetter(_ -> fn())


    // Note - the primitive setX! functions index from 1, we add 1 to calls
    // so FactIO's API indexes from 0.

    pub def putNullAt!(ix: Int32): PreparedStatementSetter[Unit] =
        use BasicDb/Internal/PreparedStatement.{sql_type_null};
        liftPrim(x -> BasicDb/Internal/PreparedStatement.setNull!(x, ix + 1, sql_type_null()))

    pub def putStringAt!(ix: Int32, str: String): PreparedStatementSetter[Unit] =
        liftPrim(x -> BasicDb/Internal/PreparedStatement.setString!(x, ix + 1, str))

    pub def putBoolAt!(ix: Int32, b: Bool): PreparedStatementSetter[Unit] =
        liftPrim(x -> BasicDb/Internal/PreparedStatement.setBool!(x, ix + 1, b))

    pub def putInt8At!(ix: Int32, n: Int8): PreparedStatementSetter[Unit] =
        liftPrim(x -> BasicDb/Internal/PreparedStatement.setInt8!(x, ix + 1, n))

    pub def putInt16At!(ix: Int32, n: Int16): PreparedStatementSetter[Unit] =
        liftPrim(x -> BasicDb/Internal/PreparedStatement.setInt16!(x, ix + 1, n))

    pub def putInt32At!(ix: Int32, n: Int32): PreparedStatementSetter[Unit] =
        liftPrim(x -> BasicDb/Internal/PreparedStatement.setInt32!(x, ix + 1, n))

    pub def putInt64At!(ix: Int32, n: Int64): PreparedStatementSetter[Unit] =
        liftPrim(x -> BasicDb/Internal/PreparedStatement.setInt64!(x, ix + 1, n))

    pub def putFloat32At!(ix: Int32, n: Float32): PreparedStatementSetter[Unit] =
        liftPrim(x -> BasicDb/Internal/PreparedStatement.setFloat32!(x, ix + 1, n))

    pub def putFloat64At!(ix: Int32, n: Float64): PreparedStatementSetter[Unit] =
        liftPrim(x -> BasicDb/Internal/PreparedStatement.setFloat64!(x, ix + 1, n))



    pub def putOptionStringAt!(ix: Int32, x: Option[String]): PreparedStatementSetter[Unit] = match x {
        case Some(s) => putStringAt!(ix, s)
        case None => putNullAt!(ix)
    }

    pub def putOptionBool!(ix: Int32, x: Option[Bool]): PreparedStatementSetter[Unit] = match x {
        case Some(b) => putBoolAt!(ix, b)
        case None => putNullAt!(ix)
    }

    pub def putOptionInt8At!(ix: Int32, x: Option[Int8]): PreparedStatementSetter[Unit] = match x {
        case Some(n) => putInt8At!(ix, n)
        case None => putNullAt!(ix)
    }

    pub def putOptionInt16At!(ix: Int32, x: Option[Int16]): PreparedStatementSetter[Unit] = match x {
        case Some(n) => putInt16At!(ix, n)
        case None => putNullAt!(ix)
    }

    pub def putOptionInt32At!(ix: Int32, x: Option[Int32]): PreparedStatementSetter[Unit] = match x {
        case Some(n) => putInt32At!(ix, n)
        case None => putNullAt!(ix)
    }

    pub def putOptionInt64At!(ix: Int32, x: Option[Int64]): PreparedStatementSetter[Unit] = match x {
        case Some(n) => putInt64At!(ix, n)
        case None => putNullAt!(ix)
    }

    pub def putOptionFloat32At!(ix: Int32, x: Option[Float32]): PreparedStatementSetter[Unit] = match x {
        case Some(n) => putFloat32At!(ix, n)
        case None => putNullAt!(ix)
    }

    pub def putOptionFloat64At!(ix: Int32, x: Option[Float64]): PreparedStatementSetter[Unit] = match x {
        case Some(n) => putFloat64At!(ix, n)
        case None => putNullAt!(ix)
    }


    ///
    /// Applies the binary function `f` to the values in `o1` and `o2`.
    ///
    /// Returns an error if either `o1` or `o2` are errors.
    ///
    pub def lift2(f: (t1, t2) -> u & ef, 
                  o1: PreparedStatementSetter[t1], 
                  o2: PreparedStatementSetter[t2]): PreparedStatementSetter[u] =
        ap(map(f, o1), o2)

    ///
    /// Applies the ternary function `f` to the values in `o1`, `o2` and `o3`.
    ///
    /// Returns an error if any of `o1`, `o2` and `o3` are errors.
    ///
    pub def lift3(f: (t1, t2, t3) -> u & ef, 
                  o1: PreparedStatementSetter[t1], 
                  o2: PreparedStatementSetter[t2], 
                  o3: PreparedStatementSetter[t3]): PreparedStatementSetter[u] =
        ap(lift2(f, o1, o2), o3)

    ///
    /// Applies the 4-ary function `f` to the values in `o1`, `o2`, `o3` and `o4`.
    ///
    /// Returns an error if any of `o1`, `o2`, `o3` and `o4` are errors.
    ///
    pub def lift4(f: (t1, t2, t3, t4) -> u & ef, 
                  o1: PreparedStatementSetter[t1], 
                  o2: PreparedStatementSetter[t2], 
                  o3: PreparedStatementSetter[t3], 
                  o4: PreparedStatementSetter[t4]): PreparedStatementSetter[u] =
        ap(lift3(f, o1, o2, o3), o4)

    ///
    /// Applies the 5-ary function `f` to the values in `o1`, `o2`, ... `o5`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o5` are errors.
    ///
    pub def lift5(f: (t1, t2, t3, t4, t5) -> u & ef, 
                      o1: PreparedStatementSetter[t1], 
                      o2: PreparedStatementSetter[t2], 
                      o3: PreparedStatementSetter[t3], 
                      o4: PreparedStatementSetter[t4], 
                      o5: PreparedStatementSetter[t5]): PreparedStatementSetter[u] =
        ap(lift4(f, o1, o2, o3, o4), o5)

    ///
    /// Applies the 6-ary function `f` to the values in `o1`, `o2`, ... `o6`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o6` are errors.
    ///
    pub def lift6(f: (t1, t2, t3, t4, t5, t6) -> u & ef, 
                  o1: PreparedStatementSetter[t1], 
                  o2: PreparedStatementSetter[t2], 
                  o3: PreparedStatementSetter[t3], 
                  o4: PreparedStatementSetter[t4], 
                  o5: PreparedStatementSetter[t5], 
                  o6: PreparedStatementSetter[t6]): PreparedStatementSetter[u] =
        ap(lift5(f, o1, o2, o3, o4, o5), o6)

    ///
    /// Applies the 7-ary function `f` to the values in `o1`, `o2`, ... `o7`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o7` are errors.
    ///
    pub def lift7(f: (t1, t2, t3, t4, t5, t6, t7) -> u & ef, 
                  o1: PreparedStatementSetter[t1], 
                  o2: PreparedStatementSetter[t2], 
                  o3: PreparedStatementSetter[t3], 
                  o4: PreparedStatementSetter[t4], 
                  o5: PreparedStatementSetter[t5], 
                  o6: PreparedStatementSetter[t6], 
                  o7: PreparedStatementSetter[t7]): PreparedStatementSetter[u] =
        ap(lift6(f, o1, o2, o3, o4, o5, o6), o7)

    ///
    /// Applies the 8-ary function `f` to the values in `o1`, `o2`, ... `o8`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o8` are errors.
    ///
    pub def lift8(f: (t1, t2, t3, t4, t5, t6, t7, t8) -> u & ef, 
                  o1: PreparedStatementSetter[t1], 
                  o2: PreparedStatementSetter[t2], 
                  o3: PreparedStatementSetter[t3], 
                  o4: PreparedStatementSetter[t4], 
                  o5: PreparedStatementSetter[t5], 
                  o6: PreparedStatementSetter[t6], 
                  o7: PreparedStatementSetter[t7], 
                  o8: PreparedStatementSetter[t8]): PreparedStatementSetter[u] =
        ap(lift7(f, o1, o2, o3, o4, o5, o6, o7), o8)

    ///
    /// Applies the 9-ary function `f` to the values in `o1`, `o2`, ... `o9`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o9` are errors.
    ///
    pub def lift9(f: (t1, t2, t3, t4, t5, t6, t7, t8, t9) -> u & ef, 
                  o1: PreparedStatementSetter[t1], 
                  o2: PreparedStatementSetter[t2], 
                  o3: PreparedStatementSetter[t3], 
                  o4: PreparedStatementSetter[t4], 
                  o5: PreparedStatementSetter[t5], 
                  o6: PreparedStatementSetter[t6], 
                  o7: PreparedStatementSetter[t7], 
                  o8: PreparedStatementSetter[t8], 
                  o9: PreparedStatementSetter[t9]): PreparedStatementSetter[u] =
        ap(lift8(f, o1, o2, o3, o4, o5, o6, o7, o8), o9)

    ///
    /// Applies the 10-ary function `f` to the values in `o1`, `o2`, ... `o10`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o10` are errors.
    ///
    pub def lift10(f: (t1, t2, t3, t4, t5, t6, t7, t8, t9, t10) -> u & ef, 
                   o1: PreparedStatementSetter[t1], 
                   o2: PreparedStatementSetter[t2], 
                   o3: PreparedStatementSetter[t3], 
                   o4: PreparedStatementSetter[t4], 
                   o5: PreparedStatementSetter[t5], 
                   o6: PreparedStatementSetter[t6], 
                   o7: PreparedStatementSetter[t7], 
                   o8: PreparedStatementSetter[t8], 
                   o9: PreparedStatementSetter[t9], 
                   o10: PreparedStatementSetter[t10]): PreparedStatementSetter[u] =
        ap(lift9(f, o1, o2, o3, o4, o5, o6, o7, o8, o9), o10)


}

