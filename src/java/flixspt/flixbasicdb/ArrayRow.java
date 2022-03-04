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

package flixspt.flixbasicdb;

import java.math.BigDecimal;
import java.sql.*;


// Should this be a wrapper over Object[] ?
// This would then be easier to use from Flix...

public class ArrayRow {

    private Object[] row;

    public ArrayRow(Object[] arr) {
        row = arr;
    }
    // https://www.cis.upenn.edu/~bcpierce/courses/629/jdkdocs/guide/jdbc/getstart/mapping.doc.html

    /// Accessors
    public int getInt(int ix) throws Exception {
        if (row[ix].getClass() == Integer.class) {
            return (int) row[ix];
        } else {
            throw new SQLException();
        }
    }

    public String getString(int ix) throws Exception {
        if (row[ix].getClass() == String.class) {
            return (String) row[ix];
        } else {
            throw new SQLException();
        }
    }

    public BigDecimal getBigDecimal(int ix) throws Exception {
        if (row[ix].getClass() == BigDecimal.class) {
            return (BigDecimal) row[ix];
        } else {
            throw new SQLException();
        }
    }

}
