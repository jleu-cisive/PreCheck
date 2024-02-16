-- =============================================
-- Author:		DEEPAK VODETHELA
-- Create Date: 02/09/2016
-- DescriptiON: To provide Empployment Audit Trail of the Investigator for a given date range
-- Execution : EXEC [dbo].[Empl_AuditReport]  'AJones ','03/28/2019','03/28/2019'
-- Modified on: 03/29/2019
-- Decription: Modified the logic to match the counts on two QReporte (Employment Audit Report & Verification Production Details with Work Number - Irrespec)
-- =============================================
CREATE PROCEDURE [dbo].[Empl_AuditReport_07232019] 
	-- Add the parameters for the stored procedure here
	@Userid varchar(50),
	@StartDate DateTime,
	@EndDate DateTime
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets FROM
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
	SELECT  distinct  v.SectStat as NewValue, (case when len(ltrim(rtrim(UserID))) <=8 then ltrim(rtrim(UserID)) else  SUBSTRING (ltrim(rtrim(UserID)) ,1 , len(ltrim(rtrim(UserID))) -5) end) + '(WKN)' as UserID,
			v.emplid as id, (CASE WHEN TableName = 'Empl.SectStat' THEN NewValue END) AS [Status], c.ChangeDate
		into #EmpltempChangeLogWN1
	FROM dbo.Changelog c (nolock)
	JOIN dbo.Integration_Verification_SourceCode i (nolock) ON c.id = i.sectionkeyid
	JOIN dbo.[Verification_RP_Logging_Empl] v (nolock) ON i.sectionkeyid = v.emplid
	WHERE (c.changedate between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate)) 
	  and i.refVerificationSource = 'WorkNumber' 
	  and i.DateTimStamp between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate)))
	  and (c.TableName = 'Empl.web_status' and (c.NewValue in (69))) 
	  AND @Userid = (case when len(ltrim(rtrim(UserID))) <=8 then ltrim(rtrim(UserID)) else  SUBSTRING (ltrim(rtrim(UserID)) ,1 , len(ltrim(rtrim(UserID))) -5) end)
	--SELECT * FROM #EmpltempChangeLogWN1

	SELECT  distinct c.NewValue, 
			(case when len(ltrim(rtrim(c.UserID))) <=8 then ltrim(rtrim(c.UserID)) else  SUBSTRING ( ltrim(rtrim(c.UserID)) ,1 , len(ltrim(rtrim(c.UserID))) -5) end) + '(WKN)' as UserID,
			i.sectionkeyid as id, (CASE WHEN TableName = 'Empl.SectStat' THEN NewValue END) AS [Status], c.ChangeDate
		into #EmpltempChangeLogWN2
	FROM dbo.Changelog c (nolock) 
	JOIN (
			SELECT  UserID, id, Max(changedate) as changedate
			FROM  dbo.Changelog (nolock)
			group by userid, id, TableName
			having (max(changedate) between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate)))
			and (TableName = 'Empl.sectstat')
	)c1 ON c.UserID = c1.UserId 
	   and c.id = c1.id 
	   and c.changedate = c1.changedate
	JOIN dbo.Integration_Verification_SourceCode i (nolock) ON c1.id = i.sectionkeyid
	WHERE (c1.changedate between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate)) 
	  and i.refVerificationSource = 'WorkNumber' 
	  and i.DateTimStamp between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate)))
	  and (c.TableName = 'Empl.sectstat') 
	  AND @Userid = (case when len(ltrim(rtrim(c.UserID))) <=8 then ltrim(rtrim(c.UserID)) else  SUBSTRING (ltrim(rtrim(c.UserID)) ,1 , len(ltrim(rtrim(c.UserID))) -5) end)

	--SELECT * FROM #EmpltempChangeLogWN2

	SELECT NewValue, UserID, ID 
		INTO #EmpltempChangeLog
	from (
		select NewValue, UserID, ID, [Status], ChangeDate from #EmpltempChangeLogWN1 where id not in (select id from #EmpltempChangeLogWN2)
		union
		select NewValue, UserID, ID, [Status], ChangeDate from #EmpltempChangeLogWN2
	)A

	--SELECT * FROM #EmpltempChangeLog

	SELECT  distinct  v.SectStat as NewValue, (case when len(ltrim(rtrim(UserID))) <=8 then ltrim(rtrim(UserID)) else  SUBSTRING ( ltrim(rtrim(UserID)) ,1 , len(ltrim(rtrim(UserID))) -5) end) as UserID,
			v.emplid as id, (CASE WHEN TableName = 'Empl.SectStat' THEN NewValue END) AS [Status], c.ChangeDate
		INTO #EmpltempChangeLogNOTWN1
	FROM  dbo.Changelog c  (nolock)
	JOIN  dbo.Integration_Verification_SourceCode i (nolock) ON c.id = i.sectionkeyid
	JOIN dbo.[Verification_RP_Logging_Empl] v (nolock) ON i.sectionkeyid = v.emplid
	WHERE (c.changedate between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate)) 
	  and i.refVerificationSource = 'WorkNumber'
	  and i.DateTimStamp between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate)))
	  and (c.TableName = 'Empl.web_status' and (c.NewValue in (69))) 
	  AND @Userid = (case when len(ltrim(rtrim(c.UserID))) <=8 then ltrim(rtrim(c.UserID)) else  SUBSTRING (ltrim(rtrim(c.UserID)) ,1 , len(ltrim(rtrim(c.UserID))) -5) end)

	  --SELECT * FROM #EmpltempChangeLogNOTWN1

	SELECT c.Newvalue,(case when len(ltrim(rtrim(c.UserID))) <=8 then ltrim(rtrim(c.UserID)) else  SUBSTRING ( ltrim(rtrim(c.UserID)) ,1 , len(ltrim(rtrim(c.UserID))) -5) end) as UserID,
			c.id, (CASE WHEN TableName = 'Empl.SectStat' THEN NewValue END) AS [Status], c.ChangeDate
		into #EmpltempChangeLogNOTWN2
	FROM dbo.ChangeLog c with (nolock)
	JOIN (
			SELECT UserID, id, Max(changedate) as changedate
			FROM  dbo.Changelog (nolock)
			group by userid, id, TableName
			having (max(changedate) between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate)))
			  and (TableName = 'Empl.sectstat')
			  AND @Userid = (case when len(ltrim(rtrim(UserID))) <=8 then ltrim(rtrim(UserID)) else  SUBSTRING (ltrim(rtrim(UserID)) ,1 , len(ltrim(rtrim(UserID))) -5) end)
	)c1 ON c.UserID = c1.UserId 
	   and c.id = c1.id 
	   and c.changedate = c1.changedate
	WHERE (c.TableName = 'Empl.SectStat') 
	  and c.UserID <> ''
	  and c.ChangeDate between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate))
	  AND @Userid = (case when len(ltrim(rtrim(c.UserID))) <=8 then ltrim(rtrim(c.UserID)) else  SUBSTRING (ltrim(rtrim(c.UserID)) ,1 , len(ltrim(rtrim(c.UserID))) -5) end)
	order by c.UserID

	--SELECT * FROM #EmpltempChangeLogNOTWN2

	insert into #EmpltempChangeLog
	SELECT NewValue, UserID, ID 
	from (
			select NewValue, UserID, ID, [Status], ChangeDate from #EmpltempChangeLogNOTWN1 where id not in (select id from #EmpltempChangeLogNOTWN2)
			union
			select NewValue, UserID, ID, [Status], ChangeDate from #EmpltempChangeLogNOTWN2
		)B

	--SELECT * FROM #EmpltempChangeLog

	select UserID 
		into #tempUsers1 
	from #EmpltempChangeLog 

	--SELECT * FROM #tempUsers1

	--STEP:2 Empl #tmp1
	Select ltrim(rtrim(investigator)) + '(WKN)' as Investigator, InvestigatorAssigned, web_Updated, sectstat, apno, emplid 
		into #Empltmp1
	From dbo.Empl with (nolock)
	Where ((InvestigatorAssigned>= @StartDate and InvestigatorAssigned< = dateadd(s,-1,dateadd(d,1,@EndDate)))
	   OR (Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))))
	  and emplid in (
					SELECT sectionkeyid
					FROM  dbo.Integration_Verification_SourceCode with (nolock)
					WHERE (DateTimStamp between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate)) 
					  and refVerificationSource = 'WorkNumber' 
					  and DateTimStamp between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate))
				   )
	)

	--SELECT * FROM #Empltmp1

	set IDENTITY_INSERT #Empltmp1 on
	insert into #Empltmp1(Investigator,InvestigatorAssigned,web_Updated,sectstat,apno,emplid )
	Select ltrim(rtrim(investigator)) as Investigator, InvestigatorAssigned,web_Updated,sectstat,apno,emplid 
	From dbo.Empl with (nolock)
	Where ((InvestigatorAssigned>= @StartDate 
	  and InvestigatorAssigned< = dateadd(s,-1,dateadd(d,1,@EndDate)))
		OR (Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))))
	order by Investigator asc

	--SELECT * FROM #Empltmp1

	select Investigator as UserID 
		into #tempUsers2 
	from #Empltmp1

	--SELECT * FROM #tempUsers2

	--STEP:3 Empl #tempChangeLog2
	SELECT distinct (case when len(ltrim(rtrim(UserID))) <=8 then ltrim(rtrim(UserID)) else  SUBSTRING ( ltrim(rtrim(UserID)) ,1 , len(ltrim(rtrim(UserID))) -5) end) + '(WKN)' as UserID,
			id, (CASE WHEN TableName = 'Empl.SectStat' THEN NewValue END) AS [Status], c.ChangeDate
		into #EmpltempChangeLog2
	FROM dbo.ChangeLog c(NOLOCK)
	where TableName =  'Empl.web_status'
	  and ChangeDate between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate))
	  AND @Userid = (case when len(ltrim(rtrim(UserID))) <=8 then ltrim(rtrim(UserID)) else  SUBSTRING (ltrim(rtrim(UserID)) ,1 , len(ltrim(rtrim(UserID))) -5) end)
	  and Newvalue <> 0 and UserID <> ''
	  and id in (
				SELECT sectionkeyid
				FROM dbo.Integration_Verification_SourceCode with (nolock)
				WHERE (DateTimStamp between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate)) 
				   and refVerificationSource = 'WorkNumber' 
				   and DateTimStamp between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate))			   
				   )
	)

	--SELECT * FROM #EmpltempChangeLog2

	insert into #EmpltempChangeLog2
	SELECT distinct (case when len(ltrim(rtrim(UserID))) <=8 then ltrim(rtrim(UserID)) else  SUBSTRING ( ltrim(rtrim(UserID)) ,1 , len(ltrim(rtrim(UserID))) -5) end) as UserID, 
			id, (CASE WHEN TableName = 'Empl.SectStat' THEN NewValue END) AS [Status], c.ChangeDate
	FROM dbo.ChangeLog c with (nolock)
	where TableName =  'Empl.web_status'
	  and ChangeDate between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate))
	  and Newvalue <> 0 and UserID <> ''
	  AND @Userid = (case when len(ltrim(rtrim(UserID))) <=8 then ltrim(rtrim(UserID)) else  SUBSTRING (ltrim(rtrim(UserID)) ,1 , len(ltrim(rtrim(UserID))) -5) end)
	order by UserID

	--SELECT * FROM #EmpltempChangeLog2

	select UserID 
		into #tempUsers3 
	from #EmpltempChangeLog2

	--SELECT * FROM #tempUsers3

	--STEP:4 Empl #tempChangeLog3
	SELECT    (case when len(ltrim(rtrim(UserID))) <=8 then ltrim(rtrim(UserID)) else  SUBSTRING ( ltrim(rtrim(UserID)) ,1 , len(ltrim(rtrim(UserID))) -5) end) + '(WKN)' as UserID,
			id , (CASE WHEN TableName = 'Empl.SectStat' THEN NewValue END) AS [Status], c.ChangeDate
		into #EmpltempChangeLog3
	FROM dbo.ChangeLog c with (nolock) 
	where UserID like '%-empl'
	  and ChangeDate between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate))
	  AND @Userid = (case when len(ltrim(rtrim(UserID))) <=8 then ltrim(rtrim(UserID)) else  SUBSTRING (ltrim(rtrim(UserID)) ,1 , len(ltrim(rtrim(UserID))) -5) end)
	  and UserID <> ''
	  and id in (
					SELECT sectionkeyid
					FROM dbo.Integration_Verification_SourceCode with (nolock)
					WHERE (DateTimStamp between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate)) 
					   and refVerificationSource = 'WorkNumber' 
					   and DateTimStamp between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate))				   
					   )
	)

	--SELECT * FROM #EmpltempChangeLog3
	
	Insert into #EmpltempChangeLog3
	SELECT (case when len(ltrim(rtrim(UserID))) <=8 then ltrim(rtrim(UserID)) else  SUBSTRING ( ltrim(rtrim(UserID)) ,1 , len(ltrim(rtrim(UserID))) -5) end) as UserID,
			id, (CASE WHEN TableName = 'Empl.SectStat' THEN NewValue END) AS [Status], c.ChangeDate
	FROM dbo.ChangeLog c with (nolock)
	where UserID like '%-empl'
	  and ChangeDate between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate))
	  AND @Userid = (case when len(ltrim(rtrim(UserID))) <=8 then ltrim(rtrim(UserID)) else  SUBSTRING (ltrim(rtrim(UserID)) ,1 , len(ltrim(rtrim(UserID))) -5) end)
	  and UserID <> ''
	order by UserID

	--SELECT * FROM #EmpltempChangeLog3

	select UserID 
		into #tempUsers4 
	from #EmpltempChangeLog3

	--SELECT * FROM #tempUsers4

	--STEP:5 Epml #tempChangeLog4
	Select  distinct id, UserID , [Status], ChangeDate
		into #EmpltempChangeLog4 
	From #EmpltempChangeLog3 

	--SELECT * FROM #EmpltempChangeLog4

	SELECT DISTINCT	E.APNO, E.Employer, e.Web_Status, l.UserID, l.id, l.[Status], l.ChangeDate
		INTO #tmpEmpls
	FROM #EmpltempChangeLog4 AS l
	INNER JOIN dbo.Empl e (NOLOCK) ON L.ID = E.EMPLID

	--SELECT * FROM #tmpEmpls

	DECLARE @tmpEmplsEffortsDetails table
	(
		APNO int,
		Employer nvarchar(100),
		Web_Status int,
		UserID nvarchar(15),
		Id int,
		[Status] varchar(10),
		ChangeDate datetime
	)

	;WITH Employment AS
	(
		SELECT T.APNO, T.Employer, T.Web_Status, T.UserID, T.id, T.Status, T.ChangeDate ,
			ROW_NUMBER() OVER (PARTITION BY T.id, T.UserID ORDER BY T.ChangeDate DESC) AS RowNumber
		FROM #tmpEmpls T
	 )
	INSERT INTO @tmpEmplsEffortsDetails
	SELECT T.APNO, T.Employer, T.Web_Status, T.UserID, T.id, T.[Status], T.ChangeDate
	FROM Employment T
	WHERE RowNumber = 1

	SELECT * FROM @tmpEmplsEffortsDetails

	
	DROP TABLE #EmpltempChangeLogWN1
	DROP TABLE #EmpltempChangeLogWN2
	DROP TABLE #EmpltempChangeLog
	DROP TABLE #EmpltempChangeLogNOTWN1
	DROP TABLE #EmpltempChangeLogNOTWN2
	DROP TABLE #Empltmp1
	DROP TABLE #EmpltempChangeLog2
	DROP TABLE #EmpltempChangeLog3
	DROP TABLE #EmpltempChangeLog4
	--drop table #tmpEmplChangeLog
	DROP TABLE #tmpEmpls
	--DROP table #tempUsers
	DROP TABLE #tempUsers1
	DROP TABLE #tempUsers2
	DROP TABLE #tempUsers3
	DROP TABLE #tempUsers4
	--DROP TABLE #tempUsers5


	
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