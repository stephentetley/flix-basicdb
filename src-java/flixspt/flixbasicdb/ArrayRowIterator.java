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

import java.util.Iterator;
import java.util.stream.Stream;
import java.sql.*;
import org.apache.commons.dbutils.*;
import org.apache.commons.dbutils.handlers.*;

public class ArrayRowIterator {

    private Iterator<Object[]> rowIter;

    protected ArrayRowIterator(Iterator<Object[]> iter1) {
        rowIter = iter1;
    }

    /// Factory method for `Files.list`
    public static ArrayRowIterator createRowIterator(Connection conn, String sql) throws Exception {
        Stream<Object[]> stream = new QueryRunner()
                .query(conn, sql, new ArrayListHandler())
                .stream();
        return new ArrayRowIterator(stream.iterator());
    }


    public boolean hasNext() throws Exception {
        return rowIter.hasNext();
    }

    public ArrayRow next() throws Exception {
        return new ArrayRow(rowIter.next());
    }

}
