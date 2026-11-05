-- ============================================================================
-- Script: 03_run_schema_and_integrity_tests.sql
-- Engine: PostgreSQL 16+
-- Description: Executes complete DB-level schema, integrity, and constraint tests.
-- ============================================================================

\set ON_ERROR_STOP on

\echo '========================================================================'
\echo 'EXECUTING FULL DATABASE VERIFICATION SUITE (PostgreSQL)'
\echo '========================================================================'

-- 1. Schema Structure Tests
DO $$
DECLARE
    v_schema_count INT;
    v_table_count INT;
    v_pk_count INT;
    v_fk_count INT;
    v_proc_count INT;
BEGIN
    SELECT COUNT(*) INTO v_schema_count FROM information_schema.schemata WHERE schema_name IN ('Salesforce', 'HubSpot', 'Dynamics365');
    SELECT COUNT(*) INTO v_table_count FROM information_schema.tables WHERE table_schema IN ('Salesforce', 'HubSpot', 'Dynamics365') AND table_type = 'BASE TABLE';
    SELECT COUNT(DISTINCT (tc.table_schema || '.' || tc.table_name)) INTO v_pk_count FROM information_schema.table_constraints tc WHERE tc.table_schema IN ('Salesforce', 'HubSpot', 'Dynamics365') AND tc.constraint_type = 'PRIMARY KEY';
    SELECT COUNT(*) INTO v_fk_count FROM information_schema.table_constraints tc WHERE tc.table_schema IN ('Salesforce', 'HubSpot', 'Dynamics365') AND tc.constraint_type = 'FOREIGN KEY';
    SELECT COUNT(*) INTO v_proc_count FROM information_schema.routines WHERE specific_schema = 'public' AND routine_name IN ('sp_cleanupallcrmdata', 'sp_seedstandarddata', 'sp_simulateheavyetlload');

    RAISE NOTICE '[1/3] Schema structure: % schemas, % tables, % PKs, % FKs, % utility procedures verified.',
        v_schema_count, v_table_count, v_pk_count, v_fk_count, v_proc_count;

    IF v_schema_count != 3 OR v_table_count != 37 OR v_pk_count != 37 OR v_proc_count < 3 THEN
        RAISE EXCEPTION 'Schema structure verification failed!';
    END IF;
END;
$$;

-- 2. Data Integrity & Standard Seeding Tests
DO $$
DECLARE
    v_total_rows INT;
    v_orphan_count INT := 0;
    v_sub_orphans INT;
