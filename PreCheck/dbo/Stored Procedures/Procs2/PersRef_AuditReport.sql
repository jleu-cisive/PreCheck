-- ===========================================================================
-- Author:		Prasanna
-- Create Date: 10/03/2018
-- DescriptiON: To provide PersReference Audit Trail of the Investigator for a given date range
-- Execution : EXEC [dbo].[PersRef_AuditReport]  'CPage','08/16/2018','10/03/2018'
-- ===========================================================================
CREATE PROCEDURE [dbo].[PersRef_AuditReport] 
	-- Add the parameters for the stored procedure here
	@Userid varchar(50),
	@StartDate DateTime,
	@EndDate DateTime
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets FROM
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT * INTO #tmp FROM 
	(
		SELECT DISTINCT p.APNO,  p.Name, p.Phone, p.Pub_Notes, l.TableName, l.NewValue, l.ChangeDate,l.UserID 
		FROM changelog l WITH (NOLOCK) 
		INNER JOIN PersRef p ON p.PersRefID = l.ID
		WHERE (Tablename LIKE 'PersRef.web_status%'
		   OR Tablename LIKE 'PersRef.SectStat%')
	) AS t


	SELECT Apno, Name, Phone, Pub_Notes, MIN((CASE WHEN TableName = 'PersRef.web_status' THEN NewValue END)) WebStatus, MIN((CASE WHEN TableName = 'PersRef.SectStat' THEN NewValue END)) [Status],UserID, MAX(ChangeDate) AS ChangeDate
	FROM #tmp 
	WHERE CASE WHEN CHARINDEX('-',Userid) > 0 THEN LEFT(Userid,CHARINDEX('-',Userid)-1) ELSE Userid END = IIF(@Userid ='',UserID, @Userid)--@Userid IIF(@AffiliateID = 0,RA.AffiliateID, @AffiliateID)
	AND ChangeDate BETWEEN @StartDate AND DATEADD(S,-1,DATEADD(D,1,@EndDate))
	GROUP BY Apno, Name, Phone, Pub_Notes, UserID
	ORDER BY Apno, ChangeDate

	DROP TABLE #tmp
END