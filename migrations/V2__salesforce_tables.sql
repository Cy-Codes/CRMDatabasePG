-- ============================================================================
-- Migration: V2__salesforce_tables.sql
-- Description: Create Salesforce CRM schema tables and constraints
-- ============================================================================

-- Table: Salesforce.User
CREATE TABLE "Salesforce"."User"
(
    "Id" VARCHAR(18) NOT NULL,
    "Username" VARCHAR(80) NOT NULL,
    "LastName" VARCHAR(80) NOT NULL,
    "FirstName" VARCHAR(40) NULL,
    "Name" VARCHAR(121) GENERATED ALWAYS AS (COALESCE("FirstName" || ' ', '') || "LastName") STORED,
    "Email" VARCHAR(128) NOT NULL,
    "IsActive" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_User_IsActive" DEFAULT TRUE,
    "UserRoleId" VARCHAR(18) NULL,
    "ProfileId" VARCHAR(18) NULL,
    "Title" VARCHAR(80) NULL,
    "Department" VARCHAR(80) NULL,
    "Phone" VARCHAR(40) NULL,
    "CreatedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_User_CreatedDate" DEFAULT (CURRENT_TIMESTAMP),
    "LastModifiedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_User_LastModifiedDate" DEFAULT (CURRENT_TIMESTAMP),
    CONSTRAINT "PK_Salesforce_User" PRIMARY KEY  ("Id"),
    CONSTRAINT "UQ_Salesforce_User_Username" UNIQUE ("Username")
);

-- Table: Salesforce.Account
CREATE TABLE "Salesforce"."Account"
(
    "Id" VARCHAR(18) NOT NULL,
    "IsDeleted" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_Account_IsDeleted" DEFAULT FALSE,
    "ParentId" VARCHAR(18) NULL,
    "Name" VARCHAR(255) NOT NULL,
    "Type" VARCHAR(40) NULL,
    "BillingStreet" VARCHAR(255) NULL,
    "BillingCity" VARCHAR(40) NULL,
    "BillingState" VARCHAR(80) NULL,
    "BillingPostalCode" VARCHAR(20) NULL,
    "BillingCountry" VARCHAR(80) NULL,
    "ShippingStreet" VARCHAR(255) NULL,
    "ShippingCity" VARCHAR(40) NULL,
    "ShippingState" VARCHAR(80) NULL,
    "ShippingPostalCode" VARCHAR(20) NULL,
    "ShippingCountry" VARCHAR(80) NULL,
    "Phone" VARCHAR(40) NULL,
    "Fax" VARCHAR(40) NULL,
    "Website" VARCHAR(255) NULL,
    "Industry" VARCHAR(40) NULL,
    "AnnualRevenue" DECIMAL(18, 2) NULL,
    "NumberOfEmployees" INT NULL,
    "Description" TEXT NULL,
    "OwnerId" VARCHAR(18) NOT NULL,
    "CreatedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_Account_CreatedDate" DEFAULT (CURRENT_TIMESTAMP),
    "CreatedById" VARCHAR(18) NOT NULL,
    "LastModifiedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_Account_LastModifiedDate" DEFAULT (CURRENT_TIMESTAMP),
    "LastModifiedById" VARCHAR(18) NOT NULL,
    CONSTRAINT "PK_Salesforce_Account" PRIMARY KEY  ("Id"),
    CONSTRAINT "FK_Salesforce_Account_ParentId" FOREIGN KEY ("ParentId") REFERENCES "Salesforce"."Account" ("Id"),
    CONSTRAINT "FK_Salesforce_Account_OwnerId" FOREIGN KEY ("OwnerId") REFERENCES "Salesforce"."User" ("Id"),
    CONSTRAINT "FK_Salesforce_Account_CreatedById" FOREIGN KEY ("CreatedById") REFERENCES "Salesforce"."User" ("Id"),
    CONSTRAINT "FK_Salesforce_Account_LastModifiedById" FOREIGN KEY ("LastModifiedById") REFERENCES "Salesforce"."User" ("Id")
);

