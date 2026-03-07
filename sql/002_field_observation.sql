-- Markbalans GIS Platform
-- Field app data model
-- Adds tables for field observations, field photos and sync events

SET search_path TO gis_platform, public;

-- =========================================================
-- Field observations
-- =========================================================
CREATE TABLE IF NOT EXISTS field_observation (
    observation_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id uuid REFERENCES property_unit(property_id) ON DELETE SET NULL,
    project_version_id uuid REFERENCES project_version(project_version_id) ON DELETE SET NULL,
    building_id uuid REFERENCES building_object(building_id) ON DELETE SET NULL,
    tower_id uuid REFERENCES tower_site(tower_id) ON DELETE SET NULL,
    alignment_id uuid REFERENCES powerline_alignment(alignment_id) ON DELETE SET NULL,
    observation_type text NOT NULL,
    impact_level text NOT NULL,
    title text,
    observation_note text NOT NULL,
    observed_at timestamptz NOT NULL DEFAULT now(),
    observed_by text,
    device_id text,
    source_app text DEFAULT 'field-app',
    latitude numeric(10,7),
    longitude numeric(10,7),
    gps_accuracy_m numeric(10,2),
    location geometry(Point, 4326),
    position_sweref geometry(Point, 3006),
    distance_to_alignment_m numeric(12,2),
    distance_to_tower_m numeric(12,2),
    visibility_rating integer,
    accessibility_rating integer,
    land_use_type text,
    weather_note text,
    requires_followup boolean NOT NULL DEFAULT false,
    is_synced boolean NOT NULL DEFAULT false,
    sync_status text NOT NULL DEFAULT 'pending',
    external_reference text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT field_observation_visibility_rating_chk CHECK (
        visibility_rating IS NULL OR visibility_rating BETWEEN 1 AND 5
    ),
    CONSTRAINT field_observation_accessibility_rating_chk CHECK (
        accessibility_rating IS NULL OR accessibility_rating BETWEEN 1 AND 5
    ),
    CONSTRAINT field_observation_location_chk CHECK (
        location IS NULL OR ST_IsValid(location)
    ),
    CONSTRAINT field_observation_position_sweref_chk CHECK (
        position_sweref IS NULL OR ST_IsValid(position_sweref)
    )
);

CREATE INDEX IF NOT EXISTS field_observation_property_idx
    ON field_observation (property_id);

CREATE INDEX IF NOT EXISTS field_observation_project_version_idx
    ON field_observation (project_version_id);

CREATE INDEX IF NOT EXISTS field_observation_building_idx
    ON field_observation (building_id);

CREATE INDEX IF NOT EXISTS field_observation_alignment_idx
    ON field_observation (alignment_id);

CREATE INDEX IF NOT EXISTS field_observation_tower_idx
    ON field_observation (tower_id);

CREATE INDEX IF NOT EXISTS field_observation_observed_at_idx
    ON field_observation (observed_at DESC);

CREATE INDEX IF NOT EXISTS field_observation_sync_status_idx
    ON field_observation (sync_status);

CREATE INDEX IF NOT EXISTS field_observation_location_gix
    ON field_observation USING GIST (location);

CREATE INDEX IF NOT EXISTS field_observation_position_sweref_gix
    ON field_observation USING GIST (position_sweref);

-- =========================================================
-- Field photos
-- =========================================================
CREATE TABLE IF NOT EXISTS field_photo (
    photo_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    observation_id uuid NOT NULL REFERENCES field_observation(observation_id) ON DELETE CASCADE,
    file_name text NOT NULL,
    storage_path text,
    mime_type text,
    caption text,
    taken_at timestamptz,
    direction_deg numeric(6,2),
    latitude numeric(10,7),
    longitude numeric(10,7),
    gps_accuracy_m numeric(10,2),
    location geometry(Point, 4326),
    position_sweref geometry(Point, 3006),
    is_primary boolean NOT NULL DEFAULT false,
    is_synced boolean NOT NULL DEFAULT false,
    sync_status text NOT NULL DEFAULT 'pending',
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT field_photo_direction_chk CHECK (
        direction_deg IS NULL OR (direction_deg >= 0 AND direction_deg < 360)
    ),
    CONSTRAINT field_photo_location_chk CHECK (
        location IS NULL OR ST_IsValid(location)
    ),
    CONSTRAINT field_photo_position_sweref_chk CHECK (
        position_sweref IS NULL OR ST_IsValid(position_sweref)
    )
);

