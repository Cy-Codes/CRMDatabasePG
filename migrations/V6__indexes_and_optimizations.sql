-- ============================================================================
-- Migration: V6__indexes_and_optimizations.sql
-- Description: Performance and foreign-key indexing across all CRM schemas
-- ============================================================================

-- Salesforce Indexes
CREATE INDEX IF NOT EXISTS idx_sf_acc_owner ON "Salesforce"."Account"("OwnerId");
CREATE INDEX IF NOT EXISTS idx_sf_con_account ON "Salesforce"."Contact"("AccountId");
CREATE INDEX IF NOT EXISTS idx_sf_opp_account ON "Salesforce"."Opportunity"("AccountId");
CREATE INDEX IF NOT EXISTS idx_sf_opp_stage ON "Salesforce"."Opportunity"("StageName");
CREATE INDEX IF NOT EXISTS idx_sf_oppline_opp ON "Salesforce"."OpportunityLineItem"("OpportunityId");
CREATE INDEX IF NOT EXISTS idx_sf_oppline_pbe ON "Salesforce"."OpportunityLineItem"("PricebookEntryId");
CREATE INDEX IF NOT EXISTS idx_sf_case_acc ON "Salesforce"."Case"("AccountId");
CREATE INDEX IF NOT EXISTS idx_sf_case_con ON "Salesforce"."Case"("ContactId");
CREATE INDEX IF NOT EXISTS idx_sf_task_who ON "Salesforce"."Task"("WhoId");
CREATE INDEX IF NOT EXISTS idx_sf_task_what ON "Salesforce"."Task"("WhatId");
CREATE INDEX IF NOT EXISTS idx_sf_event_who ON "Salesforce"."Event"("WhoId");
CREATE INDEX IF NOT EXISTS idx_sf_event_what ON "Salesforce"."Event"("WhatId");

-- HubSpot Indexes
CREATE INDEX IF NOT EXISTS idx_hs_comp_owner ON "HubSpot"."Company"("ownerId");
CREATE INDEX IF NOT EXISTS idx_hs_con_comp ON "HubSpot"."Contact"("associatedcompanyid");
CREATE INDEX IF NOT EXISTS idx_hs_con_owner ON "HubSpot"."Contact"("ownerId");
CREATE INDEX IF NOT EXISTS idx_hs_deal_pipeline ON "HubSpot"."Deal"("pipeline", "dealstage");
CREATE INDEX IF NOT EXISTS idx_hs_lineitem_deal ON "HubSpot"."LineItem"("dealId");
CREATE INDEX IF NOT EXISTS idx_hs_ticket_pipeline ON "HubSpot"."Ticket"("pipeline", "hs_pipeline_stage");
CREATE INDEX IF NOT EXISTS idx_hs_assoc_from_to ON "HubSpot"."ObjectAssociation"("fromObjectId", "fromObjectType", "toObjectId", "toObjectType");

-- Dynamics 365 Indexes
CREATE INDEX IF NOT EXISTS idx_d365_acc_parent ON "Dynamics365"."Account"("parentaccountid");
CREATE INDEX IF NOT EXISTS idx_d365_acc_owner ON "Dynamics365"."Account"("ownerid");
CREATE INDEX IF NOT EXISTS idx_d365_con_parent ON "Dynamics365"."Contact"("parentcustomerid");
CREATE INDEX IF NOT EXISTS idx_d365_opp_parent ON "Dynamics365"."Opportunity"("parentaccountid", "parentcontactid");
CREATE INDEX IF NOT EXISTS idx_d365_oppprod_opp ON "Dynamics365"."OpportunityProduct"("opportunityid");
CREATE INDEX IF NOT EXISTS idx_d365_inc_customer ON "Dynamics365"."Incident"("customerid");
CREATE INDEX IF NOT EXISTS idx_d365_act_regarding ON "Dynamics365"."ActivityPointer"("regardingobjectid");
