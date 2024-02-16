-- ===========================================================
-- Author:		Prasanna
-- Create date: 05/08/2018
-- Description:	Pulls reports with Entry method using daterange
-- =============================================================
CREATE PROCEDURE [dbo].[ReportsWithEnteredVia]  
   @StartDate datetime,
   @EndDate datetime
AS
BEGIN

	select clno as CLNO, apno as [Report Number], EnteredVia as [Entry Method], [First] AS [First Name], Middle AS [Middle Name], [Last] AS [Last Name] from Appl 
	where (apdate >=@StartDate and apdate <= @EndDate)

END