CREATE INDEX IF NOT EXISTS field_photo_observation_idx
    ON field_photo (observation_id);

CREATE INDEX IF NOT EXISTS field_photo_taken_at_idx
    ON field_photo (taken_at DESC);

CREATE INDEX IF NOT EXISTS field_photo_sync_status_idx
    ON field_photo (sync_status);

CREATE INDEX IF NOT EXISTS field_photo_location_gix
    ON field_photo USING GIST (location);

CREATE INDEX IF NOT EXISTS field_photo_position_sweref_gix
    ON field_photo USING GIST (position_sweref);

-- =========================================================
-- Field sync queue / event log
-- =========================================================
CREATE TABLE IF NOT EXISTS field_sync_event (
    sync_event_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type text NOT NULL,
    entity_id uuid NOT NULL,
    device_id text,
    event_type text NOT NULL,
    event_status text NOT NULL DEFAULT 'queued',
    payload_json jsonb,
    error_message text,
    queued_at timestamptz NOT NULL DEFAULT now(),
    processed_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS field_sync_event_entity_idx
    ON field_sync_event (entity_type, entity_id);

CREATE INDEX IF NOT EXISTS field_sync_event_status_idx
    ON field_sync_event (event_status);

CREATE INDEX IF NOT EXISTS field_sync_event_queued_at_idx
    ON field_sync_event (queued_at DESC);

-- =========================================================
-- Trigger support for updated_at
-- =========================================================
CREATE TRIGGER trg_field_observation_updated_at
BEFORE UPDATE ON field_observation
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_field_photo_updated_at
BEFORE UPDATE ON field_photo
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_field_sync_event_updated_at
BEFORE UPDATE ON field_sync_event
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =========================================================
-- Helpful view for field work overview
-- =========================================================
CREATE OR REPLACE VIEW vw_field_observation_overview AS
SELECT
    fo.observation_id,
    fo.project_version_id,
    ip.project_name,
    pu.property_designation,
    pu.municipality_name,
    fo.observation_type,
    fo.impact_level,
    fo.title,
    fo.observation_note,
    fo.observed_at,
    fo.observed_by,
    fo.requires_followup,
    fo.sync_status,
    fo.distance_to_alignment_m,
    fo.distance_to_tower_m,
    COUNT(fp.photo_id) AS photo_count
FROM field_observation fo
LEFT JOIN infrastructure_project ip
    ON ip.project_id = (
        SELECT pv.project_id
        FROM project_version pv
        WHERE pv.project_version_id = fo.project_version_id
    )
LEFT JOIN property_unit pu
    ON pu.property_id = fo.property_id
LEFT JOIN field_photo fp
    ON fp.observation_id = fo.observation_id
GROUP BY
    fo.observation_id,
    fo.project_version_id,
    ip.project_name,
    pu.property_designation,
    pu.municipality_name,
    fo.observation_type,
    fo.impact_level,
    fo.title,
    fo.observation_note,
    fo.observed_at,
    fo.observed_by,
    fo.requires_followup,
    fo.sync_status,
    fo.distance_to_alignment_m,
    fo.distance_to_tower_m;

COMMENT ON TABLE field_observation IS 'Fältobservationer från Markbalans Fältapp, kopplade till fastighet, projektversion och eventuell infrastrukturgeometri.';
COMMENT ON TABLE field_photo IS 'Fotodokumentation kopplad till fältobservationer.';
COMMENT ON TABLE field_sync_event IS 'Kö och logg för synkhändelser mellan Fältappen och central databas.';
COMMENT ON VIEW vw_field_observation_overview IS 'Översiktsvy för fältobservationer med fastighet, projekt och antal foton.';
