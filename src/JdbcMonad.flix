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

use BasicDb.JdbcMonad;
use BasicDb.JdbcMonad.{JdbcMonad};

namespace BasicDb {

    pub opaque type JdbcMonad[a] = ##java.sql.Connection ~> Result[a, System.Error]

}
namespace BasicDb/JdbcMonad {

    def apply1(ma: JdbcMonad[a], conn: ##java.sql.Connection): Result[a, System.Error] & Impure = 
        let JdbcMonad(x1) = ma;
        x1(conn)

    pub def return(x: a): JdbcMonad[a] = 
        JdbcMonad(_ -> Ok(x) as & Impure)

    pub def map(f: a -> b, ma: JdbcMonad[a]): JdbcMonad[b] = 
        JdbcMonad(conn -> 
            match apply1(ma, conn) { 
                case Ok(a) => Ok(f(a))
                case Err(e) => Err(e)
            }
        )

    pub def ap(mf: JdbcMonad[a -> b], ma: JdbcMonad[a]): JdbcMonad[b] = 
        JdbcMonad(conn -> 
            match apply1(mf, conn) { 
                case Ok(f) => match apply1(ma, conn) { 
                    case Ok(a) => Ok(f(a))
                    case Err(e) => Err(e)
                }
                case Err(e) => Err(e)
            }
        )

    pub def bind(ma: JdbcMonad[a], f: a -> JdbcMonad[b]): JdbcMonad[b] = 
        JdbcMonad(conn -> 
            match apply1(ma, conn) { 
                case Ok(a) => apply1(f(a), conn)
                case Err(e) => Err(e)
            }
        )

    pub def flatMap(f: a -> JdbcMonad[b], ma: JdbcMonad[a]): JdbcMonad[b] = bind(ma, f)

}

