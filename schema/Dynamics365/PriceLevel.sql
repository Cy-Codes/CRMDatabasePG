CREATE TABLE IF NOT EXISTS "Dynamics365"."PriceLevel"
(
    "pricelevelid" UNIQUEIDENTIFIER NOT NULL CONSTRAINT "DF_Dynamics365_PriceLevel_pricelevelid" DEFAULT (gen_random_uuid()),
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT NULL,
    "begindate" DATE NULL,
    "enddate" DATE NULL,
    "statecode" INT NOT NULL CONSTRAINT "DF_Dynamics365_PriceLevel_statecode" DEFAULT FALSE,
    "statuscode" INT NOT NULL CONSTRAINT "DF_Dynamics365_PriceLevel_statuscode" DEFAULT TRUE,
    "createdon" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Dynamics365_PriceLevel_createdon" DEFAULT (CURRENT_TIMESTAMP),
    "createdby" UUID NOT NULL,
    "modifiedon" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Dynamics365_PriceLevel_modifiedon" DEFAULT (CURRENT_TIMESTAMP),
    "modifiedby" UUID NOT NULL,
    CONSTRAINT "PK_Dynamics365_PriceLevel" PRIMARY KEY ("pricelevelid"),
    CONSTRAINT "FK_Dynamics365_PriceLevel_createdby" FOREIGN KEY ("createdby") REFERENCES "Dynamics365"."SystemUser" ("systemuserid"),
    CONSTRAINT "FK_Dynamics365_PriceLevel_modifiedby" FOREIGN KEY ("modifiedby") REFERENCES "Dynamics365"."SystemUser" ("systemuserid")
);
