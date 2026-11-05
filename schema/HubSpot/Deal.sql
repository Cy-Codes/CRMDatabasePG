CREATE TABLE IF NOT EXISTS "HubSpot"."Deal"
(
    "dealId" BIGINT NOT NULL,
    "dealName" VARCHAR(255) NOT NULL,
    "pipelineId" VARCHAR(50) NOT NULL,
    "dealStageId" VARCHAR(50) NOT NULL,
    "amount" NUMERIC(18, 2) NULL,
    "closedate" TIMESTAMPTZ NULL,
    "dealType" VARCHAR(50) NULL,
    "ownerId" BIGINT NULL,
    "createdAt" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_HubSpot_Deal_createdAt" DEFAULT (CURRENT_TIMESTAMP),
    "updatedAt" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_HubSpot_Deal_updatedAt" DEFAULT (CURRENT_TIMESTAMP),
    "archived" BOOLEAN NOT NULL CONSTRAINT "DF_HubSpot_Deal_archived" DEFAULT FALSE,
    CONSTRAINT "PK_HubSpot_Deal" PRIMARY KEY ("dealId"),
    CONSTRAINT "FK_HubSpot_Deal_pipelineId" FOREIGN KEY ("pipelineId") REFERENCES "HubSpot"."Pipeline" ("pipelineId"),
    CONSTRAINT "FK_HubSpot_Deal_dealStageId" FOREIGN KEY ("dealStageId") REFERENCES "HubSpot"."DealStage" ("stageId"),
    CONSTRAINT "FK_HubSpot_Deal_ownerId" FOREIGN KEY ("ownerId") REFERENCES "HubSpot"."Owner" ("ownerId")
);
