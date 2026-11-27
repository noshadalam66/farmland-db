BEGIN;

ALTER TABLE starter_farms
    ADD COLUMN corn integer NOT NULL DEFAULT 0 CHECK (corn >= 0),
    ADD COLUMN rice integer NOT NULL DEFAULT 0 CHECK (rice >= 0),
    ADD COLUMN planted_crop text CHECK (planted_crop IN ('wheat', 'corn', 'rice'));

UPDATE starter_farms SET planted_crop = 'wheat' WHERE planted_at IS NOT NULL;

ALTER TABLE starter_farms
    ADD CONSTRAINT starter_farms_crop_matches_plot
    CHECK ((planted_crop IS NULL) = (planted_at IS NULL));

ALTER TABLE starter_farm_commands
    ADD COLUMN crop text CHECK (crop IN ('wheat', 'corn', 'rice')),
    ADD CONSTRAINT starter_farm_commands_crop_requires_plant CHECK (crop IS NULL OR action = 'plant');

COMMIT;
