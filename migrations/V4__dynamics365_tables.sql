-- ============================================================================
-- Migration: V4__dynamics365_tables.sql
-- Description: Create Dynamics 365 CRM schema tables and constraints
-- ============================================================================

-- Table: Dynamics365.BusinessUnit
CREATE TABLE "Dynamics365"."BusinessUnit"
(
    "businessunitid" UUID NOT NULL CONSTRAINT "DF_Dynamics365_BusinessUnit_businessunitid" DEFAULT (gen_random_uuid()),
    "name" VARCHAR(160) NOT NULL,
    "description" TEXT NULL,
    "parentbusinessunitid" UUID NULL,
    "isdisabled" BOOLEAN NOT NULL CONSTRAINT "DF_Dynamics365_BusinessUnit_isdisabled" DEFAULT FALSE,
    "createdon" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Dynamics365_BusinessUnit_createdon" DEFAULT (CURRENT_TIMESTAMP),
    "modifiedon" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Dynamics365_BusinessUnit_modifiedon" DEFAULT (CURRENT_TIMESTAMP),
    CONSTRAINT "PK_Dynamics365_BusinessUnit" PRIMARY KEY  ("businessunitid"),
    CONSTRAINT "FK_Dynamics365_BusinessUnit_parentbusinessunitid" FOREIGN KEY ("parentbusinessunitid") REFERENCES "Dynamics365"."BusinessUnit" ("businessunitid")
);

-- Table: Dynamics365.SystemUser
CREATE TABLE "Dynamics365"."SystemUser"
(
    "systemuserid" UUID NOT NULL CONSTRAINT "DF_Dynamics365_SystemUser_systemuserid" DEFAULT (gen_random_uuid()),
    "businessunitid" UUID NOT NULL,
    "domainname" VARCHAR(1024) NOT NULL,
    "fullname" VARCHAR(200) NOT NULL,
    "firstname" VARCHAR(50) NULL,
    "lastname" VARCHAR(50) NOT NULL,
    "internalemailaddress" VARCHAR(100) NULL,
    "jobtitle" VARCHAR(100) NULL,
    "isdisabled" BOOLEAN NOT NULL CONSTRAINT "DF_Dynamics365_SystemUser_isdisabled" DEFAULT FALSE,
    "createdon" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Dynamics365_SystemUser_createdon" DEFAULT (CURRENT_TIMESTAMP),
    "modifiedon" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Dynamics365_SystemUser_modifiedon" DEFAULT (CURRENT_TIMESTAMP),
    CONSTRAINT "PK_Dynamics365_SystemUser" PRIMARY KEY  ("systemuserid"),
    CONSTRAINT "FK_Dynamics365_SystemUser_businessunitid" FOREIGN KEY ("businessunitid") REFERENCES "Dynamics365"."BusinessUnit" ("businessunitid")
);

