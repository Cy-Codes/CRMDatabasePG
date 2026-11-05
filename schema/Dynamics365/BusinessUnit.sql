CREATE TABLE IF NOT EXISTS "Dynamics365"."BusinessUnit"
(
    "businessunitid" UNIQUEIDENTIFIER NOT NULL CONSTRAINT "DF_Dynamics365_BusinessUnit_businessunitid" DEFAULT (gen_random_uuid()),
    "name" VARCHAR(160) NOT NULL,
    "description" TEXT NULL,
    "parentbusinessunitid" UUID NULL,
    "isdisabled" BOOLEAN NOT NULL CONSTRAINT "DF_Dynamics365_BusinessUnit_isdisabled" DEFAULT FALSE,
    "createdon" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Dynamics365_BusinessUnit_createdon" DEFAULT (CURRENT_TIMESTAMP),
    "modifiedon" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Dynamics365_BusinessUnit_modifiedon" DEFAULT (CURRENT_TIMESTAMP),
    CONSTRAINT "PK_Dynamics365_BusinessUnit" PRIMARY KEY ("businessunitid"),
    CONSTRAINT "FK_Dynamics365_BusinessUnit_parentbusinessunitid" FOREIGN KEY ("parentbusinessunitid") REFERENCES "Dynamics365"."BusinessUnit" ("businessunitid")
);
