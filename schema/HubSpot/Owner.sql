CREATE TABLE IF NOT EXISTS "HubSpot"."Owner"
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
    CONSTRAINT "PK_HubSpot_Owner" PRIMARY KEY ("ownerId"),
    CONSTRAINT "UQ_HubSpot_Owner_email" UNIQUE ("email")
);
