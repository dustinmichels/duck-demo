-- 02_remote_parquet.sql — the "mind-blowing" part.
-- Overture Maps: every place of interest on Earth, as GeoParquet on Amazon S3.
-- Nothing is downloaded up front; DuckDB fetches only the bytes each query needs.

-- 1. How many places are there in the world?
--    Only the Parquet footers are read, so this takes seconds.
SELECT count(*) AS places_worldwide
FROM read_parquet(getvariable('overture') || '/theme=places/type=place/*');

-- 2. Look at the schema of a file sitting on a server in Oregon.
DESCRIBE
SELECT * FROM read_parquet(getvariable('overture') || '/theme=places/type=place/*');

-- 3. What kinds of places are in Boston + Cambridge?
--    The bbox filter lets DuckDB skip every row group outside this box.
SELECT basic_category, count(*) AS n
FROM read_parquet(getvariable('overture') || '/theme=places/type=place/*')
WHERE bbox.xmin BETWEEN -71.19 AND -70.99
  AND bbox.ymin BETWEEN 42.29 AND 42.40
GROUP BY basic_category
ORDER BY n DESC
LIMIT 20;

-- 4. Save Boston-area places locally so the rest of the demo is instant.
CREATE OR REPLACE TABLE places AS
SELECT
  id,
  names.primary  AS name,
  basic_category,
  confidence,
  geometry
FROM read_parquet(getvariable('overture') || '/theme=places/type=place/*')
WHERE bbox.xmin BETWEEN -71.19 AND -70.99
  AND bbox.ymin BETWEEN 42.29 AND 42.40
  AND confidence > 0.5;

SELECT count(*) FROM places;

-- 5. Coffee. (If 'cafe' returns nothing, run query 3 and pick the right category.)
SELECT name, count(*) AS locations
FROM places
WHERE basic_category IN ('cafe', 'coffee_shop')
GROUP BY name
ORDER BY locations DESC
LIMIT 10;
