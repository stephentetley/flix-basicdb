# flix-basicdb

A basic database interface for Flix using JDBC.

September 2025 - flix-basicdb has been rewritten to use 
effects. However the APIs are very rough and large changes
are expected.

See the project `flix-basic-duckdb` for a DuckDB specific 
database interface.

Note:

For development and testing SQLite JDBC and DuckDB jars are 
included as dependencies. Other JDBC connections should 
work but may require some configuration (e.g. with command 
line flags) to work.