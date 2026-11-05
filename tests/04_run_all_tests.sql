-- ============================================================================
-- Master Test Runner: 04_run_all_tests.sql
-- Engine: PostgreSQL 16+
-- Description: Executes all schema, integrity, and constraint verification suites.
-- ============================================================================

\set ON_ERROR_STOP on

\echo '========================================================================'
\echo 'STARTING POSTGRESQL CRM DATABASE TEST HARNESS'
\echo '========================================================================'

\echo '--- [1/3] Running Schema Structure Tests ---'
\ir 01_schema_structure_tests.sql

\echo '--- [2/3] Running Data Integrity & Seeding Tests ---'
\ir 02_data_integrity_and_seed_tests.sql

\echo '--- [3/3] Running Constraint Enforcement & Invariant Tests ---'
\ir 03_constraint_enforcement_tests.sql

\echo '========================================================================'
\echo 'ALL POSTGRESQL CRM DATABASE TESTS COMPLETED SUCCESSFULLY'
\echo '========================================================================'
