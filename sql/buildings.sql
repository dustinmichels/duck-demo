SET s3_region = 'us-west-2';

CREATE OR REPLACE TABLE buildings AS
SELECT
  id,
  names.primary AS primary_name,
  height,
  geometry,
  ST_AsText(geometry) AS wkt,
  ST_AsGeoJSON(geometry) AS geojson
FROM
  read_parquet('s3://overturemaps-us-west-2/release/2026-09-23.1/theme=buildings/type=building/*', filename = true, hive_partitioning = 1)
WHERE
  names.primary IS NOT NULL
  AND bbox.xmin BETWEEN -73.51 AND -69.86
  AND bbox.ymin BETWEEN 41.18 AND 42.89
LIMIT 5;
