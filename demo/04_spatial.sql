-- 04_spatial.sql — GIS in SQL: a shapefile, a cloud dataset, and a spatial join.
-- Question: within Boston & Cambridge's environmental justice (EJ) block groups,
-- which kinds of EJ neighborhood have the fewest cafés per resident?
-- (MassGIS EJ layer = only the block groups that meet an EJ criterion.)

-- 1. A shapefile, read straight out of its zip. No unzip, no import tool.
CREATE OR REPLACE TABLE ej AS
SELECT GEOID, MUNICIPALI AS town, EJ, EJ_CRIT_DE AS ej_criteria, TOTAL_POP AS pop, geom
FROM ST_Read('/vsizip/data/ej2020.zip/EJ_POLY.shp')
WHERE MUNICIPALI IN ('Boston', 'Cambridge');

SELECT town, ej_criteria, count(*) AS block_groups, sum(pop) AS pop
FROM ej GROUP BY ALL ORDER BY ALL;

-- (Bonus: an Esri File Geodatabase reads the same way.)
-- SELECT * FROM ST_Read_Meta('data/NOAA_SLR_MA/NOAA_SLR_MA.gdb');

-- 2. Try a spatial join... it fails, on purpose.
--    The shapefile is in MA State Plane (EPSG:26986); Overture is lon/lat (CRS84).
--    DuckDB tracks the CRS and refuses to mix them.
SELECT count(*)
FROM places p JOIN ej ON ST_Intersects(p.geometry, ej.geom);

-- 3. Reproject, then join.
CREATE OR REPLACE TABLE cafes AS
SELECT id, name, ST_Transform(geometry, 'EPSG:26986', always_xy := true) AS geom
FROM places
WHERE basic_category IN ('cafe', 'coffee_shop');

CREATE OR REPLACE TABLE ej_cafes AS
SELECT ej.GEOID, ej.town, ej.ej_criteria, ej.pop, ej.geom,
       count(c.id) AS cafes
FROM ej
LEFT JOIN cafes c ON ST_Contains(ej.geom, c.geom)
GROUP BY ALL;

-- 4. The answer.
SELECT ej_criteria,
       count(*)                                    AS block_groups,
       sum(cafes)                                  AS cafes,
       sum(pop)                                    AS residents,
       round(1000 * sum(cafes) / sum(pop), 2)      AS cafes_per_1000_residents
FROM ej_cafes
GROUP BY ej_criteria
ORDER BY cafes_per_1000_residents;

-- How many block groups have no café at all?
SELECT town, count(*) FILTER (WHERE cafes = 0) AS no_cafe, count(*) AS total
FROM ej_cafes GROUP BY town;

-- 5. Buffers: how many cafés within a 5-minute walk (400 m) of each café?
SELECT a.name, count(*) - 1 AS cafes_within_400m
FROM cafes a JOIN cafes b ON ST_DWithin(a.geom, b.geom, 400)
GROUP BY a.id, a.name
ORDER BY cafes_within_400m DESC
LIMIT 10;

-- 6. Out to the web map: GeoJSON (lon/lat) for kepler.gl / QGIS, GeoParquet to keep.
COPY (
  SELECT GEOID, town, ej_criteria, pop, cafes,
         ST_Transform(geom, 'EPSG:4326', always_xy := true) AS geom
  FROM ej_cafes
) TO 'ej_cafes.geojson' WITH (FORMAT gdal, DRIVER 'GeoJSON');

COPY ej_cafes TO 'ej_cafes.parquet' (FORMAT parquet);
-- Drag ej_cafes.geojson onto https://kepler.gl/demo and colour by "cafes".