-- Table: Salesforce.Contact
CREATE TABLE "Salesforce"."Contact"
(
    "Id" VARCHAR(18) NOT NULL,
    "IsDeleted" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_Contact_IsDeleted" DEFAULT FALSE,
    "AccountId" VARCHAR(18) NULL,
    "LastName" VARCHAR(80) NOT NULL,
    "FirstName" VARCHAR(40) NULL,
    "Salutation" VARCHAR(40) NULL,
    "Name" VARCHAR(121) GENERATED ALWAYS AS (COALESCE("FirstName" || ' ', '') || "LastName") STORED,
    "ReportsToId" VARCHAR(18) NULL,
    "Title" VARCHAR(128) NULL,
    "Department" VARCHAR(80) NULL,
    "Email" VARCHAR(128) NULL,
    "Phone" VARCHAR(40) NULL,
    "MobilePhone" VARCHAR(40) NULL,
    "MailingStreet" VARCHAR(255) NULL,
    "MailingCity" VARCHAR(40) NULL,
    "MailingState" VARCHAR(80) NULL,
    "MailingPostalCode" VARCHAR(20) NULL,
    "MailingCountry" VARCHAR(80) NULL,
    "LeadSource" VARCHAR(40) NULL,
    "Description" TEXT NULL,
    "OwnerId" VARCHAR(18) NOT NULL,
    "CreatedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_Contact_CreatedDate" DEFAULT (CURRENT_TIMESTAMP),
    "CreatedById" VARCHAR(18) NOT NULL,
    "LastModifiedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_Contact_LastModifiedDate" DEFAULT (CURRENT_TIMESTAMP),
    "LastModifiedById" VARCHAR(18) NOT NULL,
    CONSTRAINT "PK_Salesforce_Contact" PRIMARY KEY  ("Id"),
    CONSTRAINT "FK_Salesforce_Contact_AccountId" FOREIGN KEY ("AccountId") REFERENCES "Salesforce"."Account" ("Id"),
    CONSTRAINT "FK_Salesforce_Contact_ReportsToId" FOREIGN KEY ("ReportsToId") REFERENCES "Salesforce"."Contact" ("Id"),
    CONSTRAINT "FK_Salesforce_Contact_OwnerId" FOREIGN KEY ("OwnerId") REFERENCES "Salesforce"."User" ("Id"),
    CONSTRAINT "FK_Salesforce_Contact_CreatedById" FOREIGN KEY ("CreatedById") REFERENCES "Salesforce"."User" ("Id"),
    CONSTRAINT "FK_Salesforce_Contact_LastModifiedById" FOREIGN KEY ("LastModifiedById") REFERENCES "Salesforce"."User" ("Id")
);

-- Table: Salesforce.AccountContactRelation
CREATE TABLE "Salesforce"."AccountContactRelation"
(
    "Id" VARCHAR(18) NOT NULL,
    "AccountId" VARCHAR(18) NOT NULL,
    "ContactId" VARCHAR(18) NOT NULL,
    "Roles" VARCHAR(255) NULL,
    "IsDirect" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_AccountContactRelation_IsDirect" DEFAULT FALSE,
    "IsActive" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_AccountContactRelation_IsActive" DEFAULT TRUE,
    "StartDate" DATE NULL,
    "EndDate" DATE NULL,
    "CreatedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_AccountContactRelation_CreatedDate" DEFAULT (CURRENT_TIMESTAMP),
    "LastModifiedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_AccountContactRelation_LastModifiedDate" DEFAULT (CURRENT_TIMESTAMP),
    CONSTRAINT "PK_Salesforce_AccountContactRelation" PRIMARY KEY  ("Id"),
    CONSTRAINT "FK_Salesforce_AccountContactRelation_AccountId" FOREIGN KEY ("AccountId") REFERENCES "Salesforce"."Account" ("Id"),
    CONSTRAINT "FK_Salesforce_AccountContactRelation_ContactId" FOREIGN KEY ("ContactId") REFERENCES "Salesforce"."Contact" ("Id"),
    CONSTRAINT "UQ_Salesforce_AccountContactRelation_Account_Contact" UNIQUE ("AccountId", "ContactId")
);

