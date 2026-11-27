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
