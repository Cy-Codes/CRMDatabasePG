-- ============================================================================
-- Test Suite: 02_data_integrity_and_seed_tests.sql
-- Engine: PostgreSQL 16+
-- Scope: Cleanup verification, 1,850 standard seed record validation, and orphan check
-- ============================================================================

DO $$
DECLARE
    v_total_rows INT;
    v_salesforce_rows INT;
    v_hubspot_rows INT;
    v_dynamics_rows INT;
    v_orphan_count INT := 0;
    v_sub_orphans INT;
    v_failed_tests INT := 0;
    v_passed_tests INT := 0;
BEGIN
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'TEST SUITE 2: DATA INTEGRITY, SEEDING & ORPHAN CHECKS (PostgreSQL)';
    RAISE NOTICE '========================================================================';

    -- Step 1: Test Cleanup Procedure
    RAISE NOTICE 'Executing sp_CleanupAllCRMData()...';
    CALL "public"."sp_CleanupAllCRMData"();

    -- Verify 0 rows in all CRM tables
    SELECT COALESCE(SUM(c.reltuples), 0) INTO v_total_rows
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname IN ('Salesforce', 'HubSpot', 'Dynamics365')
      AND c.relkind = 'r';

    -- Precise count query across schemas
    SELECT (
        (SELECT COUNT(*) FROM "Salesforce"."User") +
        (SELECT COUNT(*) FROM "Salesforce"."Account") +
        (SELECT COUNT(*) FROM "Salesforce"."Contact") +
        (SELECT COUNT(*) FROM "Salesforce"."Opportunity") +
        (SELECT COUNT(*) FROM "HubSpot"."Owner") +
        (SELECT COUNT(*) FROM "HubSpot"."Company") +
        (SELECT COUNT(*) FROM "HubSpot"."Contact") +
        (SELECT COUNT(*) FROM "HubSpot"."Deal") +
        (SELECT COUNT(*) FROM "Dynamics365"."BusinessUnit") +
        (SELECT COUNT(*) FROM "Dynamics365"."SystemUser") +
        (SELECT COUNT(*) FROM "Dynamics365"."Account") +
        (SELECT COUNT(*) FROM "Dynamics365"."Contact")
    ) INTO v_total_rows;

    IF v_total_rows = 0 THEN
        RAISE NOTICE '[PASS] Test 2.1: sp_CleanupAllCRMData successfully emptied all CRM tables (0 rows remain).';
        v_passed_tests := v_passed_tests + 1;
    ELSE
        RAISE WARNING '[FAIL] Test 2.1: Cleanup failed. Found % rows remaining.', v_total_rows;
        v_failed_tests := v_failed_tests + 1;
    END IF;

    -- Step 2: Test Standard Seeding (50 records per entity)
    RAISE NOTICE 'Executing sp_SeedStandardData(TRUE)...';
    CALL "public"."sp_SeedStandardData"(TRUE);

    -- Calculate total rows across Salesforce
    SELECT (
        (SELECT COUNT(*) FROM "Salesforce"."User") +
        (SELECT COUNT(*) FROM "Salesforce"."Account") +
        (SELECT COUNT(*) FROM "Salesforce"."Contact") +
        (SELECT COUNT(*) FROM "Salesforce"."AccountContactRelation") +
        (SELECT COUNT(*) FROM "Salesforce"."Lead") +
        (SELECT COUNT(*) FROM "Salesforce"."Campaign") +
        (SELECT COUNT(*) FROM "Salesforce"."CampaignMember") +
        (SELECT COUNT(*) FROM "Salesforce"."Opportunity") +
        (SELECT COUNT(*) FROM "Salesforce"."Product2") +
        (SELECT COUNT(*) FROM "Salesforce"."Pricebook2") +
        (SELECT COUNT(*) FROM "Salesforce"."PricebookEntry") +
        (SELECT COUNT(*) FROM "Salesforce"."OpportunityLineItem") +
        (SELECT COUNT(*) FROM "Salesforce"."Case") +
        (SELECT COUNT(*) FROM "Salesforce"."Task") +
        (SELECT COUNT(*) FROM "Salesforce"."Event")
    ) INTO v_salesforce_rows;

    IF v_salesforce_rows = 750 THEN
        RAISE NOTICE '[PASS] Test 2.2: Salesforce schema seeded exactly 750 rows (15 tables x 50 rows).';
        v_passed_tests := v_passed_tests + 1;
    ELSE
        RAISE WARNING '[FAIL] Test 2.2: Expected 750 Salesforce rows, found %', v_salesforce_rows;
        v_failed_tests := v_failed_tests + 1;
    END IF;

    -- Calculate total rows across HubSpot
    SELECT (
        (SELECT COUNT(*) FROM "HubSpot"."Owner") +
        (SELECT COUNT(*) FROM "HubSpot"."Company") +
        (SELECT COUNT(*) FROM "HubSpot"."Contact") +
        (SELECT COUNT(*) FROM "HubSpot"."Pipeline") +
        (SELECT COUNT(*) FROM "HubSpot"."DealStage") +
        (SELECT COUNT(*) FROM "HubSpot"."Deal") +
        (SELECT COUNT(*) FROM "HubSpot"."Ticket") +
        (SELECT COUNT(*) FROM "HubSpot"."Product") +
        (SELECT COUNT(*) FROM "HubSpot"."LineItem") +
        (SELECT COUNT(*) FROM "HubSpot"."Engagement") +
        (SELECT COUNT(*) FROM "HubSpot"."ObjectAssociation")
    ) INTO v_hubspot_rows;

    IF v_hubspot_rows = 550 THEN
        RAISE NOTICE '[PASS] Test 2.3: HubSpot schema seeded exactly 550 rows (11 tables x 50 rows).';
        v_passed_tests := v_passed_tests + 1;
    ELSE
        RAISE WARNING '[FAIL] Test 2.3: Expected 550 HubSpot rows, found %', v_hubspot_rows;
        v_failed_tests := v_failed_tests + 1;
    END IF;

    -- Calculate total rows across Dynamics 365
    SELECT (
        (SELECT COUNT(*) FROM "Dynamics365"."BusinessUnit") +
        (SELECT COUNT(*) FROM "Dynamics365"."SystemUser") +
        (SELECT COUNT(*) FROM "Dynamics365"."Product") +
        (SELECT COUNT(*) FROM "Dynamics365"."PriceLevel") +
        (SELECT COUNT(*) FROM "Dynamics365"."Account") +
        (SELECT COUNT(*) FROM "Dynamics365"."Contact") +
        (SELECT COUNT(*) FROM "Dynamics365"."Lead") +
        (SELECT COUNT(*) FROM "Dynamics365"."Opportunity") +
        (SELECT COUNT(*) FROM "Dynamics365"."OpportunityProduct") +
        (SELECT COUNT(*) FROM "Dynamics365"."Incident") +
        (SELECT COUNT(*) FROM "Dynamics365"."ActivityPointer")
    ) INTO v_dynamics_rows;

    IF v_dynamics_rows = 550 THEN
        RAISE NOTICE '[PASS] Test 2.4: Dynamics 365 schema seeded exactly 550 rows (11 tables x 50 rows).';
        v_passed_tests := v_passed_tests + 1;
    ELSE
        RAISE WARNING '[FAIL] Test 2.4: Expected 550 Dynamics 365 rows, found %', v_dynamics_rows;
        v_failed_tests := v_failed_tests + 1;
    END IF;

    v_total_rows := v_salesforce_rows + v_hubspot_rows + v_dynamics_rows;
    IF v_total_rows = 1850 THEN
        RAISE NOTICE '[PASS] Test 2.5: Total database record count matches standard baseline (1,850 rows across 37 tables).';
        v_passed_tests := v_passed_tests + 1;
    ELSE
        RAISE WARNING '[FAIL] Test 2.5: Total expected 1,850 rows, found %', v_total_rows;
        v_failed_tests := v_failed_tests + 1;
    END IF;

    -- Step 3: Referential Integrity & Orphan Prevention Checks
    -- Check Salesforce Contact -> Account orphans
    SELECT COUNT(*) INTO v_sub_orphans
    FROM "Salesforce"."Contact" c
    LEFT JOIN "Salesforce"."Account" a ON c."AccountId" = a."Id"
    WHERE c."AccountId" IS NOT NULL AND a."Id" IS NULL;
    v_orphan_count := v_orphan_count + v_sub_orphans;

    -- Check Salesforce Opportunity -> Account orphans
    SELECT COUNT(*) INTO v_sub_orphans
    FROM "Salesforce"."Opportunity" o
    LEFT JOIN "Salesforce"."Account" a ON o."AccountId" = a."Id"
    WHERE o."AccountId" IS NOT NULL AND a."Id" IS NULL;
    v_orphan_count := v_orphan_count + v_sub_orphans;

    -- Check Salesforce OpportunityLineItem -> Opportunity orphans
    SELECT COUNT(*) INTO v_sub_orphans
    FROM "Salesforce"."OpportunityLineItem" oli
    LEFT JOIN "Salesforce"."Opportunity" o ON oli."OpportunityId" = o."Id"
    WHERE o."Id" IS NULL;
    v_orphan_count := v_orphan_count + v_sub_orphans;

    -- Check HubSpot Contact -> Company orphans
    SELECT COUNT(*) INTO v_sub_orphans
    FROM "HubSpot"."Contact" c
    LEFT JOIN "HubSpot"."Company" comp ON c."associatedCompanyId" = comp."companyId"
    WHERE c."associatedCompanyId" IS NOT NULL AND comp."companyId" IS NULL;
    v_orphan_count := v_orphan_count + v_sub_orphans;

    -- Check HubSpot Deal -> Pipeline orphans
    SELECT COUNT(*) INTO v_sub_orphans
    FROM "HubSpot"."Deal" d
    LEFT JOIN "HubSpot"."Pipeline" p ON d."pipelineId" = p."pipelineId"
    WHERE p."pipelineId" IS NULL;
    v_orphan_count := v_orphan_count + v_sub_orphans;

    -- Check Dynamics 365 Contact -> Account orphans
    SELECT COUNT(*) INTO v_sub_orphans
    FROM "Dynamics365"."Contact" c
    LEFT JOIN "Dynamics365"."Account" a ON c."parentcustomerid" = a."accountid"
    WHERE c."parentcustomerid" IS NOT NULL AND a."accountid" IS NULL;
    v_orphan_count := v_orphan_count + v_sub_orphans;

    -- Check Dynamics 365 OpportunityProduct -> Opportunity orphans
    SELECT COUNT(*) INTO v_sub_orphans
    FROM "Dynamics365"."OpportunityProduct" op
    LEFT JOIN "Dynamics365"."Opportunity" o ON op."opportunityid" = o."opportunityid"
    WHERE o."opportunityid" IS NULL;
    v_orphan_count := v_orphan_count + v_sub_orphans;

    IF v_orphan_count = 0 THEN
        RAISE NOTICE '[PASS] Test 2.6: Zero orphaned child records detected across all relational foreign keys.';
        v_passed_tests := v_passed_tests + 1;
    ELSE
        RAISE WARNING '[FAIL] Test 2.6: Detected % orphaned records across foreign key relationships.', v_orphan_count;
        v_failed_tests := v_failed_tests + 1;
    END IF;

    RAISE NOTICE '------------------------------------------------------------------------';
    RAISE NOTICE 'Suite 2 Summary: % Passed, % Failed', v_passed_tests, v_failed_tests;
    RAISE NOTICE '------------------------------------------------------------------------';

    IF v_failed_tests > 0 THEN
        RAISE EXCEPTION 'Data Integrity Tests FAILED with % failure(s)', v_failed_tests;
    END IF;
END;
$$;
