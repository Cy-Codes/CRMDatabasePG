CREATE TABLE IF NOT EXISTS "HubSpot"."LineItem"
(
    "lineItemId" BIGINT NOT NULL,
    "dealId" BIGINT NOT NULL,
    "productId" BIGINT NULL,
    "name" VARCHAR(255) NOT NULL,
    "quantity" DECIMAL(12, 2) NOT NULL CONSTRAINT "DF_HubSpot_LineItem_quantity" DEFAULT TRUE,
    "price" NUMERIC(18, 2) NOT NULL,
    "amount" NUMERIC(18, 2) GENERATED ALWAYS AS (ROUND(("quantity" * "price")::NUMERIC, 2)) STORED)),
    "discount" DECIMAL(18, 2) NOT NULL CONSTRAINT "DF_HubSpot_LineItem_discount" DEFAULT (0.00),
    "createdAt" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_HubSpot_LineItem_createdAt" DEFAULT (CURRENT_TIMESTAMP),
    "updatedAt" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_HubSpot_LineItem_updatedAt" DEFAULT (CURRENT_TIMESTAMP),
    "archived" BOOLEAN NOT NULL CONSTRAINT "DF_HubSpot_LineItem_archived" DEFAULT FALSE,
    CONSTRAINT "PK_HubSpot_LineItem" PRIMARY KEY ("lineItemId"),
    CONSTRAINT "FK_HubSpot_LineItem_dealId" FOREIGN KEY ("dealId") REFERENCES "HubSpot"."Deal" ("dealId"),
    CONSTRAINT "FK_HubSpot_LineItem_productId" FOREIGN KEY ("productId") REFERENCES "HubSpot"."Product" ("productId")
);
