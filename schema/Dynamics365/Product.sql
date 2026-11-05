CREATE TABLE IF NOT EXISTS "Dynamics365"."Product"
(
    "productid" UNIQUEIDENTIFIER NOT NULL CONSTRAINT "DF_Dynamics365_Product_productid" DEFAULT (gen_random_uuid()),
    "productnumber" VARCHAR(100) NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT NULL,
    "price" NUMERIC(18, 2) NULL,
    "standardcost" NUMERIC(18, 2) NULL,
    "currentcost" NUMERIC(18, 2) NULL,
    "quantityonhand" DECIMAL(12, 2) NOT NULL CONSTRAINT "DF_Dynamics365_Product_quantityonhand" DEFAULT (0.00),
    "statecode" INT NOT NULL CONSTRAINT "DF_Dynamics365_Product_statecode" DEFAULT FALSE,
    "statuscode" INT NOT NULL CONSTRAINT "DF_Dynamics365_Product_statuscode" DEFAULT TRUE,
    "createdon" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Dynamics365_Product_createdon" DEFAULT (CURRENT_TIMESTAMP),
    "createdby" UUID NOT NULL,
    "modifiedon" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Dynamics365_Product_modifiedon" DEFAULT (CURRENT_TIMESTAMP),
    "modifiedby" UUID NOT NULL,
    CONSTRAINT "PK_Dynamics365_Product" PRIMARY KEY ("productid"),
    CONSTRAINT "FK_Dynamics365_Product_createdby" FOREIGN KEY ("createdby") REFERENCES "Dynamics365"."SystemUser" ("systemuserid"),
    CONSTRAINT "FK_Dynamics365_Product_modifiedby" FOREIGN KEY ("modifiedby") REFERENCES "Dynamics365"."SystemUser" ("systemuserid")
);
