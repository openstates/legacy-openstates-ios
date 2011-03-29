
all: kml mysql

kml: shapefile_src/shpopen.o shapefile_src/dbfopen.o
	g++ -Wall -g to_kml.c shapefile_src/shpopen.o shapefile_src/dbfopen.o -o shapefile_to_kml

mysql: shapefile_src/shpopen.o shapefile_src/dbfopen.o
	g++ -Wall -g to_mysql.c shapefile_src/shpopen.o shapefile_src/dbfopen.o -o shapefile_to_mysqldump
