BEGIN;

CREATE TABLE farm_animals (
    animal_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    player_uid text NOT NULL REFERENCES starter_farms (player_uid) ON DELETE CASCADE,
    species text NOT NULL CHECK (species IN ('goat', 'chicken')),
    acquired_at timestamptz NOT NULL DEFAULT statement_timestamp()
);

CREATE INDEX farm_animals_player_idx ON farm_animals (player_uid, acquired_at, animal_id);

ALTER TABLE starter_farm_commands
    ADD COLUMN animal_species text CHECK (animal_species IN ('goat', 'chicken')),
    DROP CONSTRAINT starter_farm_commands_action_check,
    DROP CONSTRAINT starter_farm_commands_crop_matches_action,
    ADD CONSTRAINT starter_farm_commands_action_check
        CHECK (action IN ('plant', 'harvest', 'sell', 'buy_parcel', 'buy_animal')),
    ADD CONSTRAINT starter_farm_commands_crop_matches_action
        CHECK (action = 'plant' OR (action = 'sell' AND crop IS NOT NULL)
            OR (action IN ('harvest', 'buy_parcel', 'buy_animal') AND crop IS NULL)),
    ADD CONSTRAINT starter_farm_commands_species_matches_action
        CHECK ((animal_species IS NOT NULL) = (action = 'buy_animal'));

ALTER TABLE farm_wallet_entries
    DROP CONSTRAINT farm_wallet_entries_reason_matches_delta,
    ADD CONSTRAINT farm_wallet_entries_reason_matches_delta
        CHECK ((reason = 'crop_sale' AND coin_delta > 0)
            OR (reason IN ('parcel_purchase', 'animal_purchase') AND coin_delta < 0));

COMMIT;