-- Table: Salesforce.Lead
CREATE TABLE "Salesforce"."Lead"
(
    "Id" VARCHAR(18) NOT NULL,
    "IsDeleted" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_Lead_IsDeleted" DEFAULT FALSE,
    "LastName" VARCHAR(80) NOT NULL,
    "FirstName" VARCHAR(40) NULL,
    "Salutation" VARCHAR(40) NULL,
    "Name" VARCHAR(121) GENERATED ALWAYS AS (COALESCE("FirstName" || ' ', '') || "LastName") STORED,
    "Title" VARCHAR(128) NULL,
    "Company" VARCHAR(255) NOT NULL,
    "Street" VARCHAR(255) NULL,
    "City" VARCHAR(40) NULL,
    "State" VARCHAR(80) NULL,
    "PostalCode" VARCHAR(20) NULL,
    "Country" VARCHAR(80) NULL,
    "Phone" VARCHAR(40) NULL,
    "MobilePhone" VARCHAR(40) NULL,
    "Email" VARCHAR(128) NULL,
    "Website" VARCHAR(255) NULL,
    "LeadSource" VARCHAR(40) NULL,
    "Status" VARCHAR(40) NOT NULL CONSTRAINT "DF_Salesforce_Lead_Status" DEFAULT ('Open - Not Contacted'),
    "Industry" VARCHAR(40) NULL,
    "AnnualRevenue" DECIMAL(18, 2) NULL,
    "NumberOfEmployees" INT NULL,
    "Description" TEXT NULL,
    "IsConverted" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_Lead_IsConverted" DEFAULT FALSE,
    "ConvertedDate" DATE NULL,
    "ConvertedAccountId" VARCHAR(18) NULL,
    "ConvertedContactId" VARCHAR(18) NULL,
    "ConvertedOpportunityId" VARCHAR(18) NULL,
    "IsUnreadByOwner" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_Lead_IsUnreadByOwner" DEFAULT TRUE,
    "OwnerId" VARCHAR(18) NOT NULL,
    "CreatedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_Lead_CreatedDate" DEFAULT (CURRENT_TIMESTAMP),
    "CreatedById" VARCHAR(18) NOT NULL,
    "LastModifiedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_Lead_LastModifiedDate" DEFAULT (CURRENT_TIMESTAMP),
    "LastModifiedById" VARCHAR(18) NOT NULL,
    CONSTRAINT "PK_Salesforce_Lead" PRIMARY KEY  ("Id"),
    CONSTRAINT "FK_Salesforce_Lead_ConvertedAccountId" FOREIGN KEY ("ConvertedAccountId") REFERENCES "Salesforce"."Account" ("Id"),
    CONSTRAINT "FK_Salesforce_Lead_ConvertedContactId" FOREIGN KEY ("ConvertedContactId") REFERENCES "Salesforce"."Contact" ("Id"),
    CONSTRAINT "FK_Salesforce_Lead_OwnerId" FOREIGN KEY ("OwnerId") REFERENCES "Salesforce"."User" ("Id"),
    CONSTRAINT "FK_Salesforce_Lead_CreatedById" FOREIGN KEY ("CreatedById") REFERENCES "Salesforce"."User" ("Id"),
    CONSTRAINT "FK_Salesforce_Lead_LastModifiedById" FOREIGN KEY ("LastModifiedById") REFERENCES "Salesforce"."User" ("Id")
);

