CREATE TABLE IF NOT EXISTS "Dynamics365"."ActivityPointer"
(
    "activityid" UNIQUEIDENTIFIER NOT NULL CONSTRAINT "DF_Dynamics365_ActivityPointer_activityid" DEFAULT (gen_random_uuid()),
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
    "actualdurationminutes" INTEGER NULL,
    "statecode" INT NOT NULL CONSTRAINT "DF_Dynamics365_ActivityPointer_statecode" DEFAULT FALSE, -- 0=Open, 1=Completed, 2=Canceled
    "statuscode" INT NOT NULL CONSTRAINT "DF_Dynamics365_ActivityPointer_statuscode" DEFAULT TRUE,
    "createdon" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Dynamics365_ActivityPointer_createdon" DEFAULT (CURRENT_TIMESTAMP),
    "createdby" UUID NOT NULL,
    "modifiedon" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Dynamics365_ActivityPointer_modifiedon" DEFAULT (CURRENT_TIMESTAMP),
    "modifiedby" UUID NOT NULL,
    CONSTRAINT "PK_Dynamics365_ActivityPointer" PRIMARY KEY ("activityid"),
    CONSTRAINT "FK_Dynamics365_ActivityPointer_regardingobjectid_account" FOREIGN KEY ("regardingobjectid_account") REFERENCES "Dynamics365"."Account" ("accountid"),
    CONSTRAINT "FK_Dynamics365_ActivityPointer_regardingobjectid_contact" FOREIGN KEY ("regardingobjectid_contact") REFERENCES "Dynamics365"."Contact" ("contactid"),
    CONSTRAINT "FK_Dynamics365_ActivityPointer_regardingobjectid_opportunity" FOREIGN KEY ("regardingobjectid_opportunity") REFERENCES "Dynamics365"."Opportunity" ("opportunityid"),
    CONSTRAINT "FK_Dynamics365_ActivityPointer_regardingobjectid_incident" FOREIGN KEY ("regardingobjectid_incident") REFERENCES "Dynamics365"."Incident" ("incidentid"),
    CONSTRAINT "FK_Dynamics365_ActivityPointer_ownerid" FOREIGN KEY ("ownerid") REFERENCES "Dynamics365"."SystemUser" ("systemuserid"),
    CONSTRAINT "FK_Dynamics365_ActivityPointer_owningbusinessunit" FOREIGN KEY ("owningbusinessunit") REFERENCES "Dynamics365"."BusinessUnit" ("businessunitid"),
    CONSTRAINT "FK_Dynamics365_ActivityPointer_createdby" FOREIGN KEY ("createdby") REFERENCES "Dynamics365"."SystemUser" ("systemuserid"),
    CONSTRAINT "FK_Dynamics365_ActivityPointer_modifiedby" FOREIGN KEY ("modifiedby") REFERENCES "Dynamics365"."SystemUser" ("systemuserid")
);
