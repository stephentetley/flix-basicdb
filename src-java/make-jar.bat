
set %JAVA_HOME%="C:\Program Files\Zulu\zulu-11"

javac -cp "../lib/commons-dbutils-1.7.jar;../lib/duckdb_jdbc-0.2.1.jar;../lib/sqlite-jdbc-3.36.0.3.jar" -d ./build  flixspt/flixbasicdb/*.java

cd build 

jar cf flix-basicdbjava-1.0.jar ./flixspt/flixbasicdb/*.class

