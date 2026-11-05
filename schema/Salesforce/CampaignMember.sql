CREATE TABLE IF NOT EXISTS "Salesforce"."CampaignMember"
(
    "Id" VARCHAR(18) NOT NULL,
    "IsDeleted" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_CampaignMember_IsDeleted" DEFAULT FALSE,
    "CampaignId" VARCHAR(18) NOT NULL,
    "LeadId" VARCHAR(18) NULL,
    "ContactId" VARCHAR(18) NULL,
    "Status" VARCHAR(40) NULL,
    "HasResponded" BOOLEAN NOT NULL CONSTRAINT "DF_Salesforce_CampaignMember_HasResponded" DEFAULT FALSE,
    "CreatedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_CampaignMember_CreatedDate" DEFAULT (CURRENT_TIMESTAMP),
    "CreatedById" VARCHAR(18) NOT NULL,
    "LastModifiedDate" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Salesforce_CampaignMember_LastModifiedDate" DEFAULT (CURRENT_TIMESTAMP),
    "LastModifiedById" VARCHAR(18) NOT NULL,
    CONSTRAINT "PK_Salesforce_CampaignMember" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_Salesforce_CampaignMember_CampaignId" FOREIGN KEY ("CampaignId") REFERENCES "Salesforce"."Campaign" ("Id"),
    CONSTRAINT "FK_Salesforce_CampaignMember_LeadId" FOREIGN KEY ("LeadId") REFERENCES "Salesforce"."Lead" ("Id"),
    CONSTRAINT "FK_Salesforce_CampaignMember_ContactId" FOREIGN KEY ("ContactId") REFERENCES "Salesforce"."Contact" ("Id"),
    CONSTRAINT "FK_Salesforce_CampaignMember_CreatedById" FOREIGN KEY ("CreatedById") REFERENCES "Salesforce"."User" ("Id"),
    CONSTRAINT "FK_Salesforce_CampaignMember_LastModifiedById" FOREIGN KEY ("LastModifiedById") REFERENCES "Salesforce"."User" ("Id")
);
