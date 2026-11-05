CREATE TABLE IF NOT EXISTS "Dynamics365"."OpportunityProduct"
(
    "opportunityproductid" UNIQUEIDENTIFIER NOT NULL CONSTRAINT "DF_Dynamics365_OpportunityProduct_opportunityproductid" DEFAULT (gen_random_uuid()),
    "opportunityid" UUID NOT NULL,
    "productid" UUID NULL,
    "productdescription" VARCHAR(500) NULL,
    "priceperunit" NUMERIC(18, 2) NOT NULL,
    "quantity" DECIMAL(12, 2) NOT NULL CONSTRAINT "DF_Dynamics365_OpportunityProduct_quantity" DEFAULT (1.00),
    "extendedamount" NUMERIC(18, 2) GENERATED ALWAYS AS (ROUND(("quantity" * "priceperunit")::NUMERIC, 2)) STORED)),
    "manualdiscountamount" DECIMAL(18, 2) NOT NULL CONSTRAINT "DF_Dynamics365_OpportunityProduct_manualdiscountamount" DEFAULT (0.00),
    "createdon" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Dynamics365_OpportunityProduct_createdon" DEFAULT (CURRENT_TIMESTAMP),
    "createdby" UUID NOT NULL,
    "modifiedon" TIMESTAMPTZ NOT NULL CONSTRAINT "DF_Dynamics365_OpportunityProduct_modifiedon" DEFAULT (CURRENT_TIMESTAMP),
    "modifiedby" UUID NOT NULL,
    CONSTRAINT "PK_Dynamics365_OpportunityProduct" PRIMARY KEY ("opportunityproductid"),
    CONSTRAINT "FK_Dynamics365_OpportunityProduct_opportunityid" FOREIGN KEY ("opportunityid") REFERENCES "Dynamics365"."Opportunity" ("opportunityid"),
    CONSTRAINT "FK_Dynamics365_OpportunityProduct_productid" FOREIGN KEY ("productid") REFERENCES "Dynamics365"."Product" ("productid"),
    CONSTRAINT "FK_Dynamics365_OpportunityProduct_createdby" FOREIGN KEY ("createdby") REFERENCES "Dynamics365"."SystemUser" ("systemuserid"),
    CONSTRAINT "FK_Dynamics365_OpportunityProduct_modifiedby" FOREIGN KEY ("modifiedby") REFERENCES "Dynamics365"."SystemUser" ("systemuserid")
);
