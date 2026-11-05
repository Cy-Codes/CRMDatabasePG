CREATE TABLE IF NOT EXISTS "Salesforce"."Pricebook2"
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
    CONSTRAINT "PK_Salesforce_Pricebook2" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_Salesforce_Pricebook2_CreatedById" FOREIGN KEY ("CreatedById") REFERENCES "Salesforce"."User" ("Id"),
    CONSTRAINT "FK_Salesforce_Pricebook2_LastModifiedById" FOREIGN KEY ("LastModifiedById") REFERENCES "Salesforce"."User" ("Id")
);
