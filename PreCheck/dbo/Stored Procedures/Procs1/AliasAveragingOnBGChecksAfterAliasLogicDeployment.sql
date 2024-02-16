
-- =============================================
-- Author:	DEEPAK VODETHELA
-- Create date: 10/05/2017
-- Description:	Count the number of Aliases for a given date range
-- Execution: EXEC [dbo].[AliasAveragingOnBGChecksAfterAliasLogicDeployment]  '04/07/2017','07/29/2017'
-- =============================================
CREATE PROCEDURE [dbo].[AliasAveragingOnBGChecksAfterAliasLogicDeployment] 
(
	-- Add the parameters for the stored procedure here
	 @StartDate DateTime,
	 @EndDate DateTime
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	SELECT  A.APNO, 
			COUNT(ApplAliasID) OVER (PARTITION BY AA.APNO) AS AliasCount_With_Primary, 
			((COUNT(ApplAliasID) OVER (PARTITION BY AA.APNO))-1) AS AliasCount_Without_Primary,
			IsPublicRecordQualified,
			A.Investigator
		INTO #tmpApplAlias
	FROM ApplAlias AS AA(NOLOCK)
	INNER JOIN Appl AS A(NOLOCK) ON AA.APNO = A.APNO
	WHERE A.ApDate BETWEEN @StartDate AND DATEADD(S,-1,DATEADD(D,1,@EndDate))
	  AND AA.IsActive = 1

	--SELECT * FROM #tmpApplAlias ORDER BY APNO
	
	SELECT APNO, AliasCount_With_Primary, AliasCount_Without_Primary,SUM(CAST(ISNULL(IsPublicRecordQualified,0) AS INT)) AS PublicRecordQualified, Investigator
	FROM #tmpApplAlias
	GROUP BY APNO, AliasCount_With_Primary, AliasCount_Without_Primary, Investigator

	DROP TABLE #tmpApplAlias
END
