CREATE TABLE IF NOT EXISTS "HubSpot"."ObjectAssociation"
(
    "associationId" BIGINT GENERATED ALWAYS AS IDENTITY NOT NULL,
    "fromObjectType" VARCHAR(50) NOT NULL, -- contact, company, deal, ticket, engagement
    "fromObjectId" BIGINT NOT NULL,
    "toObjectType" VARCHAR(50) NOT NULL,
    "toObjectId" BIGINT NOT NULL,
    "associationTypeId" INT NOT NULL CONSTRAINT "DF_HubSpot_ObjectAssociation_associationTypeId" DEFAULT TRUE,
    "createdAt" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_HubSpot_ObjectAssociation_createdAt" DEFAULT (CURRENT_TIMESTAMP),
    CONSTRAINT "PK_HubSpot_ObjectAssociation" PRIMARY KEY ("associationId"),
    CONSTRAINT "UQ_HubSpot_ObjectAssociation" UNIQUE ("fromObjectType", "fromObjectId", "toObjectType", "toObjectId", "associationTypeId")
);
