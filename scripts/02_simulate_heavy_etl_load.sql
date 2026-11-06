-- ============================================================================
-- Script: 02_simulate_heavy_etl_load.sql
-- Description: Simulates heavy production CRM ETL load.
--              Default scale factor 100 seeds ~88,000+ total rows.
-- ============================================================================

-- Usage: CALL "public"."sp_SimulateHeavyETLLoad"(p_scale_factor => 100, p_clean_existing => TRUE);
CALL "public"."sp_SimulateHeavyETLLoad"(100, TRUE);

-- Verify row counts and storage metrics across all schemas
SELECT
    schemaname AS "Schema",
    relname AS "Table",
    n_live_tup AS "RowCount",
    pg_size_pretty(pg_total_relation_size(relid)) AS "TotalSize"
FROM pg_stat_user_tables
WHERE schemaname IN ('Salesforce', 'HubSpot', 'Dynamics365')
ORDER BY schemaname, relname;
