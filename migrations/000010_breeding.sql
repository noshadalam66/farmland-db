BEGIN;

ALTER TABLE farm_animals
    ADD COLUMN sex text CHECK (sex IN ('female', 'male')),
    ADD COLUMN mother_id uuid,
    ADD COLUMN father_id uuid,
    ADD COLUMN mature_at timestamptz,
    ADD UNIQUE (player_uid, animal_id),
    ADD FOREIGN KEY (player_uid, mother_id) REFERENCES farm_animals (player_uid, animal_id),
    ADD FOREIGN KEY (player_uid, father_id) REFERENCES farm_animals (player_uid, animal_id),
    ADD CONSTRAINT farm_animals_parent_pair CHECK (
        (mother_id IS NULL AND father_id IS NULL)
        OR (mother_id IS NOT NULL AND father_id IS NOT NULL AND mother_id <> father_id
            AND animal_id <> mother_id AND animal_id <> father_id)
    );

WITH ranked AS (
    SELECT animal_id, row_number() OVER (PARTITION BY player_uid, species ORDER BY acquired_at, animal_id) AS n
    FROM farm_animals
)
UPDATE farm_animals a SET sex = CASE WHEN ranked.n % 2 = 1 THEN 'female' ELSE 'male' END
FROM ranked WHERE ranked.animal_id = a.animal_id;

ALTER TABLE farm_animals ALTER COLUMN sex SET NOT NULL;

CREATE TABLE farm_breeding (
    player_uid text PRIMARY KEY REFERENCES starter_farms (player_uid) ON DELETE CASCADE,
    mother_id uuid NOT NULL,
    father_id uuid NOT NULL,
    ready_at timestamptz NOT NULL,
    CHECK (mother_id <> father_id),
    FOREIGN KEY (player_uid, mother_id) REFERENCES farm_animals (player_uid, animal_id),
    FOREIGN KEY (player_uid, father_id) REFERENCES farm_animals (player_uid, animal_id)
);

ALTER TABLE starter_farm_commands
    ADD COLUMN partner_id uuid,
    DROP CONSTRAINT starter_farm_commands_action_check,
    DROP CONSTRAINT starter_farm_commands_animal_matches_action,
    ADD CONSTRAINT starter_farm_commands_action_check
        CHECK (action IN ('plant', 'harvest', 'sell', 'buy_parcel', 'buy_animal', 'feed_animal', 'collect_animal',
            'start_breeding', 'collect_offspring')),
    ADD CONSTRAINT starter_farm_commands_animal_matches_action
        CHECK ((animal_id IS NOT NULL) = (action IN ('feed_animal', 'collect_animal', 'start_breeding'))),
    ADD CONSTRAINT starter_farm_commands_partner_matches_action
        CHECK ((partner_id IS NOT NULL) = (action = 'start_breeding'));

COMMIT;
