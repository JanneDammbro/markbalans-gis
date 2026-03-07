-- Markbalans GIS Platform
-- Initial PostgreSQL/PostGIS schema
-- Purpose: establish the core data model for projects, versions,
-- corridors, alignments, towers, properties, buildings, analysis runs,
-- intersections, proximity analysis, legal cases, voluntary purchases,
-- and archived documents.

CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Optional dedicated schema
CREATE SCHEMA IF NOT EXISTS gis_platform;
SET search_path TO gis_platform, public;

-- =========================================================
-- Utility trigger for updated_at
-- =========================================================
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS trigger AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =========================================================
-- Source datasets
-- =========================================================
CREATE TABLE source_dataset (
    dataset_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    source_name text NOT NULL,
    source_type text NOT NULL,
    request_reference text,
    received_date date,
    coverage_area geometry(MultiPolygon, 3006),
    original_crs text,
    license_note text,
    confidentiality_class text,
    checksum text,
    storage_path text,
    import_status text DEFAULT 'pending',
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX source_dataset_coverage_area_gix ON source_dataset USING GIST (coverage_area);
CREATE INDEX source_dataset_source_name_idx ON source_dataset (source_name);

-- =========================================================
-- Authority cases / diary references
-- =========================================================
CREATE TABLE authority_case (
    authority_case_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    authority_name text NOT NULL,
    diary_number text,
    case_title text,
    case_type text NOT NULL,
    opened_date date,
    closed_date date,
    status text,
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT authority_case_unique UNIQUE (authority_name, diary_number)
);

-- =========================================================
-- Infrastructure projects
-- =========================================================
CREATE TABLE infrastructure_project (
    project_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    project_code text,
    project_name text NOT NULL,
    project_owner text NOT NULL,
    project_category text NOT NULL,
    voltage_kv numeric(10,2),
    region_name text,
    description text,
    status text NOT NULL,
    start_date date,
    end_date date,
    authority_case_id uuid REFERENCES authority_case(authority_case_id) ON DELETE SET NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX infrastructure_project_code_idx ON infrastructure_project (project_code);
CREATE INDEX infrastructure_project_status_idx ON infrastructure_project (status);
CREATE INDEX infrastructure_project_owner_idx ON infrastructure_project (project_owner);

-- =========================================================
-- Project versions
-- =========================================================
CREATE TABLE project_version (
    project_version_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id uuid NOT NULL REFERENCES infrastructure_project(project_id) ON DELETE CASCADE,
    dataset_id uuid REFERENCES source_dataset(dataset_id) ON DELETE SET NULL,
    version_label text NOT NULL,
    version_no integer,
    is_current boolean NOT NULL DEFAULT false,
    valid_from date,
    valid_to date,
    imported_at timestamptz NOT NULL DEFAULT now(),
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT project_version_unique UNIQUE (project_id, version_label)
);

CREATE INDEX project_version_project_idx ON project_version (project_id);
CREATE INDEX project_version_current_idx ON project_version (is_current);

-- =========================================================
-- Corridor areas
-- =========================================================
CREATE TABLE corridor_area (
    corridor_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    project_version_id uuid NOT NULL REFERENCES project_version(project_version_id) ON DELETE CASCADE,
    corridor_name text,
    corridor_type text NOT NULL,
    width_m numeric(12,2),
    priority_rank integer,
    source_feature_id text,
    geometry geometry(MultiPolygon, 3006) NOT NULL,
    area_m2 numeric(18,2),
    length_m numeric(18,2),
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT corridor_area_geometry_valid CHECK (ST_IsValid(geometry))
);

CREATE INDEX corridor_area_project_version_idx ON corridor_area (project_version_id);
CREATE INDEX corridor_area_geometry_gix ON corridor_area USING GIST (geometry);

-- =========================================================
-- Powerline alignments
-- =========================================================
CREATE TABLE powerline_alignment (
    alignment_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    project_version_id uuid NOT NULL REFERENCES project_version(project_version_id) ON DELETE CASCADE,
    alignment_name text,
    alignment_role text NOT NULL,
    circuit_count integer,
    voltage_kv numeric(10,2),
    source_feature_id text,
    geometry geometry(MultiLineString, 3006) NOT NULL,
    length_m numeric(18,2),
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT powerline_alignment_geometry_valid CHECK (ST_IsValid(geometry))
);

CREATE INDEX powerline_alignment_project_version_idx ON powerline_alignment (project_version_id);
CREATE INDEX powerline_alignment_geometry_gix ON powerline_alignment USING GIST (geometry);

-- =========================================================
-- Tower sites
-- =========================================================
CREATE TABLE tower_site (
    tower_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    project_version_id uuid NOT NULL REFERENCES project_version(project_version_id) ON DELETE CASCADE,
    alignment_id uuid REFERENCES powerline_alignment(alignment_id) ON DELETE SET NULL,
    tower_code text,
    tower_type text,
    structure_type text,
    height_m numeric(10,2),
    source_feature_id text,
    geometry geometry(Point, 3006) NOT NULL,
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT tower_site_geometry_valid CHECK (ST_IsValid(geometry))
);

CREATE INDEX tower_site_project_version_idx ON tower_site (project_version_id);
CREATE INDEX tower_site_alignment_idx ON tower_site (alignment_id);
CREATE INDEX tower_site_geometry_gix ON tower_site USING GIST (geometry);

-- =========================================================
-- Properties
-- =========================================================
CREATE TABLE property_unit (
    property_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    property_key text UNIQUE,
    property_designation text NOT NULL,
    municipality_code text,
    municipality_name text,
    county_code text,
    county_name text,
    property_type text,
    land_area_m2 numeric(18,2),
    water_area_m2 numeric(18,2),
    total_area_m2 numeric(18,2),
    geometry geometry(MultiPolygon, 3006) NOT NULL,
    centroid geometry(Point, 3006),
    source_dataset_id uuid REFERENCES source_dataset(dataset_id) ON DELETE SET NULL,
    valid_from date,
    valid_to date,
    is_current boolean NOT NULL DEFAULT true,
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT property_unit_geometry_valid CHECK (ST_IsValid(geometry))
);

CREATE UNIQUE INDEX property_unit_designation_uidx ON property_unit (property_designation);
CREATE INDEX property_unit_municipality_code_idx ON property_unit (municipality_code);
CREATE INDEX property_unit_geometry_gix ON property_unit USING GIST (geometry);
CREATE INDEX property_unit_centroid_gix ON property_unit USING GIST (centroid);

-- =========================================================
-- Property parties
-- =========================================================
CREATE TABLE property_party (
    party_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    party_type text NOT NULL,
    display_name text NOT NULL,
    org_no_or_ref text,
    privacy_class text,
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE property_ownership (
    ownership_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id uuid NOT NULL REFERENCES property_unit(property_id) ON DELETE CASCADE,
    party_id uuid NOT NULL REFERENCES property_party(party_id) ON DELETE CASCADE,
    share_text text,
    role_type text NOT NULL,
    valid_from date,
    valid_to date,
    source_dataset_id uuid REFERENCES source_dataset(dataset_id) ON DELETE SET NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX property_ownership_property_idx ON property_ownership (property_id);
CREATE INDEX property_ownership_party_idx ON property_ownership (party_id);

-- =========================================================
-- Buildings
-- =========================================================
CREATE TABLE building_object (
    building_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id uuid REFERENCES property_unit(property_id) ON DELETE SET NULL,
    building_type text NOT NULL,
    building_use text,
    building_area_m2 numeric(18,2),
    address_text text,
    year_built integer,
    geometry geometry(MultiPolygon, 3006) NOT NULL,
    centroid geometry(Point, 3006),
    source_dataset_id uuid REFERENCES source_dataset(dataset_id) ON DELETE SET NULL,
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT building_object_geometry_valid CHECK (ST_IsValid(geometry))
);

CREATE INDEX building_object_property_idx ON building_object (property_id);
CREATE INDEX building_object_geometry_gix ON building_object USING GIST (geometry);
CREATE INDEX building_object_centroid_gix ON building_object USING GIST (centroid);

-- =========================================================
-- Analysis runs
-- =========================================================
CREATE TABLE analysis_run (
    analysis_run_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    run_name text NOT NULL,
    analysis_scope text NOT NULL,
    project_version_id uuid NOT NULL REFERENCES project_version(project_version_id) ON DELETE CASCADE,
    executed_by text,
    executed_at timestamptz NOT NULL DEFAULT now(),
    software_version text,
    parameters_json jsonb,
    status text NOT NULL DEFAULT 'completed',
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX analysis_run_project_version_idx ON analysis_run (project_version_id);
CREATE INDEX analysis_run_scope_idx ON analysis_run (analysis_scope);

-- =========================================================
-- Property intersections / impacts
-- =========================================================
CREATE TABLE property_intersection (
    property_intersection_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    project_version_id uuid NOT NULL REFERENCES project_version(project_version_id) ON DELETE CASCADE,
    property_id uuid NOT NULL REFERENCES property_unit(property_id) ON DELETE CASCADE,
    corridor_id uuid REFERENCES corridor_area(corridor_id) ON DELETE SET NULL,
    alignment_id uuid REFERENCES powerline_alignment(alignment_id) ON DELETE SET NULL,
    analysis_type text NOT NULL,
    intersection_geometry geometry(MultiPolygon, 3006),
    intersection_area_m2 numeric(18,2),
    intersection_length_m numeric(18,2),
    share_of_property_pct numeric(8,4),
    min_distance_to_alignment_m numeric(18,2),
    min_distance_to_tower_m numeric(18,2),
    impact_class text,
    analysis_run_id uuid NOT NULL REFERENCES analysis_run(analysis_run_id) ON DELETE CASCADE,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX property_intersection_project_version_idx ON property_intersection (project_version_id);
CREATE INDEX property_intersection_property_idx ON property_intersection (property_id);
CREATE INDEX property_intersection_corridor_idx ON property_intersection (corridor_id);
CREATE INDEX property_intersection_alignment_idx ON property_intersection (alignment_id);
CREATE INDEX property_intersection_geometry_gix ON property_intersection USING GIST (intersection_geometry);

-- =========================================================
-- Building proximity analysis
-- =========================================================
CREATE TABLE building_proximity (
    building_proximity_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    project_version_id uuid NOT NULL REFERENCES project_version(project_version_id) ON DELETE CASCADE,
    building_id uuid NOT NULL REFERENCES building_object(building_id) ON DELETE CASCADE,
    alignment_id uuid REFERENCES powerline_alignment(alignment_id) ON DELETE SET NULL,
    tower_id uuid REFERENCES tower_site(tower_id) ON DELETE SET NULL,
    distance_to_alignment_m numeric(18,2),
    distance_to_nearest_tower_m numeric(18,2),
    within_50m boolean NOT NULL DEFAULT false,
    within_100m boolean NOT NULL DEFAULT false,
    within_200m boolean NOT NULL DEFAULT false,
    proximity_class text,
    analysis_run_id uuid NOT NULL REFERENCES analysis_run(analysis_run_id) ON DELETE CASCADE,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX building_proximity_project_version_idx ON building_proximity (project_version_id);
CREATE INDEX building_proximity_building_idx ON building_proximity (building_id);
CREATE INDEX building_proximity_alignment_idx ON building_proximity (alignment_id);
CREATE INDEX building_proximity_tower_idx ON building_proximity (tower_id);

-- =========================================================
-- Property impact summary
-- =========================================================
CREATE TABLE property_impact_summary (
    impact_summary_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    project_version_id uuid NOT NULL REFERENCES project_version(project_version_id) ON DELETE CASCADE,
    property_id uuid NOT NULL REFERENCES property_unit(property_id) ON DELETE CASCADE,
    total_overlap_area_m2 numeric(18,2),
    max_overlap_pct numeric(8,4),
    min_distance_to_alignment_m numeric(18,2),
    min_distance_to_tower_m numeric(18,2),
    dwelling_count_within_100m integer NOT NULL DEFAULT 0,
    dwelling_count_within_200m integer NOT NULL DEFAULT 0,
    tower_count_on_property integer NOT NULL DEFAULT 0,
    impact_score numeric(18,4),
    impact_rank_municipality integer,
    impact_rank_project integer,
    summary_json jsonb,
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT property_impact_summary_unique UNIQUE (project_version_id, property_id)
);

CREATE INDEX property_impact_summary_project_version_idx ON property_impact_summary (project_version_id);
CREATE INDEX property_impact_summary_property_idx ON property_impact_summary (property_id);
CREATE INDEX property_impact_summary_score_idx ON property_impact_summary (impact_score DESC);

-- =========================================================
-- Court cases
-- =========================================================
CREATE TABLE court_case (
    court_case_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    case_number text NOT NULL UNIQUE,
    court_name text NOT NULL,
    case_category text NOT NULL,
    filing_date date,
    decision_date date,
    status text,
    summary text,
    outcome text,
    precedential_value text,
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX court_case_decision_date_idx ON court_case (decision_date);
CREATE INDEX court_case_category_idx ON court_case (case_category);

-- =========================================================
-- Compensation cases
-- =========================================================
CREATE TABLE compensation_case (
    compensation_case_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id uuid REFERENCES infrastructure_project(project_id) ON DELETE SET NULL,
    property_id uuid NOT NULL REFERENCES property_unit(property_id) ON DELETE CASCADE,
    court_case_id uuid REFERENCES court_case(court_case_id) ON DELETE SET NULL,
    case_type text NOT NULL,
    claim_amount_sek numeric(18,2),
    awarded_amount_sek numeric(18,2),
    agreement_amount_sek numeric(18,2),
    valuation_date date,
    basis_text text,
    status text,
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX compensation_case_project_idx ON compensation_case (project_id);
CREATE INDEX compensation_case_property_idx ON compensation_case (property_id);
CREATE INDEX compensation_case_court_case_idx ON compensation_case (court_case_id);

-- =========================================================
-- Voluntary purchases
-- =========================================================
CREATE TABLE voluntary_purchase (
    purchase_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id uuid REFERENCES infrastructure_project(project_id) ON DELETE SET NULL,
    property_id uuid NOT NULL REFERENCES property_unit(property_id) ON DELETE CASCADE,
    buyer_name text NOT NULL,
    seller_name text,
    agreement_date date,
    access_date date,
    purchase_price_sek numeric(18,2),
    assessed_market_value_sek numeric(18,2),
    reason_category text,
    source_reliability text,
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX voluntary_purchase_project_idx ON voluntary_purchase (project_id);
CREATE INDEX voluntary_purchase_property_idx ON voluntary_purchase (property_id);
CREATE INDEX voluntary_purchase_agreement_date_idx ON voluntary_purchase (agreement_date);

-- =========================================================
-- Document archive
-- =========================================================
CREATE TABLE document_archive (
    document_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    dataset_id uuid REFERENCES source_dataset(dataset_id) ON DELETE SET NULL,
    authority_case_id uuid REFERENCES authority_case(authority_case_id) ON DELETE SET NULL,
    court_case_id uuid REFERENCES court_case(court_case_id) ON DELETE SET NULL,
    project_id uuid REFERENCES infrastructure_project(project_id) ON DELETE SET NULL,
    document_type text NOT NULL,
    title text NOT NULL,
    document_date date,
    file_name text,
    mime_type text,
    storage_path text,
    ocr_text text,
    summary_text text,
    confidentiality_class text,
    source_reference text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX document_archive_dataset_idx ON document_archive (dataset_id);
CREATE INDEX document_archive_authority_case_idx ON document_archive (authority_case_id);
CREATE INDEX document_archive_court_case_idx ON document_archive (court_case_id);
CREATE INDEX document_archive_project_idx ON document_archive (project_id);
CREATE INDEX document_archive_document_type_idx ON document_archive (document_type);

-- =========================================================
-- Case/property and case/project links
-- =========================================================
CREATE TABLE case_property_link (
    case_property_link_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    court_case_id uuid NOT NULL REFERENCES court_case(court_case_id) ON DELETE CASCADE,
    property_id uuid NOT NULL REFERENCES property_unit(property_id) ON DELETE CASCADE,
    link_type text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT case_property_link_unique UNIQUE (court_case_id, property_id, link_type)
);

CREATE TABLE case_project_link (
    case_project_link_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    court_case_id uuid NOT NULL REFERENCES court_case(court_case_id) ON DELETE CASCADE,
    project_id uuid NOT NULL REFERENCES infrastructure_project(project_id) ON DELETE CASCADE,
    link_type text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT case_project_link_unique UNIQUE (court_case_id, project_id, link_type)
);

-- =========================================================
-- Triggers for updated_at
-- =========================================================
CREATE TRIGGER trg_source_dataset_updated_at
BEFORE UPDATE ON source_dataset
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_authority_case_updated_at
BEFORE UPDATE ON authority_case
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_infrastructure_project_updated_at
BEFORE UPDATE ON infrastructure_project
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_project_version_updated_at
BEFORE UPDATE ON project_version
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_corridor_area_updated_at
BEFORE UPDATE ON corridor_area
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_powerline_alignment_updated_at
BEFORE UPDATE ON powerline_alignment
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_tower_site_updated_at
BEFORE UPDATE ON tower_site
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_property_unit_updated_at
BEFORE UPDATE ON property_unit
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_property_party_updated_at
BEFORE UPDATE ON property_party
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_property_ownership_updated_at
BEFORE UPDATE ON property_ownership
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_building_object_updated_at
BEFORE UPDATE ON building_object
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_analysis_run_updated_at
BEFORE UPDATE ON analysis_run
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_property_intersection_updated_at
BEFORE UPDATE ON property_intersection
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_building_proximity_updated_at
BEFORE UPDATE ON building_proximity
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_court_case_updated_at
BEFORE UPDATE ON court_case
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_compensation_case_updated_at
BEFORE UPDATE ON compensation_case
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_voluntary_purchase_updated_at
BEFORE UPDATE ON voluntary_purchase
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_document_archive_updated_at
BEFORE UPDATE ON document_archive
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_case_property_link_updated_at
BEFORE UPDATE ON case_property_link
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_case_project_link_updated_at
BEFORE UPDATE ON case_project_link
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =========================================================
-- Helpful views
-- =========================================================
CREATE OR REPLACE VIEW vw_project_current_version AS
SELECT pv.*
FROM project_version pv
WHERE pv.is_current = true;

CREATE OR REPLACE VIEW vw_property_project_overview AS
SELECT
    pis.project_version_id,
    pv.project_id,
    p.property_id,
    p.property_designation,
    p.municipality_name,
    pis.total_overlap_area_m2,
    pis.max_overlap_pct,
    pis.min_distance_to_alignment_m,
    pis.min_distance_to_tower_m,
    pis.dwelling_count_within_100m,
    pis.dwelling_count_within_200m,
    pis.tower_count_on_property,
    pis.impact_score,
    pis.impact_rank_project
FROM property_impact_summary pis
JOIN project_version pv ON pv.project_version_id = pis.project_version_id
JOIN property_unit p ON p.property_id = pis.property_id;

COMMENT ON SCHEMA gis_platform IS 'Core GIS schema for Markbalans infrastructure/property analysis platform.';
COMMENT ON TABLE infrastructure_project IS 'Top-level infrastructure projects such as power lines or corridor studies.';
COMMENT ON TABLE property_intersection IS 'Calculated overlap and distance metrics between a property and project geometry.';
COMMENT ON TABLE property_impact_summary IS 'Aggregated ranking-oriented impact metrics per property and project version.';

