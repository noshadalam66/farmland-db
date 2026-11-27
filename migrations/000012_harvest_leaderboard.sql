BEGIN;

CREATE TABLE farm_leaderboard_preferences (
    player_uid text PRIMARY KEY CHECK (length(player_uid) BETWEEN 1 AND 128),
    public_id uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    enabled boolean NOT NULL
);

CREATE INDEX starter_farm_harvest_receipts_idx ON starter_farm_commands (player_uid)
    WHERE action = 'harvest';

COMMIT;
