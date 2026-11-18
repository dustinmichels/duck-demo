# DuckDB demo — run sheet

Run from the repo root so the relative paths (`trains.csv`, `data/ej2020.zip`) resolve.

```bash
duckdb --version          # need 1.2.1+ for the UI; 1.5+ for CRS-aware geometry (step 04.2)
duckdb -ui demo.duckdb    # opens the notebook UI at http://localhost:4213
```

In the UI, make one notebook cell per file (or paste section by section) and run in order:

| File | What it shows | Network | Time |
| --- | --- | --- | --- |
| `00_setup.sql` | Extensions: spatial, httpfs, excel | Yes (first run) | 10 s |
| `01_files_are_tables.sql` | CSV / Parquet / Excel are all just tables | No | 1 min |
| `02_remote_parquet.sql` | Count every place on Earth on S3; pull Boston places | Yes | 2–3 min |
| `03_buildings.sql` | Overture building footprints for downtown Boston | Yes | 2 min |
| `04_spatial.sql` | Shapefile + cloud data, CRS error, spatial join, buffers, export | No | 3 min |

## Before class

- Run everything once the night before: the extensions get cached and `places` / `buildings` are saved in `demo.duckdb`, so if campus Wi-Fi fails you can skip straight to 04.
- Check the Overture release in `00_setup.sql` is still live (https://stac.overturemaps.org). Old releases are removed after a few months.
- Run `02` query 3 once and confirm the café category name (`cafe` / `coffee_shop`) matches what Boston returns.
- Delete `trains.parquet` and `stations.xlsx` so you can create them live.
- Have https://kepler.gl/demo open in a tab for the GeoJSON drop at the end.

## Data

- `trains.csv` — Dutch rail stops, 15–21 May 2023 (380,959 rows).
- `data/ej2020.zip` — MassGIS Environmental Justice Populations 2020 (block groups, EPSG:26986).
- Overture Maps places + buildings, GeoParquet on `s3://overturemaps-us-west-2` (no credentials).
