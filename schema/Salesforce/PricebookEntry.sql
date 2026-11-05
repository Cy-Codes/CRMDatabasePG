CREATE TABLE IF NOT EXISTS "Salesforce"."PricebookEntry"
(
    "Id" VARCHAR(18) NOT NULL,
    "Pricebook2Id" VARCHAR(18) NOT NULL,
    "Product2Id" VARCHAR(18) NOT NULL,
    "UnitPrice" NUMERIC(18, 2) NOT NULL,
    "IsActive" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_PricebookEntry_IsActive" DEFAULT TRUE,
    "UseStandardPrice" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_PricebookEntry_UseStandardPrice" DEFAULT FALSE,
    "IsDeleted" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_PricebookEntry_IsDeleted" DEFAULT FALSE,
    "CreatedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_PricebookEntry_CreatedDate" DEFAULT (CURRENT_TIMESTAMP),
    "CreatedById" VARCHAR(18) NOT NULL,
    "LastModifiedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_PricebookEntry_LastModifiedDate" DEFAULT (CURRENT_TIMESTAMP),
    "LastModifiedById" VARCHAR(18) NOT NULL,
    CONSTRAINT "PK_Salesforce_PricebookEntry" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_Salesforce_PricebookEntry_Pricebook2Id" FOREIGN KEY ("Pricebook2Id") REFERENCES "Salesforce"."Pricebook2" ("Id"),
    CONSTRAINT "FK_Salesforce_PricebookEntry_Product2Id" FOREIGN KEY ("Product2Id") REFERENCES "Salesforce"."Product2" ("Id"),
    CONSTRAINT "FK_Salesforce_PricebookEntry_CreatedById" FOREIGN KEY ("CreatedById") REFERENCES "Salesforce"."User" ("Id"),
    CONSTRAINT "FK_Salesforce_PricebookEntry_LastModifiedById" FOREIGN KEY ("LastModifiedById") REFERENCES "Salesforce"."User" ("Id"),
    CONSTRAINT "UQ_Salesforce_PricebookEntry_Pricebook_Product" UNIQUE ("Pricebook2Id", "Product2Id")
);
