-- ============================================================================
-- Migration: V5__functions_and_procedures.sql
-- Description: Stored procedures for CRM data cleanup, seeding, and ETL simulation
-- ============================================================================

-- 1. sp_CleanupAllCRMData
CREATE OR REPLACE PROCEDURE "public"."sp_CleanupAllCRMData"()
LANGUAGE plpgsql
AS $$
BEGIN
    TRUNCATE TABLE
        "Dynamics365"."ActivityPointer",
        "Dynamics365"."Incident",
        "Dynamics365"."OpportunityProduct",
        "Dynamics365"."Opportunity",
        "Dynamics365"."Product",
        "Dynamics365"."PriceLevel",
        "Dynamics365"."Lead",
        "Dynamics365"."Contact",
        "Dynamics365"."Account",
        "Dynamics365"."SystemUser",
        "Dynamics365"."BusinessUnit",

        "HubSpot"."ObjectAssociation",
        "HubSpot"."Engagement",
        "HubSpot"."LineItem",
        "HubSpot"."Product",
        "HubSpot"."Ticket",
        "HubSpot"."Deal",
        "HubSpot"."DealStage",
        "HubSpot"."Pipeline",
        "HubSpot"."Contact",
        "HubSpot"."Company",
        "HubSpot"."Owner",

        "Salesforce"."Event",
        "Salesforce"."Task",
        "Salesforce"."Case",
        "Salesforce"."OpportunityLineItem",
        "Salesforce"."PricebookEntry",
        "Salesforce"."Pricebook2",
        "Salesforce"."Product2",
        "Salesforce"."Opportunity",
        "Salesforce"."CampaignMember",
        "Salesforce"."Campaign",
        "Salesforce"."Lead",
        "Salesforce"."AccountContactRelation",
        "Salesforce"."Contact",
        "Salesforce"."Account",
        "Salesforce"."User"
    CASCADE;

    RAISE NOTICE 'Successfully cleaned all CRM tables across Salesforce, HubSpot, and Dynamics365 schemas.';
END;
$$;