-- Table: Salesforce.Campaign
CREATE TABLE "Salesforce"."Campaign"
(
    "Id" VARCHAR(18) NOT NULL,
    "IsDeleted" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_Campaign_IsDeleted" DEFAULT FALSE,
    "Name" VARCHAR(80) NOT NULL,
    "ParentId" VARCHAR(18) NULL,
    "Type" VARCHAR(40) NULL,
    "Status" VARCHAR(40) NULL,
    "StartDate" DATE NULL,
    "EndDate" DATE NULL,
    "ExpectedRevenue" DECIMAL(18, 2) NULL,
    "BudgetedCost" DECIMAL(18, 2) NULL,
    "ActualCost" DECIMAL(18, 2) NULL,
    "ExpectedResponse" DECIMAL(5, 2) NULL,
    "NumberSent" DECIMAL(18, 0) NULL,
    "IsActive" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_Campaign_IsActive" DEFAULT TRUE,
    "Description" TEXT NULL,
    "NumberOfLeads" INT NOT NULL CONSTRAINT "DF_Salesforce_Campaign_NumberOfLeads" DEFAULT (0),
    "NumberOfConvertedLeads" INT NOT NULL CONSTRAINT "DF_Salesforce_Campaign_NumberOfConvertedLeads" DEFAULT (0),
    "NumberOfContacts" INT NOT NULL CONSTRAINT "DF_Salesforce_Campaign_NumberOfContacts" DEFAULT (0),
    "NumberOfResponses" INT NOT NULL CONSTRAINT "DF_Salesforce_Campaign_NumberOfResponses" DEFAULT (0),
    "NumberOfOpportunities" INT NOT NULL CONSTRAINT "DF_Salesforce_Campaign_NumberOfOpportunities" DEFAULT (0),
    "NumberOfWonOpportunities" INT NOT NULL CONSTRAINT "DF_Salesforce_Campaign_NumberOfWonOpportunities" DEFAULT (0),
    "AmountAllOpportunities" DECIMAL(18, 2) NOT NULL CONSTRAINT "DF_Salesforce_Campaign_AmountAllOpportunities" DEFAULT (0.00),
    "AmountWonOpportunities" DECIMAL(18, 2) NOT NULL CONSTRAINT "DF_Salesforce_Campaign_AmountWonOpportunities" DEFAULT (0.00),
    "OwnerId" VARCHAR(18) NOT NULL,
    "CreatedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_Campaign_CreatedDate" DEFAULT (CURRENT_TIMESTAMP),
    "CreatedById" VARCHAR(18) NOT NULL,
    "LastModifiedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_Campaign_LastModifiedDate" DEFAULT (CURRENT_TIMESTAMP),
    "LastModifiedById" VARCHAR(18) NOT NULL,
    CONSTRAINT "PK_Salesforce_Campaign" PRIMARY KEY  ("Id"),
    CONSTRAINT "FK_Salesforce_Campaign_ParentId" FOREIGN KEY ("ParentId") REFERENCES "Salesforce"."Campaign" ("Id"),
    CONSTRAINT "FK_Salesforce_Campaign_OwnerId" FOREIGN KEY ("OwnerId") REFERENCES "Salesforce"."User" ("Id"),
    CONSTRAINT "FK_Salesforce_Campaign_CreatedById" FOREIGN KEY ("CreatedById") REFERENCES "Salesforce"."User" ("Id"),
    CONSTRAINT "FK_Salesforce_Campaign_LastModifiedById" FOREIGN KEY ("LastModifiedById") REFERENCES "Salesforce"."User" ("Id")
);

-- Table: Salesforce.CampaignMember
CREATE TABLE "Salesforce"."CampaignMember"
(
    "Id" VARCHAR(18) NOT NULL,
    "IsDeleted" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_CampaignMember_IsDeleted" DEFAULT FALSE,
    "CampaignId" VARCHAR(18) NOT NULL,
    "LeadId" VARCHAR(18) NULL,
    "ContactId" VARCHAR(18) NULL,
    "Status" VARCHAR(40) NULL,
    "HasResponded" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_CampaignMember_HasResponded" DEFAULT FALSE,
    "CreatedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_CampaignMember_CreatedDate" DEFAULT (CURRENT_TIMESTAMP),
    "CreatedById" VARCHAR(18) NOT NULL,
    "LastModifiedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_CampaignMember_LastModifiedDate" DEFAULT (CURRENT_TIMESTAMP),
    "LastModifiedById" VARCHAR(18) NOT NULL,
    CONSTRAINT "PK_Salesforce_CampaignMember" PRIMARY KEY  ("Id"),
    CONSTRAINT "FK_Salesforce_CampaignMember_CampaignId" FOREIGN KEY ("CampaignId") REFERENCES "Salesforce"."Campaign" ("Id"),
    CONSTRAINT "FK_Salesforce_CampaignMember_LeadId" FOREIGN KEY ("LeadId") REFERENCES "Salesforce"."Lead" ("Id"),
    CONSTRAINT "FK_Salesforce_CampaignMember_ContactId" FOREIGN KEY ("ContactId") REFERENCES "Salesforce"."Contact" ("Id"),
    CONSTRAINT "FK_Salesforce_CampaignMember_CreatedById" FOREIGN KEY ("CreatedById") REFERENCES "Salesforce"."User" ("Id"),
    CONSTRAINT "FK_Salesforce_CampaignMember_LastModifiedById" FOREIGN KEY ("LastModifiedById") REFERENCES "Salesforce"."User" ("Id")
);

