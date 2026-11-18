-- 00_setup.sql — run once at the start of the demo.
-- Launch from the repo root:   duckdb -ui demo.duckdb
-- (needs DuckDB 1.2.1+ for the UI; check with `duckdb --version`)

INSTALL spatial;  LOAD spatial;   -- geometry types + GDAL readers (shp, gdb, gpkg, geojson…)
INSTALL httpfs;   LOAD httpfs;    -- read files straight from S3 / HTTP
INSTALL excel;    LOAD excel;     -- read and write .xlsx

SET s3_region = 'us-west-2';      -- Overture's public bucket; no credentials needed

-- Overture release used throughout. Latest is listed at https://stac.overturemaps.org
SET VARIABLE overture = 's3://overturemaps-us-west-2/release/2026-09-23.1';
