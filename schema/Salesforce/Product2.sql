CREATE TABLE IF NOT EXISTS "Salesforce"."Product2"
(
    "Id" VARCHAR(18) NOT NULL,
    "Name" VARCHAR(255) NOT NULL,
    "ProductCode" VARCHAR(255) NULL,
    "Description" TEXT NULL,
    "IsActive" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_Product2_IsActive" DEFAULT TRUE,
    "Family" VARCHAR(40) NULL,
    "IsDeleted" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_Product2_IsDeleted" DEFAULT FALSE,
    "CreatedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_Product2_CreatedDate" DEFAULT (CURRENT_TIMESTAMP),
    "CreatedById" VARCHAR(18) NOT NULL,
    "LastModifiedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_Product2_LastModifiedDate" DEFAULT (CURRENT_TIMESTAMP),
    "LastModifiedById" VARCHAR(18) NOT NULL,
    CONSTRAINT "PK_Salesforce_Product2" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_Salesforce_Product2_CreatedById" FOREIGN KEY ("CreatedById") REFERENCES "Salesforce"."User" ("Id"),
    CONSTRAINT "FK_Salesforce_Product2_LastModifiedById" FOREIGN KEY ("LastModifiedById") REFERENCES "Salesforce"."User" ("Id")
);
