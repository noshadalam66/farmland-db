BEGIN;

CREATE TABLE starter_farms (
    player_uid text PRIMARY KEY CHECK (length(player_uid) BETWEEN 1 AND 128),
    revision integer NOT NULL DEFAULT 0 CHECK (revision >= 0),
    wheat integer NOT NULL DEFAULT 0 CHECK (wheat >= 0),
    planted_at timestamptz,
    ready_at timestamptz,
    CHECK (
        (planted_at IS NULL AND ready_at IS NULL) OR
        (planted_at IS NOT NULL AND ready_at IS NOT NULL AND ready_at > planted_at)
    )
);

CREATE TABLE starter_farm_commands (
    player_uid text NOT NULL REFERENCES starter_farms (player_uid) ON DELETE CASCADE,
    command_id uuid NOT NULL,
    action text NOT NULL CHECK (action IN ('plant', 'harvest')),
    expected_revision integer NOT NULL CHECK (expected_revision >= 0),
    response jsonb NOT NULL,
    PRIMARY KEY (player_uid, command_id)
);

COMMIT;
