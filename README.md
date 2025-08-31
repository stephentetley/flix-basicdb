# flix-basicdb

A basic database interface for Flix using JDBC.

_Currently broken_ - needs updating to use effects

Note:

For development and testing SQLite JDBC jar is included as a 
dependency. Other JDBC connections should work (for instance 
DuckDB) but expect to supply Java's classpath with a path to 
the respective jar when invoking Flix to run your program.