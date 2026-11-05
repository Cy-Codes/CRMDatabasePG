-- ============================================================================
-- Migration: V3__hubspot_tables.sql
-- Description: Create HubSpot CRM schema tables and constraints
-- ============================================================================

-- Table: HubSpot.Owner
CREATE TABLE "HubSpot"."Owner"
(
    "ownerId" BIGINT NOT NULL,
    "email" VARCHAR(255) NOT NULL,
    "firstName" VARCHAR(100) NULL,
    "lastName" VARCHAR(100) NULL,
    "userId" BIGINT NULL,
    "isActive" BOOLEAN NOT NULL CONSTRAINT "DF_HubSpot_Owner_isActive" DEFAULT TRUE,
    "createdAt" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_HubSpot_Owner_createdAt" DEFAULT (CURRENT_TIMESTAMP),
    "updatedAt" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_HubSpot_Owner_updatedAt" DEFAULT (CURRENT_TIMESTAMP),
    "archived" BOOLEAN NOT NULL CONSTRAINT "DF_HubSpot_Owner_archived" DEFAULT FALSE,
    CONSTRAINT "PK_HubSpot_Owner" PRIMARY KEY  ("ownerId"),
    CONSTRAINT "UQ_HubSpot_Owner_email" UNIQUE ("email")
);

-- Table: HubSpot.Company
CREATE TABLE "HubSpot"."Company"
(
    "companyId" BIGINT NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "domain" VARCHAR(255) NULL,
    "industry" VARCHAR(100) NULL,
    "phone" VARCHAR(50) NULL,
    "address" VARCHAR(255) NULL,
    "city" VARCHAR(100) NULL,
    "state" VARCHAR(100) NULL,
    "zip" VARCHAR(30) NULL,
    "country" VARCHAR(100) NULL,
    "annualRevenue" DECIMAL(18, 2) NULL,
    "numberOfEmployees" INT NULL,
    "description" TEXT NULL,
    "ownerId" BIGINT NULL,
    "lifecyclestage" VARCHAR(50) NOT NULL CONSTRAINT "DF_HubSpot_Company_lifecyclestage" DEFAULT ('lead'),
    "createdAt" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_HubSpot_Company_createdAt" DEFAULT (CURRENT_TIMESTAMP),
    "updatedAt" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_HubSpot_Company_updatedAt" DEFAULT (CURRENT_TIMESTAMP),
    "archived" BOOLEAN NOT NULL CONSTRAINT "DF_HubSpot_Company_archived" DEFAULT FALSE,
    CONSTRAINT "PK_HubSpot_Company" PRIMARY KEY  ("companyId"),
    CONSTRAINT "FK_HubSpot_Company_ownerId" FOREIGN KEY ("ownerId") REFERENCES "HubSpot"."Owner" ("ownerId")
);

-- Table: HubSpot.Contact
CREATE TABLE "HubSpot"."Contact"
(
    "contactId" BIGINT NOT NULL,
    "email" VARCHAR(255) NOT NULL,
    "firstName" VARCHAR(100) NULL,
    "lastName" VARCHAR(100) NULL,
    "phone" VARCHAR(50) NULL,
    "mobilePhone" VARCHAR(50) NULL,
    "jobTitle" VARCHAR(100) NULL,
    "associatedCompanyId" BIGINT NULL,
    "ownerId" BIGINT NULL,
    "lifecyclestage" VARCHAR(50) NOT NULL CONSTRAINT "DF_HubSpot_Contact_lifecyclestage" DEFAULT ('lead'),
    "leadStatus" VARCHAR(50) NULL,
    "address" VARCHAR(255) NULL,
    "city" VARCHAR(100) NULL,
    "state" VARCHAR(100) NULL,
    "zip" VARCHAR(30) NULL,
    "country" VARCHAR(100) NULL,
    "createdAt" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_HubSpot_Contact_createdAt" DEFAULT (CURRENT_TIMESTAMP),
    "updatedAt" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_HubSpot_Contact_updatedAt" DEFAULT (CURRENT_TIMESTAMP),
    "archived" BOOLEAN NOT NULL CONSTRAINT "DF_HubSpot_Contact_archived" DEFAULT FALSE,
    CONSTRAINT "PK_HubSpot_Contact" PRIMARY KEY  ("contactId"),
    CONSTRAINT "FK_HubSpot_Contact_associatedCompanyId" FOREIGN KEY ("associatedCompanyId") REFERENCES "HubSpot"."Company" ("companyId"),
    CONSTRAINT "FK_HubSpot_Contact_ownerId" FOREIGN KEY ("ownerId") REFERENCES "HubSpot"."Owner" ("ownerId")
);

