-- ============================================================================
-- Migration: V7__hubspot_contact_email_unique.sql
-- Description: Add unique constraint on HubSpot Contact email
-- ============================================================================

ALTER TABLE "HubSpot"."Contact"
ADD CONSTRAINT "UQ_HubSpot_Contact_email" UNIQUE ("email");
