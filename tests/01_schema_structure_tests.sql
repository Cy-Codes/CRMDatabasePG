-- ============================================================================
-- Test Suite: 01_schema_structure_tests.sql
-- Engine: PostgreSQL 16+
-- Scope: Database-level structural invariants (Schemas, Tables, PKs, FKs, Indexes, Procedures)
-- ============================================================================

DO $$
DECLARE
    v_schema_count INT;
    v_table_count INT;
    v_pk_count INT;
    v_fk_count INT;
    v_idx_count INT;
    v_proc_count INT;
    v_missing_tables TEXT;
    v_failed_tests INT := 0;
    v_passed_tests INT := 0;
BEGIN
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'TEST SUITE 1: SCHEMA STRUCTURE & METADATA VERIFICATION (PostgreSQL)';
    RAISE NOTICE '========================================================================';

    -- Test 1: Verify all 3 CRM Schema Namespaces exist
    SELECT COUNT(*) INTO v_schema_count
    FROM information_schema.schemata
    WHERE schema_name IN ('Salesforce', 'HubSpot', 'Dynamics365');

    IF v_schema_count = 3 THEN
        RAISE NOTICE '[PASS] Test 1.1: All 3 CRM Schemas (Salesforce, HubSpot, Dynamics365) exist.';
        v_passed_tests := v_passed_tests + 1;
    ELSE
        RAISE WARNING '[FAIL] Test 1.1: Expected 3 CRM Schemas, found %', v_schema_count;
        v_failed_tests := v_failed_tests + 1;
    END IF;

    -- Test 2: Verify all 37 Tables exist across the 3 schemas
    SELECT COUNT(*) INTO v_table_count
    FROM information_schema.tables
    WHERE table_schema IN ('Salesforce', 'HubSpot', 'Dynamics365')
      AND table_type = 'BASE TABLE';

    IF v_table_count = 37 THEN
        RAISE NOTICE '[PASS] Test 1.2: Exactly 37 CRM tables exist across schemas (Salesforce: 15, HubSpot: 11, Dynamics365: 11).';
        v_passed_tests := v_passed_tests + 1;
    ELSE
        RAISE WARNING '[FAIL] Test 1.2: Expected 37 tables, found %', v_table_count;
        v_failed_tests := v_failed_tests + 1;
    END IF;

    -- Test 3: Verify every table has a Primary Key constraint (37 PKs)
    SELECT COUNT(DISTINCT (tc.table_schema || '.' || tc.table_name)) INTO v_pk_count
    FROM information_schema.table_constraints tc
    WHERE tc.table_schema IN ('Salesforce', 'HubSpot', 'Dynamics365')
      AND tc.constraint_type = 'PRIMARY KEY';

    IF v_pk_count = 37 THEN
        RAISE NOTICE '[PASS] Test 1.3: All 37 CRM tables have a defined Primary Key constraint.';
        v_passed_tests := v_passed_tests + 1;
    ELSE
        RAISE WARNING '[FAIL] Test 1.3: Expected 37 tables with Primary Keys, found %', v_pk_count;
        v_failed_tests := v_failed_tests + 1;
    END IF;

    -- Test 4: Verify Foreign Key Constraints exist and are active
    SELECT COUNT(*) INTO v_fk_count
    FROM information_schema.table_constraints tc
    WHERE tc.table_schema IN ('Salesforce', 'HubSpot', 'Dynamics365')
      AND tc.constraint_type = 'FOREIGN KEY';

    IF v_fk_count >= 30 THEN
        RAISE NOTICE '[PASS] Test 1.4: Foreign Key constraints defined across relationships (% active FKs).', v_fk_count;
        v_passed_tests := v_passed_tests + 1;
    ELSE
        RAISE WARNING '[FAIL] Test 1.4: Expected at least 30 Foreign Keys, found %', v_fk_count;
        v_failed_tests := v_failed_tests + 1;
    END IF;

    -- Test 5: Verify Stored Procedures exist in public schema
    SELECT COUNT(*) INTO v_proc_count
    FROM information_schema.routines
    WHERE specific_schema = 'public'
      AND routine_name IN ('sp_cleanupallcrmdata', 'sp_seedstandarddata', 'sp_simulateheavyetlload');

    IF v_proc_count >= 3 THEN
        RAISE NOTICE '[PASS] Test 1.5: Core utility stored procedures (sp_CleanupAllCRMData, sp_SeedStandardData, sp_SimulateHeavyETLLoad) exist.';
        v_passed_tests := v_passed_tests + 1;
    ELSE
        RAISE WARNING '[FAIL] Test 1.5: Expected at least 3 utility procedures, found %', v_proc_count;
        v_failed_tests := v_failed_tests + 1;
    END IF;

    -- Test 6: Verify Indexes and Performance Optimizations
    SELECT COUNT(*) INTO v_idx_count
    FROM pg_indexes
    WHERE schemaname IN ('Salesforce', 'HubSpot', 'Dynamics365');

    IF v_idx_count >= 37 THEN
        RAISE NOTICE '[PASS] Test 1.6: Indexes defined across CRM schemas (% total indexes).', v_idx_count;
        v_passed_tests := v_passed_tests + 1;
    ELSE
        RAISE WARNING '[FAIL] Test 1.6: Expected at least 37 indexes, found %', v_idx_count;
        v_failed_tests := v_failed_tests + 1;
    END IF;

    RAISE NOTICE '------------------------------------------------------------------------';
    RAISE NOTICE 'Suite 1 Summary: % Passed, % Failed', v_passed_tests, v_failed_tests;
    RAISE NOTICE '------------------------------------------------------------------------';

    IF v_failed_tests > 0 THEN
        RAISE EXCEPTION 'Schema Structure Tests FAILED with % failure(s)', v_failed_tests;
    END IF;
END;
$$;
