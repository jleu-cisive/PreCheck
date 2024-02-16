CREATE Procedure [dbo].[HCA_Audit_Reports_Deepak] @ExcludeParallon bit = 1 ,@Month int = 12,@Year int = NULL,@currentMonth BIT = 1
AS
BEGIN
--[HCA_Audit_Reports_Deepak] 1,11
--[HCA_Audit_Reports_Deepak] 1,12,2019,1
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	--CREATE TABLE #Report (CLNO INT,Name Varchar(100),APNO INT,DeptCode varchar(50),ClientAPNO varchar(100),APDATE DateTime,CompDate DateTime,OrigCompDate DateTime,ReOpenDate DateTime,ReOpenedBy varchar(20), ApStatus varchar(1),
	--					  Division varchar(100),clientfacilitygroup varchar(100),facilitynum varchar(50),FacilityName varchar(500),IsOneHR Bit,No_of_Days_Complete Int)

	CREATE TABLE #Report (CLNO INT,Name Varchar(100), Affiliate varchar(100), Division varchar(100),
								clientfacilitygroup varchar(100),facilitynum varchar(50),FacilityName varchar(500),ClientAPNO varchar(100),IsOneHR Bit,
								--[ContactName] varchar(100),
								[ApplicantLast] varchar(50), [ApplicantFirst] varchar(50),CAM varchar(20),
								APNO INT, SSN varchar(11), ReportingMonth varchar(20),APDATE DateTime,OrigCompDate DateTime,CompDate DateTime,
								ReOpenDate DateTime,ReOpenedBy varchar(20),ApStatus varchar(1),submittedVia varchar(20),SelectedPackage varchar(100),
								DeptCode varchar(50),No_of_Days_Complete Int, ClientCertUpdated DateTime, ReleaseDate DateTime)

	CREATE TABLE #tmpDates(
		[ReleaseFormID] [int] NOT NULL,
		[SSN] [varchar](15) NULL,
		[ReleaseDate] [datetime] NULL,
		[CLNO] [int] NOT NULL)

	CREATE CLUSTERED INDEX IX_tmpDates_100 ON #tmpDates(ReleaseFormID)

	declare @Total float,@DaysGrouped Int
	Set @DaysGrouped = 35
	
	IF @currentMonth = 1
		BEGIN
			print 'This month'
			if @Month is NULL
					Set @Month = month(current_timestamp) --Set Current Month

			if @Year is null
					Set @Year = year(current_timestamp)
		END
	ELSE
		BEGIN
			print 'Null month'
			if @Month is NULL
					Set @Month = month(dateadd(m,-1,current_timestamp)) --Set Previous Month

			if @Year is null
				If @Month = 12 --adjust the year to the previous year in the month of January
					Set @Year = year(current_timestamp)-1
				else 
					Set @Year = year(current_timestamp)
		END

	Declare @MonthName varchar(20)
	Set @MonthName = DateName( month , DateAdd( month , @Month , 0 ) - 1 )

	SELECT @Month [Month], @Year [Year], @DaysGrouped [DaysGrouped]

	--;WITH tmpReleaseDates AS
	--(
	--SELECT rf.ReleaseFormID, rf.SSN, rf.[DATE], rf.CLNO,
	--		ROW_NUMBER() OVER (PARTITION BY rf.SSN ORDER BY rf.ReleaseFormID DESC) AS RowNumber
	--FROM ReleaseForm rf (NOLOCK)
	--WHERE YEAR(rf.[date]) = @Year
	-- AND MONTH(rf.[date])<= @Month  
	--)
	--INSERT INTO #tmpDates
	--SELECT T.ReleaseFormID, T.SSN, T.[DATE], T.CLNO FROM tmpReleaseDates AS T 
	--WHERE T.RowNumber = 1

	--SELECT * FROM #tmpDates

	IF @ExcludeParallon =1
	BEGIN
		--Insert into #Report
		--SELECT distinct  t.clno,replace([name],',',' ') [Name],apno,deptcode,clientapno,apdate,compDate,OrigCompDate,ReOpenDate,null,
		--apstatus,isnull(division,'') division,Isnull(clientfacilitygroup,'') clientfacilitygroup,facilitynum,replace(FacilityName,',',' ') FacilityName,Isnull(IsOneHR,0) IsOneHR,
		--dbo.elapsedbusinessdays_2(apdate,OrigcompDate)  AS No_of_Days_Complete  
		--from dbo.client t (NOLOCK)
		--left join dbo.appl a (nolock) on t.clno = a.clno		
		--LEFT JOIN HEVN.dbo.Facility F (nolock) ON isnull(deptcode,0) = facilitynum and parentemployerid = 7519 
		--										  and facilityclno is not null --added by schapyala on 12/11/2018 to remove duplicate reports caused by duplicate mapping
		--WHERE (t.affiliateid in (4)) 
		--AND year(a.OrigCompDate) = @Year
		--AND month(a.OrigCompDate)<= @Month  --added to make sure YTD is adjusted to the specific month in question - 07/29/2015
		--AND isnull(clientfacilitygroup,'') not in ('PARALLON BUSINESS SOLUTIONS')
		--AND apstatus in ('W','F') 
		--AND A.CLNO NOT IN (11764,11722,11724,12026,12174,11123,12226,12027,11725,12028,11723,9806,12217,11765,11721,11766,12029,12235)

		Insert into #Report
		SELECT distinct  t.clno,replace([name],',',' ') [Name], ra.Affiliate, isnull(division,'') division,
						Isnull(clientfacilitygroup,'') clientfacilitygroup,facilitynum,replace(FacilityName,',',' ') FacilityName,clientapno,Isnull(IsOneHR,0) IsOneHR,
						--(isnull(cc.LastName,'') + ' ' + isnull(cc.MiddleName,'') + ' ' + isnull(cc.FirstName,'')) AS [ContactName],
						a.[Last], a.[First], a.UserID, a.APNO, a.SSN,
						FORMAT(a.OrigCompDate, 'MMMM', 'en-US') AS ReportingMonth,
						--MONTH(a.ApDate) AS ReportingMonth, 
						a.ApDate,OrigCompDate,compDate,
						ReOpenDate,null,apstatus,a.EnteredVia,pm.PackageDesc,
						deptcode,dbo.elapsedbusinessdays_2(apdate,OrigcompDate)  AS No_of_Days_Complete ,
						cc.ClientCertUpdated, '' AS ReleaseDate
		from dbo.client t (NOLOCK)
		left join dbo.appl a (nolock) on t.clno = a.clno		
		LEFT JOIN HEVN.dbo.Facility F (nolock) ON isnull(deptcode,0) = facilitynum and parentemployerid = 7519 
												  and facilityclno is not null --added by schapyala on 12/11/2018 to remove duplicate reports caused by duplicate mapping
		INNER JOIN dbo.refAffiliate ra(NOLOCK) ON T.AffiliateID = ra.AffiliateID
		--INNER JOIN dbo.ClientContacts cc(NOLOCK) ON T.CLNO = cc.CLNO
		--LEFT OUTER JOIN #tmpDates AS R ON REPLACE(A.SSN,'-','') = REPLACE(R.SSN,'-','') AND A.CLNO = R.CLNO
		LEFT OUTER JOIN ClientCertification AS cc(NOLOCK) ON A.APNO = cc.APNO
		INNER JOIN dbo.PackageMain pm(NOLOCK) ON A.PackageID = pm.PackageID
		WHERE (t.affiliateid in (4)) 
		AND	DATEPART(m, a.ApDate) = DATEPART(m, DATEADD(m, -1, (dateadd(m,-1,current_timestamp))))
		AND DATEPART(yyyy, a.ApDate) = DATEPART(yyyy, DATEADD(m, -1, (dateadd(m,-1,current_timestamp))))
		AND year(a.OrigCompDate) = @Year
		AND month(a.OrigCompDate)<= @Month  --added to make sure YTD is adjusted to the specific month in question - 07/29/2015
		AND isnull(clientfacilitygroup,'') not in ('PARALLON BUSINESS SOLUTIONS')
		AND apstatus in ('W','F') 
		AND A.CLNO NOT IN (11764,11722,11724,12026,12174,11123,12226,12027,11725,12028,11723,9806,12217,11765,11721,11766,12029,12235)

	END
	ELSE
	BEGIN
		--Insert into #Report
		--SELECT distinct  t.clno,replace([name],',',' ') [Name],apno,deptcode,clientapno,apdate,compDate,OrigCompDate,ReOpenDate,Null,
		--apstatus,isnull(division,'') division,Isnull(clientfacilitygroup,'') clientfacilitygroup,facilitynum,replace(FacilityName,',',' ') FacilityName,Isnull(IsOneHR,0) IsOneHR,
		--dbo.elapsedbusinessdays_2(apdate,OrigcompDate)  AS No_of_Days_Complete  
		--from dbo.client t left join dbo.appl a (nolock) on t.clno = a.clno		
		--LEFT JOIN HEVN.dbo.Facility F (nolock) ON isnull(deptcode,0) = facilitynum and parentemployerid = 7519 
		--										  and facilityclno is not null --added by schapyala on 12/11/2018 to remove duplicate reports caused by duplicate mapping
		--WHERE (t.affiliateid in (4)) 
		--AND year(a.OrigCompDate) = @Year
		--AND month(a.OrigCompDate)<= @Month  --added to make sure YTD is adjusted to the specific month in question - 07/29/2015
		--AND apstatus in ('W','F') 
		--AND A.CLNO NOT IN (11764,11722,11724,12026,12174,11123,12226,12027,11725,12028,11723,9806,12217,11765,11721,11766,12029,12235)

		Insert into #Report
		SELECT distinct  t.clno,replace([name],',',' ') [Name], ra.Affiliate, isnull(division,'') division,
						Isnull(clientfacilitygroup,'') clientfacilitygroup,facilitynum,replace(FacilityName,',',' ') FacilityName,clientapno,Isnull(IsOneHR,0) IsOneHR,
						--(isnull(cc.LastName,'') + ' ' + isnull(cc.MiddleName,'') + ' ' + isnull(cc.FirstName,'')) AS [ContactName],
						a.[Last], a.[First], a.UserID, a.APNO, a.SSN,
						FORMAT(a.ApDate, 'MMMM', 'en-US') AS ReportingMonth,
						--MONTH(a.ApDate) AS ReportingMonth, 
						a.ApDate,OrigCompDate,compDate,
						ReOpenDate,null,apstatus,a.EnteredVia,pm.PackageDesc,
						deptcode,dbo.elapsedbusinessdays_2(apdate,OrigcompDate)  AS No_of_Days_Complete,
						cc.ClientCertUpdated, '' AS ReleaseDate
		from dbo.client t (NOLOCK)
		left join dbo.appl a (nolock) on t.clno = a.clno		
		LEFT JOIN HEVN.dbo.Facility F (nolock) ON isnull(deptcode,0) = facilitynum and parentemployerid = 7519 
												  and facilityclno is not null --added by schapyala on 12/11/2018 to remove duplicate reports caused by duplicate mapping
		INNER JOIN dbo.refAffiliate ra(NOLOCK) ON T.AffiliateID = ra.AffiliateID
		--INNER JOIN dbo.ClientContacts cc(NOLOCK) ON T.CLNO = cc.CLNO
		--LEFT OUTER JOIN #tmpDates AS R ON REPLACE(A.SSN,'-','') = REPLACE(R.SSN,'-','') AND A.CLNO = R.CLNO
		LEFT OUTER JOIN ClientCertification AS cc(NOLOCK) ON A.APNO = cc.APNO
		INNER JOIN dbo.PackageMain pm(NOLOCK) ON A.PackageID = pm.PackageID
		WHERE (t.affiliateid in (4)) 
		AND year(a.OrigCompDate) = @Year
		AND month(a.OrigCompDate)<= @Month  --added to make sure YTD is adjusted to the specific month in question - 07/29/2015
		AND apstatus in ('W','F') 
		AND A.CLNO NOT IN (11764,11722,11724,12026,12174,11123,12226,12027,11725,12028,11723,9806,12217,11765,11721,11766,12029,12235)
	 END 

	--SELECT rf.ReleaseFormID, rf.SSN, rf.[DATE], rf.CLNO
	--		,ROW_NUMBER() OVER (PARTITION BY rf.SSN ORDER BY rf.ReleaseFormID DESC) AS RowNumber
	--FROM ReleaseForm rf (NOLOCK)
	--INNER JOIN dbo.Appl a(NOLOCK) ON  MONTH(rf.[date]) = MONTH(A.ApDate) AND year(rf.[date]) = year(A.ApDate) AND rf.ssn = a.SSN AND rf.CLNO = a.CLNO	
	--INNER JOIN #Report R ON A.APNO = R.APNO
	----WHERE rf.ssn = '573-67-1684'


	-- Get Release Dates for the reports from the main set
	;WITH tmpReleaseDates AS
	(
	SELECT rf.ReleaseFormID, rf.SSN, rf.[DATE], rf.CLNO
			,ROW_NUMBER() OVER (PARTITION BY rf.SSN ORDER BY rf.ReleaseFormID DESC) AS RowNumber
	FROM ReleaseForm rf (NOLOCK)
--	INNER JOIN dbo.Appl a(NOLOCK) ON  MONTH(rf.[date]) = MONTH(A.ApDate) AND year(rf.[date]) = year(A.ApDate) AND rf.ssn = a.SSN AND rf.CLNO = a.CLNO
	INNER JOIN dbo.Appl a(NOLOCK) ON  MONTH(rf.[date]) = MONTH(A.OrigCompDate) AND year(rf.[date]) = year(A.OrigCompDate) AND rf.ssn = a.SSN AND rf.CLNO = a.CLNO
	INNER JOIN #Report R ON A.APNO = R.APNO
	)
	INSERT INTO #tmpDates
	SELECT T.ReleaseFormID, T.SSN, T.[DATE], T.CLNO FROM tmpReleaseDates AS T 
	WHERE T.RowNumber = 1

	--UPDATE R SET Division = F.Division,R.clientfacilitygroup = f.ClientFacilityGroup
	--FROM #Report R INNER JOIN HEVN..Facility F ON R.CLNO = F.FacilityCLNO AND F.ParentEmployerID = 7519
	--WHERE R.Division = '' AND R.clientfacilitygroup = ''

	--Update R
	--Set ReopenedBy = Case left(replace(replace(hostname,'Ala-',''),'Hou-',''),3) when 'IIS' then 'Module' else left(replace(replace(hostname,'Ala-',''),'Hou-',''),3) end
	--FROM #Report R LEFT JOIN dbo.appl_statuslog S on R.apno = S.apno and R.ReopenDate <= S.ChangeDate and Prev_apstatus ='F' and Curr_Apstatus = 'P'

	Update R
	Set ReopenedBy = Case left(replace(replace(hostname,'Ala-',''),'Hou-',''),3) when 'IIS' then 'Module' else left(replace(replace(hostname,'Ala-',''),'Hou-',''),3) end
	FROM #Report R LEFT JOIN dbo.appl_statuslog S on R.apno = S.apno and R.ReopenDate <= S.ChangeDate and Prev_apstatus ='F' and Curr_Apstatus = 'P'
	
	UPDATE R
		SET R.ReleaseDate = D.ReleaseDate
	FROM #Report AS R
	LEFT OUTER JOIN #tmpDates AS D ON R.SSN = D.SSN
	--SELECT * FROM #Report

	SET @Total = (select count( APNO ) from #Report )

	Select 'YTD_TAT' FileType,Days,Reports,[%],[Cumulative %] From
	(select case No_of_Days_Complete when 0 then '<1' else cast(No_of_Days_Complete as varchar) end Days,
	count(APNO) as Reports,cast(count(APNO)/ (Select cast(@Total as NUMERIC( 10, 2 )) ) *100 as NUMERIC( 10, 2 ))  AS '%',
	SUM(cast(count(APNO)/ (Select cast(@Total as NUMERIC( 10, 2 )) ) *100 as NUMERIC( 10, 2 ))) OVER (ORDER BY No_of_Days_Complete) [Cumulative %]
	from  #Report R 
	--where  apstatus in ('W','F') 
	group by  No_of_Days_Complete
	having No_of_Days_Complete <@DaysGrouped) Q
	UNION ALL
	Select 'YTD_TAT' FileType,cast(@DaysGrouped as varchar) + '+'  Days,sum(Reports) Reports,sum([%]) [%],	sum([%]) [Cumulative %] From
	(select No_of_Days_Complete,count(APNO) as Reports,cast(count(APNO)/ (Select cast(@Total as NUMERIC( 10, 2 )) ) *100 as NUMERIC( 10, 2 ))  AS '%'
	from  #Report R 
	--where  apstatus in ('W','F')
	group by  No_of_Days_Complete
	having No_of_Days_Complete >=@DaysGrouped) Q1
	Union ALL
	Select 'YTD_TAT' FileType,'YTD Total: ' Days, @Total Reports,null [%],null [Cumulative %]
	Union ALL
	Select 'YTD_TAT' FileType,'YTD Average Days: ' Days, Sum(No_of_Days_Complete)/@Total Reports,null [%],null [Cumulative %] from  #Report 
	Union ALL
	Select 'YTD_TAT' FileType,'YTD Total Spend: ' Days, Sum(Amount) Reports,null [%],null [Cumulative %] 
	from  #Report R inner join InvDetail ID on R.Apno = ID.Apno 
	Where Billed = Case when @currentMonth = 1 then 0 else 1 end


	Set @Total = 0 
	SET @Total = (select count( APNO ) from #Report  
	--where (month(apdate) = @Month or month(OrigCompDate) = @Month )) -- commented by schapyala based on Dana's feedback on 07/29/2015
	where month(apdate) = @Month)

	Select 'Monthly_TAT' FileType,Days,Reports,[%],[Cumulative %] From
	(select case No_of_Days_Complete when 0 then '<1' else cast(No_of_Days_Complete as varchar) end Days,
	count(APNO) as Reports,cast(count(APNO)/ (Select cast(@Total as NUMERIC( 10, 2 )) ) *100 as NUMERIC( 10, 2 ))  AS '%',
	SUM(cast(count(APNO)/ (Select cast(@Total as NUMERIC( 10, 2 )) ) *100 as NUMERIC( 10, 2 ))) OVER (ORDER BY No_of_Days_Complete) [Cumulative %]
	from  #Report R 
	--where   (month(apdate) = @Month or month(OrigCompDate) = @Month ) -- commented by schapyala based on Dana's feedback on 07/29/2015
	where month(apdate) = @Month
	group by  No_of_Days_Complete
	having No_of_Days_Complete <@DaysGrouped) Q
	UNION ALL
	Select 'Monthly_TAT' FileType,cast(@DaysGrouped as varchar) + '+'  Days,sum(Reports) Reports,sum([%]) [%],	sum([%]) [Cumulative %] From
	(select No_of_Days_Complete,count(APNO) as Reports,cast(count(APNO)/ (Select cast(@Total as NUMERIC( 10, 2 )) ) *100 as NUMERIC( 10, 2 ))  AS '%'
	from  #Report R 
	--where   (month(apdate) = @Month or month(OrigCompDate) = @Month ) -- commented by schapyala based on Dana's feedback on 07/29/2015
	where month(apdate) = @Month
	group by  No_of_Days_Complete
	having No_of_Days_Complete >=@DaysGrouped) Q1
	Union ALL
	Select 'Monthly_TAT' FileType,@MonthName + ' Total: ' Days, @Total Reports,null [%],null [Cumulative %]
	Union ALL
	Select 'Monthly_TAT' FileType,'Monthly Average Days: ' Days, Sum(No_of_Days_Complete)/@Total Reports,null [%],null [Cumulative %] from  #Report 
	where month(apdate) = @Month
	Union ALL
	Select 'Monthly_TAT' FileType,'Monthly Total Spend: ' Days, Sum(Amount) Reports,null [%],null [Cumulative %] 
	from  #Report R inner join InvDetail ID on R.Apno = ID.Apno
	where month(apdate) = @Month
	and Billed = Case when @currentMonth = 1 then 0 else 1 end

	Set @Total = 0
	SET @Total = (select count( APNO ) from #Report where IsOneHR=1) --and apstatus in ('W','F')  	)

	Select 'YTD_HROC-TAT' FileType,Days,Reports,[%],[Cumulative %] From
	(select case No_of_Days_Complete when 0 then '<1' else cast(No_of_Days_Complete as varchar) end Days,
	count(APNO) as Reports,cast(count(APNO)/ (Select cast(@Total as NUMERIC( 10, 2 )) ) *100 as NUMERIC( 10, 2 ))  AS '%',
	SUM(cast(count(APNO)/ (Select cast(@Total as NUMERIC( 10, 2 )) ) *100 as NUMERIC( 10, 2 ))) OVER (ORDER BY No_of_Days_Complete) [Cumulative %]
	from  #Report R 
	where   IsOneHR=1 --and apstatus in ('W','F')
	group by  No_of_Days_Complete
	having No_of_Days_Complete <@DaysGrouped) Q
	UNION ALL
	Select 'YTD_HROC-TAT' FileType,cast(@DaysGrouped as varchar) + '+'  Days,sum(Reports) Reports,sum([%]) [%],	sum([%]) [Cumulative %] From
	(select No_of_Days_Complete,count(APNO) as Reports,cast(count(APNO)/ (Select cast(@Total as NUMERIC( 10, 2 )) ) *100 as NUMERIC( 10, 2 ))  AS '%'
	from  #Report R 
	where IsOneHR=1  --and apstatus in ('W','F')
	group by  No_of_Days_Complete
	having No_of_Days_Complete >=@DaysGrouped) Q1
	Union ALL
	Select 'YTD_HROC-TAT' FileType,'YTD Total: ' Days, @Total Reports,null [%],null [Cumulative %]
	Union ALL
	Select 'YTD_HROC-TAT' FileType,'YTD HROC Average Days: ' Days, Sum(No_of_Days_Complete)/@Total Reports,null [%],null [Cumulative %] from  #Report 
	where IsOneHR=1 
	Union ALL
	Select 'YTD_HROC-TAT' FileType,'YTD HROC Total Spend: ' Days, Sum(Amount) Reports,null [%],null [Cumulative %] 
	from  #Report R inner join InvDetail ID on R.Apno = ID.Apno
	where IsOneHR=1 
	and Billed = Case when @currentMonth = 1 then 0 else 1 end

	Set @Total = 0 
	SET @Total = (select count( APNO ) from #Report  where  IsOneHR=1  
	--and (month(apdate) = @Month or month(OrigCompDate) = @Month )) -- commented by schapyala based on Dana's feedback on 07/29/2015
	and month(apdate) = @Month)

	Select 'Monthly_HROC-TAT' FileType,Days,Reports,[%],[Cumulative %] From
	(select case No_of_Days_Complete when 0 then '<1' else cast(No_of_Days_Complete as varchar) end Days,
	count(APNO) as Reports,cast(count(APNO)/ (Select cast(@Total as NUMERIC( 10, 2 )) ) *100 as NUMERIC( 10, 2 ))  AS '%',
	SUM(cast(count(APNO)/ (Select cast(@Total as NUMERIC( 10, 2 )) ) *100 as NUMERIC( 10, 2 ))) OVER (ORDER BY No_of_Days_Complete) [Cumulative %]
	from  #Report R 
	where  IsOneHR=1 
	--and (month(apdate) = @Month or month(OrigCompDate) = @Month ) -- commented by schapyala based on Dana's feedback on 07/29/2015
	and month(apdate) = @Month
	group by  No_of_Days_Complete
	having No_of_Days_Complete <@DaysGrouped) Q
	UNION ALL
	Select 'Monthly_HROC-TAT' FileType,cast(@DaysGrouped as varchar) + '+' Days,sum(Reports) Reports,sum([%]) [%],	sum([%]) [Cumulative %] From
	(select No_of_Days_Complete,count(APNO) as Reports,cast(count(APNO)/ (Select cast(@Total as NUMERIC( 10, 2 )) ) *100 as NUMERIC( 10, 2 ))  AS '%'
	from  #Report R 
	where    IsOneHR=1 
	--and (month(apdate) = @Month or month(OrigCompDate) = @Month ) -- commented by schapyala based on Dana's feedback on 07/29/2015
	and month(apdate) = @Month
	group by  No_of_Days_Complete
	having No_of_Days_Complete >=@DaysGrouped) Q1	
	Union ALL
	Select 'Monthly_HROC-TAT' FileType,@MonthName + ' Total: ' Days, @Total Reports,null [%],null [Cumulative %]
	Union ALL
	Select 'Monthly_HROC-TAT' FileType,'Monthly HROC Average Days: ' Days, Sum(No_of_Days_Complete)/@Total Reports,null [%],null [Cumulative %] from  #Report 
	where IsOneHR=1 and month(apdate) = @Month
	Union ALL
	Select 'Monthly_HROC-TAT' FileType,'Monthly HROC Total Spend: ' Days, Sum(Amount) Reports,null [%],null [Cumulative %] 
	from  #Report R inner join InvDetail ID on R.Apno = ID.Apno
	where IsOneHR=1 and month(apdate) = @Month
	and Billed = Case when @currentMonth = 1 then 0 else 1 end

	--Select 'YTD_TAT_Detail' FileType,* from #Report

	--Select 'Monthly_TAT_Detail' FileType,* from #Report 
	----Where (month(apdate) = @Month or month(OrigCompDate) = @Month ) -- commented by schapyala based on Dana's feedback on 07/29/2015
	--Where month(apdate) = @Month

	--SELECT '#Report' AS FileType, * FROM #Report R WHERE R.APNO = 4388798
	--SELECT '#tmpDates' AS FileType, * FROM #tmpDates D WHERE D.SSN = '339-60-9752'

	SELECT	'YTD_TAT_Detail' FileType,
			r.CLNO AS [Client ID], r.Name AS [Client Name], r.Affiliate, r.Division, r.clientfacilitygroup AS [Client Facility Group], 
			r.facilitynum AS [Facility Number], r.FacilityName AS [Facility Name], r.ClientAPNO AS [Client Report Number], 
			CASE WHEN r.IsOneHR = 1 THEN 'True' ELSE 'False' END [Is One HR],
			r.ApplicantLast AS [Applicant Last], r.ApplicantFirst AS [Applicant First], r.CAM, r.APNO AS [Report Number], 
			r.ReportingMonth AS [Reporting Month], 
			FORMAT(r.APDATE,'MM/dd/yyyy hh:mm tt') AS [Report Create Date], 
			FORMAT(r.OrigCompDate,'MM/dd/yyyy hh:mm tt') AS [Original Completion Date], 
			FORMAT(r.CompDate,'MM/dd/yyyy hh:mm tt') AS [Report Completion Date], 
			FORMAT(r.ReOpenDate,'MM/dd/yyyy hh:mm tt') AS [Re-Open Date], 
			r.ReOpenedBy AS [Re-Opened by], r.ApStatus AS [Report Status], r.submittedVia AS [Submitted Via], r.SelectedPackage AS [Selected Package], 
			r.No_of_Days_Complete AS [TAT by Business Days],
			DATEDIFF(day,r.apdate, r.origcompdate)as [TAT by Calendar Days],
			dbo.elapsedbusinesshours_2(r.Apdate,r.Origcompdate) as [Business Hours],
			DATEDIFF(hour,r.apdate,r.origcompdate)as [Calendar Time Hours],
			(dbo.elapsedbusinessdays_2(r.Apdate, r.Origcompdate ) + dbo.elapsedbusinessdays_2(r.Reopendate, r.Compdate )) as [Reopen Turnaround],
			DATEDIFF(hh,r.ReleaseDate,r.ClientCertUpdated) AS [Straight Hours based on HROC’s 24/7/365 operating hours],
			[dbo].[GetWorkingHours](r.ReleaseDate,r.ClientCertUpdated) AS [Elapsed Business Hours]
	FROM #Report AS r

	SELECT	'Monthly_TAT_Detail' FileType,
			r.CLNO AS [Client ID], r.Name AS [Client Name], r.Affiliate, r.Division, r.clientfacilitygroup AS [Client Facility Group], 
			r.facilitynum AS [Facility Number], r.FacilityName AS [Facility Name], r.ClientAPNO AS [Client Report Number], 
			CASE WHEN r.IsOneHR = 1 THEN 'True' ELSE 'False' END [Is One HR],			
			--r.IsOneHR AS [Is One HR], 
			r.ApplicantLast AS [Applicant Last], r.ApplicantFirst AS [Applicant First], r.CAM, r.APNO AS [Report Number], 
			r.ReportingMonth AS [Reporting Month], 
			FORMAT(r.APDATE,'MM/dd/yyyy hh:mm tt') AS [Report Create Date], 
			FORMAT(r.OrigCompDate,'MM/dd/yyyy hh:mm tt') AS [Original Completion Date], 
			FORMAT(r.CompDate,'MM/dd/yyyy hh:mm tt') AS [Report Completion Date], 
			FORMAT(r.ReOpenDate,'MM/dd/yyyy hh:mm tt') AS [Re-Open Date], 
			r.ReOpenedBy AS [Re-Opened by], r.ApStatus AS [Report Status], r.submittedVia AS [Submitted Via], r.SelectedPackage AS [Selected Package], 
			r.No_of_Days_Complete AS [TAT by Business Days],
			DATEDIFF(day,r.apdate, r.origcompdate)as [TAT by Calendar Days],
			dbo.elapsedbusinesshours_2(r.Apdate,r.Origcompdate) as [Business Hours],
			DATEDIFF(hour,r.apdate,r.origcompdate)as [Calendar Time Hours],
			(dbo.elapsedbusinessdays_2(r.Apdate, r.Origcompdate ) + dbo.elapsedbusinessdays_2(r.Reopendate, r.Compdate )) as [Reopen Turnaround],
			DATEDIFF(hh,r.ReleaseDate,r.ClientCertUpdated) AS [Straight Hours based on HROC’s 24/7/365 operating hours],
			[dbo].[GetWorkingHours](r.ReleaseDate,r.ClientCertUpdated) AS [Elapsed Business Hours]
	FROM #Report AS r
	WHERE month(apdate) = @Month

	DROP TABLE #Report
	--DROP TABLE #ReportToBe

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	SET NOCOUNT OFF
END