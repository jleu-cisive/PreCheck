


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[StateBoardDisciplinaryRun_Select]
	-- Add the parameters for the stored procedure here
(
@ReviewMode int
)
AS	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
    -- Insert statements for procedure here
	IF @ReviewMode = 1
	BEGIN 
		SELECT DISTINCT SourceName, SourceState,Abbreviation, VerificationURL, BoardOrderInstructions, ReportDate, BatchDate, NextRunDate, Frequency, VerificationPhone, StartedDate, CompletedDate, UserA, DateStartedA, DateCompletedA, UserB, DateStartedB, DateCompletedB, dbo.VWLicenseAuthority.StateBoardSourceID, StateBoardDisciplinaryRunID 
		FROM dbo.VWLicenseAuthority INNER JOIN dbo.StateBoardDisciplinaryRun  ON dbo.VWLicenseAuthority.StateBoardSourceID = dbo.StateBoardDisciplinaryRun.StateBoardSourceID 
		WHERE (dbo.StateBoardDisciplinaryRun.DateCompletedA IS NOT NULL) AND (dbo.StateBoardDisciplinaryRun.DateCompletedB IS NOT NULL) AND (dbo.StateBoardDisciplinaryRun.CompletedDate IS NULL) ORDER BY dbo.VWLicenseAuthority.SourceName
	END 
	ELSE
		SELECT DISTINCT SourceName, SourceState,Abbreviation, VerificationURL, BoardOrderInstructions, ReportDate, BatchDate, NextRunDate, Frequency, VerificationPhone, StartedDate, CompletedDate, UserA, DateStartedA, DateCompletedA,  UserB, DateStartedB, DateCompletedB, dbo.VWLicenseAuthority.StateBoardSourceID, StateBoardDisciplinaryRunID
		FROM dbo.VWLicenseAuthority LEFT JOIN dbo.StateBoardDisciplinaryRun  
		ON dbo.VWLicenseAuthority.StateBoardSourceID = dbo.StateBoardDisciplinaryRun.StateBoardSourceID WHERE ((dbo.StateBoardDisciplinaryRun.DateCompletedA IS NULL) OR (dbo.StateBoardDisciplinaryRun.DateCompletedB IS NULL)) 
		ORDER BY dbo.VWLicenseAuthority.SourceName
	
	SET NOCOUNT OFF
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED


--==================================================================

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
