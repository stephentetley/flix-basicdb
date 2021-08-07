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

package flix.runtime.spt.basicdb;

import org.apache.commons.dbutils.QueryRunner;
import org.apache.commons.dbutils.handlers.MapListHandler;

import java.sql.Connection;
import java.util.Iterator;
import java.util.Map;
import java.util.stream.Stream;

public class MapRowIterator {

    private Iterator<Map<String,Object>> rowIter;

    protected MapRowIterator(Iterator<Map<String,Object>> iter1) {
        rowIter = iter1;
    }

    /// Factory method for `Files.list`
    public static MapRowIterator createRowIterator(Connection conn, String sql) throws Exception {
        Stream<Map<String,Object>> stream = new QueryRunner()
                .query(conn, sql, new MapListHandler())
                .stream();
        return new MapRowIterator(stream.iterator());
    }


    public boolean hasNext() throws Exception {
        return rowIter.hasNext();
    }

    public MapRow next() throws Exception {
        return new MapRow(rowIter.next());
    }

}
