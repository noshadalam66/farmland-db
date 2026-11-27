BEGIN;

CREATE TABLE world_requests (
    player_uid text PRIMARY KEY CHECK (length(player_uid) BETWEEN 1 AND 128),
    world_id uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    request_id uuid NOT NULL,
    latitude double precision NOT NULL CHECK (latitude BETWEEN -80 AND 80),
    longitude double precision NOT NULL CHECK (longitude >= -180 AND longitude < 180),
    area_km2 integer NOT NULL CHECK (area_km2 IN (1, 4, 9)),
    status text NOT NULL DEFAULT 'queued' CHECK (status IN ('queued', 'generating', 'ready', 'failed')),
    created_at timestamptz NOT NULL DEFAULT statement_timestamp()
);

CREATE INDEX world_requests_queue_idx ON world_requests (created_at, world_id)
    WHERE status = 'queued';

COMMIT;