-- Table: Salesforce.Opportunity
CREATE TABLE "Salesforce"."Opportunity"
(
    "Id" VARCHAR(18) NOT NULL,
    "IsDeleted" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_Opportunity_IsDeleted" DEFAULT FALSE,
    "AccountId" VARCHAR(18) NULL,
    "IsPrivate" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_Opportunity_IsPrivate" DEFAULT FALSE,
    "Name" VARCHAR(120) NOT NULL,
    "Description" TEXT NULL,
    "StageName" VARCHAR(40) NOT NULL,
    "Amount" DECIMAL(18, 2) NULL,
    "Probability" DECIMAL(5, 2) NULL,
    "ExpectedRevenue" DECIMAL(18, 2) GENERATED ALWAYS AS (CAST("Amount" * ("Probability" / 100.0) AS DECIMAL(18, 2))) STORED,
    "CloseDate" DATE NOT NULL,
    "Type" VARCHAR(40) NULL,
    "LeadSource" VARCHAR(40) NULL,
    "IsClosed" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_Opportunity_IsClosed" DEFAULT FALSE,
    "IsWon" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_Opportunity_IsWon" DEFAULT FALSE,
    "ForecastCategoryName" VARCHAR(40) NOT NULL CONSTRAINT "DF_Salesforce_Opportunity_ForecastCategoryName" DEFAULT ('Pipeline'),
    "CampaignId" VARCHAR(18) NULL,
    "Pricebook2Id" VARCHAR(18) NULL,
    "OwnerId" VARCHAR(18) NOT NULL,
    "CreatedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_Opportunity_CreatedDate" DEFAULT (CURRENT_TIMESTAMP),
    "CreatedById" VARCHAR(18) NOT NULL,
    "LastModifiedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_Opportunity_LastModifiedDate" DEFAULT (CURRENT_TIMESTAMP),
    "LastModifiedById" VARCHAR(18) NOT NULL,
    CONSTRAINT "PK_Salesforce_Opportunity" PRIMARY KEY  ("Id"),
    CONSTRAINT "FK_Salesforce_Opportunity_AccountId" FOREIGN KEY ("AccountId") REFERENCES "Salesforce"."Account" ("Id"),
    CONSTRAINT "FK_Salesforce_Opportunity_CampaignId" FOREIGN KEY ("CampaignId") REFERENCES "Salesforce"."Campaign" ("Id"),
    CONSTRAINT "FK_Salesforce_Opportunity_Pricebook2Id" FOREIGN KEY ("Pricebook2Id") REFERENCES "Salesforce"."Pricebook2" ("Id"),
    CONSTRAINT "FK_Salesforce_Opportunity_OwnerId" FOREIGN KEY ("OwnerId") REFERENCES "Salesforce"."User" ("Id"),
    CONSTRAINT "FK_Salesforce_Opportunity_CreatedById" FOREIGN KEY ("CreatedById") REFERENCES "Salesforce"."User" ("Id"),
    CONSTRAINT "FK_Salesforce_Opportunity_LastModifiedById" FOREIGN KEY ("LastModifiedById") REFERENCES "Salesforce"."User" ("Id")
);

-- Table: Salesforce.Product2
CREATE TABLE "Salesforce"."Product2"
(
    "Id" VARCHAR(18) NOT NULL,
    "Name" VARCHAR(255) NOT NULL,
    "ProductCode" VARCHAR(255) NULL,
    "Description" TEXT NULL,
    "IsActive" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_Product2_IsActive" DEFAULT TRUE,
    "Family" VARCHAR(40) NULL,
    "IsDeleted" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_Product2_IsDeleted" DEFAULT FALSE,
    "CreatedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_Product2_CreatedDate" DEFAULT (CURRENT_TIMESTAMP),
    "CreatedById" VARCHAR(18) NOT NULL,
    "LastModifiedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_Product2_LastModifiedDate" DEFAULT (CURRENT_TIMESTAMP),
    "LastModifiedById" VARCHAR(18) NOT NULL,
    CONSTRAINT "PK_Salesforce_Product2" PRIMARY KEY  ("Id"),
    CONSTRAINT "FK_Salesforce_Product2_CreatedById" FOREIGN KEY ("CreatedById") REFERENCES "Salesforce"."User" ("Id"),
    CONSTRAINT "FK_Salesforce_Product2_LastModifiedById" FOREIGN KEY ("LastModifiedById") REFERENCES "Salesforce"."User" ("Id")
);

