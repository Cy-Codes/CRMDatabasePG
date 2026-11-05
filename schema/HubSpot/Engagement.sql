CREATE TABLE IF NOT EXISTS "HubSpot"."Engagement"
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
    CONSTRAINT "PK_HubSpot_Engagement" PRIMARY KEY ("engagementId"),
    CONSTRAINT "FK_HubSpot_Engagement_ownerId" FOREIGN KEY ("ownerId") REFERENCES "HubSpot"."Owner" ("ownerId")
);
