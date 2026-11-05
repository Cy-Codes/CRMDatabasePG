CREATE TABLE IF NOT EXISTS "HubSpot"."Ticket"
(
    "ticketId" BIGINT NOT NULL,
    "subject" VARCHAR(255) NOT NULL,
    "content" TEXT NULL,
    "pipelineId" VARCHAR(50) NOT NULL,
    "ticketStatusStageId" VARCHAR(50) NOT NULL,
    "priority" VARCHAR(20) NOT NULL CONSTRAINT "DF_HubSpot_Ticket_priority" DEFAULT (N'MEDIUM'),
    "ownerId" BIGINT NULL,
    "createdAt" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_HubSpot_Ticket_createdAt" DEFAULT (CURRENT_TIMESTAMP),
    "updatedAt" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_HubSpot_Ticket_updatedAt" DEFAULT (CURRENT_TIMESTAMP),
    "archived" BOOLEAN NOT NULL CONSTRAINT "DF_HubSpot_Ticket_archived" DEFAULT FALSE,
    CONSTRAINT "PK_HubSpot_Ticket" PRIMARY KEY ("ticketId"),
    CONSTRAINT "FK_HubSpot_Ticket_pipelineId" FOREIGN KEY ("pipelineId") REFERENCES "HubSpot"."Pipeline" ("pipelineId"),
    CONSTRAINT "FK_HubSpot_Ticket_ownerId" FOREIGN KEY ("ownerId") REFERENCES "HubSpot"."Owner" ("ownerId")
);