-- Table: Salesforce.Pricebook2
CREATE TABLE "Salesforce"."Pricebook2"
(
    "Id" VARCHAR(18) NOT NULL,
    "IsDeleted" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_Pricebook2_IsDeleted" DEFAULT FALSE,
    "Name" VARCHAR(255) NOT NULL,
    "IsActive" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_Pricebook2_IsActive" DEFAULT TRUE,
    "IsStandard" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_Pricebook2_IsStandard" DEFAULT FALSE,
    "Description" VARCHAR(255) NULL,
    "CreatedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_Pricebook2_CreatedDate" DEFAULT (CURRENT_TIMESTAMP),
    "CreatedById" VARCHAR(18) NOT NULL,
    "LastModifiedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_Pricebook2_LastModifiedDate" DEFAULT (CURRENT_TIMESTAMP),
    "LastModifiedById" VARCHAR(18) NOT NULL,
    CONSTRAINT "PK_Salesforce_Pricebook2" PRIMARY KEY  ("Id"),
    CONSTRAINT "FK_Salesforce_Pricebook2_CreatedById" FOREIGN KEY ("CreatedById") REFERENCES "Salesforce"."User" ("Id"),
    CONSTRAINT "FK_Salesforce_Pricebook2_LastModifiedById" FOREIGN KEY ("LastModifiedById") REFERENCES "Salesforce"."User" ("Id")
);

-- Table: Salesforce.PricebookEntry
CREATE TABLE "Salesforce"."PricebookEntry"
(
    "Id" VARCHAR(18) NOT NULL,
    "Pricebook2Id" VARCHAR(18) NOT NULL,
    "Product2Id" VARCHAR(18) NOT NULL,
    "UnitPrice" DECIMAL(18, 2) NOT NULL,
    "IsActive" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_PricebookEntry_IsActive" DEFAULT TRUE,
    "UseStandardPrice" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_PricebookEntry_UseStandardPrice" DEFAULT FALSE,
    "IsDeleted" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_PricebookEntry_IsDeleted" DEFAULT FALSE,
    "CreatedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_PricebookEntry_CreatedDate" DEFAULT (CURRENT_TIMESTAMP),
    "CreatedById" VARCHAR(18) NOT NULL,
    "LastModifiedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_PricebookEntry_LastModifiedDate" DEFAULT (CURRENT_TIMESTAMP),
    "LastModifiedById" VARCHAR(18) NOT NULL,
    CONSTRAINT "PK_Salesforce_PricebookEntry" PRIMARY KEY  ("Id"),
    CONSTRAINT "FK_Salesforce_PricebookEntry_Pricebook2Id" FOREIGN KEY ("Pricebook2Id") REFERENCES "Salesforce"."Pricebook2" ("Id"),
    CONSTRAINT "FK_Salesforce_PricebookEntry_Product2Id" FOREIGN KEY ("Product2Id") REFERENCES "Salesforce"."Product2" ("Id"),
    CONSTRAINT "FK_Salesforce_PricebookEntry_CreatedById" FOREIGN KEY ("CreatedById") REFERENCES "Salesforce"."User" ("Id"),
    CONSTRAINT "FK_Salesforce_PricebookEntry_LastModifiedById" FOREIGN KEY ("LastModifiedById") REFERENCES "Salesforce"."User" ("Id"),
    CONSTRAINT "UQ_Salesforce_PricebookEntry_Pricebook_Product" UNIQUE ("Pricebook2Id", "Product2Id")
);

