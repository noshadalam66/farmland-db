BEGIN;

ALTER TABLE starter_farms
    ADD COLUMN coins integer NOT NULL DEFAULT 0 CHECK (coins >= 0);

ALTER TABLE starter_farm_commands
    DROP CONSTRAINT starter_farm_commands_action_check,
    DROP CONSTRAINT starter_farm_commands_crop_requires_plant,
    ADD CONSTRAINT starter_farm_commands_action_check CHECK (action IN ('plant', 'harvest', 'sell')),
    ADD CONSTRAINT starter_farm_commands_crop_matches_action
    CHECK ((action = 'plant') OR (action = 'harvest' AND crop IS NULL) OR (action = 'sell' AND crop IS NOT NULL));

CREATE TABLE farm_wallet_entries (
    player_uid text NOT NULL,
    command_id uuid NOT NULL,
    reason text NOT NULL CHECK (reason = 'crop_sale'),
    coin_delta integer NOT NULL CHECK (coin_delta > 0),
    balance_after integer NOT NULL CHECK (balance_after >= 0),
    created_at timestamptz NOT NULL DEFAULT statement_timestamp(),
    PRIMARY KEY (player_uid, command_id),
    FOREIGN KEY (player_uid, command_id)
        REFERENCES starter_farm_commands (player_uid, command_id) ON DELETE CASCADE
);

COMMIT;
