BEGIN;

ALTER TABLE starter_farm_commands
    ADD COLUMN town_order_key text,
    ADD COLUMN town_order_date date,
    DROP CONSTRAINT starter_farm_commands_action_check,
    ADD CONSTRAINT starter_farm_commands_action_check
        CHECK (action IN ('plant', 'harvest', 'sell', 'buy_parcel', 'buy_animal', 'feed_animal', 'collect_animal',
            'start_breeding', 'collect_offspring', 'buy_mill', 'start_milling', 'collect_flour', 'sell_flour',
            'build_town', 'fulfil_town_order')),
    ADD CONSTRAINT starter_farm_commands_town_order_check CHECK (
        (action = 'fulfil_town_order' AND town_order_key IN ('wheat_supply', 'flour_supply', 'milk_supply')
            AND town_order_key IS NOT NULL AND town_order_date IS NOT NULL)
        OR (action <> 'fulfil_town_order' AND town_order_key IS NULL AND town_order_date IS NULL)
    );

CREATE UNIQUE INDEX starter_farm_commands_one_daily_order
    ON starter_farm_commands (player_uid, town_order_date, town_order_key)
    WHERE action = 'fulfil_town_order';

ALTER TABLE farm_wallet_entries
    DROP CONSTRAINT farm_wallet_entries_reason_matches_delta,
    ADD CONSTRAINT farm_wallet_entries_reason_matches_delta
        CHECK ((reason IN ('crop_sale', 'flour_sale', 'town_order') AND coin_delta > 0)
            OR (reason IN ('parcel_purchase', 'animal_purchase', 'mill_purchase', 'town_construction') AND coin_delta < 0));

COMMIT;
