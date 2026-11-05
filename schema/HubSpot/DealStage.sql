CREATE TABLE IF NOT EXISTS "HubSpot"."DealStage"
(
    "stageId" VARCHAR(50) NOT NULL,
    "pipelineId" VARCHAR(50) NOT NULL,
    "label" VARCHAR(100) NOT NULL,
    "displayOrder" INT NOT NULL CONSTRAINT "DF_HubSpot_DealStage_displayOrder" DEFAULT FALSE,
    "probability" DECIMAL(5, 2) NOT NULL CONSTRAINT "DF_HubSpot_DealStage_probability" DEFAULT (0.00),
    "closedWon" BOOLEAN NOT NULL CONSTRAINT "DF_HubSpot_DealStage_closedWon" DEFAULT FALSE,
    "createdAt" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_HubSpot_DealStage_createdAt" DEFAULT (CURRENT_TIMESTAMP),
    "updatedAt" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_HubSpot_DealStage_updatedAt" DEFAULT (CURRENT_TIMESTAMP),
    "archived" BOOLEAN NOT NULL CONSTRAINT "DF_HubSpot_DealStage_archived" DEFAULT FALSE,
    CONSTRAINT "PK_HubSpot_DealStage" PRIMARY KEY ("stageId"),
    CONSTRAINT "FK_HubSpot_DealStage_pipelineId" FOREIGN KEY ("pipelineId") REFERENCES "HubSpot"."Pipeline" ("pipelineId")
);
