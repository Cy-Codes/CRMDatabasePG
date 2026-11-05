-- ============================================================================
-- Migration: V1__init_schemas.sql
-- Description: Create schemas and extensions for CRM Database
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE SCHEMA IF NOT EXISTS "Salesforce";
CREATE SCHEMA IF NOT EXISTS "HubSpot";
CREATE SCHEMA IF NOT EXISTS "Dynamics365";
