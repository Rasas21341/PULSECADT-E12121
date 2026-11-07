-- ============================================
-- Illinois State Police written warning / citation table
-- Run this ENTIRE script in the Supabase SQL Editor and click RUN.
-- ============================================

-- Citations table (create if it does not already exist)
CREATE TABLE IF NOT EXISTS citations (
    id BIGSERIAL PRIMARY KEY,
    citation_number TEXT,
    warning_number TEXT,
    citation_type TEXT,
    warning_or_citation TEXT,
    civilian_id TEXT,
    civilian_name TEXT,
    officer_id TEXT,
    officer_name TEXT,
    officer_rank TEXT,
    officer_callsign TEXT,
    statute TEXT,
    reason TEXT,
    location TEXT,
    location_description TEXT,
    county TEXT,
    gps_latitude TEXT,
    gps_longitude TEXT,
    city TEXT,
    township TEXT,
    highway_or_street_name TEXT,
    township_rd TEXT,
    milepost TEXT,
    distance NUMERIC,
    unit TEXT,
    address_no TEXT,
    intersection_or_road_feature TEXT,
    direction TEXT,
    violation_code TEXT,
    violation_description TEXT,
    posted_speed_limit TEXT,
    actual_speed TEXT,
    seat_belt_offender TEXT,
    seat_belt_role TEXT,
    vehicle_year TEXT,
    vehicle_make TEXT,
    vehicle_model TEXT,
    vehicle_plate TEXT,
    vin TEXT,
    vehicle_type TEXT,
    vehicle_color TEXT,
    registration_number TEXT,
    registration_expiration TEXT,
    registration_state TEXT,
    cmv BOOLEAN,
    usdot TEXT,
    last_name TEXT,
    first_name TEXT,
    middle_name TEXT,
    sex TEXT,
    address TEXT,
    apt_number TEXT,
    date_of_birth DATE,
    residence_city TEXT,
    residence_state TEXT,
    zip_code TEXT,
    cdl TEXT,
    drivers_license_number TEXT,
    dl_state TEXT,
    dl_class TEXT,
    license_expires DATE,
    incident_date DATE,
    incident_time TIME,
    method_of_stop TEXT,
    fine NUMERIC,
    court_date DATE,
    notes TEXT,
    signature TEXT,
    signature_data_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for faster lookups
CREATE INDEX IF NOT EXISTS idx_citations_officer ON citations(officer_id);
CREATE INDEX IF NOT EXISTS idx_citations_civilian ON citations(civilian_id);
CREATE INDEX IF NOT EXISTS idx_citations_warning_number ON citations(warning_number);
CREATE INDEX IF NOT EXISTS idx_citations_incident_date ON citations(incident_date);
CREATE INDEX IF NOT EXISTS idx_citations_vehicle_plate ON citations(vehicle_plate);
CREATE INDEX IF NOT EXISTS idx_citations_last_name ON citations(last_name);
CREATE INDEX IF NOT EXISTS idx_citations_driver_license ON citations(drivers_license_number);
CREATE INDEX IF NOT EXISTS idx_citations_created ON citations(created_at DESC);

-- Enable RLS
ALTER TABLE citations ENABLE ROW LEVEL SECURITY;

-- Policy: Officers can view citations they created
CREATE POLICY "Officers can view own citations" ON citations
    FOR SELECT USING (officer_id = current_setting('request.jwt.claims', true)::json->>'sub');

-- Policy: Officers can insert their own citations
CREATE POLICY "Officers can insert own citations" ON citations
    FOR INSERT WITH CHECK (officer_id = current_setting('request.jwt.claims', true)::json->>'sub');

-- Policy: Officers can update their own citations
CREATE POLICY "Officers can update own citations" ON citations
    FOR UPDATE USING (officer_id = current_setting('request.jwt.claims', true)::json->>'sub')
    WITH CHECK (officer_id = current_setting('request.jwt.claims', true)::json->>'sub');

-- Policy: Officers can delete their own citations
CREATE POLICY "Officers can delete own citations" ON citations
    FOR DELETE USING (officer_id = current_setting('request.jwt.claims', true)::json->>'sub');

-- Refresh PostgREST schema cache.
NOTIFY pgrst, 'reload schema';

-- ============================================
-- Done! This matches the Illinois State Police written warning format used in the police UI.
-- ============================================