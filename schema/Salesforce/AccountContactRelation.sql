CREATE TABLE IF NOT EXISTS "Salesforce"."AccountContactRelation"
(
    "Id" VARCHAR(18) NOT NULL,
    "AccountId" VARCHAR(18) NOT NULL,
    "ContactId" VARCHAR(18) NOT NULL,
    "Roles" VARCHAR(255) NULL,
    "IsDirect" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_AccountContactRelation_IsDirect" DEFAULT FALSE,
    "IsActive" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_AccountContactRelation_IsActive" DEFAULT TRUE,
    "StartDate" DATE NULL,
    "EndDate" DATE NULL,
    "CreatedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_AccountContactRelation_CreatedDate" DEFAULT (CURRENT_TIMESTAMP),
    "LastModifiedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_AccountContactRelation_LastModifiedDate" DEFAULT (CURRENT_TIMESTAMP),
    CONSTRAINT "PK_Salesforce_AccountContactRelation" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_Salesforce_AccountContactRelation_AccountId" FOREIGN KEY ("AccountId") REFERENCES "Salesforce"."Account" ("Id"),
    CONSTRAINT "FK_Salesforce_AccountContactRelation_ContactId" FOREIGN KEY ("ContactId") REFERENCES "Salesforce"."Contact" ("Id"),
    CONSTRAINT "UQ_Salesforce_AccountContactRelation_Account_Contact" UNIQUE ("AccountId", "ContactId")
);
