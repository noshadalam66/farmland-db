\set ON_ERROR_STOP on
BEGIN;

DO $$
DECLARE
    owner_uid text := gen_random_uuid()::text;
    world uuid;
    lease uuid := gen_random_uuid();
BEGIN
    INSERT INTO world_requests (player_uid, request_id, latitude, longitude, area_km2)
    VALUES (owner_uid, gen_random_uuid(), 37.7598, -122.499, 9)
    RETURNING world_id INTO world;

    BEGIN
        INSERT INTO world_requests (player_uid, request_id, latitude, longitude, area_km2)
        VALUES (owner_uid, gen_random_uuid(), 37.7598, -122.499, 1);
        RAISE EXCEPTION 'Multiple worlds were accepted for one player';
    EXCEPTION WHEN unique_violation THEN NULL;
    END;

    BEGIN
        UPDATE world_requests SET status = 'ready' WHERE world_id = world;
        RAISE EXCEPTION 'A world became ready without an artifact';
    EXCEPTION WHEN check_violation THEN NULL;
    END;

    BEGIN
        UPDATE world_requests SET status = 'generating' WHERE world_id = world;
        RAISE EXCEPTION 'Generation started without a lease';
    EXCEPTION WHEN check_violation THEN NULL;
    END;

    UPDATE world_requests
    SET status = 'generating', lease_id = lease, lease_expires_at = now() + interval '5 minutes'
    WHERE world_id = world;

    UPDATE world_requests
    SET status = 'failed', lease_id = NULL, lease_expires_at = NULL,
        failure_code = 'terrain_outside_coverage'
    WHERE world_id = world;

    UPDATE world_requests
    SET status = 'queued', request_id = gen_random_uuid(), failure_code = NULL
    WHERE world_id = world;

    UPDATE world_requests SET status = 'ready', artifact_id = gen_random_uuid()
    WHERE world_id = world;
END $$;

ROLLBACK;
