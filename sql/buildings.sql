-- Load Spatial Extensions
INSTALL spatial;  LOAD spatial;   -- geometry types + GDAL readers (shp, gdb, gpkg, geojson…)
INSTALL httpfs;   LOAD httpfs;    -- read files straight from S3 / HTTP

-- Create table for Boston
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

SELECT count(*) AS buildings FROM buildings;

-- Tallest buildings in the box
SELECT name, round(height) AS height_m, num_floors
FROM buildings
WHERE height IS NOT NULL
ORDER BY height DESC
LIMIT 10;

-- Footprint area needs a projected CRS (metres). EPSG:26986 = MA State Plane.
SELECT
  class,
  count(*) AS n,
  round(avg(ST_Area(ST_Transform(geometry, 'EPSG:26986', always_xy := true)))) AS avg_footprint_m2
FROM buildings
GROUP BY class
ORDER BY n DESC
LIMIT 10;

-- Save footprint as GeoParquet (lon/lat).
COPY (
  SELECT
    id,
    name,
    class,
    height,
    round(ST_Area(ST_Transform(geometry, 'EPSG:26986', always_xy := true))) AS footprint_m2,
    geometry
  FROM buildings
) TO 'buildings.parquet' (FORMAT parquet);
