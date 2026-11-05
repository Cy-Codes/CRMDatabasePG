CREATE TABLE IF NOT EXISTS "HubSpot"."Company"
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
    "annualRevenue" NUMERIC(18, 2) NULL,
    "numberOfEmployees" INTEGER NULL,
    "description" TEXT NULL,
    "ownerId" BIGINT NULL,
    "lifecyclestage" VARCHAR(50) NOT NULL CONSTRAINT "DF_HubSpot_Company_lifecyclestage" DEFAULT (N'lead'),
    "createdAt" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_HubSpot_Company_createdAt" DEFAULT (CURRENT_TIMESTAMP),
    "updatedAt" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_HubSpot_Company_updatedAt" DEFAULT (CURRENT_TIMESTAMP),
    "archived" BOOLEAN NOT NULL CONSTRAINT "DF_HubSpot_Company_archived" DEFAULT FALSE,
    CONSTRAINT "PK_HubSpot_Company" PRIMARY KEY ("companyId"),
    CONSTRAINT "FK_HubSpot_Company_ownerId" FOREIGN KEY ("ownerId") REFERENCES "HubSpot"."Owner" ("ownerId")
);
