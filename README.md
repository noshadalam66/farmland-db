# FarmLand Empire database

PostgreSQL 17 and PostGIS migrations for the shared game backend.

Run the local database and apply the initial SQL migration.

```sh
docker compose up -d --wait
docker compose exec -T db psql -v ON_ERROR_STOP=1 -U farmland -d farmland < migrations/000001_enable_postgis.sql
docker compose exec -T db psql -U farmland -d farmland -c 'SELECT PostGIS_Version();'
```

The Compose credentials are for local development. Use a dedicated migration identity with extension permissions on production databases. Apply migrations in numeric order and add a new migration for each schema change.

Open pull requests against `main` after the initial bootstrap.

## Starter farm migration

After applying `000001_enable_postgis.sql`, apply the farm schema:

```sh
docker compose exec -T db psql -v ON_ERROR_STOP=1 -U farmland -d farmland < migrations/000002_starter_farms.sql
```

The schema holds one starter plot per Firebase UID, its wheat inventory and
revision, and successful command receipts for safe retries.

## World selection migration

Apply `000003_world_requests.sql` after the starter farm migration. It stores
one world selection per Firebase account and indexes queued generation requests.
Coordinates represent the center of the selected area in WGS 84.

Apply `000004_terrain_generation.sql` next. It adds worker leases and records
the completed artifact or failure for each request.