-- Table: HubSpot.Pipeline
CREATE TABLE "HubSpot"."Pipeline"
(
    "pipelineId" VARCHAR(50) NOT NULL,
    "label" VARCHAR(100) NOT NULL,
    "displayOrder" INT NOT NULL CONSTRAINT "DF_HubSpot_Pipeline_displayOrder" DEFAULT (0),
    "objectType" VARCHAR(50) NOT NULL,
    "createdAt" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_HubSpot_Pipeline_createdAt" DEFAULT (CURRENT_TIMESTAMP),
    "updatedAt" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_HubSpot_Pipeline_updatedAt" DEFAULT (CURRENT_TIMESTAMP),
    "archived" BOOLEAN NOT NULL CONSTRAINT "DF_HubSpot_Pipeline_archived" DEFAULT FALSE,
    CONSTRAINT "PK_HubSpot_Pipeline" PRIMARY KEY  ("pipelineId")
);

-- Table: HubSpot.DealStage
CREATE TABLE "HubSpot"."DealStage"
(
    "stageId" VARCHAR(50) NOT NULL,
    "pipelineId" VARCHAR(50) NOT NULL,
    "label" VARCHAR(100) NOT NULL,
    "displayOrder" INT NOT NULL CONSTRAINT "DF_HubSpot_DealStage_displayOrder" DEFAULT (0),
    "probability" DECIMAL(5, 2) NOT NULL CONSTRAINT "DF_HubSpot_DealStage_probability" DEFAULT (0.00),
    "closedWon" BOOLEAN NOT NULL CONSTRAINT "DF_HubSpot_DealStage_closedWon" DEFAULT FALSE,
    "createdAt" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_HubSpot_DealStage_createdAt" DEFAULT (CURRENT_TIMESTAMP),
    "updatedAt" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_HubSpot_DealStage_updatedAt" DEFAULT (CURRENT_TIMESTAMP),
    "archived" BOOLEAN NOT NULL CONSTRAINT "DF_HubSpot_DealStage_archived" DEFAULT FALSE,
    CONSTRAINT "PK_HubSpot_DealStage" PRIMARY KEY  ("stageId"),
    CONSTRAINT "FK_HubSpot_DealStage_pipelineId" FOREIGN KEY ("pipelineId") REFERENCES "HubSpot"."Pipeline" ("pipelineId")
);

-- Table: HubSpot.Deal
CREATE TABLE "HubSpot"."Deal"
(
    "dealId" BIGINT NOT NULL,
    "dealName" VARCHAR(255) NOT NULL,
    "pipelineId" VARCHAR(50) NOT NULL,
    "dealStageId" VARCHAR(50) NOT NULL,
    "amount" DECIMAL(18, 2) NULL,
    "closedate" TIMESTAMPTZ NULL,
    "dealType" VARCHAR(50) NULL,
    "ownerId" BIGINT NULL,
    "createdAt" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_HubSpot_Deal_createdAt" DEFAULT (CURRENT_TIMESTAMP),
    "updatedAt" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_HubSpot_Deal_updatedAt" DEFAULT (CURRENT_TIMESTAMP),
    "archived" BOOLEAN NOT NULL CONSTRAINT "DF_HubSpot_Deal_archived" DEFAULT FALSE,
    CONSTRAINT "PK_HubSpot_Deal" PRIMARY KEY  ("dealId"),
    CONSTRAINT "FK_HubSpot_Deal_pipelineId" FOREIGN KEY ("pipelineId") REFERENCES "HubSpot"."Pipeline" ("pipelineId"),
    CONSTRAINT "FK_HubSpot_Deal_dealStageId" FOREIGN KEY ("dealStageId") REFERENCES "HubSpot"."DealStage" ("stageId"),
    CONSTRAINT "FK_HubSpot_Deal_ownerId" FOREIGN KEY ("ownerId") REFERENCES "HubSpot"."Owner" ("ownerId")
);

-- Table: HubSpot.Ticket
CREATE TABLE "HubSpot"."Ticket"
(
    "ticketId" BIGINT NOT NULL,
    "subject" VARCHAR(255) NOT NULL,
    "content" TEXT NULL,
    "pipelineId" VARCHAR(50) NOT NULL,
    "ticketStatusStageId" VARCHAR(50) NOT NULL,
    "priority" VARCHAR(20) NOT NULL CONSTRAINT "DF_HubSpot_Ticket_priority" DEFAULT ('MEDIUM'),
    "ownerId" BIGINT NULL,
    "createdAt" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_HubSpot_Ticket_createdAt" DEFAULT (CURRENT_TIMESTAMP),
    "updatedAt" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_HubSpot_Ticket_updatedAt" DEFAULT (CURRENT_TIMESTAMP),
    "archived" BOOLEAN NOT NULL CONSTRAINT "DF_HubSpot_Ticket_archived" DEFAULT FALSE,
    CONSTRAINT "PK_HubSpot_Ticket" PRIMARY KEY  ("ticketId"),
    CONSTRAINT "FK_HubSpot_Ticket_pipelineId" FOREIGN KEY ("pipelineId") REFERENCES "HubSpot"."Pipeline" ("pipelineId"),
    CONSTRAINT "FK_HubSpot_Ticket_ownerId" FOREIGN KEY ("ownerId") REFERENCES "HubSpot"."Owner" ("ownerId")
);

