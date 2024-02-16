-- =============================================
-- Author:		Prasanna
-- Create date: 03/05/2021
-- Description:	QReport for the student profile - To Check the Opt-Ins & Out (HDT#85327)
-- EXEC StudentCheckOptInsAndOuts '02/26/2021','03/05/2021'
-- =============================================
CREATE PROCEDURE [dbo].[StudentCheckOptInsAndOuts]
	@StartDate datetime,
	@EndDate datetime
AS
BEGIN

	SELECT count(IsEnrollForEmployment) AS TotalApplicant,SUM(CASE WHEN IsEnrollForEmployment = 'True' THEN 1 ELSE 0 END) AS OptIns, 
	SUM(CASE WHEN IsEnrollForEmployment = 'False' THEN 1 ELSE 0 END) AS OptOuts
	FROM [Enterprise].[Profile].[User] (NOLOCK) 
	WHERE CREATEDATE between @StartDate and @EndDate + 1
	--and Ishealthcareenrolled is not null 

END