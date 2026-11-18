INSTALL spatial;  LOAD spatial;   -- geometry types + GDAL readers (shp, gdb, gpkg, geojson…)
INSTALL httpfs;   LOAD httpfs;    -- read files straight from S3 / HTTP
INSTALL excel;    LOAD excel;     -- read and write .xlsx

SET s3_region = 'us-west-2';      -- Overture's public bucket; no credentials needed



-- The theme=buildings/type=building/* partition in Overture Maps release 2026-09-23.1
-- contains 2,533,842,612 building footprints (~2.53 billion rows) and takes up roughly 120–130 GB
-- of compressed GeoParquet storage on S3

CREATE OR REPLACE TABLE buildings AS
SELECT
  id,
  names.primary AS name,
  class,
  height,
  num_floors,
  geometry
FROM read_parquet('s3://overturemaps-us-west-2/release/2026-09-23.1/theme=buildings/type=building/*')
WHERE bbox.xmin BETWEEN -71.13 AND -71.03
  AND bbox.ymin BETWEEN 42.33 AND 42.38;