-- Table: HubSpot.Product
CREATE TABLE "HubSpot"."Product"
(
    "productId" BIGINT NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "sku" VARCHAR(100) NULL,
    "description" TEXT NULL,
    "price" DECIMAL(18, 2) NOT NULL,
    "cost" DECIMAL(18, 2) NULL,
    "recurringBillingFrequency" VARCHAR(50) NULL,
    "createdAt" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_HubSpot_Product_createdAt" DEFAULT (CURRENT_TIMESTAMP),
    "updatedAt" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_HubSpot_Product_updatedAt" DEFAULT (CURRENT_TIMESTAMP),
    "archived" BOOLEAN NOT NULL CONSTRAINT "DF_HubSpot_Product_archived" DEFAULT FALSE,
    CONSTRAINT "PK_HubSpot_Product" PRIMARY KEY  ("productId")
);

-- Table: HubSpot.LineItem
CREATE TABLE "HubSpot"."LineItem"
(
    "lineItemId" BIGINT NOT NULL,
    "dealId" BIGINT NOT NULL,
    "productId" BIGINT NULL,
    "name" VARCHAR(255) NOT NULL,
    "quantity" DECIMAL(12, 2) NOT NULL CONSTRAINT "DF_HubSpot_LineItem_quantity" DEFAULT (1),
    "price" DECIMAL(18, 2) NOT NULL,
    "amount" DECIMAL(18, 2) GENERATED ALWAYS AS (CAST("quantity" * "price" AS DECIMAL(18, 2))) STORED,
    "discount" DECIMAL(18, 2) NOT NULL CONSTRAINT "DF_HubSpot_LineItem_discount" DEFAULT (0.00),
    "createdAt" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_HubSpot_LineItem_createdAt" DEFAULT (CURRENT_TIMESTAMP),
    "updatedAt" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_HubSpot_LineItem_updatedAt" DEFAULT (CURRENT_TIMESTAMP),
    "archived" BOOLEAN NOT NULL CONSTRAINT "DF_HubSpot_LineItem_archived" DEFAULT FALSE,
    CONSTRAINT "PK_HubSpot_LineItem" PRIMARY KEY  ("lineItemId"),
    CONSTRAINT "FK_HubSpot_LineItem_dealId" FOREIGN KEY ("dealId") REFERENCES "HubSpot"."Deal" ("dealId"),
    CONSTRAINT "FK_HubSpot_LineItem_productId" FOREIGN KEY ("productId") REFERENCES "HubSpot"."Product" ("productId")
);

-- Table: HubSpot.Engagement
CREATE TABLE "HubSpot"."Engagement"
(
    "engagementId" BIGINT NOT NULL,
    "engagementType" VARCHAR(50) NOT NULL, -- NOTE, EMAIL, TASK, CALL, MEETING
    "ownerId" BIGINT NULL,
    "timestamp" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_HubSpot_Engagement_timestamp" DEFAULT (CURRENT_TIMESTAMP),
    "body" TEXT NULL,
    "status" VARCHAR(50) NULL,
    "activityDurationMilliseconds" BIGINT NULL,
    "createdAt" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_HubSpot_Engagement_createdAt" DEFAULT (CURRENT_TIMESTAMP),
    "updatedAt" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_HubSpot_Engagement_updatedAt" DEFAULT (CURRENT_TIMESTAMP),
    "archived" BOOLEAN NOT NULL CONSTRAINT "DF_HubSpot_Engagement_archived" DEFAULT FALSE,
    CONSTRAINT "PK_HubSpot_Engagement" PRIMARY KEY  ("engagementId"),
    CONSTRAINT "FK_HubSpot_Engagement_ownerId" FOREIGN KEY ("ownerId") REFERENCES "HubSpot"."Owner" ("ownerId")
);

-- Table: HubSpot.ObjectAssociation
CREATE TABLE "HubSpot"."ObjectAssociation"
(
    "associationId" BIGINT GENERATED ALWAYS AS IDENTITY NOT NULL,
    "fromObjectType" VARCHAR(50) NOT NULL, -- contact, company, deal, ticket, engagement
    "fromObjectId" BIGINT NOT NULL,
    "toObjectType" VARCHAR(50) NOT NULL,
    "toObjectId" BIGINT NOT NULL,
    "associationTypeId" INT NOT NULL CONSTRAINT "DF_HubSpot_ObjectAssociation_associationTypeId" DEFAULT (1),
    "createdAt" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_HubSpot_ObjectAssociation_createdAt" DEFAULT (CURRENT_TIMESTAMP),
    CONSTRAINT "PK_HubSpot_ObjectAssociation" PRIMARY KEY  ("associationId"),
    CONSTRAINT "UQ_HubSpot_ObjectAssociation" UNIQUE ("fromObjectType", "fromObjectId", "toObjectType", "toObjectId", "associationTypeId")
);
