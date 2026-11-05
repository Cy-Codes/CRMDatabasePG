-- ============================================================================
-- Script: 00_cleanup_all_data.sql
-- Description: Truncates all CRM tables across Salesforce, HubSpot, and Dynamics 365.
-- ============================================================================

CALL "public"."sp_CleanupAllCRMData"();
