BEGIN;

CREATE TABLE farm_expansion_plots (
    player_uid text PRIMARY KEY REFERENCES starter_farms (player_uid) ON DELETE CASCADE,
    planted_crop text CHECK (planted_crop IN ('wheat', 'corn', 'rice')),
    planted_at timestamptz,
    ready_at timestamptz,
    CHECK (
        (planted_crop IS NULL AND planted_at IS NULL AND ready_at IS NULL)
        OR (planted_crop IS NOT NULL AND planted_at IS NOT NULL AND ready_at IS NOT NULL AND ready_at > planted_at)
    )
);

ALTER TABLE starter_farm_commands
    ADD COLUMN plot_id text CHECK (plot_id IN ('starter', 'expansion')),
    DROP CONSTRAINT starter_farm_commands_action_check,
    DROP CONSTRAINT starter_farm_commands_crop_matches_action,
    ADD CONSTRAINT starter_farm_commands_action_check CHECK (action IN ('plant', 'harvest', 'sell', 'buy_parcel')),
    ADD CONSTRAINT starter_farm_commands_crop_matches_action
        CHECK (action = 'plant' OR (action = 'sell' AND crop IS NOT NULL) OR (action IN ('harvest', 'buy_parcel') AND crop IS NULL)),
    ADD CONSTRAINT starter_farm_commands_plot_matches_action
        CHECK (plot_id IS NULL OR action IN ('plant', 'harvest'));

ALTER TABLE farm_wallet_entries
    DROP CONSTRAINT farm_wallet_entries_reason_check,
    DROP CONSTRAINT farm_wallet_entries_coin_delta_check,
    ADD CONSTRAINT farm_wallet_entries_reason_matches_delta
        CHECK ((reason = 'crop_sale' AND coin_delta > 0) OR (reason = 'parcel_purchase' AND coin_delta < 0));

COMMIT;
