-- ============================================
-- Add Illinois State Police Written Warning / citation fields to citations table
-- Run this ENTIRE script in your Supabase SQL Editor and click RUN.
-- ============================================

-- 1) Make sure the table exists
CREATE TABLE IF NOT EXISTS citations (
    id BIGSERIAL PRIMARY KEY,
    citation_number TEXT,
    civilian_id TEXT,
    civilian_name TEXT,
    officer_id TEXT,
    officer_name TEXT,
    officer_rank TEXT,
    officer_callsign TEXT,
    statute TEXT,
    reason TEXT,
    location TEXT,
    fine NUMERIC,
    vehicle_make TEXT,
    vehicle_model TEXT,
    vehicle_plate TEXT,
    court_date DATE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2) Add the Police form fields used by the Illinois State Police written warning / citation
ALTER TABLE citations ADD COLUMN IF NOT EXISTS warning_number TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS citation_type TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS incident_date DATE;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS incident_time TIME;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS method_of_stop TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS location_description TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS county TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS gps_latitude TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS gps_longitude TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS city TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS township TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS highway_or_street_name TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS township_rd TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS milepost TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS distance NUMERIC;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS unit TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS address_no TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS intersection_or_road_feature TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS direction TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS violation_code TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS violation_description TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS posted_speed_limit TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS actual_speed TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS seat_belt_offender TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS seat_belt_role TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS vehicle_year TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS vin TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS vehicle_type TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS vehicle_color TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS registration_number TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS registration_expiration TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS registration_state TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS cmv BOOLEAN;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS usdot TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS last_name TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS first_name TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS middle_name TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS sex TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS address TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS apt_number TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS date_of_birth DATE;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS residence_city TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS residence_state TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS zip_code TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS cdl TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS drivers_license_number TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS dl_state TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS dl_class TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS license_expires DATE;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS signature TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS signature_data_url TEXT;
ALTER TABLE citations ADD COLUMN IF NOT EXISTS warning_or_citation TEXT;

-- 3) Add a few practical indexes for search / sorting
CREATE INDEX IF NOT EXISTS idx_citations_warning_number ON citations(warning_number);
CREATE INDEX IF NOT EXISTS idx_citations_incident_date ON citations(incident_date);
CREATE INDEX IF NOT EXISTS idx_citations_vehicle_plate ON citations(vehicle_plate);
CREATE INDEX IF NOT EXISTS idx_citations_last_name ON citations(last_name);
CREATE INDEX IF NOT EXISTS idx_citations_driver_license ON citations(drivers_license_number);

-- 4) Enable RLS and make sure officers can update their own citations
ALTER TABLE citations ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policy WHERE polname = 'Officers can update citations') THEN
        CREATE POLICY "Officers can update citations" ON citations
            FOR UPDATE USING (officer_id = current_setting('request.jwt.claims', true)::json->>'sub')
            WITH CHECK (officer_id = current_setting('request.jwt.claims', true)::json->>'sub');
    END IF;
END $$;

-- 5) Refresh PostgREST schema cache
NOTIFY pgrst, 'reload schema';

-- ============================================
-- Done! Your citations table now supports the Illinois State Police written warning / citation form.
-- ============================================