-- Table: Dynamics365.Account
CREATE TABLE "Dynamics365"."Account"
(
    "accountid" UUID NOT NULL CONSTRAINT "DF_Dynamics365_Account_accountid" DEFAULT (gen_random_uuid()),
    "name" VARCHAR(160) NOT NULL,
    "accountnumber" VARCHAR(20) NULL,
    "parentaccountid" UUID NULL,
    "telephone1" VARCHAR(50) NULL,
    "emailaddress1" VARCHAR(100) NULL,
    "websiteurl" VARCHAR(200) NULL,
    "address1_line1" VARCHAR(250) NULL,
    "address1_city" VARCHAR(80) NULL,
    "address1_stateorprovince" VARCHAR(50) NULL,
    "address1_postalcode" VARCHAR(20) NULL,
    "address1_country" VARCHAR(80) NULL,
    "revenue" DECIMAL(18, 2) NULL,
    "numberofemployees" INT NULL,
    "industrycode" INT NULL,
    "description" TEXT NULL,
    "ownerid" UUID NOT NULL,
    "owningbusinessunit" UUID NOT NULL,
    "statecode" INT NOT NULL CONSTRAINT "DF_Dynamics365_Account_statecode" DEFAULT (0), -- 0=Active, 1=Inactive
    "statuscode" INT NOT NULL CONSTRAINT "DF_Dynamics365_Account_statuscode" DEFAULT (1), -- 1=Active, 2=Inactive
    "createdon" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Dynamics365_Account_createdon" DEFAULT (CURRENT_TIMESTAMP),
    "createdby" UUID NOT NULL,
    "modifiedon" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Dynamics365_Account_modifiedon" DEFAULT (CURRENT_TIMESTAMP),
    "modifiedby" UUID NOT NULL,
    CONSTRAINT "PK_Dynamics365_Account" PRIMARY KEY  ("accountid"),
    CONSTRAINT "FK_Dynamics365_Account_parentaccountid" FOREIGN KEY ("parentaccountid") REFERENCES "Dynamics365"."Account" ("accountid"),
    CONSTRAINT "FK_Dynamics365_Account_ownerid" FOREIGN KEY ("ownerid") REFERENCES "Dynamics365"."SystemUser" ("systemuserid"),
    CONSTRAINT "FK_Dynamics365_Account_owningbusinessunit" FOREIGN KEY ("owningbusinessunit") REFERENCES "Dynamics365"."BusinessUnit" ("businessunitid"),
    CONSTRAINT "FK_Dynamics365_Account_createdby" FOREIGN KEY ("createdby") REFERENCES "Dynamics365"."SystemUser" ("systemuserid"),
    CONSTRAINT "FK_Dynamics365_Account_modifiedby" FOREIGN KEY ("modifiedby") REFERENCES "Dynamics365"."SystemUser" ("systemuserid")
);

-- Table: Dynamics365.Contact
CREATE TABLE "Dynamics365"."Contact"
(
    "contactid" UUID NOT NULL CONSTRAINT "DF_Dynamics365_Contact_contactid" DEFAULT (gen_random_uuid()),
    "parentcustomerid" UUID NULL,
    "firstname" VARCHAR(50) NULL,
    "lastname" VARCHAR(50) NOT NULL,
    "fullname" VARCHAR(160) NOT NULL,
    "jobtitle" VARCHAR(100) NULL,
    "emailaddress1" VARCHAR(100) NULL,
    "telephone1" VARCHAR(50) NULL,
    "mobilephone" VARCHAR(50) NULL,
    "address1_line1" VARCHAR(250) NULL,
    "address1_city" VARCHAR(80) NULL,
    "address1_stateorprovince" VARCHAR(50) NULL,
    "address1_postalcode" VARCHAR(20) NULL,
    "address1_country" VARCHAR(80) NULL,
    "leadsourcecode" INT NULL,
    "description" TEXT NULL,
    "ownerid" UUID NOT NULL,
    "owningbusinessunit" UUID NOT NULL,
    "statecode" INT NOT NULL CONSTRAINT "DF_Dynamics365_Contact_statecode" DEFAULT (0),
    "statuscode" INT NOT NULL CONSTRAINT "DF_Dynamics365_Contact_statuscode" DEFAULT (1),
    "createdon" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Dynamics365_Contact_createdon" DEFAULT (CURRENT_TIMESTAMP),
    "createdby" UUID NOT NULL,
    "modifiedon" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Dynamics365_Contact_modifiedon" DEFAULT (CURRENT_TIMESTAMP),
    "modifiedby" UUID NOT NULL,
    CONSTRAINT "PK_Dynamics365_Contact" PRIMARY KEY  ("contactid"),
    CONSTRAINT "FK_Dynamics365_Contact_parentcustomerid" FOREIGN KEY ("parentcustomerid") REFERENCES "Dynamics365"."Account" ("accountid"),
    CONSTRAINT "FK_Dynamics365_Contact_ownerid" FOREIGN KEY ("ownerid") REFERENCES "Dynamics365"."SystemUser" ("systemuserid"),
    CONSTRAINT "FK_Dynamics365_Contact_owningbusinessunit" FOREIGN KEY ("owningbusinessunit") REFERENCES "Dynamics365"."BusinessUnit" ("businessunitid"),
    CONSTRAINT "FK_Dynamics365_Contact_createdby" FOREIGN KEY ("createdby") REFERENCES "Dynamics365"."SystemUser" ("systemuserid"),
    CONSTRAINT "FK_Dynamics365_Contact_modifiedby" FOREIGN KEY ("modifiedby") REFERENCES "Dynamics365"."SystemUser" ("systemuserid")
);