-- 2. sp_SeedStandardData
CREATE OR REPLACE PROCEDURE "public"."sp_SeedStandardData"(
    p_clean_existing BOOLEAN DEFAULT TRUE
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_clean_existing THEN
        CALL "public"."sp_CleanupAllCRMData"();
    END IF;

    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'Seeding standard CRM dataset (50 records per entity, 1,850 total)...';
    RAISE NOTICE '========================================================================';

    CREATE TEMP TABLE _N (N INT PRIMARY KEY) ON COMMIT DROP;
    INSERT INTO _N SELECT generate_series(1, 50);

    -------------------------------------------------------------------------
    -- 1. SALESFORCE SCHEMA SEEDING (50 records each)
    -------------------------------------------------------------------------
    RAISE NOTICE '  -> Seeding Salesforce schema...';

    -- 1.1 Users (18-char ID: '005000000000001AAA' to '005000000000050AAA')
    INSERT INTO "Salesforce"."User" ("Id", "Username", "LastName", "FirstName", "Email", "IsActive", "Title", "Department", "Phone")
    SELECT 
        '005000000000' || LPAD(N::text, 3, '0') || 'AAA',
        'user' || N::text || '@example-crm.com',
        CASE (N % 5)
            WHEN 0 THEN 'Smith' WHEN 1 THEN 'Johnson' WHEN 2 THEN 'Williams'
            WHEN 3 THEN 'Brown' ELSE 'Davis'
        END || N::text,
        CASE (N % 4)
            WHEN 0 THEN 'Alex' WHEN 1 THEN 'Jordan' WHEN 2 THEN 'Taylor' ELSE 'Morgan'
        END,
        'user' || N::text || '@example-crm.com',
        TRUE,
        CASE (N % 5)
            WHEN 0 THEN 'VP Sales' WHEN 1 THEN 'Enterprise Account Executive'
            WHEN 2 THEN 'Sales Development Rep' WHEN 3 THEN 'Customer Success Manager'
            ELSE 'Solutions Architect'
        END,
        CASE (N % 3) WHEN 0 THEN 'Sales' WHEN 1 THEN 'Customer Support' ELSE 'Executive' END,
        '+1-555-' || LPAD((1000 + N)::text, 4, '0')
    FROM _N;

    -- 1.2 Accounts ('001000000000001AAA'..'001000000000050AAA')
    INSERT INTO "Salesforce"."Account" (
        "Id", "ParentId", "Name", "Type", "BillingStreet", "BillingCity", "BillingState", "BillingPostalCode",
        "BillingCountry", "ShippingStreet", "ShippingCity", "ShippingState", "ShippingPostalCode", "ShippingCountry",
        "Phone", "Website", "Industry", "AnnualRevenue", "NumberOfEmployees", "Description", "OwnerId",
        "CreatedById", "LastModifiedById"
    )
    SELECT 
        '001000000000' || LPAD(N::text, 3, '0') || 'AAA',
        CASE WHEN N > 10 AND N % 4 = 0 THEN '001000000000' || LPAD(((N % 10) + 1)::text, 3, '0') || 'AAA' ELSE NULL END,
        CASE (N % 10)
            WHEN 0 THEN 'Acme Enterprise ' WHEN 1 THEN 'Global Dynamics ' WHEN 2 THEN 'Apex Technologies '
            WHEN 3 THEN 'Nexus Logistics ' WHEN 4 THEN 'Summit Health ' WHEN 5 THEN 'Vanguard Capital '
            WHEN 6 THEN 'Starlight Energy ' WHEN 7 THEN 'Horizon Media ' WHEN 8 THEN 'Omni Retail '
            ELSE 'BlueWave Biotech '
        END || N::text,
        CASE (N % 3) WHEN 0 THEN 'Customer - Direct' WHEN 1 THEN 'Customer - Channel' ELSE 'Prospect' END,
        (100 + N)::text || ' Market Street',
        CASE (N % 5) WHEN 0 THEN 'San Francisco' WHEN 1 THEN 'New York' WHEN 2 THEN 'Austin' WHEN 3 THEN 'Chicago' ELSE 'Seattle' END,
        CASE (N % 5) WHEN 0 THEN 'CA' WHEN 1 THEN 'NY' WHEN 2 THEN 'TX' WHEN 3 THEN 'IL' ELSE 'WA' END,
        LPAD((94000 + N)::text, 5, '0'),
        'USA',
        (100 + N)::text || ' Market Street',
        CASE (N % 5) WHEN 0 THEN 'San Francisco' WHEN 1 THEN 'New York' WHEN 2 THEN 'Austin' WHEN 3 THEN 'Chicago' ELSE 'Seattle' END,
        CASE (N % 5) WHEN 0 THEN 'CA' WHEN 1 THEN 'NY' WHEN 2 THEN 'TX' WHEN 3 THEN 'IL' ELSE 'WA' END,
        LPAD((94000 + N)::text, 5, '0'),
        'USA',
        '+1-415-555-' || LPAD((2000 + N)::text, 4, '0'),
        'https://www.account' || N::text || '.example.com',
        CASE (N % 5) WHEN 0 THEN 'Technology' WHEN 1 THEN 'Finance' WHEN 2 THEN 'Healthcare' WHEN 3 THEN 'Manufacturing' ELSE 'Retail' END,
        500000.00 + (N * 250000.00),
        50 + (N * 25),
        'Standard seed enterprise account record #' || N::text,
        '005000000000' || LPAD((((N - 1) % 50) + 1)::text, 3, '0') || 'AAA',
        '005000000000' || LPAD((((N - 1) % 50) + 1)::text, 3, '0') || 'AAA',
        '005000000000' || LPAD((((N - 1) % 50) + 1)::text, 3, '0') || 'AAA'
    FROM _N;

    -- 1.3 Contacts ('003000000000001AAA'..'003000000000050AAA')
    INSERT INTO "Salesforce"."Contact" (
        "Id", "AccountId", "LastName", "FirstName", "Salutation", "Title", "Department", "Email",
        "Phone", "MobilePhone", "LeadSource", "OwnerId", "CreatedById", "LastModifiedById"
    )
    SELECT 
        '003000000000' || LPAD(N::text, 3, '0') || 'AAA',
        '001000000000' || LPAD(N::text, 3, '0') || 'AAA',
        'ContactLast' || N::text,
        'ContactFirst' || N::text,
        CASE (N % 3) WHEN 0 THEN 'Mr.' WHEN 1 THEN 'Ms.' ELSE 'Dr.' END,
        CASE (N % 5) WHEN 0 THEN 'Chief Executive Officer' WHEN 1 THEN 'VP of Operations' WHEN 2 THEN 'Head of Procurement' WHEN 3 THEN 'Director of IT' ELSE 'Senior Product Manager' END,
        CASE (N % 4) WHEN 0 THEN 'Executive' WHEN 1 THEN 'Operations' WHEN 2 THEN 'Procurement' ELSE 'IT' END,
        'contact' || N::text || '@account' || N::text || '.example.com',
        '+1-555-' || LPAD((3000 + N)::text, 4, '0'),
        '+1-555-' || LPAD((7000 + N)::text, 4, '0'),
        CASE (N % 4) WHEN 0 THEN 'Web' WHEN 1 THEN 'Trade Show' WHEN 2 THEN 'Partner Referral' ELSE 'Inbound Call' END,
        '005000000000' || LPAD((((N - 1) % 50) + 1)::text, 3, '0') || 'AAA',
        '005000000000' || LPAD((((N - 1) % 50) + 1)::text, 3, '0') || 'AAA',
        '005000000000' || LPAD((((N - 1) % 50) + 1)::text, 3, '0') || 'AAA'
    FROM _N;

    -- 1.4 AccountContactRelations
    INSERT INTO "Salesforce"."AccountContactRelation" ("Id", "AccountId", "ContactId", "Roles", "IsDirect", "IsActive", "StartDate")
    SELECT 
        '07k000000000' || LPAD(N::text, 3, '0') || 'AAA',
        '001000000000' || LPAD(N::text, 3, '0') || 'AAA',
        '003000000000' || LPAD(N::text, 3, '0') || 'AAA',
        CASE (N % 3) WHEN 0 THEN 'Business User;Decision Maker' WHEN 1 THEN 'Technical Buyer' ELSE 'Evaluator' END,
        TRUE,
        TRUE,
        (CURRENT_DATE + (-30 + N))::date
    FROM _N;

    -- 1.5 Leads ('00Q000000000001AAA'..'00Q000000000050AAA')
    INSERT INTO "Salesforce"."Lead" (
        "Id", "LastName", "FirstName", "Salutation", "Title", "Company", "Street", "City",
        "State", "PostalCode", "Country", "Phone", "Email", "Status", "Industry", "AnnualRevenue",
        "NumberOfEmployees", "OwnerId", "CreatedById", "LastModifiedById"
    )
    SELECT 
        '00Q000000000' || LPAD(N::text, 3, '0') || 'AAA',
        'LeadLast' || N::text,
        'LeadFirst' || N::text,
        CASE (N % 2) WHEN 0 THEN 'Mr.' ELSE 'Ms.' END,
        CASE (N % 4) WHEN 0 THEN 'Director of Strategy' WHEN 1 THEN 'CTO' WHEN 2 THEN 'Marketing Lead' ELSE 'VP Technology' END,
        'Prospective Enterprise ' || N::text || ' Inc.',
        (500 + N)::text || ' Innovation Drive',
        CASE (N % 4) WHEN 0 THEN 'Atlanta' WHEN 1 THEN 'Denver' WHEN 2 THEN 'Miami' ELSE 'Dallas' END,
        CASE (N % 4) WHEN 0 THEN 'GA' WHEN 1 THEN 'CO' WHEN 2 THEN 'FL' ELSE 'TX' END,
        LPAD((30000 + N)::text, 5, '0'),
        'USA',
        '+1-555-' || LPAD((4000 + N)::text, 4, '0'),
        'lead' || N::text || '@prospect' || N::text || '.io',
        CASE (N % 4) WHEN 0 THEN 'Open - Not Contacted' WHEN 1 THEN 'Working - Contacted' WHEN 2 THEN 'Closed - Converted' ELSE 'Closed - Not Converted' END,
        CASE (N % 4) WHEN 0 THEN 'Technology' WHEN 1 THEN 'Healthcare' WHEN 2 THEN 'Financial Services' ELSE 'Education' END,
        300000.00 + (N * 100000.00),
        20 + (N * 10),
        '005000000000' || LPAD((((N - 1) % 50) + 1)::text, 3, '0') || 'AAA',
        '005000000000' || LPAD((((N - 1) % 50) + 1)::text, 3, '0') || 'AAA',
        '005000000000' || LPAD((((N - 1) % 50) + 1)::text, 3, '0') || 'AAA'
    FROM _N;

    -- 1.6 Campaigns ('701000000000001AAA'..'701000000000050AAA')
    INSERT INTO "Salesforce"."Campaign" (
        "Id", "Name", "Type", "Status", "StartDate", "EndDate", "ExpectedRevenue", "BudgetedCost",
        "ActualCost", "ExpectedResponse", "NumberSent", "IsActive", "OwnerId", "CreatedById", "LastModifiedById"
    )
    SELECT 
        '701000000000' || LPAD(N::text, 3, '0') || 'AAA',
        CASE (N % 5)
            WHEN 0 THEN 'Global Tech Expo ' WHEN 1 THEN 'Q3 Digital Demand Wave ' WHEN 2 THEN 'Executive Breakfast Series '
            WHEN 3 THEN 'Partner Innovation Summit ' ELSE 'Product Tier Launch '
        END || N::text,
        CASE (N % 4) WHEN 0 THEN 'Conference' WHEN 1 THEN 'Webinar' WHEN 2 THEN 'Email' ELSE 'Direct Mail' END,
        CASE (N % 3) WHEN 0 THEN 'In Progress' WHEN 1 THEN 'Completed' ELSE 'Planned' END,
        (CURRENT_DATE + (-30 + N))::date,
        (CURRENT_DATE + (60 + N))::date,
        150000.00 + (N * 50000.00),
        25000.00 + (N * 5000.00),
        22000.00 + (N * 4500.00),
        5.50 + (N % 10),
        1000 + (N * 200),
        TRUE,
        '005000000000' || LPAD((((N - 1) % 50) + 1)::text, 3, '0') || 'AAA',
        '005000000000' || LPAD((((N - 1) % 50) + 1)::text, 3, '0') || 'AAA',
        '005000000000' || LPAD((((N - 1) % 50) + 1)::text, 3, '0') || 'AAA'
    FROM _N;

    -- 1.7 CampaignMembers
    INSERT INTO "Salesforce"."CampaignMember" ("Id", "CampaignId", "LeadId", "ContactId", "Status", "HasResponded", "CreatedById", "LastModifiedById")
    SELECT 
        '00v000000000' || LPAD(N::text, 3, '0') || 'AAA',
        '701000000000' || LPAD((((N - 1) % 50) + 1)::text, 3, '0') || 'AAA',
        CASE WHEN N % 2 = 1 THEN '00Q000000000' || LPAD(N::text, 3, '0') || 'AAA' ELSE NULL END,
        CASE WHEN N % 2 = 0 THEN '003000000000' || LPAD(N::text, 3, '0') || 'AAA' ELSE NULL END,
        CASE (N % 3) WHEN 0 THEN 'Sent' WHEN 1 THEN 'Responded' ELSE 'Attended' END,
        CASE WHEN (N % 3) > 0 THEN TRUE ELSE FALSE END,
        '005000000000' || LPAD((((N - 1) % 50) + 1)::text, 3, '0') || 'AAA',
        '005000000000' || LPAD((((N - 1) % 50) + 1)::text, 3, '0') || 'AAA'
    FROM _N;

    -- 1.8 Opportunities ('006000000000001AAA'..'006000000000050AAA')
    INSERT INTO "Salesforce"."Opportunity" (
        "Id", "AccountId", "Name", "StageName", "Amount", "Probability", "CloseDate", "Type",
        "LeadSource", "IsClosed", "IsWon", "ForecastCategoryName", "CampaignId", "OwnerId",
        "CreatedById", "LastModifiedById"
    )
    SELECT 
        '006000000000' || LPAD(N::text, 3, '0') || 'AAA',
        '001000000000' || LPAD((((N - 1) % 50) + 1)::text, 3, '0') || 'AAA',
        'Enterprise Deal Suite ' || N::text,
        CASE (N % 5)
            WHEN 0 THEN 'Prospecting' WHEN 1 THEN 'Qualification' WHEN 2 THEN 'Proposal/Price Quote'
            WHEN 3 THEN 'Negotiation/Review' ELSE 'Closed Won'
        END,
        50000.00 + (N * 15000.00),
        CASE (N % 5) WHEN 0 THEN 10.00 WHEN 1 THEN 25.00 WHEN 2 THEN 60.00 WHEN 3 THEN 80.00 ELSE 100.00 END,
        (CURRENT_DATE + (N * 3))::date,
        CASE (N % 3) WHEN 0 THEN 'New Customer' WHEN 1 THEN 'Existing Customer - Upgrade' ELSE 'Existing Customer - Replacement' END,
        CASE (N % 4) WHEN 0 THEN 'Web' WHEN 1 THEN 'Partner Referral' WHEN 2 THEN 'Trade Show' ELSE 'Advertisement' END,
        CASE WHEN (N % 5) = 4 THEN TRUE ELSE FALSE END,
        CASE WHEN (N % 5) = 4 THEN TRUE ELSE FALSE END,
        CASE (N % 5) WHEN 0 THEN 'Pipeline' WHEN 1 THEN 'Pipeline' WHEN 2 THEN 'BestCase' WHEN 3 THEN 'Commit' ELSE 'Closed' END,
        '701000000000' || LPAD((((N - 1) % 50) + 1)::text, 3, '0') || 'AAA',
        '005000000000' || LPAD((((N - 1) % 50) + 1)::text, 3, '0') || 'AAA',
        '005000000000' || LPAD((((N - 1) % 50) + 1)::text, 3, '0') || 'AAA',
        '005000000000' || LPAD((((N - 1) % 50) + 1)::text, 3, '0') || 'AAA'
    FROM _N;

    -- 1.9 Product2 ('01t000000000001AAA'..'01t000000000050AAA')
    INSERT INTO "Salesforce"."Product2" (
        "Id", "Name", "ProductCode", "Description", "IsActive", "Family", "CreatedById", "LastModifiedById"
    )
    SELECT 
        '01t000000000' || LPAD(N::text, 3, '0') || 'AAA',
        CASE (N % 5)
            WHEN 0 THEN 'Cloud Storage Enterprise ' WHEN 1 THEN 'Unified Analytics Platform ' WHEN 2 THEN 'Security Compliance Shield '
            WHEN 3 THEN 'Real-time Event Broker ' ELSE 'Developer Acceleration Toolkit '
        END || N::text,
        'SKU-SF-' || LPAD((1000 + N)::text, 4, '0'),
        'High performance software and cloud infrastructure module #' || N::text,
        TRUE,
        CASE (N % 3) WHEN 0 THEN 'Software' WHEN 1 THEN 'Hardware' ELSE 'Service' END,
        '005000000000' || LPAD((((N - 1) % 50) + 1)::text, 3, '0') || 'AAA',
        '005000000000' || LPAD((((N - 1) % 50) + 1)::text, 3, '0') || 'AAA'
    FROM _N;

    -- 1.10 Pricebook2 ('01s000000000001AAA'..'01s000000000050AAA')
    INSERT INTO "Salesforce"."Pricebook2" (
        "Id", "Name", "IsActive", "IsStandard", "Description", "CreatedById", "LastModifiedById"
    )
    SELECT 
        '01s000000000' || LPAD(N::text, 3, '0') || 'AAA',
        CASE WHEN N = 1 THEN 'Standard Price Book' ELSE 'Commercial Price Book Tier ' || N::text END,
        TRUE,
        CASE WHEN N = 1 THEN TRUE ELSE FALSE END,
        'Salesforce official corporate price book catalog tier ' || N::text,
        '005000000000' || LPAD((((N - 1) % 50) + 1)::text, 3, '0') || 'AAA',
        '005000000000' || LPAD((((N - 1) % 50) + 1)::text, 3, '0') || 'AAA'
    FROM _N;

    -- 1.11 PricebookEntry ('01u000000000001AAA'..'01u000000000050AAA')
    INSERT INTO "Salesforce"."PricebookEntry" (
        "Id", "Pricebook2Id", "Product2Id", "UnitPrice", "IsActive", "UseStandardPrice", "CreatedById", "LastModifiedById"
    )
    SELECT 
        '01u000000000' || LPAD(N::text, 3, '0') || 'AAA',
        '01s000000000001AAA',
        '01t000000000' || LPAD(N::text, 3, '0') || 'AAA',
        1200.00 + (N * 250.00),
        TRUE,
        FALSE,
        '005000000000' || LPAD((((N - 1) % 50) + 1)::text, 3, '0') || 'AAA',
        '005000000000' || LPAD((((N - 1) % 50) + 1)::text, 3, '0') || 'AAA'
    FROM _N;

    -- 1.12 OpportunityLineItem ('00k000000000001AAA'..'00k000000000050AAA')
    INSERT INTO "Salesforce"."OpportunityLineItem" (
        "Id", "OpportunityId", "PricebookEntryId", "Quantity", "UnitPrice", "ListPrice",
        "Description", "CreatedById", "LastModifiedById"
    )
    SELECT 
        '00k000000000' || LPAD(N::text, 3, '0') || 'AAA',
        '006000000000' || LPAD(N::text, 3, '0') || 'AAA',
        '01u000000000' || LPAD(N::text, 3, '0') || 'AAA',
        1.00 + (N % 5),
        1200.00 + (N * 250.00),
        1200.00 + (N * 250.00),
        'Line item configuration package #' || N::text,
        '005000000000' || LPAD((((N - 1) % 50) + 1)::text, 3, '0') || 'AAA',
        '005000000000' || LPAD((((N - 1) % 50) + 1)::text, 3, '0') || 'AAA'
    FROM _N;

    -- 1.13 Case ('500000000000001AAA'..'500000000000050AAA')
    INSERT INTO "Salesforce"."Case" (
        "Id", "CaseNumber", "ContactId", "AccountId", "SuppliedEmail", "Type", "Status", "Reason",
        "Origin", "Subject", "Priority", "Description", "OwnerId", "CreatedById", "LastModifiedById"
    )
    SELECT 
        '500000000000' || LPAD(N::text, 3, '0') || 'AAA',
        'CASE-' || LPAD((10000 + N)::text, 6, '0'),
        '003000000000' || LPAD(N::text, 3, '0') || 'AAA',
        '001000000000' || LPAD(N::text, 3, '0') || 'AAA',
        'support_user' || N::text || '@account' || N::text || '.example.com',
        CASE (N % 3) WHEN 0 THEN 'Problem' WHEN 1 THEN 'Feature Request' ELSE 'Question' END,
        CASE (N % 4) WHEN 0 THEN 'New' WHEN 1 THEN 'Working' WHEN 2 THEN 'Escalated' ELSE 'Closed' END,
        CASE (N % 3) WHEN 0 THEN 'Complex functionality' WHEN 1 THEN 'Existing problem' ELSE 'Instructions not clear' END,
        CASE (N % 3) WHEN 0 THEN 'Web' WHEN 1 THEN 'Phone' ELSE 'Email' END,
        'Issue with deployment configuration #' || N::text,
        CASE (N % 3) WHEN 0 THEN 'High' WHEN 1 THEN 'Medium' ELSE 'Low' END,
        'Detailed client inquiry regarding integration architecture #' || N::text,
        '005000000000' || LPAD((((N - 1) % 50) + 1)::text, 3, '0') || 'AAA',
        '005000000000' || LPAD((((N - 1) % 50) + 1)::text, 3, '0') || 'AAA',
        '005000000000' || LPAD((((N - 1) % 50) + 1)::text, 3, '0') || 'AAA'
    FROM _N;

    -- 1.14 Task ('00T000000000001AAA'..'00T000000000050AAA')
    INSERT INTO "Salesforce"."Task" (
        "Id", "WhoId", "WhatId", "Subject", "ActivityDate", "Status", "Priority", "OwnerId", "CreatedById", "LastModifiedById"
    )
    SELECT 
        '00T000000000' || LPAD(N::text, 3, '0') || 'AAA',
        '003000000000' || LPAD(N::text, 3, '0') || 'AAA',
        '001000000000' || LPAD(N::text, 3, '0') || 'AAA',
        CASE (N % 3) WHEN 0 THEN 'Call customer re: contract review' WHEN 1 THEN 'Send proposal documentation' ELSE 'Follow up on technical requirements' END,
        (CURRENT_DATE + (N % 14))::date,
        CASE (N % 3) WHEN 0 THEN 'Not Started' WHEN 1 THEN 'In Progress' ELSE 'Completed' END,
        CASE (N % 3) WHEN 0 THEN 'High' WHEN 1 THEN 'Normal' ELSE 'Low' END,
        '005000000000' || LPAD((((N - 1) % 50) + 1)::text, 3, '0') || 'AAA',
        '005000000000' || LPAD((((N - 1) % 50) + 1)::text, 3, '0') || 'AAA',
        '005000000000' || LPAD((((N - 1) % 50) + 1)::text, 3, '0') || 'AAA'
    FROM _N;

    -- 1.15 Event ('00U000000000001AAA'..'00U000000000050AAA')
    INSERT INTO "Salesforce"."Event" (
        "Id", "WhoId", "WhatId", "Subject", "StartDateTime", "EndDateTime", "DurationInMinutes",
        "Description", "OwnerId", "CreatedById", "LastModifiedById"
    )
    SELECT 
        '00U000000000' || LPAD(N::text, 3, '0') || 'AAA',
        '003000000000' || LPAD(N::text, 3, '0') || 'AAA',
        '006000000000' || LPAD(N::text, 3, '0') || 'AAA',
        'Executive Solution Workshop #' || N::text,
        (CURRENT_TIMESTAMP + (N || ' hours')::interval),
        (CURRENT_TIMESTAMP + (N || ' hours')::interval + INTERVAL '60 minutes'),
        60,
        'Technical overview and platform demonstration #' || N::text,
        '005000000000' || LPAD((((N - 1) % 50) + 1)::text, 3, '0') || 'AAA',
        '005000000000' || LPAD((((N - 1) % 50) + 1)::text, 3, '0') || 'AAA',
        '005000000000' || LPAD((((N - 1) % 50) + 1)::text, 3, '0') || 'AAA'
    FROM _N;

    -------------------------------------------------------------------------
    -- 2. HUBSPOT SCHEMA SEEDING (50 records each)
    -------------------------------------------------------------------------
    RAISE NOTICE '  -> Seeding HubSpot schema...';

    -- 2.1 Owners (ownerId: 1001..1050)
    INSERT INTO "HubSpot"."Owner" ("ownerId", "email", "firstName", "lastName", "userId")
    SELECT 
        1000 + N,
        'hs_owner' || N::text || '@example-crm.com',
        CASE (N % 4) WHEN 0 THEN 'Sam' WHEN 1 THEN 'Chris' WHEN 2 THEN 'Pat' ELSE 'Robin' END,
        'HubSpotRep' || N::text,
        20000 + N
    FROM _N;

    -- 2.2 Companies (companyId: 2001..2050)
    INSERT INTO "HubSpot"."Company" (
        "companyId", "name", "domain", "industry", "phone", "city", "state", "country",
        "annualRevenue", "numberOfEmployees", "lifecyclestage", "ownerId"
    )
    SELECT 
        2000 + N,
        'Inbound Growth Corp ' || N::text,
        'growth' || N::text || '.example.io',
        CASE (N % 5) WHEN 0 THEN 'INFORMATION_TECHNOLOGY_AND_SERVICES' WHEN 1 THEN 'FINANCIAL_SERVICES' WHEN 2 THEN 'MARKETING_AND_ADVERTISING' WHEN 3 THEN 'HOSPITAL_AND_HEALTH_CARE' ELSE 'LOGISTICS' END,
        '+1-617-555-' || LPAD((1000 + N)::text, 4, '0'),
        CASE (N % 4) WHEN 0 THEN 'Boston' WHEN 1 THEN 'Cambridge' WHEN 2 THEN 'Austin' ELSE 'San Francisco' END,
        CASE (N % 4) WHEN 0 THEN 'MA' WHEN 1 THEN 'MA' WHEN 2 THEN 'TX' ELSE 'CA' END,
        'United States',
        750000.00 + (N * 180000.00),
        40 + (N * 15),
        CASE (N % 4) WHEN 0 THEN 'lead' WHEN 1 THEN 'marketingqualifiedlead' WHEN 2 THEN 'salesqualifiedlead' ELSE 'customer' END,
        1000 + (((N - 1) % 50) + 1)
    FROM _N;

    -- 2.3 Contacts (contactId: 3001..3050)
    INSERT INTO "HubSpot"."Contact" (
        "contactId", "email", "firstName", "lastName", "phone", "jobTitle", "lifecyclestage",
        "leadStatus", "associatedCompanyId", "ownerId"
    )
    SELECT 
        3000 + N,
        'hs_contact' || N::text || '@growth' || N::text || '.example.io',
        'HubContactFirst' || N::text,
        'HubContactLast' || N::text,
        '+1-617-555-' || LPAD((2000 + N)::text, 4, '0'),
        CASE (N % 4) WHEN 0 THEN 'VP Marketing' WHEN 1 THEN 'Chief Revenue Officer' WHEN 2 THEN 'Director of Demand Gen' ELSE 'Sales Manager' END,
        CASE (N % 4) WHEN 0 THEN 'lead' WHEN 1 THEN 'marketingqualifiedlead' WHEN 2 THEN 'salesqualifiedlead' ELSE 'customer' END,
        CASE (N % 4) WHEN 0 THEN 'NEW' WHEN 1 THEN 'OPEN' WHEN 2 THEN 'IN_PROGRESS' ELSE 'CONNECTED' END,
        2000 + N,
        1000 + (((N - 1) % 50) + 1)
    FROM _N;

    -- 2.4 Pipelines (pipelineId: pipe_4001..pipe_4050)
    INSERT INTO "HubSpot"."Pipeline" ("pipelineId", "label", "displayOrder", "objectType")
    SELECT 
        'pipe_' || (4000 + N)::text,
        CASE (N % 4) WHEN 0 THEN 'Direct Sales Pipeline ' WHEN 1 THEN 'Enterprise Solution Funnel ' WHEN 2 THEN 'Channel Partner Pipeline ' ELSE 'Renewals & Upgrades ' END || N::text,
        N,
        'deals'
    FROM _N;

    -- 2.5 DealStages (stageId: stage_5001..stage_5050)
    INSERT INTO "HubSpot"."DealStage" ("stageId", "pipelineId", "label", "displayOrder", "probability", "closedWon")
    SELECT 
        'stage_' || (5000 + N)::text,
        'pipe_' || (4000 + N)::text,
        CASE (N % 5)
            WHEN 0 THEN 'Appointment Scheduled'
            WHEN 1 THEN 'Qualified To Buy'
            WHEN 2 THEN 'Decision Maker Bought-In'
            WHEN 3 THEN 'Contract Sent'
            ELSE 'Closed Won'
        END,
        (N % 5) + 1,
        CASE (N % 5) WHEN 0 THEN 0.20 WHEN 1 THEN 0.40 WHEN 2 THEN 0.60 WHEN 3 THEN 0.80 ELSE 1.00 END,
        CASE WHEN (N % 5) = 4 THEN TRUE ELSE FALSE END
    FROM _N;

    -- 2.6 Deals (dealId: 6001..6050)
    INSERT INTO "HubSpot"."Deal" ("dealId", "dealName", "amount", "pipelineId", "dealStageId", "closedate", "dealType", "ownerId")
    SELECT 
        6000 + N,
        'Deal Package ' || N::text,
        45000.00 + (N * 12000.00),
        'pipe_' || (4000 + N)::text,
        'stage_' || (5000 + N)::text,
        (CURRENT_TIMESTAMP + ((N * 2) || ' days')::interval),
        CASE (N % 2) WHEN 0 THEN 'newbusiness' ELSE 'existingbusiness' END,
        1000 + (((N - 1) % 50) + 1)
    FROM _N;

    -- 2.7 Tickets (ticketId: 7001..7050)
    INSERT INTO "HubSpot"."Ticket" ("ticketId", "subject", "content", "pipelineId", "ticketStatusStageId", "priority", "ownerId")
    SELECT 
        7000 + N,
        'HubSpot Inbound Issue #' || N::text,
        'Inquiry regarding campaign tracking script installation #' || N::text,
        'pipe_' || (4000 + N)::text,
        'stage_' || (5000 + N)::text,
        CASE (N % 4) WHEN 0 THEN 'LOW' WHEN 1 THEN 'MEDIUM' WHEN 2 THEN 'HIGH' ELSE 'URGENT' END,
        1000 + (((N - 1) % 50) + 1)
    FROM _N;

    -- 2.8 Products (productId: 8001..8050)
    INSERT INTO "HubSpot"."Product" ("productId", "name", "description", "price", "cost", "recurringBillingFrequency")
    SELECT 
        8000 + N,
        'HubSpot Add-on Module ' || N::text,
        'Automated workflow & attribution reporting tier #' || N::text,
        1200.00 + (N * 150.00),
        300.00 + (N * 30.00),
        CASE (N % 3) WHEN 0 THEN 'monthly' WHEN 1 THEN 'annually' ELSE 'quarterly' END
    FROM _N;

    -- 2.9 LineItems (lineItemId: 9001..9050)
    INSERT INTO "HubSpot"."LineItem" ("lineItemId", "dealId", "productId", "name", "quantity", "price", "discount")
    SELECT 
        9000 + N,
        6000 + N,
        8000 + N,
        'Line Item Service ' || N::text,
        1.00 + (N % 4),
        1200.00 + (N * 150.00),
        CASE WHEN (N % 5) = 0 THEN 50.00 ELSE 0.00 END
    FROM _N;

    -- 2.10 Engagements (engagementId: 10001..10050)
    INSERT INTO "HubSpot"."Engagement" ("engagementId", "engagementType", "ownerId", "timestamp", "body", "status", "activityDurationMilliseconds")
    SELECT 
        10000 + N,
        CASE (N % 4) WHEN 0 THEN 'NOTE' WHEN 1 THEN 'EMAIL' WHEN 2 THEN 'CALL' ELSE 'MEETING' END,
        1000 + (((N - 1) % 50) + 1),
        (CURRENT_TIMESTAMP + ((-10 + N) || ' days')::interval),
        'Client communication transcript regarding annual expansion package #' || N::text,
        'COMPLETED',
        (15 + (N % 45)) * 60000
    FROM _N;

    -- 2.11 ObjectAssociations (associationId auto-increments)
    INSERT INTO "HubSpot"."ObjectAssociation" ("fromObjectType", "fromObjectId", "toObjectType", "toObjectId", "associationTypeId")
    SELECT 
        'contact',
        3000 + N,
        'company',
        2000 + N,
        1
    FROM _N;

    -------------------------------------------------------------------------
    -- 3. DYNAMICS 365 SCHEMA SEEDING (50 records each)
    -------------------------------------------------------------------------
    RAISE NOTICE '  -> Seeding Dynamics 365 schema...';

    CREATE TEMP TABLE _D365_BU (N INT PRIMARY KEY, BUId UUID) ON COMMIT DROP;
    CREATE TEMP TABLE _D365_User (N INT PRIMARY KEY, UserId UUID) ON COMMIT DROP;
    CREATE TEMP TABLE _D365_Product (N INT PRIMARY KEY, ProductId UUID) ON COMMIT DROP;
    CREATE TEMP TABLE _D365_PriceLevel (N INT PRIMARY KEY, PriceLevelId UUID) ON COMMIT DROP;

    INSERT INTO _D365_BU SELECT N, ('aa000000-0000-0000-0000-' || LPAD(N::text, 12, '0'))::uuid FROM _N;
    INSERT INTO _D365_User SELECT N, ('bb000000-0000-0000-0000-' || LPAD(N::text, 12, '0'))::uuid FROM _N;
    INSERT INTO _D365_Product SELECT N, ('cc000000-0000-0000-0000-' || LPAD(N::text, 12, '0'))::uuid FROM _N;
    INSERT INTO _D365_PriceLevel SELECT N, ('dd000000-0000-0000-0000-' || LPAD(N::text, 12, '0'))::uuid FROM _N;

    -- 3.1 BusinessUnits
    INSERT INTO "Dynamics365"."BusinessUnit" ("businessunitid", "name", "parentbusinessunitid", "isdisabled")
    SELECT 
        b.BUId,
        'Dynamics Division ' || b.N::text,
        CASE WHEN b.N > 1 THEN (SELECT BUId FROM _D365_BU WHERE N = 1 LIMIT 1) ELSE NULL END,
        FALSE
    FROM _D365_BU b;

    -- 3.2 SystemUsers
    INSERT INTO "Dynamics365"."SystemUser" (
        "systemuserid", "businessunitid", "domainname", "fullname", "firstname", "lastname",
        "internalemailaddress", "jobtitle", "isdisabled"
    )
    SELECT 
        u.UserId,
        b.BUId,
        'CORP\d365_user_' || u.N::text,
        'Dynamics User ' || u.N::text,
        'D365First_' || u.N::text,
        'D365Last_' || u.N::text,
        'd365_user_' || u.N::text || '@dynamics-corp.com',
        CASE (u.N % 4) WHEN 0 THEN 'Enterprise Account Manager' WHEN 1 THEN 'Solutions Consultant' WHEN 2 THEN 'Service Specialist' ELSE 'System Administrator' END,
        FALSE
    FROM _D365_User u
    JOIN _D365_BU b ON u.N = b.N;

    -- 3.3 Products
    INSERT INTO "Dynamics365"."Product" (
        "productid", "productnumber", "name", "description", "price", "standardcost", "currentcost",
        "quantityonhand", "statecode", "statuscode", "createdby", "modifiedby"
    )
    SELECT 
        p.ProductId,
        'MS-D365-SKU-' || LPAD(p.N::text, 4, '0'),
        'Dataverse Solution Package ' || p.N::text,
        'Dynamics 365 enterprise service module #' || p.N::text,
        1500.00 + (p.N * 120.00),
        900.00 + (p.N * 80.00),
        1100.00 + (p.N * 100.00),
        500.00,
        0, 1,
        (SELECT UserId FROM _D365_User WHERE N = 1 LIMIT 1),
        (SELECT UserId FROM _D365_User WHERE N = 1 LIMIT 1)
    FROM _D365_Product p;

    -- 3.4 PriceLevels
    INSERT INTO "Dynamics365"."PriceLevel" (
        "pricelevelid", "name", "begindate", "enddate", "statecode", "statuscode", "createdby", "modifiedby"
    )
    SELECT 
        pl.PriceLevelId,
        'Dynamics Commercial Price Tier ' || pl.N::text,
        (CURRENT_DATE - INTERVAL '1 year')::date,
        (CURRENT_DATE + INTERVAL '2 years')::date,
        0, 1,
        (SELECT UserId FROM _D365_User WHERE N = 1 LIMIT 1),
        (SELECT UserId FROM _D365_User WHERE N = 1 LIMIT 1)
    FROM _D365_PriceLevel pl;

    -- 3.5 Accounts
    INSERT INTO "Dynamics365"."Account" (
        "accountid", "accountnumber", "name", "telephone1", "websiteurl", "address1_line1",
        "address1_city", "address1_stateorprovince", "address1_postalcode", "address1_country",
        "revenue", "numberofemployees", "industrycode", "statecode", "statuscode",
        "ownerid", "owningbusinessunit", "createdby", "modifiedby"
    )
    SELECT 
        ('c1000000-0000-0000-0000-' || LPAD(n.N::text, 12, '0'))::uuid,
        'ACT-' || LPAD(n.N::text, 6, '0'),
        'Dataverse Enterprise Corp ' || n.N::text,
        '+1-425-555-' || LPAD((5000 + n.N)::text, 4, '0'),
        'https://www.dataverse' || n.N::text || '.example.com',
        (1000 + n.N)::text || ' Microsoft Way',
        CASE (n.N % 4) WHEN 0 THEN 'Redmond' WHEN 1 THEN 'Seattle' WHEN 2 THEN 'Bellevue' ELSE 'Kirkland' END,
        'WA',
        '98052',
        'United States',
        1000000.00 + (n.N * 350000.00),
        100 + (n.N * 40),
        (n.N % 10) + 1,
        0, 1,
        u.UserId,
        b.BUId,
        u.UserId,
        u.UserId
    FROM _N n
    JOIN _D365_User u ON u.N = n.N
    JOIN _D365_BU b ON b.N = n.N;

    -- 3.6 Contacts
    INSERT INTO "Dynamics365"."Contact" (
        "contactid", "fullname", "firstname", "lastname", "emailaddress1", "telephone1", "jobtitle",
        "parentcustomerid", "statecode", "statuscode", "ownerid", "owningbusinessunit", "createdby", "modifiedby"
    )
    SELECT 
        ('d2000000-0000-0000-0000-' || LPAD(n.N::text, 12, '0'))::uuid,
        'D365 Contact ' || n.N::text,
        'D365First_' || n.N::text,
        'D365Last_' || n.N::text,
        'contact' || n.N::text || '@dataverse' || n.N::text || '.example.com',
        '+1-425-555-' || LPAD((6000 + n.N)::text, 4, '0'),
        CASE (n.N % 4) WHEN 0 THEN 'VP Business Development' WHEN 1 THEN 'Enterprise IT Architect' WHEN 2 THEN 'Lead Operations Manager' ELSE 'Finance Director' END,
        ('c1000000-0000-0000-0000-' || LPAD(n.N::text, 12, '0'))::uuid,
        0, 1,
        u.UserId,
        b.BUId,
        u.UserId,
        u.UserId
    FROM _N n
    JOIN _D365_User u ON u.N = n.N
    JOIN _D365_BU b ON b.N = n.N;

    -- 3.7 Leads
    INSERT INTO "Dynamics365"."Lead" (
        "leadid", "fullname", "firstname", "lastname", "companyname", "subject", "emailaddress1",
        "telephone1", "estimatedamount", "leadqualitycode", "leadsourcecode", "statecode", "statuscode",
        "ownerid", "owningbusinessunit", "createdby", "modifiedby"
    )
    SELECT 
        ('e3000000-0000-0000-0000-' || LPAD(n.N::text, 12, '0'))::uuid,
        'D365 Lead ' || n.N::text,
        'LeadFirst_' || n.N::text,
        'LeadLast_' || n.N::text,
        'Prospective Cloud Enterprise ' || n.N::text,
        'Interest in Dataverse ERP Migration Suite #' || n.N::text,
        'lead' || n.N::text || '@futurecorp' || n.N::text || '.io',
        '+1-425-555-' || LPAD((7000 + n.N)::text, 4, '0'),
        85000.00 + (n.N * 15000.00),
        (n.N % 3) + 1,
        (n.N % 5) + 1,
        0, 1,
        u.UserId,
        b.BUId,
        u.UserId,
        u.UserId
    FROM _N n
    JOIN _D365_User u ON u.N = n.N
    JOIN _D365_BU b ON b.N = n.N;

    -- 3.8 Opportunities
    INSERT INTO "Dynamics365"."Opportunity" (
        "opportunityid", "name", "parentaccountid", "pricelevelid", "estimatedvalue",
        "estimatedclosedate", "closeprobability", "stepname", "salesstage", "statecode", "statuscode",
        "ownerid", "owningbusinessunit", "createdby", "modifiedby"
    )
    SELECT 
        ('f4000000-0000-0000-0000-' || LPAD(n.N::text, 12, '0'))::uuid,
        'Dynamics Enterprise Transformation ' || n.N::text,
        ('c1000000-0000-0000-0000-' || LPAD(n.N::text, 12, '0'))::uuid,
        pl.PriceLevelId,
        150000.00 + (n.N * 30000.00),
        (CURRENT_DATE + (n.N * 4))::date,
        50 + (n.N % 50),
        'Qualify -> Develop -> Propose',
        (n.N % 4) + 1,
        0, 1,
        u.UserId,
        b.BUId,
        u.UserId,
        u.UserId
    FROM _N n
    JOIN _D365_User u ON u.N = n.N
    JOIN _D365_BU b ON b.N = n.N
    JOIN _D365_PriceLevel pl ON pl.N = n.N;

    -- 3.9 OpportunityProducts
    INSERT INTO "Dynamics365"."OpportunityProduct" (
        "opportunityproductid", "opportunityid", "productid", "priceperunit", "quantity",
        "manualdiscountamount", "createdby", "modifiedby"
    )
    SELECT 
        ('a5000000-0000-0000-0000-' || LPAD(n.N::text, 12, '0'))::uuid,
        ('f4000000-0000-0000-0000-' || LPAD(n.N::text, 12, '0'))::uuid,
        p.ProductId,
        1500.00 + (n.N * 120.00),
        1.00 + (n.N % 5),
        0.00,
        u.UserId,
        u.UserId
    FROM _N n
    JOIN _D365_User u ON u.N = n.N
    JOIN _D365_Product p ON p.N = n.N;

    -- 3.10 Incidents
    INSERT INTO "Dynamics365"."Incident" (
        "incidentid", "ticketnumber", "title", "customerid_account", "customerid_contact",
        "prioritycode", "statecode", "statuscode", "ownerid", "owningbusinessunit", "createdby", "modifiedby"
    )
    SELECT 
        ('b6000000-0000-0000-0000-' || LPAD(n.N::text, 12, '0'))::uuid,
        'CAS-' || LPAD((20000 + n.N)::text, 6, '0'),
        'Power Apps connector issue #' || n.N::text,
        ('c1000000-0000-0000-0000-' || LPAD(n.N::text, 12, '0'))::uuid,
        ('d2000000-0000-0000-0000-' || LPAD(n.N::text, 12, '0'))::uuid,
        (n.N % 3) + 1,
        0, 1,
        u.UserId,
        b.BUId,
        u.UserId,
        u.UserId
    FROM _N n
    JOIN _D365_User u ON u.N = n.N
    JOIN _D365_BU b ON b.N = n.N;

    -- 3.11 ActivityPointers
    INSERT INTO "Dynamics365"."ActivityPointer" (
        "activityid", "activitytypecode", "subject", "regardingobjectid_account",
        "regardingobjectid_opportunity", "ownerid", "owningbusinessunit", "statecode", "statuscode",
        "createdby", "modifiedby"
    )
    SELECT 
        ('c7000000-0000-0000-0000-' || LPAD(n.N::text, 12, '0'))::uuid,
        CASE (n.N % 4) WHEN 0 THEN 'appointment' WHEN 1 THEN 'email' WHEN 2 THEN 'phonecall' ELSE 'task' END,
        'Dataverse customer strategy touchpoint #' || n.N::text,
        ('c1000000-0000-0000-0000-' || LPAD(n.N::text, 12, '0'))::uuid,
        ('f4000000-0000-0000-0000-' || LPAD(n.N::text, 12, '0'))::uuid,
        u.UserId,
        b.BUId,
        0, 1,
        u.UserId,
        u.UserId
    FROM _N n
    JOIN _D365_User u ON u.N = n.N
    JOIN _D365_BU b ON b.N = n.N;

    RAISE NOTICE 'Standard seeding completed successfully. 1,850 rows inserted.';
END;
$$;


-- 3. sp_SimulateHeavyETLLoad
CREATE OR REPLACE PROCEDURE "public"."sp_SimulateHeavyETLLoad"(
    p_scale_factor INT DEFAULT 100,
    p_clean_existing BOOLEAN DEFAULT TRUE
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_ScaleFactor INT := p_scale_factor;
    v_UserCount INT;
    v_AccountCount INT;
    v_ContactCount INT;
    v_LeadCount INT;
    v_OpportunityCount INT;
    v_ProductCount INT;
    v_CaseCount INT;
    v_ActivityCount INT;
    v_CampaignCount INT;
    v_MaxRecords INT;
    v_D365BUCount INT;
BEGIN
    IF v_ScaleFactor < 1 THEN v_ScaleFactor := 1; END IF;
    IF v_ScaleFactor > 1000 THEN v_ScaleFactor := 1000; END IF;

    v_UserCount        := 10 * v_ScaleFactor;
    v_AccountCount     := 50 * v_ScaleFactor;
    v_ContactCount     := 100 * v_ScaleFactor;
    v_LeadCount        := 150 * v_ScaleFactor;
    v_OpportunityCount := 80 * v_ScaleFactor;
    v_ProductCount     := 20 * v_ScaleFactor;
    v_CaseCount        := 120 * v_ScaleFactor;
    v_ActivityCount    := 250 * v_ScaleFactor;
    v_CampaignCount    := 15 * v_ScaleFactor;

    v_MaxRecords       := v_ActivityCount;
    v_D365BUCount      := CASE WHEN v_UserCount / 10 < 10 THEN 10 ELSE v_UserCount / 10 END;

    IF p_clean_existing THEN
        CALL "public"."sp_CleanupAllCRMData"();
    END IF;

    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'Beginning high-volume ETL simulation load (Scale Factor: %)...', v_ScaleFactor;
    RAISE NOTICE 'Target volume: ~88,000+ records across 3 CRM engines';
    RAISE NOTICE '========================================================================';

    CREATE TEMP TABLE _Tally (N INT PRIMARY KEY) ON COMMIT DROP;
    INSERT INTO _Tally SELECT generate_series(1, v_MaxRecords);

    -------------------------------------------------------------------------
    -- 1. HEAVY LOAD: SALESFORCE SCHEMA
    -------------------------------------------------------------------------
    RAISE NOTICE '  -> Bulk inserting Salesforce production dataset...';

    -- Users
    INSERT INTO "Salesforce"."User" ("Id", "Username", "LastName", "FirstName", "Email", "IsActive", "Title", "Department", "Phone", "CreatedDate", "LastModifiedDate")
    SELECT 
        '005' || LPAD(N::text, 12, '0') || 'AAA',
        'sf_etl_user_' || N::text || '@salesforce-perf.com',
        'SF_User_' || N::text,
        'SF_First_' || N::text,
        'sf_etl_user_' || N::text || '@salesforce-perf.com',
        TRUE,
        CASE (N % 6) WHEN 0 THEN 'Enterprise Account Executive' WHEN 1 THEN 'Senior Solution Architect' WHEN 2 THEN 'Director of Customer Success' WHEN 3 THEN 'Business Development Rep' WHEN 4 THEN 'VP Sales' ELSE 'Support Specialist' END,
        CASE (N % 4) WHEN 0 THEN 'Global Sales' WHEN 1 THEN 'Solution Engineering' WHEN 2 THEN 'Customer Success' ELSE 'Executive Management' END,
        '+1-555-' || LPAD((1000 + (N % 9000))::text, 4, '0'),
        (CURRENT_TIMESTAMP - ((N % 1051200) || ' minutes')::interval),
        (CURRENT_TIMESTAMP - ((N % 525600) || ' minutes')::interval)
    FROM _Tally WHERE N <= v_UserCount;

    -- Accounts
    INSERT INTO "Salesforce"."Account" (
        "Id", "ParentId", "Name", "Type", "BillingStreet", "BillingCity", "BillingState", "BillingPostalCode",
        "BillingCountry", "ShippingStreet", "ShippingCity", "ShippingState", "ShippingPostalCode", "ShippingCountry",
        "Phone", "Website", "Industry", "AnnualRevenue", "NumberOfEmployees", "Description", "OwnerId",
        "CreatedById", "LastModifiedById", "CreatedDate", "LastModifiedDate"
    )
    SELECT 
        '001' || LPAD(N::text, 12, '0') || 'AAA',
        CASE WHEN N > 100 AND N % 10 = 0 THEN '001' || LPAD(((N % 100) + 1)::text, 12, '0') || 'AAA' ELSE NULL END,
        'Salesforce Global Enterprise Corp ' || N::text,
        CASE (N % 4) WHEN 0 THEN 'Customer - Direct' WHEN 1 THEN 'Customer - Channel' WHEN 2 THEN 'Prospect' ELSE 'Technology Partner' END,
        ((N % 999) + 1)::text || ' Technology Boulevard',
        CASE (N % 6) WHEN 0 THEN 'San Francisco' WHEN 1 THEN 'New York' WHEN 2 THEN 'Austin' WHEN 3 THEN 'Chicago' WHEN 4 THEN 'Seattle' ELSE 'Boston' END,
        CASE (N % 6) WHEN 0 THEN 'CA' WHEN 1 THEN 'NY' WHEN 2 THEN 'TX' WHEN 3 THEN 'IL' WHEN 4 THEN 'WA' ELSE 'MA' END,
        LPAD((90000 + (N % 9999))::text, 5, '0'),
        'United States',
        ((N % 999) + 1)::text || ' Technology Boulevard',
        CASE (N % 6) WHEN 0 THEN 'San Francisco' WHEN 1 THEN 'New York' WHEN 2 THEN 'Austin' WHEN 3 THEN 'Chicago' WHEN 4 THEN 'Seattle' ELSE 'Boston' END,
        CASE (N % 6) WHEN 0 THEN 'CA' WHEN 1 THEN 'NY' WHEN 2 THEN 'TX' WHEN 3 THEN 'IL' WHEN 4 THEN 'WA' ELSE 'MA' END,
        LPAD((90000 + (N % 9999))::text, 5, '0'),
        'United States',
        '+1-415-555-' || LPAD((N % 10000)::text, 4, '0'),
        'https://www.sf-enterprise' || N::text || '.io',
        CASE (N % 7) WHEN 0 THEN 'Technology' WHEN 1 THEN 'Finance' WHEN 2 THEN 'Healthcare' WHEN 3 THEN 'Manufacturing' WHEN 4 THEN 'Retail' WHEN 5 THEN 'Telecommunications' ELSE 'Energy' END,
        ROUND((500000 + ((N * 37) % 50000000))::numeric, 2),
        50 + ((N * 13) % 25000),
        'High-density Salesforce synthetic account record #' || N::text,
        '005' || LPAD((((N - 1) % v_UserCount) + 1)::text, 12, '0') || 'AAA',
        '005' || LPAD((((N - 1) % v_UserCount) + 1)::text, 12, '0') || 'AAA',
        '005' || LPAD((((N - 1) % v_UserCount) + 1)::text, 12, '0') || 'AAA',
        (CURRENT_TIMESTAMP - ((N % 1051200) || ' minutes')::interval),
        (CURRENT_TIMESTAMP - ((N % 525600) || ' minutes')::interval)
    FROM _Tally WHERE N <= v_AccountCount;

    -- Contacts
    INSERT INTO "Salesforce"."Contact" (
        "Id", "AccountId", "LastName", "FirstName", "Salutation", "Title", "Department", "Email",
        "Phone", "MobilePhone", "LeadSource", "OwnerId", "CreatedById", "LastModifiedById", "CreatedDate", "LastModifiedDate"
    )
    SELECT 
        '003' || LPAD(N::text, 12, '0') || 'AAA',
        '001' || LPAD((((N - 1) % v_AccountCount) + 1)::text, 12, '0') || 'AAA',
        'SF_Contact_' || N::text,
        'SF_First_' || N::text,
        CASE (N % 3) WHEN 0 THEN 'Mr.' WHEN 1 THEN 'Ms.' ELSE 'Dr.' END,
        CASE (N % 6) WHEN 0 THEN 'Chief Executive Officer' WHEN 1 THEN 'Chief Technology Officer' WHEN 2 THEN 'VP Engineering' WHEN 3 THEN 'Director of Architecture' WHEN 4 THEN 'Head of Procurement' ELSE 'Lead Security Engineer' END,
        CASE (N % 5) WHEN 0 THEN 'Executive Leadership' WHEN 1 THEN 'Engineering' WHEN 2 THEN 'Security' WHEN 3 THEN 'Procurement' ELSE 'IT Operations' END,
        'contact' || N::text || '@sf-enterprise' || (((N - 1) % v_AccountCount) + 1)::text || '.io',
        '+1-555-' || LPAD((N % 10000)::text, 4, '0'),
        '+1-555-' || LPAD(((N + 5000) % 10000)::text, 4, '0'),
        CASE (N % 5) WHEN 0 THEN 'Web Organic' WHEN 1 THEN 'Partner Ecosystem' WHEN 2 THEN 'Global Summit' WHEN 3 THEN 'Inbound API' ELSE 'Executive Referral' END,
        '005' || LPAD((((N - 1) % v_UserCount) + 1)::text, 12, '0') || 'AAA',
        '005' || LPAD((((N - 1) % v_UserCount) + 1)::text, 12, '0') || 'AAA',
        '005' || LPAD((((N - 1) % v_UserCount) + 1)::text, 12, '0') || 'AAA',
        (CURRENT_TIMESTAMP - ((N % 1051200) || ' minutes')::interval),
        (CURRENT_TIMESTAMP - ((N % 525600) || ' minutes')::interval)
    FROM _Tally WHERE N <= v_ContactCount;

    -- AccountContactRelation
    INSERT INTO "Salesforce"."AccountContactRelation" ("Id", "AccountId", "ContactId", "Roles", "IsDirect", "IsActive", "StartDate", "CreatedDate", "LastModifiedDate")
    SELECT 
        '07k' || LPAD(N::text, 12, '0') || 'AAA',
        '001' || LPAD((((N - 1) % v_AccountCount) + 1)::text, 12, '0') || 'AAA',
        '003' || LPAD(N::text, 12, '0') || 'AAA',
        'Technical Decision Maker;Executive Sponsor',
        TRUE, TRUE,
        (CURRENT_DATE - ((N % 730) || ' days')::interval)::date,
        (CURRENT_TIMESTAMP - ((N % 1051200) || ' minutes')::interval),
        (CURRENT_TIMESTAMP - ((N % 525600) || ' minutes')::interval)
    FROM _Tally WHERE N <= v_ContactCount;

    -- Leads
    INSERT INTO "Salesforce"."Lead" (
        "Id", "LastName", "FirstName", "Salutation", "Title", "Company", "Street", "City",
        "State", "PostalCode", "Country", "Phone", "Email", "Status", "Industry", "AnnualRevenue",
        "NumberOfEmployees", "OwnerId", "CreatedById", "LastModifiedById", "CreatedDate", "LastModifiedDate"
    )
    SELECT 
        '00Q' || LPAD(N::text, 12, '0') || 'AAA',
        'SF_LeadLast_' || N::text,
        'SF_LeadFirst_' || N::text,
        CASE (N % 2) WHEN 0 THEN 'Mr.' ELSE 'Ms.' END,
        CASE (N % 5) WHEN 0 THEN 'Director of Data Systems' WHEN 1 THEN 'VP Cloud Infrastructure' WHEN 2 THEN 'Head of Digital Transformation' WHEN 3 THEN 'Chief Data Officer' ELSE 'Principal Enterprise Architect' END,
        'Inbound Prospect Corp ' || N::text,
        ((N % 899) + 100)::text || ' Cloud Way',
        CASE (N % 5) WHEN 0 THEN 'Atlanta' WHEN 1 THEN 'Denver' WHEN 2 THEN 'Miami' WHEN 3 THEN 'Dallas' ELSE 'Phoenix' END,
        CASE (N % 5) WHEN 0 THEN 'GA' WHEN 1 THEN 'CO' WHEN 2 THEN 'FL' WHEN 3 THEN 'TX' ELSE 'AZ' END,
        LPAD((30000 + (N % 9999))::text, 5, '0'),
        'United States',
        '+1-555-' || LPAD((N % 10000)::text, 4, '0'),
        'lead' || N::text || '@inbound' || N::text || '.io',
        CASE (N % 4) WHEN 0 THEN 'Open - Not Contacted' WHEN 1 THEN 'Working - Contacted' WHEN 2 THEN 'Closed - Converted' ELSE 'Closed - Not Converted' END,
        CASE (N % 5) WHEN 0 THEN 'Technology' WHEN 1 THEN 'Healthcare' WHEN 2 THEN 'Financial Services' WHEN 3 THEN 'Manufacturing' ELSE 'Retail' END,
        ROUND((100000 + ((N * 29) % 10000000))::numeric, 2),
        10 + ((N * 7) % 5000),
        '005' || LPAD((((N - 1) % v_UserCount) + 1)::text, 12, '0') || 'AAA',
        '005' || LPAD((((N - 1) % v_UserCount) + 1)::text, 12, '0') || 'AAA',
        '005' || LPAD((((N - 1) % v_UserCount) + 1)::text, 12, '0') || 'AAA',
        (CURRENT_TIMESTAMP - ((N % 1051200) || ' minutes')::interval),
        (CURRENT_TIMESTAMP - ((N % 525600) || ' minutes')::interval)
    FROM _Tally WHERE N <= v_LeadCount;

    -- Campaigns
    INSERT INTO "Salesforce"."Campaign" (
        "Id", "Name", "Type", "Status", "StartDate", "EndDate", "ExpectedRevenue", "BudgetedCost",
        "ActualCost", "ExpectedResponse", "NumberSent", "IsActive", "OwnerId", "CreatedById", "LastModifiedById", "CreatedDate", "LastModifiedDate"
    )
    SELECT 
        '701' || LPAD(N::text, 12, '0') || 'AAA',
        'Enterprise Global Marketing Wave #' || N::text,
        CASE (N % 4) WHEN 0 THEN 'Global Conference' WHEN 1 THEN 'Executive Webinar' WHEN 2 THEN 'Multi-channel Email' ELSE 'Partner Co-Marketing' END,
        CASE (N % 3) WHEN 0 THEN 'In Progress' WHEN 1 THEN 'Completed' ELSE 'Planned' END,
        (CURRENT_DATE - ((N % 180) || ' days')::interval)::date,
        (CURRENT_DATE + ((N % 180) || ' days')::interval)::date,
        ROUND((500000 + ((N * 19) % 2000000))::numeric, 2),
        ROUND((50000 + ((N * 7) % 250000))::numeric, 2),
        ROUND((45000 + ((N * 6) % 240000))::numeric, 2),
        4.50 + ((N % 20) * 0.5),
        10000 + (N * 500),
        TRUE,
        '005' || LPAD((((N - 1) % v_UserCount) + 1)::text, 12, '0') || 'AAA',
        '005' || LPAD((((N - 1) % v_UserCount) + 1)::text, 12, '0') || 'AAA',
        '005' || LPAD((((N - 1) % v_UserCount) + 1)::text, 12, '0') || 'AAA',
        (CURRENT_TIMESTAMP - ((N % 1051200) || ' minutes')::interval),
        (CURRENT_TIMESTAMP - ((N % 525600) || ' minutes')::interval)
    FROM _Tally WHERE N <= v_CampaignCount;

    -- CampaignMembers
    INSERT INTO "Salesforce"."CampaignMember" ("Id", "CampaignId", "LeadId", "ContactId", "Status", "HasResponded", "CreatedById", "LastModifiedById", "CreatedDate", "LastModifiedDate")
    SELECT 
        '00v' || LPAD(N::text, 12, '0') || 'AAA',
        '701' || LPAD((((N - 1) % v_CampaignCount) + 1)::text, 12, '0') || 'AAA',
        CASE WHEN N % 2 = 1 THEN '00Q' || LPAD((((N - 1) % v_LeadCount) + 1)::text, 12, '0') || 'AAA' ELSE NULL END,
        CASE WHEN N % 2 = 0 THEN '003' || LPAD((((N - 1) % v_ContactCount) + 1)::text, 12, '0') || 'AAA' ELSE NULL END,
        CASE (N % 3) WHEN 0 THEN 'Sent' WHEN 1 THEN 'Responded' ELSE 'Attended & Engaged' END,
        CASE WHEN (N % 3) > 0 THEN TRUE ELSE FALSE END,
        '005' || LPAD((((N - 1) % v_UserCount) + 1)::text, 12, '0') || 'AAA',
        '005' || LPAD((((N - 1) % v_UserCount) + 1)::text, 12, '0') || 'AAA',
        (CURRENT_TIMESTAMP - ((N % 1051200) || ' minutes')::interval),
        (CURRENT_TIMESTAMP - ((N % 525600) || ' minutes')::interval)
    FROM _Tally WHERE N <= v_ContactCount;

    -- Opportunities
    INSERT INTO "Salesforce"."Opportunity" (
        "Id", "AccountId", "Name", "StageName", "Amount", "Probability", "CloseDate", "Type",
        "LeadSource", "IsClosed", "IsWon", "ForecastCategoryName", "CampaignId", "OwnerId",
        "CreatedById", "LastModifiedById", "CreatedDate", "LastModifiedDate"
    )
    SELECT 
        '006' || LPAD(N::text, 12, '0') || 'AAA',
        '001' || LPAD((((N - 1) % v_AccountCount) + 1)::text, 12, '0') || 'AAA',
        'Strategic Expansion Deal #' || N::text,
        CASE (N % 6)
            WHEN 0 THEN 'Prospecting' WHEN 1 THEN 'Qualification' WHEN 2 THEN 'Value Proposition'
            WHEN 3 THEN 'Proposal/Price Quote' WHEN 4 THEN 'Negotiation/Review' ELSE 'Closed Won'
        END,
        ROUND((25000 + ((N * 47) % 750000))::numeric, 2),
        CASE (N % 6) WHEN 0 THEN 10.00 WHEN 1 THEN 20.00 WHEN 2 THEN 40.00 WHEN 3 THEN 60.00 WHEN 4 THEN 80.00 ELSE 100.00 END,
        (CURRENT_DATE + (((N % 120) - 60) || ' days')::interval)::date,
        CASE (N % 3) WHEN 0 THEN 'New Customer' WHEN 1 THEN 'Existing Customer - Upgrade' ELSE 'Existing Customer - Expansion' END,
        CASE (N % 4) WHEN 0 THEN 'Web Organic' WHEN 1 THEN 'Executive Referral' WHEN 2 THEN 'Industry Summit' ELSE 'Outbound Campaign' END,
        CASE WHEN (N % 6) = 5 THEN TRUE ELSE FALSE END,
        CASE WHEN (N % 6) = 5 THEN TRUE ELSE FALSE END,
        CASE (N % 6) WHEN 0 THEN 'Pipeline' WHEN 1 THEN 'Pipeline' WHEN 2 THEN 'Pipeline' WHEN 3 THEN 'BestCase' WHEN 4 THEN 'Commit' ELSE 'Closed' END,
        '701' || LPAD((((N - 1) % v_CampaignCount) + 1)::text, 12, '0') || 'AAA',
        '005' || LPAD((((N - 1) % v_UserCount) + 1)::text, 12, '0') || 'AAA',
        '005' || LPAD((((N - 1) % v_UserCount) + 1)::text, 12, '0') || 'AAA',
        '005' || LPAD((((N - 1) % v_UserCount) + 1)::text, 12, '0') || 'AAA',
        (CURRENT_TIMESTAMP - ((N % 1051200) || ' minutes')::interval),
        (CURRENT_TIMESTAMP - ((N % 525600) || ' minutes')::interval)
    FROM _Tally WHERE N <= v_OpportunityCount;

    -- Product2
    INSERT INTO "Salesforce"."Product2" (
        "Id", "Name", "ProductCode", "Description", "IsActive", "Family", "CreatedById", "LastModifiedById", "CreatedDate", "LastModifiedDate"
    )
    SELECT 
        '01t' || LPAD(N::text, 12, '0') || 'AAA',
        'Salesforce Production Cloud SKU ' || N::text,
        'SF-PROD-SKU-' || LPAD(N::text, 6, '0'),
        'High scale benchmark product component #' || N::text,
        TRUE,
        CASE (N % 3) WHEN 0 THEN 'Software License' WHEN 1 THEN 'Cloud Compute' ELSE 'Managed Support' END,
        '005' || LPAD((((N - 1) % v_UserCount) + 1)::text, 12, '0') || 'AAA',
        '005' || LPAD((((N - 1) % v_UserCount) + 1)::text, 12, '0') || 'AAA',
        (CURRENT_TIMESTAMP - ((N % 1051200) || ' minutes')::interval),
        (CURRENT_TIMESTAMP - ((N % 525600) || ' minutes')::interval)
    FROM _Tally WHERE N <= v_ProductCount;

    -- Pricebook2 (Standard + Tier Pricebooks)
    INSERT INTO "Salesforce"."Pricebook2" (
        "Id", "Name", "IsActive", "IsStandard", "Description", "CreatedById", "LastModifiedById", "CreatedDate", "LastModifiedDate"
    )
    SELECT 
        '01s' || LPAD(N::text, 12, '0') || 'AAA',
        CASE WHEN N = 1 THEN 'Standard Price Book' ELSE 'Global Enterprise Tier ' || N::text END,
        TRUE,
        CASE WHEN N = 1 THEN TRUE ELSE FALSE END,
        'Automated ETL benchmark price book catalog #' || N::text,
        '005' || LPAD((((N - 1) % v_UserCount) + 1)::text, 12, '0') || 'AAA',
        '005' || LPAD((((N - 1) % v_UserCount) + 1)::text, 12, '0') || 'AAA',
        (CURRENT_TIMESTAMP - ((N % 1051200) || ' minutes')::interval),
        (CURRENT_TIMESTAMP - ((N % 525600) || ' minutes')::interval)
    FROM _Tally WHERE N <= CASE WHEN v_ProductCount < 50 THEN v_ProductCount ELSE 50 END;

    -- PricebookEntry
    INSERT INTO "Salesforce"."PricebookEntry" (
        "Id", "Pricebook2Id", "Product2Id", "UnitPrice", "IsActive", "UseStandardPrice", "CreatedById", "LastModifiedById", "CreatedDate", "LastModifiedDate"
    )
    SELECT 
        '01u' || LPAD(N::text, 12, '0') || 'AAA',
        '01s000000000001AAA',
        '01t' || LPAD((((N - 1) % v_ProductCount) + 1)::text, 12, '0') || 'AAA',
        ROUND((500.00 + ((N * 17) % 15000))::numeric, 2),
        TRUE, FALSE,
        '005' || LPAD((((N - 1) % v_UserCount) + 1)::text, 12, '0') || 'AAA',
        '005' || LPAD((((N - 1) % v_UserCount) + 1)::text, 12, '0') || 'AAA',
        (CURRENT_TIMESTAMP - ((N % 1051200) || ' minutes')::interval),
        (CURRENT_TIMESTAMP - ((N % 525600) || ' minutes')::interval)
    FROM _Tally WHERE N <= v_ProductCount;

    -- OpportunityLineItem
    INSERT INTO "Salesforce"."OpportunityLineItem" (
        "Id", "OpportunityId", "PricebookEntryId", "Quantity", "UnitPrice", "ListPrice",
        "Description", "CreatedById", "LastModifiedById", "CreatedDate", "LastModifiedDate"
    )
    SELECT 
        '00k' || LPAD(N::text, 12, '0') || 'AAA',
        '006' || LPAD((((N - 1) % v_OpportunityCount) + 1)::text, 12, '0') || 'AAA',
        '01u' || LPAD((((N - 1) % v_ProductCount) + 1)::text, 12, '0') || 'AAA',
        1.00 + (N % 10),
        ROUND((500.00 + ((N * 17) % 15000))::numeric, 2),
        ROUND((500.00 + ((N * 17) % 15000))::numeric, 2),
        'Scale benchmark opportunity line component #' || N::text,
        '005' || LPAD((((N - 1) % v_UserCount) + 1)::text, 12, '0') || 'AAA',
        '005' || LPAD((((N - 1) % v_UserCount) + 1)::text, 12, '0') || 'AAA',
        (CURRENT_TIMESTAMP - ((N % 1051200) || ' minutes')::interval),
        (CURRENT_TIMESTAMP - ((N % 525600) || ' minutes')::interval)
    FROM _Tally WHERE N <= v_OpportunityCount;

    -- Cases
    INSERT INTO "Salesforce"."Case" (
        "Id", "CaseNumber", "ContactId", "AccountId", "SuppliedEmail", "Type", "Status", "Reason",
        "Origin", "Subject", "Priority", "Description", "OwnerId", "CreatedById", "LastModifiedById", "CreatedDate", "LastModifiedDate"
    )
    SELECT 
        '500' || LPAD(N::text, 12, '0') || 'AAA',
        'SF-CASE-' || LPAD(N::text, 8, '0'),
        '003' || LPAD((((N - 1) % v_ContactCount) + 1)::text, 12, '0') || 'AAA',
        '001' || LPAD((((N - 1) % v_AccountCount) + 1)::text, 12, '0') || 'AAA',
        'support_client_' || N::text || '@sf-enterprise.io',
        CASE (N % 3) WHEN 0 THEN 'Platform Configuration' WHEN 1 THEN 'Performance Optimization' ELSE 'API Integration' END,
        CASE (N % 4) WHEN 0 THEN 'New' WHEN 1 THEN 'Working' WHEN 2 THEN 'Escalated to Tier 3' ELSE 'Closed Resolved' END,
        CASE (N % 3) WHEN 0 THEN 'Throughput Scaling' WHEN 1 THEN 'Timeout Thresholds' ELSE 'Network Protocol Latency' END,
        CASE (N % 3) WHEN 0 THEN 'Web Portal' WHEN 1 THEN 'Direct Hotline' ELSE 'Automated Telemetry' END,
        'High load benchmark case incident #' || N::text,
        CASE (N % 3) WHEN 0 THEN 'High' WHEN 1 THEN 'Medium' ELSE 'Low' END,
        'Automated enterprise ETL simulated ticket issue description #' || N::text,
        '005' || LPAD((((N - 1) % v_UserCount) + 1)::text, 12, '0') || 'AAA',
        '005' || LPAD((((N - 1) % v_UserCount) + 1)::text, 12, '0') || 'AAA',
        '005' || LPAD((((N - 1) % v_UserCount) + 1)::text, 12, '0') || 'AAA',
        (CURRENT_TIMESTAMP - ((N % 1051200) || ' minutes')::interval),
        (CURRENT_TIMESTAMP - ((N % 525600) || ' minutes')::interval)
    FROM _Tally WHERE N <= v_CaseCount;

    -- Tasks
    INSERT INTO "Salesforce"."Task" (
        "Id", "WhoId", "WhatId", "Subject", "ActivityDate", "Status", "Priority", "OwnerId", "CreatedById", "LastModifiedById", "CreatedDate", "LastModifiedDate"
    )
    SELECT 
        '00T' || LPAD(N::text, 12, '0') || 'AAA',
        '003' || LPAD((((N - 1) % v_ContactCount) + 1)::text, 12, '0') || 'AAA',
        '001' || LPAD((((N - 1) % v_AccountCount) + 1)::text, 12, '0') || 'AAA',
        'Strategic quarterly business review action #' || N::text,
        (CURRENT_DATE + (((N % 60) - 30) || ' days')::interval)::date,
        CASE (N % 3) WHEN 0 THEN 'Not Started' WHEN 1 THEN 'In Progress' ELSE 'Completed' END,
        CASE (N % 3) WHEN 0 THEN 'High' WHEN 1 THEN 'Normal' ELSE 'Low' END,
        '005' || LPAD((((N - 1) % v_UserCount) + 1)::text, 12, '0') || 'AAA',
        '005' || LPAD((((N - 1) % v_UserCount) + 1)::text, 12, '0') || 'AAA',
        '005' || LPAD((((N - 1) % v_UserCount) + 1)::text, 12, '0') || 'AAA',
        (CURRENT_TIMESTAMP - ((N % 1051200) || ' minutes')::interval),
        (CURRENT_TIMESTAMP - ((N % 525600) || ' minutes')::interval)
    FROM _Tally WHERE N <= v_ActivityCount;

    -- Events
    INSERT INTO "Salesforce"."Event" (
        "Id", "WhoId", "WhatId", "Subject", "StartDateTime", "EndDateTime", "DurationInMinutes",
        "Description", "OwnerId", "CreatedById", "LastModifiedById", "CreatedDate", "LastModifiedDate"
    )
    SELECT 
        '00U' || LPAD(N::text, 12, '0') || 'AAA',
        '003' || LPAD((((N - 1) % v_ContactCount) + 1)::text, 12, '0') || 'AAA',
        '006' || LPAD((((N - 1) % v_OpportunityCount) + 1)::text, 12, '0') || 'AAA',
        'Solution Demonstration & Architecture Deep Dive #' || N::text,
        (CURRENT_TIMESTAMP + ((N % 720) || ' hours')::interval),
        (CURRENT_TIMESTAMP + ((N % 720) || ' hours')::interval + INTERVAL '45 minutes'),
        45,
        'Deep architectural review session for high scale production data pipeline #' || N::text,
        '005' || LPAD((((N - 1) % v_UserCount) + 1)::text, 12, '0') || 'AAA',
        '005' || LPAD((((N - 1) % v_UserCount) + 1)::text, 12, '0') || 'AAA',
        '005' || LPAD((((N - 1) % v_UserCount) + 1)::text, 12, '0') || 'AAA',
        (CURRENT_TIMESTAMP - ((N % 1051200) || ' minutes')::interval),
        (CURRENT_TIMESTAMP - ((N % 525600) || ' minutes')::interval)
    FROM _Tally WHERE N <= v_ActivityCount;


    -------------------------------------------------------------------------
    -- 2. HEAVY LOAD: HUBSPOT SCHEMA
    -------------------------------------------------------------------------
    RAISE NOTICE '  -> Bulk inserting HubSpot production dataset...';

    -- Owners
    INSERT INTO "HubSpot"."Owner" ("ownerId", "email", "firstName", "lastName", "userId", "createdAt", "updatedAt")
    SELECT 
        100000 + N,
        'hs_rep_' || N::text || '@hubspot-perf.io',
        'HS_First_' || N::text,
        'HS_Rep_' || N::text,
        500000 + N,
        (CURRENT_TIMESTAMP - ((N % 1051200) || ' minutes')::interval),
        (CURRENT_TIMESTAMP - ((N % 525600) || ' minutes')::interval)
    FROM _Tally WHERE N <= v_UserCount;

    -- Companies
    INSERT INTO "HubSpot"."Company" (
        "companyId", "name", "domain", "industry", "phone", "city", "state", "country",
        "annualRevenue", "numberOfEmployees", "lifecyclestage", "ownerId", "createdAt", "updatedAt"
    )
    SELECT 
        200000 + N,
        'HubSpot Inbound Enterprise ' || N::text,
        'inbound' || N::text || '.io',
        CASE (N % 5) WHEN 0 THEN 'INFORMATION_TECHNOLOGY_AND_SERVICES' WHEN 1 THEN 'FINANCIAL_SERVICES' WHEN 2 THEN 'MARKETING_AND_ADVERTISING' WHEN 3 THEN 'HOSPITAL_AND_HEALTH_CARE' ELSE 'LOGISTICS' END,
        '+1-617-555-' || LPAD((N % 10000)::text, 4, '0'),
        CASE (N % 4) WHEN 0 THEN 'Boston' WHEN 1 THEN 'Cambridge' WHEN 2 THEN 'Austin' ELSE 'San Francisco' END,
        CASE (N % 4) WHEN 0 THEN 'MA' WHEN 1 THEN 'MA' WHEN 2 THEN 'TX' ELSE 'CA' END,
        'United States',
        ROUND((750000 + ((N * 43) % 40000000))::numeric, 2),
        40 + ((N * 11) % 15000),
        CASE (N % 4) WHEN 0 THEN 'lead' WHEN 1 THEN 'marketingqualifiedlead' WHEN 2 THEN 'salesqualifiedlead' ELSE 'customer' END,
        100000 + (((N - 1) % v_UserCount) + 1),
        (CURRENT_TIMESTAMP - ((N % 1051200) || ' minutes')::interval),
        (CURRENT_TIMESTAMP - ((N % 525600) || ' minutes')::interval)
    FROM _Tally WHERE N <= v_AccountCount;

    -- Contacts
    INSERT INTO "HubSpot"."Contact" (
        "contactId", "email", "firstName", "lastName", "phone", "jobTitle", "lifecyclestage",
        "leadStatus", "associatedCompanyId", "ownerId", "createdAt", "updatedAt"
    )
    SELECT 
        300000 + N,
        'hs_contact_' || N::text || '@inbound' || (((N - 1) % v_AccountCount) + 1)::text || '.io',
        'HS_ContactFirst_' || N::text,
        'HS_ContactLast_' || N::text,
        '+1-617-555-' || LPAD((N % 10000)::text, 4, '0'),
        CASE (N % 4) WHEN 0 THEN 'VP Inbound Marketing' WHEN 1 THEN 'Chief Commercial Officer' WHEN 2 THEN 'Director of Growth Analytics' ELSE 'Demand Gen Manager' END,
        CASE (N % 4) WHEN 0 THEN 'lead' WHEN 1 THEN 'marketingqualifiedlead' WHEN 2 THEN 'salesqualifiedlead' ELSE 'customer' END,
        CASE (N % 4) WHEN 0 THEN 'NEW' WHEN 1 THEN 'OPEN' WHEN 2 THEN 'IN_PROGRESS' ELSE 'CONNECTED' END,
        200000 + (((N - 1) % v_AccountCount) + 1),
        100000 + (((N - 1) % v_UserCount) + 1),
        (CURRENT_TIMESTAMP - ((N % 1051200) || ' minutes')::interval),
        (CURRENT_TIMESTAMP - ((N % 525600) || ' minutes')::interval)
    FROM _Tally WHERE N <= v_ContactCount;

    -- Pipelines
    INSERT INTO "HubSpot"."Pipeline" ("pipelineId", "label", "displayOrder", "objectType", "createdAt", "updatedAt")
    SELECT 
        'pipe_etl_' || N::text,
        'Inbound Pipeline Stream Tier ' || N::text,
        N,
        'deals',
        (CURRENT_TIMESTAMP - ((N % 1051200) || ' minutes')::interval),
        (CURRENT_TIMESTAMP - ((N % 525600) || ' minutes')::interval)
    FROM _Tally WHERE N <= CASE WHEN v_CampaignCount < 20 THEN v_CampaignCount ELSE 20 END;

    -- DealStages (5 stages per pipeline)
    INSERT INTO "HubSpot"."DealStage" ("stageId", "pipelineId", "label", "displayOrder", "probability", "closedWon", "createdAt", "updatedAt")
    SELECT 
        'stage_etl_' || N::text,
        'pipe_etl_' || (((N - 1) % (CASE WHEN v_CampaignCount < 20 THEN v_CampaignCount ELSE 20 END)) + 1)::text,
        CASE (N % 5)
            WHEN 0 THEN 'Initial Discovery Scheduled'
            WHEN 1 THEN 'Technical Validation'
            WHEN 2 THEN 'Commercial Term Negotiation'
            WHEN 3 THEN 'Legal & Procurement'
            ELSE 'Closed Won Platform'
        END,
        (N % 5) + 1,
        CASE (N % 5) WHEN 0 THEN 0.20 WHEN 1 THEN 0.40 WHEN 2 THEN 0.60 WHEN 3 THEN 0.80 ELSE 1.00 END,
        CASE WHEN (N % 5) = 4 THEN TRUE ELSE FALSE END,
        (CURRENT_TIMESTAMP - ((N % 1051200) || ' minutes')::interval),
        (CURRENT_TIMESTAMP - ((N % 525600) || ' minutes')::interval)
    FROM _Tally WHERE N <= (CASE WHEN v_CampaignCount < 20 THEN v_CampaignCount ELSE 20 END) * 5;

    -- Deals
    INSERT INTO "HubSpot"."Deal" ("dealId", "dealName", "amount", "pipelineId", "dealStageId", "closedate", "dealType", "ownerId", "createdAt", "updatedAt")
    SELECT 
        600000 + N,
        'HubSpot Enterprise Revenue Package ' || N::text,
        ROUND((15000 + ((N * 31) % 450000))::numeric, 2),
        'pipe_etl_' || (((N - 1) % (CASE WHEN v_CampaignCount < 20 THEN v_CampaignCount ELSE 20 END)) + 1)::text,
        'stage_etl_' || (((N - 1) % ((CASE WHEN v_CampaignCount < 20 THEN v_CampaignCount ELSE 20 END) * 5)) + 1)::text,
        (CURRENT_TIMESTAMP + (((N % 120) - 60) || ' days')::interval),
        CASE (N % 2) WHEN 0 THEN 'newbusiness' ELSE 'existingbusiness' END,
        100000 + (((N - 1) % v_UserCount) + 1),
        (CURRENT_TIMESTAMP - ((N % 1051200) || ' minutes')::interval),
        (CURRENT_TIMESTAMP - ((N % 525600) || ' minutes')::interval)
    FROM _Tally WHERE N <= v_OpportunityCount;

    -- Tickets
    INSERT INTO "HubSpot"."Ticket" ("ticketId", "subject", "content", "pipelineId", "ticketStatusStageId", "priority", "ownerId", "createdAt", "updatedAt")
    SELECT 
        700000 + N,
        'HubSpot Inbound Performance Ticket #' || N::text,
        'Simulated telemetry event regarding analytics ingestion queue #' || N::text,
        'pipe_etl_' || (((N - 1) % (CASE WHEN v_CampaignCount < 20 THEN v_CampaignCount ELSE 20 END)) + 1)::text,
        'stage_etl_' || (((N - 1) % ((CASE WHEN v_CampaignCount < 20 THEN v_CampaignCount ELSE 20 END) * 5)) + 1)::text,
        CASE (N % 4) WHEN 0 THEN 'LOW' WHEN 1 THEN 'MEDIUM' WHEN 2 THEN 'HIGH' ELSE 'URGENT' END,
        100000 + (((N - 1) % v_UserCount) + 1),
        (CURRENT_TIMESTAMP - ((N % 1051200) || ' minutes')::interval),
        (CURRENT_TIMESTAMP - ((N % 525600) || ' minutes')::interval)
    FROM _Tally WHERE N <= v_CaseCount;

    -- Products
    INSERT INTO "HubSpot"."Product" ("productId", "name", "sku", "description", "price", "cost", "recurringBillingFrequency", "createdAt", "updatedAt")
    SELECT 
        800000 + N,
        'HubSpot Marketing Automation Module ' || N::text,
        'HS-SKU-' || LPAD(N::text, 6, '0'),
        'High-volume marketing attribution component #' || N::text,
        ROUND((800.00 + ((N * 13) % 4500))::numeric, 2),
        ROUND((200.00 + ((N * 5) % 1500))::numeric, 2),
        CASE (N % 3) WHEN 0 THEN 'monthly' WHEN 1 THEN 'annually' ELSE 'quarterly' END,
        (CURRENT_TIMESTAMP - ((N % 1051200) || ' minutes')::interval),
        (CURRENT_TIMESTAMP - ((N % 525600) || ' minutes')::interval)
    FROM _Tally WHERE N <= v_ProductCount;

    -- LineItems
    INSERT INTO "HubSpot"."LineItem" ("lineItemId", "dealId", "productId", "name", "quantity", "price", "discount", "createdAt", "updatedAt")
    SELECT 
        900000 + N,
        600000 + (((N - 1) % v_OpportunityCount) + 1),
        800000 + (((N - 1) % v_ProductCount) + 1),
        'Inbound SKU Service Item ' || N::text,
        1.00 + (N % 5),
        ROUND((800.00 + ((N * 13) % 4500))::numeric, 2),
        CASE WHEN (N % 8) = 0 THEN 100.00 ELSE 0.00 END,
        (CURRENT_TIMESTAMP - ((N % 1051200) || ' minutes')::interval),
        (CURRENT_TIMESTAMP - ((N % 525600) || ' minutes')::interval)
    FROM _Tally WHERE N <= v_OpportunityCount;

    -- Engagements
    INSERT INTO "HubSpot"."Engagement" ("engagementId", "engagementType", "ownerId", "timestamp", "body", "status", "activityDurationMilliseconds", "createdAt", "updatedAt")
    SELECT 
        1000000 + N,
        CASE (N % 4) WHEN 0 THEN 'NOTE' WHEN 1 THEN 'EMAIL' WHEN 2 THEN 'CALL' ELSE 'MEETING' END,
        100000 + (((N - 1) % v_UserCount) + 1),
        (CURRENT_TIMESTAMP + (((N % 180) - 90) || ' days')::interval),
        'Automated engagement log trace for ETL load benchmark #' || N::text,
        'COMPLETED',
        (10 + (N % 60)) * 60000,
        (CURRENT_TIMESTAMP - ((N % 1051200) || ' minutes')::interval),
        (CURRENT_TIMESTAMP - ((N % 525600) || ' minutes')::interval)
    FROM _Tally WHERE N <= v_ActivityCount;

    -- ObjectAssociations (auto-incrementing IDENTITY)
    INSERT INTO "HubSpot"."ObjectAssociation" (
        "fromObjectType", "fromObjectId", "toObjectType", "toObjectId", "associationTypeId", "createdAt"
    )
    SELECT 
        'contact',
        300000 + N,
        'company',
        200000 + (((N - 1) % v_AccountCount) + 1),
        1,
        (CURRENT_TIMESTAMP - ((N % 1051200) || ' minutes')::interval)
    FROM _Tally WHERE N <= v_ContactCount;


    -------------------------------------------------------------------------
    -- 3. HEAVY LOAD: DYNAMICS 365 SCHEMA
    -------------------------------------------------------------------------
    RAISE NOTICE '  -> Bulk inserting Dynamics 365 production dataset...';

    -- Generate deterministic GUID mapping batches
    CREATE TEMP TABLE _D365_Bulk_BU (N INT PRIMARY KEY, BUId UUID) ON COMMIT DROP;
    CREATE TEMP TABLE _D365_Bulk_User (N INT PRIMARY KEY, UserId UUID) ON COMMIT DROP;
    CREATE TEMP TABLE _D365_Bulk_Product (N INT PRIMARY KEY, ProductId UUID) ON COMMIT DROP;
    CREATE TEMP TABLE _D365_Bulk_PriceLevel (N INT PRIMARY KEY, PriceLevelId UUID) ON COMMIT DROP;

    INSERT INTO _D365_Bulk_BU
    SELECT N, ('aa000000-0000-0000-0000-' || LPAD(N::text, 12, '0'))::uuid
    FROM _Tally WHERE N <= v_D365BUCount;

    INSERT INTO _D365_Bulk_User
    SELECT N, ('bb000000-0000-0000-0000-' || LPAD(N::text, 12, '0'))::uuid
    FROM _Tally WHERE N <= v_UserCount;

    INSERT INTO _D365_Bulk_Product
    SELECT N, ('cc000000-0000-0000-0000-' || LPAD(N::text, 12, '0'))::uuid
    FROM _Tally WHERE N <= v_ProductCount;

    INSERT INTO _D365_Bulk_PriceLevel
    SELECT N, ('dd000000-0000-0000-0000-' || LPAD(N::text, 12, '0'))::uuid
    FROM _Tally WHERE N <= CASE WHEN v_ProductCount < 50 THEN v_ProductCount ELSE 50 END;

    -- Business Units
    INSERT INTO "Dynamics365"."BusinessUnit" ("businessunitid", "name", "parentbusinessunitid", "isdisabled", "createdon", "modifiedon")
    SELECT 
        b.BUId,
        'Dynamics BU Regional Division #' || b.N::text,
        CASE WHEN b.N > 1 THEN (SELECT BUId FROM _D365_Bulk_BU WHERE N = 1 LIMIT 1) ELSE NULL END,
        FALSE,
        CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
    FROM _D365_Bulk_BU b;

    -- System Users
    INSERT INTO "Dynamics365"."SystemUser" (
        "systemuserid", "businessunitid", "domainname", "fullname", "firstname", "lastname", "internalemailaddress", "jobtitle", "isdisabled", "createdon", "modifiedon"
    )
    SELECT 
        u.UserId,
        b.BUId,
        'CORP\d365_rep_' || u.N::text,
        'Dynamics User ' || u.N::text,
        'D365First_' || u.N::text,
        'D365Last_' || u.N::text,
        'd365_rep_' || u.N::text || '@dataverse-etl.com',
        CASE (u.N % 4) WHEN 0 THEN 'Enterprise Account Manager' WHEN 1 THEN 'Solutions Consultant' WHEN 2 THEN 'Service Specialist' ELSE 'System Administrator' END,
        FALSE,
        (CURRENT_TIMESTAMP - ((u.N % 1051200) || ' minutes')::interval),
        (CURRENT_TIMESTAMP - ((u.N % 525600) || ' minutes')::interval)
    FROM _D365_Bulk_User u
    JOIN _D365_Bulk_BU b ON (((u.N - 1) % v_D365BUCount) + 1) = b.N;

    -- Products
    INSERT INTO "Dynamics365"."Product" (
        "productid", "productnumber", "name", "description", "price", "standardcost", "currentcost", "quantityonhand", "statecode", "statuscode", "createdby", "modifiedby"
    )
    SELECT 
        p.ProductId,
        'MS-D365-ETL-' || LPAD(p.N::text, 6, '0'),
        'Dataverse Enterprise Solution SKU ' || p.N::text,
        'High volume ETL Dataverse component SKU #' || p.N::text,
        ROUND((150.00 + ((p.N * 23) % 4500))::numeric, 2),
        ROUND((100.00 + ((p.N * 17) % 3000))::numeric, 2),
        ROUND((120.00 + ((p.N * 20) % 3500))::numeric, 2),
        10000.00, 0, 1,
        (SELECT UserId FROM _D365_Bulk_User WHERE N = 1 LIMIT 1),
        (SELECT UserId FROM _D365_Bulk_User WHERE N = 1 LIMIT 1)
    FROM _D365_Bulk_Product p;

    -- Price Levels
    INSERT INTO "Dynamics365"."PriceLevel" (
        "pricelevelid", "name", "begindate", "enddate", "statecode", "statuscode", "createdby", "modifiedby"
    )
    SELECT 
        pl.PriceLevelId,
        'Dynamics Commercial Price List Tier ' || pl.N::text,
        (CURRENT_DATE - INTERVAL '2 years')::date,
        (CURRENT_DATE + INTERVAL '3 years')::date,
        0, 1,
        (SELECT UserId FROM _D365_Bulk_User WHERE N = 1 LIMIT 1),
        (SELECT UserId FROM _D365_Bulk_User WHERE N = 1 LIMIT 1)
    FROM _D365_Bulk_PriceLevel pl;

    -- Accounts
    INSERT INTO "Dynamics365"."Account" (
        "accountid", "accountnumber", "name", "telephone1", "websiteurl", "address1_line1", "address1_city",
        "address1_stateorprovince", "address1_postalcode", "address1_country", "revenue", "numberofemployees",
        "industrycode", "statecode", "statuscode", "ownerid", "owningbusinessunit", "createdby", "modifiedby",
        "createdon", "modifiedon"
    )
    SELECT 
        ('c1000000-0000-0000-0000-' || LPAD(t.N::text, 12, '0'))::uuid,
        'ACC-' || LPAD(t.N::text, 8, '0'),
        'Dataverse Global Corp ' || t.N::text,
        '+1-800-555-' || LPAD((t.N % 10000)::text, 4, '0'),
        'https://www.dynamics-corp' || t.N::text || '.com',
        ((t.N % 999) + 1)::text || ' Technology Way',
        CASE (t.N % 5) WHEN 0 THEN 'Redmond' WHEN 1 THEN 'Seattle' WHEN 2 THEN 'Austin' WHEN 3 THEN 'London' ELSE 'Munich' END,
        CASE (t.N % 5) WHEN 0 THEN 'WA' WHEN 1 THEN 'WA' WHEN 2 THEN 'TX' WHEN 3 THEN 'ENG' ELSE 'BY' END,
        '98052',
        CASE (t.N % 5) WHEN 3 THEN 'United Kingdom' WHEN 4 THEN 'Germany' ELSE 'United States' END,
        ROUND((500000 + ((t.N * 53) % 100000000))::numeric, 2),
        50 + ((t.N * 19) % 35000),
        (t.N % 10) + 1,
        CASE WHEN (t.N % 50) = 0 THEN 1 ELSE 0 END, -- 2% inactive for ETL state tracking
        CASE WHEN (t.N % 50) = 0 THEN 2 ELSE 1 END,
        u.UserId,
        b.BUId,
        u.UserId,
        u.UserId,
        (CURRENT_TIMESTAMP - ((t.N % 1051200) || ' minutes')::interval),
        (CURRENT_TIMESTAMP - ((t.N % 525600) || ' minutes')::interval)
    FROM _Tally t
    JOIN _D365_Bulk_User u ON (((t.N - 1) % v_UserCount) + 1) = u.N
    JOIN _D365_Bulk_BU b ON (((t.N - 1) % v_D365BUCount) + 1) = b.N
    WHERE t.N <= v_AccountCount;

    -- Contacts
    INSERT INTO "Dynamics365"."Contact" (
        "contactid", "fullname", "firstname", "lastname", "emailaddress1", "telephone1", "jobtitle",
        "parentcustomerid", "statecode", "statuscode", "ownerid", "owningbusinessunit", "createdby", "modifiedby",
        "createdon", "modifiedon"
    )
    SELECT 
        ('d2000000-0000-0000-0000-' || LPAD(t.N::text, 12, '0'))::uuid,
        'D365 Contact ' || t.N::text,
        'D365First_' || t.N::text,
        'D365Last_' || t.N::text,
        'contact' || t.N::text || '@dynamics-corp' || (((t.N - 1) % v_AccountCount) + 1)::text || '.com',
        '+1-800-555-' || LPAD((t.N % 10000)::text, 4, '0'),
        CASE (t.N % 5) WHEN 0 THEN 'VP Information Technology' WHEN 1 THEN 'Director of Operations' WHEN 2 THEN 'Head of Procurement' WHEN 3 THEN 'Chief Architect' ELSE 'Senior Program Manager' END,
        ('c1000000-0000-0000-0000-' || LPAD((((t.N - 1) % v_AccountCount) + 1)::text, 12, '0'))::uuid,
        0, 1,
        u.UserId,
        b.BUId,
        u.UserId,
        u.UserId,
        (CURRENT_TIMESTAMP - ((t.N % 1051200) || ' minutes')::interval),
        (CURRENT_TIMESTAMP - ((t.N % 525600) || ' minutes')::interval)
    FROM _Tally t
    JOIN _D365_Bulk_User u ON (((t.N - 1) % v_UserCount) + 1) = u.N
    JOIN _D365_Bulk_BU b ON (((t.N - 1) % v_D365BUCount) + 1) = b.N
    WHERE t.N <= v_ContactCount;

    -- Leads
    INSERT INTO "Dynamics365"."Lead" (
        "leadid", "fullname", "firstname", "lastname", "companyname", "subject", "emailaddress1",
        "telephone1", "estimatedamount", "leadqualitycode", "leadsourcecode", "statecode", "statuscode",
        "ownerid", "owningbusinessunit", "createdby", "modifiedby", "createdon", "modifiedon"
    )
    SELECT 
        ('e3000000-0000-0000-0000-' || LPAD(t.N::text, 12, '0'))::uuid,
        'D365 Enterprise Lead ' || t.N::text,
        'D365LeadFirst_' || t.N::text,
        'D365LeadLast_' || t.N::text,
        'Prospect Enterprise Group ' || t.N::text,
        'Inbound ERP Modernization Program #' || t.N::text,
        'lead' || t.N::text || '@prospectcorp' || t.N::text || '.com',
        '+1-800-555-' || LPAD((t.N % 10000)::text, 4, '0'),
        ROUND((75000 + ((t.N * 33) % 2500000))::numeric, 2),
        (t.N % 3) + 1,
        (t.N % 6) + 1,
        0, 1,
        u.UserId,
        b.BUId,
        u.UserId,
        u.UserId,
        (CURRENT_TIMESTAMP - ((t.N % 1051200) || ' minutes')::interval),
        (CURRENT_TIMESTAMP - ((t.N % 525600) || ' minutes')::interval)
    FROM _Tally t
    JOIN _D365_Bulk_User u ON (((t.N - 1) % v_UserCount) + 1) = u.N
    JOIN _D365_Bulk_BU b ON (((t.N - 1) % v_D365BUCount) + 1) = b.N
    WHERE t.N <= v_LeadCount;

    -- Opportunities
    INSERT INTO "Dynamics365"."Opportunity" (
        "opportunityid", "name", "parentaccountid", "pricelevelid", "estimatedvalue",
        "estimatedclosedate", "closeprobability", "stepname", "salesstage", "statecode", "statuscode",
        "ownerid", "owningbusinessunit", "createdby", "modifiedby", "createdon", "modifiedon"
    )
    SELECT 
        ('f4000000-0000-0000-0000-' || LPAD(t.N::text, 12, '0'))::uuid,
        'Dynamics High Scale Transformation ' || t.N::text,
        ('c1000000-0000-0000-0000-' || LPAD((((t.N - 1) % v_AccountCount) + 1)::text, 12, '0'))::uuid,
        pl.PriceLevelId,
        ROUND((100000 + ((t.N * 61) % 5000000))::numeric, 2),
        (CURRENT_DATE + (((t.N % 120) - 60) || ' days')::interval)::date,
        30 + (t.N % 70),
        'Qualify -> Develop -> Propose -> Close',
        (t.N % 4) + 1,
        CASE WHEN (t.N % 20) = 0 THEN 1 ELSE 0 END, -- 5% won
        CASE WHEN (t.N % 20) = 0 THEN 3 ELSE 1 END,
        u.UserId,
        b.BUId,
        u.UserId,
        u.UserId,
        (CURRENT_TIMESTAMP - ((t.N % 1051200) || ' minutes')::interval),
        (CURRENT_TIMESTAMP - ((t.N % 525600) || ' minutes')::interval)
    FROM _Tally t
    JOIN _D365_Bulk_User u ON (((t.N - 1) % v_UserCount) + 1) = u.N
    JOIN _D365_Bulk_BU b ON (((t.N - 1) % v_D365BUCount) + 1) = b.N
    JOIN _D365_Bulk_PriceLevel pl ON (((t.N - 1) % (CASE WHEN v_ProductCount < 50 THEN v_ProductCount ELSE 50 END)) + 1) = pl.N
    WHERE t.N <= v_OpportunityCount;

    -- OpportunityProducts
    INSERT INTO "Dynamics365"."OpportunityProduct" (
        "opportunityproductid", "opportunityid", "productid", "priceperunit", "quantity",
        "manualdiscountamount", "createdby", "modifiedby", "createdon", "modifiedon"
    )
    SELECT 
        ('a5000000-0000-0000-0000-' || LPAD(t.N::text, 12, '0'))::uuid,
        ('f4000000-0000-0000-0000-' || LPAD((((t.N - 1) % v_OpportunityCount) + 1)::text, 12, '0'))::uuid,
        p.ProductId,
        ROUND((150.00 + ((t.N * 23) % 4500))::numeric, 2),
        1.00 + (t.N % 10),
        0.00,
        (SELECT UserId FROM _D365_Bulk_User WHERE N = 1 LIMIT 1),
        (SELECT UserId FROM _D365_Bulk_User WHERE N = 1 LIMIT 1),
        (CURRENT_TIMESTAMP - ((t.N % 1051200) || ' minutes')::interval),
        (CURRENT_TIMESTAMP - ((t.N % 525600) || ' minutes')::interval)
    FROM _Tally t
    JOIN _D365_Bulk_Product p ON (((t.N - 1) % v_ProductCount) + 1) = p.N
    WHERE t.N <= v_OpportunityCount;

    -- Incidents
    INSERT INTO "Dynamics365"."Incident" (
        "incidentid", "ticketnumber", "title", "customerid_account", "customerid_contact",
        "prioritycode", "statecode", "statuscode", "ownerid", "owningbusinessunit", "createdby", "modifiedby", "createdon", "modifiedon"
    )
    SELECT 
        ('b6000000-0000-0000-0000-' || LPAD(t.N::text, 12, '0'))::uuid,
        'D365-CAS-' || LPAD(t.N::text, 8, '0'),
        'Dataverse Platform Incident #' || t.N::text,
        ('c1000000-0000-0000-0000-' || LPAD((((t.N - 1) % v_AccountCount) + 1)::text, 12, '0'))::uuid,
        ('d2000000-0000-0000-0000-' || LPAD((((t.N - 1) % v_ContactCount) + 1)::text, 12, '0'))::uuid,
        (t.N % 3) + 1,
        0, 1,
        u.UserId,
        b.BUId,
        u.UserId,
        u.UserId,
        (CURRENT_TIMESTAMP - ((t.N % 1051200) || ' minutes')::interval),
        (CURRENT_TIMESTAMP - ((t.N % 525600) || ' minutes')::interval)
    FROM _Tally t
    JOIN _D365_Bulk_User u ON (((t.N - 1) % v_UserCount) + 1) = u.N
    JOIN _D365_Bulk_BU b ON (((t.N - 1) % v_D365BUCount) + 1) = b.N
    WHERE t.N <= v_CaseCount;

    -- ActivityPointers
    INSERT INTO "Dynamics365"."ActivityPointer" (
        "activityid", "activitytypecode", "subject", "regardingobjectid_account",
        "regardingobjectid_opportunity", "ownerid", "owningbusinessunit", "statecode", "statuscode",
        "createdby", "modifiedby", "createdon", "modifiedon"
    )
    SELECT 
        ('c7000000-0000-0000-0000-' || LPAD(t.N::text, 12, '0'))::uuid,
        CASE (t.N % 4) WHEN 0 THEN 'appointment' WHEN 1 THEN 'email' WHEN 2 THEN 'phonecall' ELSE 'task' END,
        'Enterprise synthetic telemetry activity #' || t.N::text,
        ('c1000000-0000-0000-0000-' || LPAD((((t.N - 1) % v_AccountCount) + 1)::text, 12, '0'))::uuid,
        ('f4000000-0000-0000-0000-' || LPAD((((t.N - 1) % v_OpportunityCount) + 1)::text, 12, '0'))::uuid,
        u.UserId,
        b.BUId,
        0, 1,
        u.UserId,
        u.UserId,
        (CURRENT_TIMESTAMP - ((t.N % 1051200) || ' minutes')::interval),
        (CURRENT_TIMESTAMP - ((t.N % 525600) || ' minutes')::interval)
    FROM _Tally t
    JOIN _D365_Bulk_User u ON (((t.N - 1) % v_UserCount) + 1) = u.N
    JOIN _D365_Bulk_BU b ON (((t.N - 1) % v_D365BUCount) + 1) = b.N
    WHERE t.N <= v_ActivityCount;

    RAISE NOTICE 'Heavy ETL simulation load complete. Successfully bulk loaded scale factor % (~88,000+ records).', v_ScaleFactor;
END;
$$;
