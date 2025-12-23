-- PostgreSQL Initialization Script for Keycloak
-- This script runs on first database initialization

-- Create extensions if needed
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Set timezone
SET timezone = 'UTC';

-- Log initialization
DO $$
BEGIN
    RAISE NOTICE 'Keycloak database initialized successfully';
END $$;
