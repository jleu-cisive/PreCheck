-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 12/11/2020
-- Description:	VerificationProductionDetails_WithWorkNumber_EmploymentALLInvestigators for all investigators Qreport
-- EXEC [VerificationProductionDetails_WithWorkNumber_EmploymentALLInvestigators] '12/09/2020', '12/09/2020'
-- =============================================
CREATE PROCEDURE [dbo].[VerificationProductionDetails_WithWorkNumber_EmploymentALLInvestigators] 
	-- Add the parameters for the stored procedure here
@StartDate datetime,
@EndDate datetime

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON;

DROP TABLE IF EXISTS #tempInvestigators
DROP TABLE IF EXISTS #tempProductionDetails

CREATE TABLE #tempInvestigators
(
	Investigator varchar(8)
)

INSERT INTO #tempInvestigators
EXEC [Employment_Investigators] @StartDate, @EndDate

--Select * from #tempInvestigators

CREATE TABLE #tempProductionDetails
(
	UserID varchar(20),
	EmplEfforts int,
	DuplicateRecords int,
	WorkNumber int,
	DuplicateWorkNumber int,
	ALERT int,
	VERIFIED int,
	UNVERIFIED int,
	SEEATTACHED int,
	PENDING int,
	COMPLETE int
)

DECLARE @investigator VARCHAR(8)

DECLARE Batch_Cursor CURSOR FOR 
SELECT Investigator FROM #tempInvestigators

OPEN Batch_Cursor;
FETCH NEXT FROM Batch_Cursor INTO @investigator
WHILE @@FETCH_STATUS = 0
 BEGIN
	INSERT INTO #tempProductionDetails
    EXEC [dbo].[VerificationProductionDetails_WithWorkNumber_Employment] @StartDate, @EndDate, @investigator
	FETCH NEXT FROM Batch_Cursor INTO @investigator

END
CLOSE Batch_Cursor    
DEALLOCATE Batch_Cursor

SELECT * FROM #tempProductionDetails ORDER BY USERID asc


END
