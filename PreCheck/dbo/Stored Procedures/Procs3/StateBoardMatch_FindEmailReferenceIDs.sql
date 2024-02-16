



CREATE PROCEDURE [dbo].[StateBoardMatch_FindEmailReferenceIDs]
(
	--these are additional filters
	@FilterEmailAddress varchar(200)=null,
	@FilterClientID int=null,
	@FilterFacilityID int=null,
	@FilterDepartmentID int=null,
	@FilterActionDateFrom datetime=null,
	@FilterActionDateTo datetime=null,
	@FilterEmailSentDateFrom datetime=null,
	@FilterEmailSentDateTo datetime=null
)
AS
--=====================Tester=================
/*
DECLARE @FilterEmailAddress varchar(200)
DECLARE	@FilterClientID int
DECLARE	@FilterFacilityID int
DECLARE	@FilterDepartmentID int
DECLARE	@FilterActionDateFrom datetime
DECLARE	@FilterActionDateTo datetime
DECLARE	@FilterEmailSentDateFrom datetime
DECLARE	@FilterEmailSentDateTo datetime

SET @FilterEmailAddress=NULL
SET	@FilterClientID=NULL
SET	@FilterFacilityID=NULL
SET	@FilterDepartmentID=NULL
SET	@FilterActionDateFrom='1999-1-1'
SET	@FilterActionDateTo='2000-10-9'
SET	@FilterEmailSentDateFrom='1900-1-1' 
SET	@FilterEmailSentDateTo='3000-12-29'
*/
--=====================================

SELECT DISTINCT SBEA.EmailReferenceID
FROM dbo.StateBoardMatch AS SBM 
	INNER JOIN dbo.StateBoardFinalData SBFD ON SBM.StateBoardDataID=SBFD.StateBoardFinalDataID
	INNER JOIN dbo.StateBoardEmailBatch AS SBEB ON SBM.StateBoardMatchID = SBEB.StateBoardMatchID 
	INNER JOIN dbo.StateBoardEmailActivities AS SBEA ON SBEB.StateBoardEmailBatchID = SBEA.EmailBatchID
WHERE  (SBM.MatchingIsAMatch=1) 
	AND (@FilterActionDateFrom IS NULL OR SBFD.ActionDate>=@FilterActionDateFrom) 
	AND (@FilterActionDateTo IS NULL OR SBFD.ActionDate<=@FilterActionDateTo) 
	AND (@FilterEmailSentDateFrom IS NULL OR SBEA.EmailDateTime>=@FilterEmailSentDateFrom) 
	AND (@FilterEmailSentDateTo IS NULL OR SBEA.EmailDateTime<=@FilterEmailSentDateTo) 
	AND (@FilterEmailAddress IS NULL OR PATINDEX('%'+@FilterEmailAddress+'%', SBEA.ClientEmail)>0)
	AND (@FilterClientID IS NULL OR SBEA.ClientID=@FilterClientID)
	AND (@FilterFacilityID IS NULL OR SBEA.FacilityID=@FilterFacilityID)
	AND (@FilterDepartmentID IS NULL OR SBEA.DepartmentID=@FilterDepartmentID)




















