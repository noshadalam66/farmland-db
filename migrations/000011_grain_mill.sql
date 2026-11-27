BEGIN;

CREATE TABLE farm_grain_mills (
    player_uid text PRIMARY KEY REFERENCES starter_farms (player_uid) ON DELETE CASCADE,
    ready_at timestamptz
);

ALTER TABLE starter_farms
    ADD COLUMN flour integer NOT NULL DEFAULT 0 CHECK (flour >= 0);

ALTER TABLE starter_farm_commands
    DROP CONSTRAINT starter_farm_commands_action_check,
    ADD CONSTRAINT starter_farm_commands_action_check
        CHECK (action IN ('plant', 'harvest', 'sell', 'buy_parcel', 'buy_animal', 'feed_animal', 'collect_animal',
            'start_breeding', 'collect_offspring', 'buy_mill', 'start_milling', 'collect_flour', 'sell_flour'));

ALTER TABLE farm_wallet_entries
    DROP CONSTRAINT farm_wallet_entries_reason_matches_delta,
    ADD CONSTRAINT farm_wallet_entries_reason_matches_delta
        CHECK ((reason IN ('crop_sale', 'flour_sale') AND coin_delta > 0)
            OR (reason IN ('parcel_purchase', 'animal_purchase', 'mill_purchase') AND coin_delta < 0));

COMMIT;
