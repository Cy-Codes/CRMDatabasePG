CREATE TABLE IF NOT EXISTS "Dynamics365"."Opportunity"
(
    "opportunityid" UNIQUEIDENTIFIER NOT NULL CONSTRAINT "DF_Dynamics365_Opportunity_opportunityid" DEFAULT (gen_random_uuid()),
    "name" VARCHAR(300) NOT NULL,
    "parentaccountid" UUID NULL,
    "parentcontactid" UUID NULL,
    "pricelevelid" UUID NULL,
    "originatingleadid" UUID NULL,
    "estimatedvalue" NUMERIC(18, 2) NULL,
    "actualvalue" NUMERIC(18, 2) NULL,
    "estimatedclosedate" DATE NULL,
    "actualclosedate" DATE NULL,
    "closeprobability" INTEGER NULL,
    "stepname" VARCHAR(200) NULL,
    "salesstage" INTEGER NULL,
    "description" TEXT NULL,
    "ownerid" UUID NOT NULL,
    "owningbusinessunit" UUID NOT NULL,
    "statecode" INT NOT NULL CONSTRAINT "DF_Dynamics365_Opportunity_statecode" DEFAULT FALSE, -- 0=Open, 1=Won, 2=Lost
    "statuscode" INT NOT NULL CONSTRAINT "DF_Dynamics365_Opportunity_statuscode" DEFAULT TRUE, -- 1=In Progress, 2=On Hold, 3=Won, 4=Canceled, 5=Out-Sold
    "createdon" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Dynamics365_Opportunity_createdon" DEFAULT (CURRENT_TIMESTAMP),
    "createdby" UUID NOT NULL,
    "modifiedon" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Dynamics365_Opportunity_modifiedon" DEFAULT (CURRENT_TIMESTAMP),
    "modifiedby" UUID NOT NULL,
    CONSTRAINT "PK_Dynamics365_Opportunity" PRIMARY KEY ("opportunityid"),
    CONSTRAINT "FK_Dynamics365_Opportunity_parentaccountid" FOREIGN KEY ("parentaccountid") REFERENCES "Dynamics365"."Account" ("accountid"),
    CONSTRAINT "FK_Dynamics365_Opportunity_parentcontactid" FOREIGN KEY ("parentcontactid") REFERENCES "Dynamics365"."Contact" ("contactid"),
    CONSTRAINT "FK_Dynamics365_Opportunity_pricelevelid" FOREIGN KEY ("pricelevelid") REFERENCES "Dynamics365"."PriceLevel" ("pricelevelid"),
    CONSTRAINT "FK_Dynamics365_Opportunity_originatingleadid" FOREIGN KEY ("originatingleadid") REFERENCES "Dynamics365"."Lead" ("leadid"),
    CONSTRAINT "FK_Dynamics365_Opportunity_ownerid" FOREIGN KEY ("ownerid") REFERENCES "Dynamics365"."SystemUser" ("systemuserid"),
    CONSTRAINT "FK_Dynamics365_Opportunity_owningbusinessunit" FOREIGN KEY ("owningbusinessunit") REFERENCES "Dynamics365"."BusinessUnit" ("businessunitid"),
    CONSTRAINT "FK_Dynamics365_Opportunity_createdby" FOREIGN KEY ("createdby") REFERENCES "Dynamics365"."SystemUser" ("systemuserid"),
    CONSTRAINT "FK_Dynamics365_Opportunity_modifiedby" FOREIGN KEY ("modifiedby") REFERENCES "Dynamics365"."SystemUser" ("systemuserid")
);
