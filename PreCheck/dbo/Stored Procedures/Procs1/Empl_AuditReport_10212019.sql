-- =============================================
-- Author:		DEEPAK VODETHELA
-- Create Date: 02/09/2016
-- DescriptiON: To provide Empployment Audit Trail of the Investigator for a given date range
-- Execution : EXEC [dbo].[Empl_AuditReport]  'CValenzu','07/29/2019','07/29/2019'
-- Modified on: 03/29/2019
-- Decription: Modified the logic to match the counts on two QReporte (Employment Audit Report & Verification Production Details with Work Number - Irrespec)
-- Modified By:		DEEPAK VODETHELA
-- Modified Date: 02/09/2016
-- Description: Req#55786 - The report was not showing all the data points. Therefore I changed the logic to display all the audits per user.
-- =============================================
CREATE PROCEDURE [dbo].[Empl_AuditReport_10212019] 

	-- Add the parameters for the stored procedure here
	@Userid varchar(50),
	@StartDate DateTime,
	@EndDate DateTime
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets FROM
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	--STEP:1 Empl #tempChangeLog3
	SELECT DISTINCT  (case when len(ltrim(rtrim(UserID))) <=8 then ltrim(rtrim(UserID)) else  SUBSTRING ( ltrim(rtrim(UserID)) ,1 , len(ltrim(rtrim(UserID))) -5) end) + '(WKN)' as UserID,
			id , (CASE WHEN TableName = 'Empl.SectStat' THEN NewValue END) AS [Status], c.ChangeDate
		into #EmpltempChangeLog3
	FROM dbo.ChangeLog c with (nolock) 
	where TableName like '%Empl%'
	  and ChangeDate between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate))
	  and [UserId] like @UserId + '%'	  
	  and id in (
					SELECT sectionkeyid
					FROM dbo.Integration_Verification_SourceCode with (nolock)
					WHERE (DateTimStamp between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate)) 
					   and refVerificationSource = 'WorkNumber' 
					   and DateTimStamp between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate))				   
					   )
	)

	--SELECT * FROM #EmpltempChangeLog3  c where C.ID = 6277571
	
	Insert into #EmpltempChangeLog3
	SELECT DISTINCT (case when len(ltrim(rtrim(UserID))) <=8 then ltrim(rtrim(UserID)) else  SUBSTRING ( ltrim(rtrim(UserID)) ,1 , len(ltrim(rtrim(UserID))) -5) end) as UserID,
			id, (CASE WHEN TableName = 'Empl.SectStat' THEN NewValue END) AS [Status], c.ChangeDate
	FROM dbo.ChangeLog c with (nolock)
	where TableName like '%Empl%'
	  and ChangeDate between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate))
	   and [UserId] like @UserId + '%'	  	
	order by UserID

	--SELECT * FROM #EmpltempChangeLog3  c where C.ID = 6277571

	select DISTINCT UserID 
		into #tempUsers4 
	from #EmpltempChangeLog3

	--SELECT * FROM #tempUsers4  c 

	--STEP:5 Epml #tempChangeLog4
	Select  DISTINCT id, UserID , [Status], ChangeDate
		into #EmpltempChangeLog4 
	From #EmpltempChangeLog3 

	--SELECT * FROM #EmpltempChangeLog4  c where C.ID = 6277571

	SELECT DISTINCT	E.APNO, E.Employer, e.Web_Status, l.UserID, l.id, l.[Status], l.ChangeDate
		INTO #tmpEmpls
	FROM #EmpltempChangeLog4 AS l
	INNER JOIN dbo.Empl e (NOLOCK) ON L.ID = E.EMPLID

	--SELECT * FROM #tmpEmpls c where C.ID = 6277571

	DECLARE @tmpEmplsEffortsDetails table
	(
		APNO int,
		Employer nvarchar(100),
		Web_Status varchar(50),
		UserID nvarchar(15),
		Id int,
		[Status] varchar(50),
		ChangeDate datetime
	)

	;WITH Employment AS
	(
		SELECT T.APNO, T.Employer, T.Web_Status, T.UserID, T.id, T.Status, T.ChangeDate ,
			ROW_NUMBER() OVER (PARTITION BY T.id ORDER BY T.ChangeDate DESC) AS RowNumber
		FROM #tmpEmpls T
	 )
	INSERT INTO @tmpEmplsEffortsDetails
	SELECT T.APNO, T.Employer, w.description, T.UserID, T.id, S.Description, T.ChangeDate
	FROM Employment T 
	LEFT OUTER JOIN dbo.SectStat s on T.Status = s.Code
	LEFT OUTER JOIN dbo.Websectstat w on T.web_status = w.code
	WHERE RowNumber = 1

	SELECT * FROM @tmpEmplsEffortsDetails E ORDER BY 1 DESC --where e.APNO = 4720227

	DROP TABLE IF EXISTS #EmpltempChangeLog3
	DROP TABLE IF EXISTS #EmpltempChangeLog4
	DROP TABLE IF EXISTS #tmpEmpls
	DROP TABLE IF EXISTS #tempUsers4


	
	/* -- VD: Modified the logoc to match the counts on two QReporte (Employment Audit Report & Verification Production Details with Work Number - Irrespec)
	SELECT * INTO #tmp FROM 
	(
		SELECT DISTINCT e.Apno, e.Employer, l.TableName, l.NewValue, l.ChangeDate,l.UserID 
		FROM changelog l WITH (NOLOCK) 
		INNER JOIN Empl E ON E.EmplID = l.ID 
		WHERE (Tablename LIKE 'Empl.web_status%'
		   OR Tablename LIKE 'Empl.SectStat%')
	) AS t

		/*Select the resultset and apply filter*/
		--SELECT Apno, Employer, (CASE WHEN TableName = 'Empl.web_status' THEN NewValue END) WebStatus, (CASE WHEN TableName = 'Empl.SectStat' THEN NewValue END) [Status], ChangeDate 
		--FROM #tmp 
		--WHERE CASE WHEN CHARINDEX('-',Userid) > 0 THEN LEFT(Userid,CHARINDEX('-',Userid)-1) ELSE Userid END = @Userid
		--  AND ChangeDate BETWEEN @StartDate AND DATEADD(S,-1,DATEADD(D,1,@EndDate))
		--ORDER BY Employer, ChangeDate

		SELECT MAX(Apno) AS Apno, Employer, MIN((CASE WHEN TableName = 'Empl.web_status' THEN NewValue END)) WebStatus, MIN((CASE WHEN TableName = 'Empl.SectStat' THEN NewValue END)) [Status], MAX(ChangeDate) AS ChangeDate
		FROM #tmp 
		WHERE CASE WHEN CHARINDEX('-',Userid) > 0 THEN LEFT(Userid,CHARINDEX('-',Userid)-1) ELSE Userid END = @Userid
		  AND ChangeDate BETWEEN @StartDate AND DATEADD(S,-1,DATEADD(D,1,@EndDate))
		GROUP BY Employer
		ORDER BY Employer, ChangeDate

	-- Drop Table
	DROP TABLE #tmp
	*/
END