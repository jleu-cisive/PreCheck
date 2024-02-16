


-- ================================================
-- Date: 01/10/2014
-- Author: Radhika Dereddy
-- Description: Clear all the Staging Tables 
-- ================================================ 
CREATE PROCEDURE [dbo].[Billing_ClearStagingTables]
	
AS
SET NOCOUNT ON

TRUNCATE Table dbo.InvCreateInvoiceQueue

TRUNCATE Table dbo.Staging_InvMaster

TRUNCATE Table dbo.Staging_InvRegistrar

TRUNCATE Table dbo.Staging_InvRegistrarTotal

TRUNCATE TABLE dbo.Staging_CreateInvoiceMainPull
  
   


