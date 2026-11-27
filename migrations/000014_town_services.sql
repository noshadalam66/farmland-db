BEGIN;

ALTER TABLE farm_town_buildings
    DROP CONSTRAINT farm_town_buildings_kind_check,
    ADD CONSTRAINT farm_town_buildings_kind_check
        CHECK (kind IN ('road', 'cottage', 'water_tower', 'workshop', 'school', 'clinic'));

ALTER TABLE starter_farm_commands
    DROP CONSTRAINT starter_farm_commands_building_kind_check,
    ADD CONSTRAINT starter_farm_commands_building_kind_check
        CHECK (building_kind IN ('road', 'cottage', 'water_tower', 'workshop', 'school', 'clinic'));

COMMIT;