-- Table: Dynamics365.Lead
CREATE TABLE "Dynamics365"."Lead"
(
    "leadid" UUID NOT NULL CONSTRAINT "DF_Dynamics365_Lead_leadid" DEFAULT (gen_random_uuid()),
    "subject" VARCHAR(300) NOT NULL,
    "firstname" VARCHAR(50) NULL,
    "lastname" VARCHAR(50) NOT NULL,
    "fullname" VARCHAR(160) NOT NULL,
    "companyname" VARCHAR(100) NULL,
    "jobtitle" VARCHAR(100) NULL,
    "emailaddress1" VARCHAR(100) NULL,
    "telephone1" VARCHAR(50) NULL,
    "mobilephone" VARCHAR(50) NULL,
    "address1_line1" VARCHAR(250) NULL,
    "address1_city" VARCHAR(80) NULL,
    "address1_stateorprovince" VARCHAR(50) NULL,
    "address1_postalcode" VARCHAR(20) NULL,
    "address1_country" VARCHAR(80) NULL,
    "estimatedamount" DECIMAL(18, 2) NULL,
    "leadqualitycode" INT NULL, -- 1=Hot, 2=Warm, 3=Cold
    "leadsourcecode" INT NULL,
    "parentaccountid" UUID NULL,
    "parentcontactid" UUID NULL,
    "qualifyingopportunityid" UUID NULL,
    "description" TEXT NULL,
    "ownerid" UUID NOT NULL,
    "owningbusinessunit" UUID NOT NULL,
    "statecode" INT NOT NULL CONSTRAINT "DF_Dynamics365_Lead_statecode" DEFAULT (0), -- 0=Open, 1=Qualified, 2=Disqualified
    "statuscode" INT NOT NULL CONSTRAINT "DF_Dynamics365_Lead_statuscode" DEFAULT (1),
    "createdon" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Dynamics365_Lead_createdon" DEFAULT (CURRENT_TIMESTAMP),
    "createdby" UUID NOT NULL,
    "modifiedon" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Dynamics365_Lead_modifiedon" DEFAULT (CURRENT_TIMESTAMP),
    "modifiedby" UUID NOT NULL,
    CONSTRAINT "PK_Dynamics365_Lead" PRIMARY KEY  ("leadid"),
    CONSTRAINT "FK_Dynamics365_Lead_parentaccountid" FOREIGN KEY ("parentaccountid") REFERENCES "Dynamics365"."Account" ("accountid"),
    CONSTRAINT "FK_Dynamics365_Lead_parentcontactid" FOREIGN KEY ("parentcontactid") REFERENCES "Dynamics365"."Contact" ("contactid"),
    CONSTRAINT "FK_Dynamics365_Lead_ownerid" FOREIGN KEY ("ownerid") REFERENCES "Dynamics365"."SystemUser" ("systemuserid"),
    CONSTRAINT "FK_Dynamics365_Lead_owningbusinessunit" FOREIGN KEY ("owningbusinessunit") REFERENCES "Dynamics365"."BusinessUnit" ("businessunitid"),
    CONSTRAINT "FK_Dynamics365_Lead_createdby" FOREIGN KEY ("createdby") REFERENCES "Dynamics365"."SystemUser" ("systemuserid"),
    CONSTRAINT "FK_Dynamics365_Lead_modifiedby" FOREIGN KEY ("modifiedby") REFERENCES "Dynamics365"."SystemUser" ("systemuserid")
);

