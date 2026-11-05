CREATE TABLE IF NOT EXISTS "Dynamics365"."Incident"
(
    "incidentid" UNIQUEIDENTIFIER NOT NULL CONSTRAINT "DF_Dynamics365_Incident_incidentid" DEFAULT (gen_random_uuid()),
    "ticketnumber" VARCHAR(100) NOT NULL,
    "title" VARCHAR(200) NOT NULL,
    "customerid_account" UUID NULL,
    "customerid_contact" UUID NULL,
    "prioritycode" INT NOT NULL CONSTRAINT "DF_Dynamics365_Incident_prioritycode" DEFAULT (2), -- 1=High, 2=Normal, 3=Low
    "severitycode" INTEGER NULL,
    "casetypecode" INTEGER NULL,
    "casesubject" VARCHAR(500) NULL,
    "description" TEXT NULL,
    "ownerid" UUID NOT NULL,
    "owningbusinessunit" UUID NOT NULL,
    "statecode" INT NOT NULL CONSTRAINT "DF_Dynamics365_Incident_statecode" DEFAULT FALSE, -- 0=Active, 1=Resolved, 2=Canceled
    "statuscode" INT NOT NULL CONSTRAINT "DF_Dynamics365_Incident_statuscode" DEFAULT TRUE, -- 1=In Progress, 2=On Hold, 3=Waiting for Details, etc.
    "createdon" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Dynamics365_Incident_createdon" DEFAULT (CURRENT_TIMESTAMP),
    "createdby" UUID NOT NULL,
    "modifiedon" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Dynamics365_Incident_modifiedon" DEFAULT (CURRENT_TIMESTAMP),
    "modifiedby" UUID NOT NULL,
    CONSTRAINT "PK_Dynamics365_Incident" PRIMARY KEY ("incidentid"),
    CONSTRAINT "FK_Dynamics365_Incident_customerid_account" FOREIGN KEY ("customerid_account") REFERENCES "Dynamics365"."Account" ("accountid"),
    CONSTRAINT "FK_Dynamics365_Incident_customerid_contact" FOREIGN KEY ("customerid_contact") REFERENCES "Dynamics365"."Contact" ("contactid"),
    CONSTRAINT "FK_Dynamics365_Incident_ownerid" FOREIGN KEY ("ownerid") REFERENCES "Dynamics365"."SystemUser" ("systemuserid"),
    CONSTRAINT "FK_Dynamics365_Incident_owningbusinessunit" FOREIGN KEY ("owningbusinessunit") REFERENCES "Dynamics365"."BusinessUnit" ("businessunitid"),
    CONSTRAINT "FK_Dynamics365_Incident_createdby" FOREIGN KEY ("createdby") REFERENCES "Dynamics365"."SystemUser" ("systemuserid"),
    CONSTRAINT "FK_Dynamics365_Incident_modifiedby" FOREIGN KEY ("modifiedby") REFERENCES "Dynamics365"."SystemUser" ("systemuserid")
);
