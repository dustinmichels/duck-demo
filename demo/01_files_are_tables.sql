-- 01_files_are_tables.sql — "SQL is a language, not a database"
-- 380,959 rows of Dutch train stops, one week in May 2023. Just a CSV file.

-- 1. A file in the FROM clause. No import, no CREATE TABLE.
SELECT * FROM 'trains.csv' LIMIT 10;

-- DuckDB sniffed the column types for us:
DESCRIBE FROM 'trains.csv';

-- 2. Real questions, straight off the file.
SELECT station_name, count(*) AS departures
FROM 'trains.csv'
GROUP BY station_name
ORDER BY departures DESC
LIMIT 10;

-- 3. Same data as Parquet: 33.6 MB -> ~2 MB.
COPY (FROM 'trains.csv') TO 'trains.parquet' (FORMAT parquet, COMPRESSION zstd);

-- Same query, Parquet file. (Toggle timing in the UI and compare: ~40x faster.)
SELECT station_name, count(*) AS departures
FROM 'trains.parquet'
GROUP BY station_name
ORDER BY departures DESC
LIMIT 10;

-- 4. Excel is just another table too.
COPY (
  SELECT station_code, station_name, count(*) AS departures
  FROM 'trains.parquet'
  GROUP BY ALL
) TO 'stations.xlsx' (FORMAT xlsx, HEADER true);

SELECT * FROM read_xlsx('stations.xlsx') ORDER BY departures DESC LIMIT 5;

-- 5. Mix them: join a Parquet file to an Excel file.
SELECT t.type, count(*) AS stops
FROM 'trains.parquet' t
JOIN read_xlsx('stations.xlsx') s USING (station_code)
WHERE s.departures > 4000
GROUP BY t.type
ORDER BY stops DESC;