-- Table: Dynamics365.PriceLevel
CREATE TABLE "Dynamics365"."PriceLevel"
(
    "pricelevelid" UUID NOT NULL CONSTRAINT "DF_Dynamics365_PriceLevel_pricelevelid" DEFAULT (gen_random_uuid()),
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT NULL,
    "begindate" DATE NULL,
    "enddate" DATE NULL,
    "statecode" INT NOT NULL CONSTRAINT "DF_Dynamics365_PriceLevel_statecode" DEFAULT (0),
    "statuscode" INT NOT NULL CONSTRAINT "DF_Dynamics365_PriceLevel_statuscode" DEFAULT (1),
    "createdon" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Dynamics365_PriceLevel_createdon" DEFAULT (CURRENT_TIMESTAMP),
    "createdby" UUID NOT NULL,
    "modifiedon" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Dynamics365_PriceLevel_modifiedon" DEFAULT (CURRENT_TIMESTAMP),
    "modifiedby" UUID NOT NULL,
    CONSTRAINT "PK_Dynamics365_PriceLevel" PRIMARY KEY  ("pricelevelid"),
    CONSTRAINT "FK_Dynamics365_PriceLevel_createdby" FOREIGN KEY ("createdby") REFERENCES "Dynamics365"."SystemUser" ("systemuserid"),
    CONSTRAINT "FK_Dynamics365_PriceLevel_modifiedby" FOREIGN KEY ("modifiedby") REFERENCES "Dynamics365"."SystemUser" ("systemuserid")
);

-- Table: Dynamics365.Product
CREATE TABLE "Dynamics365"."Product"
(
    "productid" UUID NOT NULL CONSTRAINT "DF_Dynamics365_Product_productid" DEFAULT (gen_random_uuid()),
    "productnumber" VARCHAR(100) NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT NULL,
    "price" DECIMAL(18, 2) NULL,
    "standardcost" DECIMAL(18, 2) NULL,
    "currentcost" DECIMAL(18, 2) NULL,
    "quantityonhand" DECIMAL(12, 2) NOT NULL CONSTRAINT "DF_Dynamics365_Product_quantityonhand" DEFAULT (0.00),
    "statecode" INT NOT NULL CONSTRAINT "DF_Dynamics365_Product_statecode" DEFAULT (0),
    "statuscode" INT NOT NULL CONSTRAINT "DF_Dynamics365_Product_statuscode" DEFAULT (1),
    "createdon" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Dynamics365_Product_createdon" DEFAULT (CURRENT_TIMESTAMP),
    "createdby" UUID NOT NULL,
    "modifiedon" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Dynamics365_Product_modifiedon" DEFAULT (CURRENT_TIMESTAMP),
    "modifiedby" UUID NOT NULL,
    CONSTRAINT "PK_Dynamics365_Product" PRIMARY KEY  ("productid"),
    CONSTRAINT "FK_Dynamics365_Product_createdby" FOREIGN KEY ("createdby") REFERENCES "Dynamics365"."SystemUser" ("systemuserid"),
    CONSTRAINT "FK_Dynamics365_Product_modifiedby" FOREIGN KEY ("modifiedby") REFERENCES "Dynamics365"."SystemUser" ("systemuserid")
);

