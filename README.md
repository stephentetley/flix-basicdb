# flix-basicdb

A basic monadic database interface for Flix using JDBC.

To run the tests or programs depending on this library you are likely to 
have to use the classpath option to tell java where to find to the JDBC driver.

In the command below `sqlite-jdbc-3.36.n.n.jar` is in the folder `lib`:

> java -cp "./lib/*;../bin/flix.jar" ca.uwaterloo.flix.Main test

`flix-basicdb` is also tested with DuckDB but its jar file is too large to be
included in this repository. It will need downloading from Maven central or 
another jar store.

Dependencies: 

https://github.com/stephentetley/flix-time

https://github.com/stephentetley/basis-base

https://github.com/stephentetley/graded-lib

https://github.com/stephentetley/interop-base


Compatible *.pkg files are included in the folder `lib`.

To connect to a specific database you will need an appropriate JDBC jar.
A jar for SQLite is included in the `lib` folder.

