-- ============================================================================
-- Script: 01_seed_standard_50records.sql
-- Description: Seeds 50 realistic records with sane defaults into every table
--              across Salesforce, HubSpot, and Dynamics 365 (1,850 records total).
-- ============================================================================

CALL "public"."sp_SeedStandardData"(TRUE);

-- Verify row counts across all 3 CRM schemas
SELECT
    schemaname AS "Schema",
    relname AS "Table",
    n_live_tup AS "RowCount"
FROM pg_stat_user_tables
WHERE schemaname IN ('Salesforce', 'HubSpot', 'Dynamics365')
ORDER BY schemaname, relname;
