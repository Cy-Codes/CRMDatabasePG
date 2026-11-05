CREATE TABLE IF NOT EXISTS "HubSpot"."Pipeline"
(
    "pipelineId" VARCHAR(50) NOT NULL,
    "label" VARCHAR(100) NOT NULL,
    "displayOrder" INT NOT NULL CONSTRAINT "DF_HubSpot_Pipeline_displayOrder" DEFAULT FALSE,
    "objectType" VARCHAR(50) NOT NULL,
    "createdAt" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_HubSpot_Pipeline_createdAt" DEFAULT (CURRENT_TIMESTAMP),
    "updatedAt" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_HubSpot_Pipeline_updatedAt" DEFAULT (CURRENT_TIMESTAMP),
    "archived" BOOLEAN NOT NULL CONSTRAINT "DF_HubSpot_Pipeline_archived" DEFAULT FALSE,
    CONSTRAINT "PK_HubSpot_Pipeline" PRIMARY KEY ("pipelineId")
);
