-- ============================================================================
-- Test Suite: 03_constraint_enforcement_tests.sql
-- Engine: PostgreSQL 16+
-- Scope: Negative tests verifying database engine enforcement of FK, NOT NULL,
--        UNIQUE constraints, and computed generated columns
-- ============================================================================

DO $$
DECLARE
    v_error_caught BOOLEAN;
    v_computed_val NUMERIC;
    v_computed_name TEXT;
    v_failed_tests INT := 0;
    v_passed_tests INT := 0;
BEGIN
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'TEST SUITE 3: CONSTRAINT ENFORCEMENT & INVARIANT TESTS (PostgreSQL)';
    RAISE NOTICE '========================================================================';

    -- Test 3.1: Foreign Key Violation Rejection
    v_error_caught := FALSE;
    BEGIN
        INSERT INTO "Salesforce"."Contact" (
            "Id", "AccountId", "LastName", "FirstName", "Email", "OwnerId", "CreatedById", "LastModifiedById"
        ) VALUES (
            '003999999999999AAA',
            '001NONEXISTENT1AAA', -- Invalid AccountId foreign key
            'OrphanTest',
            'Test',
            'orphan@test.com',
            '005000000000001AAA',
            '005000000000001AAA',
            '005000000000001AAA'
        );
    EXCEPTION
        WHEN foreign_key_violation THEN
            v_error_caught := TRUE;
    END;

    IF v_error_caught THEN
        RAISE NOTICE '[PASS] Test 3.1: Foreign Key constraint prevented invalid child record insertion.';
        v_passed_tests := v_passed_tests + 1;
    ELSE
        RAISE WARNING '[FAIL] Test 3.1: Foreign Key violation was NOT rejected by the database engine!';
        v_failed_tests := v_failed_tests + 1;
    END IF;

    -- Test 3.2: NOT NULL Constraint Violation Rejection
    v_error_caught := FALSE;
    BEGIN
        INSERT INTO "Salesforce"."Account" (
            "Id", "Name", "OwnerId", "CreatedById", "LastModifiedById"
        ) VALUES (
            '001999999999999AAA',
            NULL, -- Violates NOT NULL on Name
            '005000000000001AAA',
            '005000000000001AAA',
            '005000000000001AAA'
        );
    EXCEPTION
        WHEN not_null_violation THEN
            v_error_caught := TRUE;
    END;

    IF v_error_caught THEN
        RAISE NOTICE '[PASS] Test 3.2: NOT NULL constraint prevented null mandatory field insertion.';
        v_passed_tests := v_passed_tests + 1;
    ELSE
        RAISE WARNING '[FAIL] Test 3.2: NOT NULL violation was NOT rejected by the database engine!';
        v_failed_tests := v_failed_tests + 1;
    END IF;

    -- Test 3.3: Unique Constraint Rejection
    v_error_caught := FALSE;
    BEGIN
        -- Attempt to insert duplicate username
        INSERT INTO "Salesforce"."User" (
            "Id", "Username", "LastName", "FirstName", "Email"
        ) VALUES (
            '005999999999999AAA',
            'user1@example-crm.com', -- Already exists in standard seed
            'DuplicateUser',
            'Test',
            'duplicate@example.com'
        );
    EXCEPTION
        WHEN unique_violation THEN
            v_error_caught := TRUE;
    END;

    IF v_error_caught THEN
        RAISE NOTICE '[PASS] Test 3.3: UNIQUE constraint prevented duplicate username insertion.';
        v_passed_tests := v_passed_tests + 1;
    ELSE
        RAISE WARNING '[FAIL] Test 3.3: UNIQUE constraint violation was NOT rejected by the database engine!';
        v_failed_tests := v_failed_tests + 1;
    END IF;

    -- Test 3.4: Generated Column Expression Evaluation (Salesforce.User.Name)
    SELECT "Name" INTO v_computed_name
    FROM "Salesforce"."User"
    WHERE "Id" = '005000000000001AAA';

    IF v_computed_name IS NOT NULL AND POSITION('Johnson' IN v_computed_name) > 0 THEN
        RAISE NOTICE '[PASS] Test 3.4: Generated column (Salesforce.User.Name) accurately evaluated: "%"', v_computed_name;
        v_passed_tests := v_passed_tests + 1;
    ELSE
        RAISE WARNING '[FAIL] Test 3.4: Generated column evaluation failed. Found: "%"', v_computed_name;
        v_failed_tests := v_failed_tests + 1;
    END IF;

    -- Test 3.5: Generated Column Expression Evaluation (Salesforce.Opportunity.ExpectedRevenue)
    SELECT "ExpectedRevenue" INTO v_computed_val
    FROM "Salesforce"."Opportunity"
    WHERE "Id" = '006000000000001AAA';

    -- Row 1: Amount = 65000, Probability = 25.00 -> ExpectedRevenue = 16250.00
    IF v_computed_val = 16250.00 THEN
        RAISE NOTICE '[PASS] Test 3.5: Generated column (Salesforce.Opportunity.ExpectedRevenue) accurately calculated: %', v_computed_val;
        v_passed_tests := v_passed_tests + 1;
    ELSE
        RAISE WARNING '[FAIL] Test 3.5: Generated column expected 16250.00, found %', v_computed_val;
        v_failed_tests := v_failed_tests + 1;
    END IF;

    RAISE NOTICE '------------------------------------------------------------------------';
    RAISE NOTICE 'Suite 3 Summary: % Passed, % Failed', v_passed_tests, v_failed_tests;
    RAISE NOTICE '------------------------------------------------------------------------';

    IF v_failed_tests > 0 THEN
        RAISE EXCEPTION 'Constraint Enforcement Tests FAILED with % failure(s)', v_failed_tests;
    END IF;
END;
$$;
