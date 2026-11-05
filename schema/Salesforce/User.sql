CREATE TABLE IF NOT EXISTS "Salesforce"."User"
(
    "Id" VARCHAR(18) NOT NULL,
    "Username" VARCHAR(80) NOT NULL,
    "LastName" VARCHAR(80) NOT NULL,
    "FirstName" VARCHAR(40) NULL,
    "Name" VARCHAR(121) GENERATED ALWAYS AS (COALESCE("FirstName" || ' ', '') || "LastName") STORED + [LastName]),
    "Email" VARCHAR(128) NOT NULL,
    "IsActive" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_User_IsActive" DEFAULT TRUE,
    "UserRoleId" VARCHAR(18) NULL,
    "ProfileId" VARCHAR(18) NULL,
    "Title" VARCHAR(80) NULL,
    "Department" VARCHAR(80) NULL,
    "Phone" VARCHAR(40) NULL,
    "CreatedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_User_CreatedDate" DEFAULT (CURRENT_TIMESTAMP),
    "LastModifiedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_User_LastModifiedDate" DEFAULT (CURRENT_TIMESTAMP),
    CONSTRAINT "PK_Salesforce_User" PRIMARY KEY ("Id"),
    CONSTRAINT "UQ_Salesforce_User_Username" UNIQUE ("Username")
);
