-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 12/18/2020
-- Description:	Changing the inline query to a stored Procedure
-- EXEC [IRIS_Measurement_Report_By_APNO] '12/18/2020', '12/18/2020','ASanchez'
-- EXEC [IRIS_Measurement_Report_By_APNO] '12/18/2020', '12/18/2020',''
-- Modified By: Sahithi Gangaraju
-- Modified Date:1/27/2020
--Added "Clear Internal" status to the report
-- =============================================
CREATE PROCEDURE [dbo].[IRIS_Measurement_Report_By_APNO]
@StartDate datetime,
@EndDate datetime,
@Investigator varchar(8) = null
/*,
@Category varchar(20) =null,
@CategoryID int =0,
@CLNO int= 0,
@State varchar(20) =null,
@County varchar(50) =null,
@APNO int =0
*/
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


IF(@Investigator ='' OR @Investigator=null)
SET @Investigator =''

SELECT i.Investigator,
	 (SELECT ResultLogCategory FROM dbo.IRIS_ResultLogCategory with (nolock) WHERE ResultLogCategoryID = i.ResultLogCategoryID) AS Category,
	 CASE	WHEN i.Clear = 'T' THEN 'Clear'
			WHEN i.Clear = 'F' THEN 'Record Found'
			WHEN i.Clear = 'P' THEN 'Possible Record'
			WHEN i.Clear = 'Q' THEN 'Needs QA'
			WHEN i.Clear = 'I' THEN 'Needs Research'
			WHEN i.Clear = 'A' THEN 'Cancelled/Internal Error/Incomplete Results'
			--WHEN i.Clear = 'B' THEN 'Clear Internal'
			WHEN i.Clear = 'C' THEN 'Cancelled by Client/Incomplete Results'
			ELSE 'Ordered' END AS Status
	, COUNT(ResultLogID) AS RecordCount, 
	c.Apno as APNO, 
	c.county AS County,
    cc.state AS State, 
	i.LogDate 
FROM dbo.IRIS_ResultLog i with (NOLOCK) 
INNER JOIN Crim c with (nolock) on i.crimid =c.crimid
INNER JOIN counties cc with (nolock) on  c.cnty_no =cc.cnty_no
LEFT JOIN appl a with (nolock) on c.apno = a.apno
WHERE c.Clear IN ('T','F','Q','I','P','A','C') 
 AND i.LogDate >= @StartDate AND i.LogDate < DATEADD(day, 1,@EndDate)
 AND i.Investigator = IIF(@Investigator='',i.Investigator,@Investigator)
GROUP BY i.Investigator, i.ResultLogCategoryID, i.Clear, c.APNO, i.LogDate, c.county, cc.state
UNION ALL--- addedto include status 'B'- Clear Internal
	SELECT DISTINCT	cl.userid AS Investigator, 
			'OASIS' as Category, 
			CASE WHEN cl.newvalue = 'B' THEN 'Clear Internal' END AS Status,
			COUNT(cl.UserID) AS RecordCount,
	c.Apno as APNO, 
	c.county AS County,
    cc.state AS State, 
	cl.ChangeDate AS LogDate 
	FROM dbo.changelog AS cl (NOLOCK)
	INNER JOIN Crim c WITH (NOLOCK) ON CL.ID = c.crimid 
	INNER JOIN Counties cc WITH (NOLOCK) ON C.CNTY_NO = cc.CNTY_NO
	LEFT OUTER JOIN Appl a WITH (NOLOCK) ON A.APNO = c.APNO
	WHERE TableName = 'Crim.Clear' 
	  AND (cl.changedate>= @StartDate 
	  AND cl.changedate <= DATEADD(s,-1,dateadd(d, 1, @EndDate)))
	  AND cl.newvalue = 'B'	  
	  AND cl.UserID = IIF(@Investigator='',cl.UserID ,@Investigator)
	  --AND a.clno = IIF(@CLNO = 0,a.clno,@CLNO)
	 
 --AND i.LogDate >= @StartDate AND i.LogDate < DATEADD(day, 1,@EndDate)
 --AND i.Investigator = IIF(@Investigator='',i.Investigator,@Investigator)
	GROUP BY cl.userid, cl.newvalue,c.APNO,cl.ChangeDate,c.County,cc.State;
	
	--ORDER BY Investigator

END
