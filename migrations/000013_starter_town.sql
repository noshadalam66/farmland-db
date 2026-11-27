BEGIN;

CREATE TABLE farm_town_buildings (
    building_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    player_uid text NOT NULL REFERENCES starter_farms (player_uid) ON DELETE CASCADE,
    kind text NOT NULL CHECK (kind IN ('road', 'cottage')),
    built_at timestamptz NOT NULL DEFAULT statement_timestamp()
);

CREATE INDEX farm_town_buildings_player_idx ON farm_town_buildings (player_uid, built_at, building_id);

ALTER TABLE starter_farm_commands
    ADD COLUMN building_kind text CHECK (building_kind IN ('road', 'cottage')),
    DROP CONSTRAINT starter_farm_commands_action_check,
    ADD CONSTRAINT starter_farm_commands_action_check
        CHECK (action IN ('plant', 'harvest', 'sell', 'buy_parcel', 'buy_animal', 'feed_animal', 'collect_animal',
            'start_breeding', 'collect_offspring', 'buy_mill', 'start_milling', 'collect_flour', 'sell_flour', 'build_town')),
    ADD CONSTRAINT starter_farm_commands_building_matches_action
        CHECK ((building_kind IS NOT NULL) = (action = 'build_town'));

ALTER TABLE farm_wallet_entries
    DROP CONSTRAINT farm_wallet_entries_reason_matches_delta,
    ADD CONSTRAINT farm_wallet_entries_reason_matches_delta
        CHECK ((reason IN ('crop_sale', 'flour_sale') AND coin_delta > 0)
            OR (reason IN ('parcel_purchase', 'animal_purchase', 'mill_purchase', 'town_construction') AND coin_delta < 0));

COMMIT;