BEGIN
    -- Seed standard dataset (50 records per entity)
    CALL "public"."sp_SeedStandardData"(TRUE);

    SELECT (
        (SELECT COUNT(*) FROM "Salesforce"."User") + (SELECT COUNT(*) FROM "Salesforce"."Account") +
        (SELECT COUNT(*) FROM "Salesforce"."Contact") + (SELECT COUNT(*) FROM "Salesforce"."AccountContactRelation") +
        (SELECT COUNT(*) FROM "Salesforce"."Lead") + (SELECT COUNT(*) FROM "Salesforce"."Campaign") +
        (SELECT COUNT(*) FROM "Salesforce"."CampaignMember") + (SELECT COUNT(*) FROM "Salesforce"."Opportunity") +
        (SELECT COUNT(*) FROM "Salesforce"."Product2") + (SELECT COUNT(*) FROM "Salesforce"."Pricebook2") +
        (SELECT COUNT(*) FROM "Salesforce"."PricebookEntry") + (SELECT COUNT(*) FROM "Salesforce"."OpportunityLineItem") +
        (SELECT COUNT(*) FROM "Salesforce"."Case") + (SELECT COUNT(*) FROM "Salesforce"."Task") +
        (SELECT COUNT(*) FROM "Salesforce"."Event") +
        (SELECT COUNT(*) FROM "HubSpot"."Owner") + (SELECT COUNT(*) FROM "HubSpot"."Company") +
        (SELECT COUNT(*) FROM "HubSpot"."Contact") + (SELECT COUNT(*) FROM "HubSpot"."Pipeline") +
        (SELECT COUNT(*) FROM "HubSpot"."DealStage") + (SELECT COUNT(*) FROM "HubSpot"."Deal") +
        (SELECT COUNT(*) FROM "HubSpot"."Ticket") + (SELECT COUNT(*) FROM "HubSpot"."Product") +
        (SELECT COUNT(*) FROM "HubSpot"."LineItem") + (SELECT COUNT(*) FROM "HubSpot"."Engagement") +
        (SELECT COUNT(*) FROM "HubSpot"."ObjectAssociation") +
        (SELECT COUNT(*) FROM "Dynamics365"."BusinessUnit") + (SELECT COUNT(*) FROM "Dynamics365"."SystemUser") +
        (SELECT COUNT(*) FROM "Dynamics365"."Product") + (SELECT COUNT(*) FROM "Dynamics365"."PriceLevel") +
        (SELECT COUNT(*) FROM "Dynamics365"."Account") + (SELECT COUNT(*) FROM "Dynamics365"."Contact") +
        (SELECT COUNT(*) FROM "Dynamics365"."Lead") + (SELECT COUNT(*) FROM "Dynamics365"."Opportunity") +
        (SELECT COUNT(*) FROM "Dynamics365"."OpportunityProduct") + (SELECT COUNT(*) FROM "Dynamics365"."Incident") +
        (SELECT COUNT(*) FROM "Dynamics365"."ActivityPointer")
    ) INTO v_total_rows;

    RAISE NOTICE '[2/3] Data seeding: % total rows present (Expected: 1,850).', v_total_rows;

    -- Orphan checks
    SELECT COUNT(*) INTO v_sub_orphans FROM "Salesforce"."Contact" c LEFT JOIN "Salesforce"."Account" a ON c."AccountId" = a."Id" WHERE c."AccountId" IS NOT NULL AND a."Id" IS NULL;
    v_orphan_count := v_orphan_count + v_sub_orphans;
    SELECT COUNT(*) INTO v_sub_orphans FROM "HubSpot"."Contact" c LEFT JOIN "HubSpot"."Company" comp ON c."associatedCompanyId" = comp."companyId" WHERE c."associatedCompanyId" IS NOT NULL AND comp."companyId" IS NULL;
    v_orphan_count := v_orphan_count + v_sub_orphans;
    SELECT COUNT(*) INTO v_sub_orphans FROM "Dynamics365"."Contact" c LEFT JOIN "Dynamics365"."Account" a ON c."parentcustomerid" = a."accountid" WHERE c."parentcustomerid" IS NOT NULL AND a."accountid" IS NULL;
    v_orphan_count := v_orphan_count + v_sub_orphans;

    RAISE NOTICE '[2/3] Referential integrity: % orphan records found across relationships.', v_orphan_count;

    IF v_total_rows != 1850 OR v_orphan_count != 0 THEN
        RAISE EXCEPTION 'Data integrity verification failed!';
    END IF;
END;
$$;

-- 3. Constraint Invariant Tests
DO $$
DECLARE
    v_error_caught BOOLEAN := FALSE;
BEGIN
    BEGIN
        INSERT INTO "Salesforce"."Contact" (
            "Id", "AccountId", "LastName", "FirstName", "Email", "OwnerId", "CreatedById", "LastModifiedById"
        ) VALUES (
            '003999999999999AAA', '001NONEXISTENT1AAA', 'Orphan', 'Test', 'orphan@test.com',
            '005000000000001AAA', '005000000000001AAA', '005000000000001AAA'
        );
    EXCEPTION
        WHEN foreign_key_violation THEN
            v_error_caught := TRUE;
    END;

    IF NOT v_error_caught THEN
        RAISE EXCEPTION 'Foreign key constraint violation test failed (invalid insert was permitted)!';
    END IF;

    RAISE NOTICE '[3/3] Invariant validation: Database engine successfully rejected FK constraint violation.';
END;
$$;

\echo '========================================================================'
\echo 'ALL DATABASE TESTS PASSED SUCCESSFULLY'
\echo '========================================================================'
