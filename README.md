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

Apply `000005_crop_variety.sql` for wheat, corn, and rice. It retains existing
planted plots as wheat and starts new inventory counters at zero.

Apply `000006_crop_market.sql` for the coin balance and wallet entries. Each
sale references its successful farm command receipt.

Apply `000007_farm_expansion.sql` for the pilot expansion plot, plot-aware
command receipts, and parcel purchase debits.

Apply `000008_livestock.sql` to store individually identified goats and
chickens and track animal purchase debits.

Apply `000009_animal_production.sql` for per-animal growth timers and
milk and egg inventory.

Apply `000010_breeding.sql` to store animal sex, parent IDs, maturation,
and pending breeding reservations.

Apply `000011_grain_mill.sql` to store the mill, its active batch, flour
inventory, and mill and flour entries in the wallet ledger.