-- Table: Salesforce.OpportunityLineItem
CREATE TABLE "Salesforce"."OpportunityLineItem"
(
    "Id" VARCHAR(18) NOT NULL,
    "OpportunityId" VARCHAR(18) NOT NULL,
    "PricebookEntryId" VARCHAR(18) NOT NULL,
    "Quantity" DECIMAL(12, 2) NOT NULL,
    "UnitPrice" DECIMAL(18, 2) NOT NULL,
    "TotalPrice" DECIMAL(18, 2) GENERATED ALWAYS AS (CAST("Quantity" * "UnitPrice" AS DECIMAL(18, 2))) STORED,
    "ListPrice" DECIMAL(18, 2) NULL,
    "Description" VARCHAR(255) NULL,
    "IsDeleted" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_OpportunityLineItem_IsDeleted" DEFAULT FALSE,
    "CreatedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_OpportunityLineItem_CreatedDate" DEFAULT (CURRENT_TIMESTAMP),
    "CreatedById" VARCHAR(18) NOT NULL,
    "LastModifiedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_OpportunityLineItem_LastModifiedDate" DEFAULT (CURRENT_TIMESTAMP),
    "LastModifiedById" VARCHAR(18) NOT NULL,
    CONSTRAINT "PK_Salesforce_OpportunityLineItem" PRIMARY KEY  ("Id"),
    CONSTRAINT "FK_Salesforce_OpportunityLineItem_OpportunityId" FOREIGN KEY ("OpportunityId") REFERENCES "Salesforce"."Opportunity" ("Id"),
    CONSTRAINT "FK_Salesforce_OpportunityLineItem_PricebookEntryId" FOREIGN KEY ("PricebookEntryId") REFERENCES "Salesforce"."PricebookEntry" ("Id"),
    CONSTRAINT "FK_Salesforce_OpportunityLineItem_CreatedById" FOREIGN KEY ("CreatedById") REFERENCES "Salesforce"."User" ("Id"),
    CONSTRAINT "FK_Salesforce_OpportunityLineItem_LastModifiedById" FOREIGN KEY ("LastModifiedById") REFERENCES "Salesforce"."User" ("Id")
);

-- Table: Salesforce.Case
CREATE TABLE "Salesforce"."Case"
(
    "Id" VARCHAR(18) NOT NULL,
    "IsDeleted" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_Case_IsDeleted" DEFAULT FALSE,
    "CaseNumber" VARCHAR(30) NOT NULL,
    "ContactId" VARCHAR(18) NULL,
    "AccountId" VARCHAR(18) NULL,
    "ParentId" VARCHAR(18) NULL,
    "SuppliedName" VARCHAR(80) NULL,
    "SuppliedEmail" VARCHAR(128) NULL,
    "SuppliedPhone" VARCHAR(40) NULL,
    "SuppliedCompany" VARCHAR(80) NULL,
    "Type" VARCHAR(40) NULL,
    "Status" VARCHAR(40) NOT NULL CONSTRAINT "DF_Salesforce_Case_Status" DEFAULT ('New'),
    "Reason" VARCHAR(40) NULL,
    "Origin" VARCHAR(40) NULL,
    "Subject" VARCHAR(255) NULL,
    "Priority" VARCHAR(40) NOT NULL CONSTRAINT "DF_Salesforce_Case_Priority" DEFAULT ('Medium'),
    "Description" TEXT NULL,
    "IsClosed" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_Case_IsClosed" DEFAULT FALSE,
    "ClosedDate" TIMESTAMPTZ NULL,
    "IsEscalated" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_Case_IsEscalated" DEFAULT FALSE,
    "OwnerId" VARCHAR(18) NOT NULL,
    "CreatedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_Case_CreatedDate" DEFAULT (CURRENT_TIMESTAMP),
    "CreatedById" VARCHAR(18) NOT NULL,
    "LastModifiedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_Case_LastModifiedDate" DEFAULT (CURRENT_TIMESTAMP),
    "LastModifiedById" VARCHAR(18) NOT NULL,
    CONSTRAINT "PK_Salesforce_Case" PRIMARY KEY  ("Id"),
    CONSTRAINT "FK_Salesforce_Case_ContactId" FOREIGN KEY ("ContactId") REFERENCES "Salesforce"."Contact" ("Id"),
    CONSTRAINT "FK_Salesforce_Case_AccountId" FOREIGN KEY ("AccountId") REFERENCES "Salesforce"."Account" ("Id"),
    CONSTRAINT "FK_Salesforce_Case_ParentId" FOREIGN KEY ("ParentId") REFERENCES "Salesforce"."Case" ("Id"),
    CONSTRAINT "FK_Salesforce_Case_OwnerId" FOREIGN KEY ("OwnerId") REFERENCES "Salesforce"."User" ("Id"),
    CONSTRAINT "FK_Salesforce_Case_CreatedById" FOREIGN KEY ("CreatedById") REFERENCES "Salesforce"."User" ("Id"),
    CONSTRAINT "FK_Salesforce_Case_LastModifiedById" FOREIGN KEY ("LastModifiedById") REFERENCES "Salesforce"."User" ("Id")
);

