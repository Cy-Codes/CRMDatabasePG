CREATE TABLE IF NOT EXISTS "Dynamics365"."Account"
(
    "accountid" UNIQUEIDENTIFIER NOT NULL CONSTRAINT "DF_Dynamics365_Account_accountid" DEFAULT (gen_random_uuid()),
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
    "revenue" NUMERIC(18, 2) NULL,
    "numberofemployees" INTEGER NULL,
    "industrycode" INTEGER NULL,
    "description" TEXT NULL,
    "ownerid" UUID NOT NULL,
    "owningbusinessunit" UUID NOT NULL,
    "statecode" INT NOT NULL CONSTRAINT "DF_Dynamics365_Account_statecode" DEFAULT FALSE, -- 0=Active, 1=Inactive
    "statuscode" INT NOT NULL CONSTRAINT "DF_Dynamics365_Account_statuscode" DEFAULT TRUE, -- 1=Active, 2=Inactive
    "createdon" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Dynamics365_Account_createdon" DEFAULT (CURRENT_TIMESTAMP),
    "createdby" UUID NOT NULL,
    "modifiedon" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Dynamics365_Account_modifiedon" DEFAULT (CURRENT_TIMESTAMP),
    "modifiedby" UUID NOT NULL,
    CONSTRAINT "PK_Dynamics365_Account" PRIMARY KEY ("accountid"),
    CONSTRAINT "FK_Dynamics365_Account_parentaccountid" FOREIGN KEY ("parentaccountid") REFERENCES "Dynamics365"."Account" ("accountid"),
    CONSTRAINT "FK_Dynamics365_Account_ownerid" FOREIGN KEY ("ownerid") REFERENCES "Dynamics365"."SystemUser" ("systemuserid"),
    CONSTRAINT "FK_Dynamics365_Account_owningbusinessunit" FOREIGN KEY ("owningbusinessunit") REFERENCES "Dynamics365"."BusinessUnit" ("businessunitid"),
    CONSTRAINT "FK_Dynamics365_Account_createdby" FOREIGN KEY ("createdby") REFERENCES "Dynamics365"."SystemUser" ("systemuserid"),
    CONSTRAINT "FK_Dynamics365_Account_modifiedby" FOREIGN KEY ("modifiedby") REFERENCES "Dynamics365"."SystemUser" ("systemuserid")
);