-- Table: Dynamics365.Opportunity
CREATE TABLE "Dynamics365"."Opportunity"
(
    "opportunityid" UUID NOT NULL CONSTRAINT "DF_Dynamics365_Opportunity_opportunityid" DEFAULT (gen_random_uuid()),
    "name" VARCHAR(300) NOT NULL,
    "parentaccountid" UUID NULL,
    "parentcontactid" UUID NULL,
    "pricelevelid" UUID NULL,
    "originatingleadid" UUID NULL,
    "estimatedvalue" DECIMAL(18, 2) NULL,
    "actualvalue" DECIMAL(18, 2) NULL,
    "estimatedclosedate" DATE NULL,
    "actualclosedate" DATE NULL,
    "closeprobability" INT NULL,
    "stepname" VARCHAR(200) NULL,
    "salesstage" INT NULL,
    "description" TEXT NULL,
    "ownerid" UUID NOT NULL,
    "owningbusinessunit" UUID NOT NULL,
    "statecode" INT NOT NULL CONSTRAINT "DF_Dynamics365_Opportunity_statecode" DEFAULT (0), -- 0=Open, 1=Won, 2=Lost
    "statuscode" INT NOT NULL CONSTRAINT "DF_Dynamics365_Opportunity_statuscode" DEFAULT (1), -- 1=In Progress, 2=On Hold, 3=Won, 4=Canceled, 5=Out-Sold
    "createdon" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Dynamics365_Opportunity_createdon" DEFAULT (CURRENT_TIMESTAMP),
    "createdby" UUID NOT NULL,
    "modifiedon" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Dynamics365_Opportunity_modifiedon" DEFAULT (CURRENT_TIMESTAMP),
    "modifiedby" UUID NOT NULL,
    CONSTRAINT "PK_Dynamics365_Opportunity" PRIMARY KEY  ("opportunityid"),
    CONSTRAINT "FK_Dynamics365_Opportunity_parentaccountid" FOREIGN KEY ("parentaccountid") REFERENCES "Dynamics365"."Account" ("accountid"),
    CONSTRAINT "FK_Dynamics365_Opportunity_parentcontactid" FOREIGN KEY ("parentcontactid") REFERENCES "Dynamics365"."Contact" ("contactid"),
    CONSTRAINT "FK_Dynamics365_Opportunity_pricelevelid" FOREIGN KEY ("pricelevelid") REFERENCES "Dynamics365"."PriceLevel" ("pricelevelid"),
    CONSTRAINT "FK_Dynamics365_Opportunity_originatingleadid" FOREIGN KEY ("originatingleadid") REFERENCES "Dynamics365"."Lead" ("leadid"),
    CONSTRAINT "FK_Dynamics365_Opportunity_ownerid" FOREIGN KEY ("ownerid") REFERENCES "Dynamics365"."SystemUser" ("systemuserid"),
    CONSTRAINT "FK_Dynamics365_Opportunity_owningbusinessunit" FOREIGN KEY ("owningbusinessunit") REFERENCES "Dynamics365"."BusinessUnit" ("businessunitid"),
    CONSTRAINT "FK_Dynamics365_Opportunity_createdby" FOREIGN KEY ("createdby") REFERENCES "Dynamics365"."SystemUser" ("systemuserid"),
    CONSTRAINT "FK_Dynamics365_Opportunity_modifiedby" FOREIGN KEY ("modifiedby") REFERENCES "Dynamics365"."SystemUser" ("systemuserid")
);