-- Table: Salesforce.Task
CREATE TABLE "Salesforce"."Task"
(
    "Id" VARCHAR(18) NOT NULL,
    "WhoId" VARCHAR(18) NULL,
    "WhatId" VARCHAR(18) NULL,
    "WhoCount" INT NOT NULL CONSTRAINT "DF_Salesforce_Task_WhoCount" DEFAULT (0),
    "WhatCount" INT NOT NULL CONSTRAINT "DF_Salesforce_Task_WhatCount" DEFAULT (0),
    "Subject" VARCHAR(255) NOT NULL,
    "ActivityDate" DATE NULL,
    "Status" VARCHAR(40) NOT NULL CONSTRAINT "DF_Salesforce_Task_Status" DEFAULT ('Not Started'),
    "Priority" VARCHAR(40) NOT NULL CONSTRAINT "DF_Salesforce_Task_Priority" DEFAULT ('Normal'),
    "IsHighPriority" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_Task_IsHighPriority" DEFAULT FALSE,
    "OwnerId" VARCHAR(18) NOT NULL,
    "Description" TEXT NULL,
    "IsDeleted" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_Task_IsDeleted" DEFAULT FALSE,
    "IsClosed" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_Task_IsClosed" DEFAULT FALSE,
    "CreatedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_Task_CreatedDate" DEFAULT (CURRENT_TIMESTAMP),
    "CreatedById" VARCHAR(18) NOT NULL,
    "LastModifiedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_Task_LastModifiedDate" DEFAULT (CURRENT_TIMESTAMP),
    "LastModifiedById" VARCHAR(18) NOT NULL,
    CONSTRAINT "PK_Salesforce_Task" PRIMARY KEY  ("Id"),
    CONSTRAINT "FK_Salesforce_Task_OwnerId" FOREIGN KEY ("OwnerId") REFERENCES "Salesforce"."User" ("Id"),
    CONSTRAINT "FK_Salesforce_Task_CreatedById" FOREIGN KEY ("CreatedById") REFERENCES "Salesforce"."User" ("Id"),
    CONSTRAINT "FK_Salesforce_Task_LastModifiedById" FOREIGN KEY ("LastModifiedById") REFERENCES "Salesforce"."User" ("Id")
);

-- Table: Salesforce.Event
CREATE TABLE "Salesforce"."Event"
(
    "Id" VARCHAR(18) NOT NULL,
    "WhoId" VARCHAR(18) NULL,
    "WhatId" VARCHAR(18) NULL,
    "WhoCount" INT NOT NULL CONSTRAINT "DF_Salesforce_Event_WhoCount" DEFAULT (0),
    "WhatCount" INT NOT NULL CONSTRAINT "DF_Salesforce_Event_WhatCount" DEFAULT (0),
    "Subject" VARCHAR(255) NOT NULL,
    "Location" VARCHAR(255) NULL,
    "IsAllDayEvent" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_Event_IsAllDayEvent" DEFAULT FALSE,
    "ActivityDateTime" TIMESTAMPTZ NULL,
    "ActivityDate" DATE NULL,
    "DurationInMinutes" INT NULL,
    "StartDateTime" TIMESTAMPTZ NOT NULL,
    "EndDateTime" TIMESTAMPTZ NOT NULL,
    "Description" TEXT NULL,
    "OwnerId" VARCHAR(18) NOT NULL,
    "IsDeleted" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_Event_IsDeleted" DEFAULT FALSE,
    "CreatedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_Event_CreatedDate" DEFAULT (CURRENT_TIMESTAMP),
    "CreatedById" VARCHAR(18) NOT NULL,
    "LastModifiedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_Event_LastModifiedDate" DEFAULT (CURRENT_TIMESTAMP),
    "LastModifiedById" VARCHAR(18) NOT NULL,
    CONSTRAINT "PK_Salesforce_Event" PRIMARY KEY  ("Id"),
    CONSTRAINT "FK_Salesforce_Event_OwnerId" FOREIGN KEY ("OwnerId") REFERENCES "Salesforce"."User" ("Id"),
    CONSTRAINT "FK_Salesforce_Event_CreatedById" FOREIGN KEY ("CreatedById") REFERENCES "Salesforce"."User" ("Id"),
    CONSTRAINT "FK_Salesforce_Event_LastModifiedById" FOREIGN KEY ("LastModifiedById") REFERENCES "Salesforce"."User" ("Id")
);
