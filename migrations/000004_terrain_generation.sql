BEGIN;

ALTER TABLE world_requests
    ADD COLUMN lease_id uuid,
    ADD COLUMN lease_expires_at timestamptz,
    ADD COLUMN artifact_id uuid,
    ADD COLUMN failure_code text,
    ADD CONSTRAINT world_request_lease_state CHECK (
        (status = 'generating' AND lease_id IS NOT NULL AND lease_expires_at IS NOT NULL)
        OR (status <> 'generating' AND lease_id IS NULL AND lease_expires_at IS NULL)
    ),
    ADD CONSTRAINT world_request_artifact_state CHECK ((status = 'ready') = (artifact_id IS NOT NULL)),
    ADD CONSTRAINT world_request_failure_state CHECK ((status = 'failed') = (failure_code IS NOT NULL));

CREATE INDEX world_requests_expired_lease_idx ON world_requests (lease_expires_at)
    WHERE status = 'generating';

COMMIT;
