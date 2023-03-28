# flix-basicdb

A basic monadic database interface for Flix using JDBC.

Note:

For development and testing SQLite JDBC jar is included as a 
dependency. Other JDBC connections should work (for instance 
DuckDB) but expect to supply Java's classpath with a path to 
the respective jar when invoking Flix to run your program.