-- Table: Dynamics365.OpportunityProduct
CREATE TABLE "Dynamics365"."OpportunityProduct"
(
    "opportunityproductid" UUID NOT NULL CONSTRAINT "DF_Dynamics365_OpportunityProduct_opportunityproductid" DEFAULT (gen_random_uuid()),
    "opportunityid" UUID NOT NULL,
    "productid" UUID NULL,
    "productdescription" VARCHAR(500) NULL,
    "priceperunit" DECIMAL(18, 2) NOT NULL,
    "quantity" DECIMAL(12, 2) NOT NULL CONSTRAINT "DF_Dynamics365_OpportunityProduct_quantity" DEFAULT (1.00),
    "extendedamount" DECIMAL(18, 2) GENERATED ALWAYS AS (CAST("quantity" * "priceperunit" AS DECIMAL(18, 2))) STORED,
    "manualdiscountamount" DECIMAL(18, 2) NOT NULL CONSTRAINT "DF_Dynamics365_OpportunityProduct_manualdiscountamount" DEFAULT (0.00),
    "createdon" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Dynamics365_OpportunityProduct_createdon" DEFAULT (CURRENT_TIMESTAMP),
    "createdby" UUID NOT NULL,
    "modifiedon" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Dynamics365_OpportunityProduct_modifiedon" DEFAULT (CURRENT_TIMESTAMP),
    "modifiedby" UUID NOT NULL,
    CONSTRAINT "PK_Dynamics365_OpportunityProduct" PRIMARY KEY  ("opportunityproductid"),
    CONSTRAINT "FK_Dynamics365_OpportunityProduct_opportunityid" FOREIGN KEY ("opportunityid") REFERENCES "Dynamics365"."Opportunity" ("opportunityid"),
    CONSTRAINT "FK_Dynamics365_OpportunityProduct_productid" FOREIGN KEY ("productid") REFERENCES "Dynamics365"."Product" ("productid"),
    CONSTRAINT "FK_Dynamics365_OpportunityProduct_createdby" FOREIGN KEY ("createdby") REFERENCES "Dynamics365"."SystemUser" ("systemuserid"),
    CONSTRAINT "FK_Dynamics365_OpportunityProduct_modifiedby" FOREIGN KEY ("modifiedby") REFERENCES "Dynamics365"."SystemUser" ("systemuserid")
);

-- Table: Dynamics365.Incident
CREATE TABLE "Dynamics365"."Incident"
(
    "incidentid" UUID NOT NULL CONSTRAINT "DF_Dynamics365_Incident_incidentid" DEFAULT (gen_random_uuid()),
    "ticketnumber" VARCHAR(100) NOT NULL,
    "title" VARCHAR(200) NOT NULL,
    "customerid_account" UUID NULL,
    "customerid_contact" UUID NULL,
    "prioritycode" INT NOT NULL CONSTRAINT "DF_Dynamics365_Incident_prioritycode" DEFAULT (2), -- 1=High, 2=Normal, 3=Low
    "severitycode" INT NULL,
    "casetypecode" INT NULL,
    "casesubject" VARCHAR(500) NULL,
    "description" TEXT NULL,
    "ownerid" UUID NOT NULL,
    "owningbusinessunit" UUID NOT NULL,
    "statecode" INT NOT NULL CONSTRAINT "DF_Dynamics365_Incident_statecode" DEFAULT (0), -- 0=Active, 1=Resolved, 2=Canceled
    "statuscode" INT NOT NULL CONSTRAINT "DF_Dynamics365_Incident_statuscode" DEFAULT (1), -- 1=In Progress, 2=On Hold, 3=Waiting for Details, etc.
    "createdon" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Dynamics365_Incident_createdon" DEFAULT (CURRENT_TIMESTAMP),
    "createdby" UUID NOT NULL,
    "modifiedon" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Dynamics365_Incident_modifiedon" DEFAULT (CURRENT_TIMESTAMP),
    "modifiedby" UUID NOT NULL,
    CONSTRAINT "PK_Dynamics365_Incident" PRIMARY KEY  ("incidentid"),
    CONSTRAINT "FK_Dynamics365_Incident_customerid_account" FOREIGN KEY ("customerid_account") REFERENCES "Dynamics365"."Account" ("accountid"),
    CONSTRAINT "FK_Dynamics365_Incident_customerid_contact" FOREIGN KEY ("customerid_contact") REFERENCES "Dynamics365"."Contact" ("contactid"),
    CONSTRAINT "FK_Dynamics365_Incident_ownerid" FOREIGN KEY ("ownerid") REFERENCES "Dynamics365"."SystemUser" ("systemuserid"),
    CONSTRAINT "FK_Dynamics365_Incident_owningbusinessunit" FOREIGN KEY ("owningbusinessunit") REFERENCES "Dynamics365"."BusinessUnit" ("businessunitid"),
    CONSTRAINT "FK_Dynamics365_Incident_createdby" FOREIGN KEY ("createdby") REFERENCES "Dynamics365"."SystemUser" ("systemuserid"),
    CONSTRAINT "FK_Dynamics365_Incident_modifiedby" FOREIGN KEY ("modifiedby") REFERENCES "Dynamics365"."SystemUser" ("systemuserid")
);

