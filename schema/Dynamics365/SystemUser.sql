CREATE TABLE IF NOT EXISTS "Dynamics365"."SystemUser"
(
    "systemuserid" UNIQUEIDENTIFIER NOT NULL CONSTRAINT "DF_Dynamics365_SystemUser_systemuserid" DEFAULT (gen_random_uuid()),
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
    CONSTRAINT "PK_Dynamics365_SystemUser" PRIMARY KEY ("systemuserid"),
    CONSTRAINT "FK_Dynamics365_SystemUser_businessunitid" FOREIGN KEY ("businessunitid") REFERENCES "Dynamics365"."BusinessUnit" ("businessunitid")
);
