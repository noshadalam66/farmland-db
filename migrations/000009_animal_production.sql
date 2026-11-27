BEGIN;

ALTER TABLE farm_animals ADD COLUMN product_ready_at timestamptz;
ALTER TABLE starter_farms
    ADD COLUMN milk integer NOT NULL DEFAULT 0 CHECK (milk >= 0),
    ADD COLUMN eggs integer NOT NULL DEFAULT 0 CHECK (eggs >= 0);

ALTER TABLE starter_farm_commands
    ADD COLUMN animal_id uuid,
    DROP CONSTRAINT starter_farm_commands_action_check,
    DROP CONSTRAINT starter_farm_commands_crop_matches_action,
    ADD CONSTRAINT starter_farm_commands_action_check
        CHECK (action IN ('plant', 'harvest', 'sell', 'buy_parcel', 'buy_animal', 'feed_animal', 'collect_animal')),
    ADD CONSTRAINT starter_farm_commands_crop_matches_action
        CHECK (action = 'plant' OR (action = 'sell' AND crop IS NOT NULL)
            OR (action NOT IN ('plant', 'sell') AND crop IS NULL)),
    ADD CONSTRAINT starter_farm_commands_animal_matches_action
        CHECK ((animal_id IS NOT NULL) = (action IN ('feed_animal', 'collect_animal')));

COMMIT;