-- Table: Dynamics365.ActivityPointer
CREATE TABLE "Dynamics365"."ActivityPointer"
(
    "activityid" UUID NOT NULL CONSTRAINT "DF_Dynamics365_ActivityPointer_activityid" DEFAULT (gen_random_uuid()),
    "activitytypecode" VARCHAR(64) NOT NULL, -- task, email, phonecall, appointment
    "subject" VARCHAR(200) NOT NULL,
    "description" TEXT NULL,
    "regardingobjectid_account" UUID NULL,
    "regardingobjectid_contact" UUID NULL,
    "regardingobjectid_opportunity" UUID NULL,
    "regardingobjectid_incident" UUID NULL,
    "ownerid" UUID NOT NULL,
    "owningbusinessunit" UUID NOT NULL,
    "scheduledstart" TIMESTAMPTZ NULL,
    "scheduledend" TIMESTAMPTZ NULL,
    "actualstart" TIMESTAMPTZ NULL,
    "actualend" TIMESTAMPTZ NULL,
    "actualdurationminutes" INT NULL,
    "statecode" INT NOT NULL CONSTRAINT "DF_Dynamics365_ActivityPointer_statecode" DEFAULT (0), -- 0=Open, 1=Completed, 2=Canceled
    "statuscode" INT NOT NULL CONSTRAINT "DF_Dynamics365_ActivityPointer_statuscode" DEFAULT (1),
    "createdon" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Dynamics365_ActivityPointer_createdon" DEFAULT (CURRENT_TIMESTAMP),
    "createdby" UUID NOT NULL,
    "modifiedon" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Dynamics365_ActivityPointer_modifiedon" DEFAULT (CURRENT_TIMESTAMP),
    "modifiedby" UUID NOT NULL,
    CONSTRAINT "PK_Dynamics365_ActivityPointer" PRIMARY KEY  ("activityid"),
    CONSTRAINT "FK_Dynamics365_ActivityPointer_regardingobjectid_account" FOREIGN KEY ("regardingobjectid_account") REFERENCES "Dynamics365"."Account" ("accountid"),
    CONSTRAINT "FK_Dynamics365_ActivityPointer_regardingobjectid_contact" FOREIGN KEY ("regardingobjectid_contact") REFERENCES "Dynamics365"."Contact" ("contactid"),
    CONSTRAINT "FK_Dynamics365_ActivityPointer_regardingobjectid_opportunity" FOREIGN KEY ("regardingobjectid_opportunity") REFERENCES "Dynamics365"."Opportunity" ("opportunityid"),
    CONSTRAINT "FK_Dynamics365_ActivityPointer_regardingobjectid_incident" FOREIGN KEY ("regardingobjectid_incident") REFERENCES "Dynamics365"."Incident" ("incidentid"),
    CONSTRAINT "FK_Dynamics365_ActivityPointer_ownerid" FOREIGN KEY ("ownerid") REFERENCES "Dynamics365"."SystemUser" ("systemuserid"),
    CONSTRAINT "FK_Dynamics365_ActivityPointer_owningbusinessunit" FOREIGN KEY ("owningbusinessunit") REFERENCES "Dynamics365"."BusinessUnit" ("businessunitid"),
    CONSTRAINT "FK_Dynamics365_ActivityPointer_createdby" FOREIGN KEY ("createdby") REFERENCES "Dynamics365"."SystemUser" ("systemuserid"),
    CONSTRAINT "FK_Dynamics365_ActivityPointer_modifiedby" FOREIGN KEY ("modifiedby") REFERENCES "Dynamics365"."SystemUser" ("systemuserid")
);
