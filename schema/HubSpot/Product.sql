CREATE TABLE IF NOT EXISTS "HubSpot"."Product"
(
    "productId" BIGINT NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "sku" VARCHAR(100) NULL,
    "description" TEXT NULL,
    "price" NUMERIC(18, 2) NOT NULL,
    "cost" NUMERIC(18, 2) NULL,
    "recurringBillingFrequency" VARCHAR(50) NULL,
    "createdAt" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_HubSpot_Product_createdAt" DEFAULT (CURRENT_TIMESTAMP),
    "updatedAt" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_HubSpot_Product_updatedAt" DEFAULT (CURRENT_TIMESTAMP),
    "archived" BOOLEAN NOT NULL CONSTRAINT "DF_HubSpot_Product_archived" DEFAULT FALSE,
    CONSTRAINT "PK_HubSpot_Product" PRIMARY KEY ("productId")
);
