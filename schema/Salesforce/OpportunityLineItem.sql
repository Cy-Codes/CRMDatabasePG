CREATE TABLE IF NOT EXISTS "Salesforce"."OpportunityLineItem"
(
    "Id" VARCHAR(18) NOT NULL,
    "OpportunityId" VARCHAR(18) NOT NULL,
    "PricebookEntryId" VARCHAR(18) NOT NULL,
    "Quantity" NUMERIC(12, 2) NOT NULL,
    "UnitPrice" NUMERIC(18, 2) NOT NULL,
    "TotalPrice" NUMERIC(18, 2) GENERATED ALWAYS AS (ROUND(("Quantity" * "UnitPrice")::NUMERIC, 2)) STORED)),
    "ListPrice" NUMERIC(18, 2) NULL,
    "Description" VARCHAR(255) NULL,
    "IsDeleted" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_OpportunityLineItem_IsDeleted" DEFAULT FALSE,
    "CreatedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_OpportunityLineItem_CreatedDate" DEFAULT (CURRENT_TIMESTAMP),
    "CreatedById" VARCHAR(18) NOT NULL,
    "LastModifiedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_OpportunityLineItem_LastModifiedDate" DEFAULT (CURRENT_TIMESTAMP),
    "LastModifiedById" VARCHAR(18) NOT NULL,
    CONSTRAINT "PK_Salesforce_OpportunityLineItem" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_Salesforce_OpportunityLineItem_OpportunityId" FOREIGN KEY ("OpportunityId") REFERENCES "Salesforce"."Opportunity" ("Id"),
    CONSTRAINT "FK_Salesforce_OpportunityLineItem_PricebookEntryId" FOREIGN KEY ("PricebookEntryId") REFERENCES "Salesforce"."PricebookEntry" ("Id"),
    CONSTRAINT "FK_Salesforce_OpportunityLineItem_CreatedById" FOREIGN KEY ("CreatedById") REFERENCES "Salesforce"."User" ("Id"),
    CONSTRAINT "FK_Salesforce_OpportunityLineItem_LastModifiedById" FOREIGN KEY ("LastModifiedById") REFERENCES "Salesforce"."User" ("Id")
);
