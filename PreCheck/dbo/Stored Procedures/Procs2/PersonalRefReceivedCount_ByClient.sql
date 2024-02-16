-- =============================================
-- Author:		Prasanna
-- Create date: 4/16/2018
-- Description:	QReport to show the number of personal references records received by Client. 
-- Execution: [PersonalRefReceivedCount_ByClient] '11/01/2017','12/01/2017',13244
--			  [PersonalRefReceivedCount_ByClient] '01/01/2017','08/31/2017',12909
-- =============================================
CREATE PROCEDURE [dbo].[PersonalRefReceivedCount_ByClient] 
(
	-- Add the parameters for the stored procedure here
	@StartDate DATETIME,
	@EndDate DATETIME,
	@Clno INT
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   	SELECT	A.CLNO AS [Client #], count(A.CLNO) as [PersonalReference RecordCount]
	FROM dbo.PersRef AS P(NOLOCK)
	INNER JOIN Appl AS A(NOLOCK) ON P.APNO = A.APNO
	INNER JOIN Client AS C(NOLOCK) ON A.CLNO = C.CLNO
	--INNER JOIN SectStat AS S(NOLOCK) ON P.SectStat = S.CODE
	WHERE --P.SectStat  IN ('5','6','7','8') AND
	--P.IsOnReport = 1
	--AND P.IsHidden = 0 AND
	A.ApDate BETWEEN @StartDate AND DATEADD(S,-1,DATEADD(D,1,@EndDate))
	AND A.CLNO = IIF(@CLNO = 0,A.CLNO, @CLNO)
	group by  A.CLNO 

END
