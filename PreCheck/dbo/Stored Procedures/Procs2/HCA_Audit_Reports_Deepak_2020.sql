/*
Modified By : Deepak Vodethela
Modified Date : 05/03/2019
Description: Req#49736 - Monthly HCA Audit/Mofifications 
Execution:	[dbo].[HCA_Audit_Reports_Deepak_2020] 1,11
			[dbo].[HCA_Audit_Reports_Deepak_2020] 1,12,2019,0
			[dbo].[HCA_Audit_Reports_Deepak_2020]
*/
CREATE Procedure [dbo].[HCA_Audit_Reports_Deepak_2020] @ExcludeParallon bit = 1 ,@Month int = null,@Year int = NULL,@currentMonth BIT = 0
AS
BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

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
	
	DECLARE	@PreviousMonthsReportsOnly int -- VD:01212020 - Adjust the MONTH to the previous MONTH

	IF @currentMonth = 1
		BEGIN
			if @Month IS NULL
					SET @Month = MONTH(current_timestamp) --Set Current Month

			if @Year IS NULL
					SET @Year = YEAR(current_timestamp)
		END
	ELSE
		BEGIN
			IF @Month IS NULL
			BEGIN
				SET @Month = MONTH(dateadd(m,-1,current_timestamp)) --Set Previous Month
				SET @PreviousMonthsReportsOnly = @Month - 1 
			END
			ELSE
			BEGIN
				If @Month = 01 -- VD:01212020 - Adjust the MONTH to the previous YEAR in the MONTH of December
					SET @PreviousMonthsReportsOnly = 12 
				ELSE
					SET @PreviousMonthsReportsOnly = @Month - 1  
			END
			
			if @Year IS NULL
				If @Month = 12 --adjust the YEAR to the previous YEAR in the MONTH of January
					SET @Year = YEAR(current_timestamp)-1
				ELSE 
					SET @Year = YEAR(current_timestamp)
	END

	DECLARE @MonthName varchar(20)
	SET @MonthName = DateName( MONTH , DateAdd( MONTH , @Month , 0 ) - 1 )

	SELECT  @Year AS [Year], @currentMonth AS currentMonth,@Month AS [Reporting Month], @MonthName AS [MonthName], @PreviousMonthsReportsOnly AS PreviousMonthsReportsOnly

	IF @ExcludeParallon =1
	BEGIN

		Insert into #Report
		SELECT distinct  t.clno,replace([name],',',' ') [Name], ra.Affiliate, ISNULL(division,'') division,
						Isnull(clientfacilitygroup,'') clientfacilitygroup,facilitynum,replace(FacilityName,',',' ') FacilityName,clientapno,Isnull(IsOneHR,0) IsOneHR,
						a.[Last], a.[First], a.UserID, a.APNO, a.SSN,
						FORMAT(a.OrigCompDate, 'MMMM', 'en-US') AS ReportingMonth,
						a.ApDate,OrigCompDate,compDate,
						ReOpenDate,null,apstatus,a.EnteredVia,pm.PackageDesc,
						deptcode,dbo.elapsedbusinessdays_2(apdate,OrigcompDate)  AS No_of_Days_Complete ,
						cc.ClientCertUpdated, '' AS ReleaseDate
		from dbo.client t (NOLOCK)
		left join dbo.appl a (nolock) on t.clno = a.clno		
		LEFT JOIN HEVN.dbo.Facility F (nolock) ON ISNULL(deptcode,0) = facilitynum and parentemployerid = 7519 
												  and facilityclno is not null --added by schapyala on 12/11/2018 to remove duplicate reports caused by duplicate mapping
		INNER JOIN dbo.refAffiliate ra(NOLOCK) ON T.AffiliateID = ra.AffiliateID
		LEFT OUTER JOIN ClientCertification AS cc(NOLOCK) ON A.APNO = cc.APNO
		INNER JOIN dbo.PackageMain pm(NOLOCK) ON A.PackageID = pm.PackageID
		WHERE (t.affiliateid in (4)) 
		AND MONTH(a.ApDate) = @PreviousMonthsReportsOnly
		AND YEAR(a.OrigCompDate) = @Year
		AND MONTH(a.OrigCompDate) = @Month  --added to make sure YTD is adjusted to the specific MONTH in question - 07/29/2015
		AND ISNULL(clientfacilitygroup,'') not in ('PARALLON BUSINESS SOLUTIONS')
		AND apstatus in ('W','F') 
		AND A.CLNO NOT IN (11764,11722,11724,12026,12174,11123,12226,12027,11725,12028,11723,9806,12217,11765,11721,11766,12029,12235)

	END
	ELSE
	BEGIN
		--Insert into #Report
		Insert into #Report
		SELECT distinct  t.clno,replace([name],',',' ') [Name], ra.Affiliate, ISNULL(division,'') division,
						Isnull(clientfacilitygroup,'') clientfacilitygroup,facilitynum,replace(FacilityName,',',' ') FacilityName,clientapno,Isnull(IsOneHR,0) IsOneHR,
						a.[Last], a.[First], a.UserID, a.APNO, a.SSN,
						FORMAT(a.ApDate, 'MMMM', 'en-US') AS ReportingMonth,
						a.ApDate,OrigCompDate,compDate,
						ReOpenDate,null,apstatus,a.EnteredVia,pm.PackageDesc,
						deptcode,dbo.elapsedbusinessdays_2(apdate,OrigcompDate)  AS No_of_Days_Complete,
						cc.ClientCertUpdated, '' AS ReleaseDate
		from dbo.client t (NOLOCK)
		left join dbo.appl a (nolock) on t.clno = a.clno		
		LEFT JOIN HEVN.dbo.Facility F (nolock) ON ISNULL(deptcode,0) = facilitynum and parentemployerid = 7519 
												  and facilityclno is not null --added by schapyala on 12/11/2018 to remove duplicate reports caused by duplicate mapping
		INNER JOIN dbo.refAffiliate ra(NOLOCK) ON T.AffiliateID = ra.AffiliateID
		LEFT OUTER JOIN ClientCertification AS cc(NOLOCK) ON A.APNO = cc.APNO
		INNER JOIN dbo.PackageMain pm(NOLOCK) ON A.PackageID = pm.PackageID
		WHERE (t.affiliateid in (4)) 
		AND MONTH(a.ApDate) = @PreviousMonthsReportsOnly
		AND YEAR(a.OrigCompDate) = @Year
		AND MONTH(a.OrigCompDate) = @Month  --added to make sure YTD is adjusted to the specific MONTH in question - 07/29/2015
		AND apstatus in ('W','F') 
		AND A.CLNO NOT IN (11764,11722,11724,12026,12174,11123,12226,12027,11725,12028,11723,9806,12217,11765,11721,11766,12029,12235)
	 END 

	-- Get Release Dates for the reports from the main set
	;WITH tmpReleaseDates AS
	(
	SELECT rf.ReleaseFormID, rf.SSN, rf.[DATE], rf.CLNO
			,ROW_NUMBER() OVER (PARTITION BY rf.SSN ORDER BY rf.ReleaseFormID DESC) AS RowNumber
	FROM ReleaseForm rf (NOLOCK)
	INNER JOIN dbo.Appl a(NOLOCK) ON  MONTH(rf.[date]) = MONTH(A.ApDate) AND YEAR(rf.[date]) = YEAR(A.ApDate) AND rf.ssn = a.SSN AND rf.CLNO = a.CLNO
	INNER JOIN #Report R ON A.APNO = R.APNO
	)
	INSERT INTO #tmpDates
	SELECT T.ReleaseFormID, T.SSN, T.[DATE], T.CLNO FROM tmpReleaseDates AS T 
	WHERE T.RowNumber = 1

	Update R
	Set ReopenedBy = Case left(replace(replace(hostname,'Ala-',''),'Hou-',''),3) when 'IIS' then 'Module' else left(replace(replace(hostname,'Ala-',''),'Hou-',''),3) end
	FROM #Report R LEFT JOIN dbo.appl_statuslog S on R.apno = S.apno and R.ReopenDate <= S.ChangeDate and Prev_apstatus ='F' and Curr_Apstatus = 'P'
	
	UPDATE R
		SET R.ReleaseDate = D.ReleaseDate
	FROM #Report AS R
	LEFT OUTER JOIN #tmpDates AS D ON R.SSN = D.SSN
	
	SELECT * FROM #Report

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
	--where (MONTH(apdate) = @Month or MONTH(OrigCompDate) = @Month )) -- commented by schapyala based on Dana's feedback on 07/29/2015
	where MONTH(apdate) = @Month)

	Select 'Monthly_TAT' FileType,Days,Reports,[%],[Cumulative %] From
	(select case No_of_Days_Complete when 0 then '<1' else cast(No_of_Days_Complete as varchar) end Days,
	count(APNO) as Reports,cast(count(APNO)/ (Select cast(@Total as NUMERIC( 10, 2 )) ) *100 as NUMERIC( 10, 2 ))  AS '%',
	SUM(cast(count(APNO)/ (Select cast(@Total as NUMERIC( 10, 2 )) ) *100 as NUMERIC( 10, 2 ))) OVER (ORDER BY No_of_Days_Complete) [Cumulative %]
	from  #Report R 
	--where   (MONTH(apdate) = @Month or MONTH(OrigCompDate) = @Month ) -- commented by schapyala based on Dana's feedback on 07/29/2015
	where MONTH(apdate) = @Month
	group by  No_of_Days_Complete
	having No_of_Days_Complete <@DaysGrouped) Q
	UNION ALL
	Select 'Monthly_TAT' FileType,cast(@DaysGrouped as varchar) + '+'  Days,sum(Reports) Reports,sum([%]) [%],	sum([%]) [Cumulative %] From
	(select No_of_Days_Complete,count(APNO) as Reports,cast(count(APNO)/ (Select cast(@Total as NUMERIC( 10, 2 )) ) *100 as NUMERIC( 10, 2 ))  AS '%'
	from  #Report R 
	--where   (MONTH(apdate) = @Month or MONTH(OrigCompDate) = @Month ) -- commented by schapyala based on Dana's feedback on 07/29/2015
	where MONTH(apdate) = @Month
	group by  No_of_Days_Complete
	having No_of_Days_Complete >=@DaysGrouped) Q1
	Union ALL
	Select 'Monthly_TAT' FileType,@MonthName + ' Total: ' Days, @Total Reports,null [%],null [Cumulative %]
	Union ALL
	Select 'Monthly_TAT' FileType,'Monthly Average Days: ' Days, Sum(No_of_Days_Complete)/@Total Reports,null [%],null [Cumulative %] from  #Report 
	where MONTH(apdate) = @Month
	Union ALL
	Select 'Monthly_TAT' FileType,'Monthly Total Spend: ' Days, Sum(Amount) Reports,null [%],null [Cumulative %] 
	from  #Report R inner join InvDetail ID on R.Apno = ID.Apno
	where MONTH(apdate) = @Month
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
	--and (MONTH(apdate) = @Month or MONTH(OrigCompDate) = @Month )) -- commented by schapyala based on Dana's feedback on 07/29/2015
	and MONTH(apdate) = @Month)

	Select 'Monthly_HROC-TAT' FileType,Days,Reports,[%],[Cumulative %] From
	(select case No_of_Days_Complete when 0 then '<1' else cast(No_of_Days_Complete as varchar) end Days,
	count(APNO) as Reports,cast(count(APNO)/ (Select cast(@Total as NUMERIC( 10, 2 )) ) *100 as NUMERIC( 10, 2 ))  AS '%',
	SUM(cast(count(APNO)/ (Select cast(@Total as NUMERIC( 10, 2 )) ) *100 as NUMERIC( 10, 2 ))) OVER (ORDER BY No_of_Days_Complete) [Cumulative %]
	from  #Report R 
	where  IsOneHR=1 
	--and (MONTH(apdate) = @Month or MONTH(OrigCompDate) = @Month ) -- commented by schapyala based on Dana's feedback on 07/29/2015
	and MONTH(apdate) = @Month
	group by  No_of_Days_Complete
	having No_of_Days_Complete <@DaysGrouped) Q
	UNION ALL
	Select 'Monthly_HROC-TAT' FileType,cast(@DaysGrouped as varchar) + '+' Days,sum(Reports) Reports,sum([%]) [%],	sum([%]) [Cumulative %] From
	(select No_of_Days_Complete,count(APNO) as Reports,cast(count(APNO)/ (Select cast(@Total as NUMERIC( 10, 2 )) ) *100 as NUMERIC( 10, 2 ))  AS '%'
	from  #Report R 
	where    IsOneHR=1 
	--and (MONTH(apdate) = @Month or MONTH(OrigCompDate) = @Month ) -- commented by schapyala based on Dana's feedback on 07/29/2015
	and MONTH(apdate) = @Month
	group by  No_of_Days_Complete
	having No_of_Days_Complete >=@DaysGrouped) Q1	
	Union ALL
	Select 'Monthly_HROC-TAT' FileType,@MonthName + ' Total: ' Days, @Total Reports,null [%],null [Cumulative %]
	Union ALL
	Select 'Monthly_HROC-TAT' FileType,'Monthly HROC Average Days: ' Days, Sum(No_of_Days_Complete)/@Total Reports,null [%],null [Cumulative %] from  #Report 
	where IsOneHR=1 and MONTH(apdate) = @Month
	Union ALL
	Select 'Monthly_HROC-TAT' FileType,'Monthly HROC Total Spend: ' Days, Sum(Amount) Reports,null [%],null [Cumulative %] 
	from  #Report R inner join InvDetail ID on R.Apno = ID.Apno
	where IsOneHR=1 and MONTH(apdate) = @Month
	and Billed = Case when @currentMonth = 1 then 0 else 1 end

	--Select 'YTD_TAT_Detail' FileType,* from #Report

	--Select 'Monthly_TAT_Detail' FileType,* from #Report 
	----Where (MONTH(apdate) = @Month or MONTH(OrigCompDate) = @Month ) -- commented by schapyala based on Dana's feedback on 07/29/2015
	--Where MONTH(apdate) = @Month

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
	WHERE MONTH(apdate) = @Month

	DROP TABLE #Report
	--DROP TABLE #ReportToBe

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	SET NOCOUNT OFF
END

/* -- Commented BY: Deepak on 05/21/2019. Changed the Original SP in reference to Req#49736 - Monthly HCA Audit/Mofifications 
BEGIN

	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	CREATE TABLE #Report (CLNO INT,Name Varchar(100),APNO INT,DeptCode varchar(50),ClientAPNO varchar(100),APDATE DateTime,CompDate DateTime,OrigCompDate DateTime,ReOpenDate DateTime,ReOpenedBy varchar(20), ApStatus varchar(1),
						  Division varchar(100),clientfacilitygroup varchar(100),facilitynum varchar(50),FacilityName varchar(500),IsOneHR Bit,No_of_Days_Complete Int)

	declare @Total float,@DaysGrouped Int
	Set @DaysGrouped = 35
	
	IF @currentMonth = 1
		BEGIN
			if @Month is NULL
					Set @Month = MONTH(current_timestamp) --Set Current Month

			if @Year is null
					Set @Year = YEAR(current_timestamp)
		END
	ELSE
		BEGIN
			if @Month is NULL
					Set @Month = MONTH(dateadd(m,-1,current_timestamp)) --Set Previous Month

			if @Year is null
				If @Month = 12 --adjust the YEAR to the previous YEAR in the MONTH of January
					Set @Year = YEAR(current_timestamp)-1
				else 
					Set @Year = YEAR(current_timestamp)
		END

	Declare @MonthName varchar(20)
	Set @MonthName = DateName( MONTH , DateAdd( MONTH , @Month , 0 ) - 1 )

	
	IF @ExcludeParallon =1
		Insert into #Report
		SELECT distinct  t.clno,replace([name],',',' ') [Name],apno,deptcode,clientapno,apdate,compDate,OrigCompDate,ReOpenDate,null,
		apstatus,ISNULL(division,'') division,Isnull(clientfacilitygroup,'') clientfacilitygroup,facilitynum,replace(FacilityName,',',' ') FacilityName,Isnull(IsOneHR,0) IsOneHR,
		dbo.elapsedbusinessdays_2(apdate,OrigcompDate)  AS No_of_Days_Complete  
		from dbo.client t left join dbo.appl a (nolock) on t.clno = a.clno		
		LEFT JOIN HEVN.dbo.Facility F (nolock) ON ISNULL(deptcode,0) = facilitynum and parentemployerid = 7519 
												  and facilityclno is not null --added by schapyala on 12/11/2018 to remove duplicate reports caused by duplicate mapping
		WHERE (t.affiliateid in (4)) 
		AND YEAR(a.apDate) = @Year
		AND MONTH(a.apdate)<= @Month  --added to make sure YTD is adjusted to the specific MONTH in question - 07/29/2015
		AND ISNULL(clientfacilitygroup,'') not in ('PARALLON BUSINESS SOLUTIONS')
		AND apstatus in ('W','F') 
	ELSE
		Insert into #Report
		SELECT distinct  t.clno,replace([name],',',' ') [Name],apno,deptcode,clientapno,apdate,compDate,OrigCompDate,ReOpenDate,Null,
		apstatus,ISNULL(division,'') division,Isnull(clientfacilitygroup,'') clientfacilitygroup,facilitynum,replace(FacilityName,',',' ') FacilityName,Isnull(IsOneHR,0) IsOneHR,
		dbo.elapsedbusinessdays_2(apdate,OrigcompDate)  AS No_of_Days_Complete  
		from dbo.client t left join dbo.appl a (nolock) on t.clno = a.clno		
		LEFT JOIN HEVN.dbo.Facility F (nolock) ON ISNULL(deptcode,0) = facilitynum and parentemployerid = 7519 
												  and facilityclno is not null --added by schapyala on 12/11/2018 to remove duplicate reports caused by duplicate mapping
		WHERE (t.affiliateid in (4)) 
		AND YEAR(a.apDate) = @Year
		AND MONTH(a.apdate)<= @Month  --added to make sure YTD is adjusted to the specific MONTH in question - 07/29/2015
		AND apstatus in ('W','F') 
	  
	UPDATE R SET Division = F.Division,R.clientfacilitygroup = f.ClientFacilityGroup
	FROM #Report R INNER JOIN HEVN..Facility F ON R.CLNO = F.FacilityCLNO AND F.ParentEmployerID = 7519
	WHERE R.Division = '' AND R.clientfacilitygroup = ''

	Update R
	Set ReopenedBy = Case left(replace(replace(hostname,'Ala-',''),'Hou-',''),3) when 'IIS' then 'Module' else left(replace(replace(hostname,'Ala-',''),'Hou-',''),3) end
	FROM #Report R LEFT JOIN dbo.appl_statuslog S on R.apno = S.apno and R.ReopenDate <= S.ChangeDate and Prev_apstatus ='F' and Curr_Apstatus = 'P'
	
	SET @Total = (select count( APNO ) from #Report )

	----select distinct apno,reopenedby from #Report where reopenedby is not null

	--select  No_of_Days_Complete,
	--count(1) as Reports,cast(count(APNO)/ (Select cast(@Total as NUMERIC( 10, 2 )) ) *100 as NUMERIC( 10, 2 ))  AS '%'
	--into #TATReport
	--from  #Report R 
	--where  apstatus in ('W','F') 
	--group by  No_of_Days_Complete
	--Order By No_of_Days_Complete

	--SELECT 'YTD_TAT' FileType,case No_of_Days_Complete when 0 then '<1' else cast(No_of_Days_Complete as varchar) end Days,Reports, [%],
	--SUM([%]) OVER (ORDER BY No_of_Days_Complete) [Cumulative %]
	--FROM #TATReport 
	--Where No_of_Days_Complete < @DaysGrouped
	--UNION ALL 
	--SELECT 'YTD_TAT' FileType,'@DaysGrouped+' Days,sum(Reports) Reports, sum([%]) '%',
	--SUM([%])  [Cumulative %]
	--FROM #TATReport 
	--Where No_of_Days_Complete >= @DaysGrouped
	--Union ALL
	--Select 'YTD_TAT' FileType,'Total: ' Days, @Total Reports,null [%],null [Cumulative %]

	--DROP TABLE #TATReport

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
	--where (MONTH(apdate) = @Month or MONTH(OrigCompDate) = @Month )) -- commented by schapyala based on Dana's feedback on 07/29/2015
	where MONTH(apdate) = @Month)

	Select 'Monthly_TAT' FileType,Days,Reports,[%],[Cumulative %] From
	(select case No_of_Days_Complete when 0 then '<1' else cast(No_of_Days_Complete as varchar) end Days,
	count(APNO) as Reports,cast(count(APNO)/ (Select cast(@Total as NUMERIC( 10, 2 )) ) *100 as NUMERIC( 10, 2 ))  AS '%',
	SUM(cast(count(APNO)/ (Select cast(@Total as NUMERIC( 10, 2 )) ) *100 as NUMERIC( 10, 2 ))) OVER (ORDER BY No_of_Days_Complete) [Cumulative %]
	from  #Report R 
	--where   (MONTH(apdate) = @Month or MONTH(OrigCompDate) = @Month ) -- commented by schapyala based on Dana's feedback on 07/29/2015
	where MONTH(apdate) = @Month
	group by  No_of_Days_Complete
	having No_of_Days_Complete <@DaysGrouped) Q
	UNION ALL
	Select 'Monthly_TAT' FileType,cast(@DaysGrouped as varchar) + '+'  Days,sum(Reports) Reports,sum([%]) [%],	sum([%]) [Cumulative %] From
	(select No_of_Days_Complete,count(APNO) as Reports,cast(count(APNO)/ (Select cast(@Total as NUMERIC( 10, 2 )) ) *100 as NUMERIC( 10, 2 ))  AS '%'
	from  #Report R 
	--where   (MONTH(apdate) = @Month or MONTH(OrigCompDate) = @Month ) -- commented by schapyala based on Dana's feedback on 07/29/2015
	where MONTH(apdate) = @Month
	group by  No_of_Days_Complete
	having No_of_Days_Complete >=@DaysGrouped) Q1
	Union ALL
	Select 'Monthly_TAT' FileType,@MonthName + ' Total: ' Days, @Total Reports,null [%],null [Cumulative %]
	Union ALL
	Select 'Monthly_TAT' FileType,'Monthly Average Days: ' Days, Sum(No_of_Days_Complete)/@Total Reports,null [%],null [Cumulative %] from  #Report 
	where MONTH(apdate) = @Month
	Union ALL
	Select 'Monthly_TAT' FileType,'Monthly Total Spend: ' Days, Sum(Amount) Reports,null [%],null [Cumulative %] 
	from  #Report R inner join InvDetail ID on R.Apno = ID.Apno
	where MONTH(apdate) = @Month
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
	--and (MONTH(apdate) = @Month or MONTH(OrigCompDate) = @Month )) -- commented by schapyala based on Dana's feedback on 07/29/2015
	and MONTH(apdate) = @Month)

	Select 'Monthly_HROC-TAT' FileType,Days,Reports,[%],[Cumulative %] From
	(select case No_of_Days_Complete when 0 then '<1' else cast(No_of_Days_Complete as varchar) end Days,
	count(APNO) as Reports,cast(count(APNO)/ (Select cast(@Total as NUMERIC( 10, 2 )) ) *100 as NUMERIC( 10, 2 ))  AS '%',
	SUM(cast(count(APNO)/ (Select cast(@Total as NUMERIC( 10, 2 )) ) *100 as NUMERIC( 10, 2 ))) OVER (ORDER BY No_of_Days_Complete) [Cumulative %]
	from  #Report R 
	where  IsOneHR=1 
	--and (MONTH(apdate) = @Month or MONTH(OrigCompDate) = @Month ) -- commented by schapyala based on Dana's feedback on 07/29/2015
	and MONTH(apdate) = @Month
	group by  No_of_Days_Complete
	having No_of_Days_Complete <@DaysGrouped) Q
	UNION ALL
	Select 'Monthly_HROC-TAT' FileType,cast(@DaysGrouped as varchar) + '+' Days,sum(Reports) Reports,sum([%]) [%],	sum([%]) [Cumulative %] From
	(select No_of_Days_Complete,count(APNO) as Reports,cast(count(APNO)/ (Select cast(@Total as NUMERIC( 10, 2 )) ) *100 as NUMERIC( 10, 2 ))  AS '%'
	from  #Report R 
	where    IsOneHR=1 
	--and (MONTH(apdate) = @Month or MONTH(OrigCompDate) = @Month ) -- commented by schapyala based on Dana's feedback on 07/29/2015
	and MONTH(apdate) = @Month
	group by  No_of_Days_Complete
	having No_of_Days_Complete >=@DaysGrouped) Q1	
	Union ALL
	Select 'Monthly_HROC-TAT' FileType,@MonthName + ' Total: ' Days, @Total Reports,null [%],null [Cumulative %]
	Union ALL
	Select 'Monthly_HROC-TAT' FileType,'Monthly HROC Average Days: ' Days, Sum(No_of_Days_Complete)/@Total Reports,null [%],null [Cumulative %] from  #Report 
	where IsOneHR=1 and MONTH(apdate) = @Month
	Union ALL
	Select 'Monthly_HROC-TAT' FileType,'Monthly HROC Total Spend: ' Days, Sum(Amount) Reports,null [%],null [Cumulative %] 
	from  #Report R inner join InvDetail ID on R.Apno = ID.Apno
	where IsOneHR=1 and MONTH(apdate) = @Month
	and Billed = Case when @currentMonth = 1 then 0 else 1 end

	Select 'YTD_TAT_Detail' FileType,* from #Report

	Select 'Monthly_TAT_Detail' FileType,* from #Report 
	--Where (MONTH(apdate) = @Month or MONTH(OrigCompDate) = @Month ) -- commented by schapyala based on Dana's feedback on 07/29/2015
	Where MONTH(apdate) = @Month

	DROP TABLE #Report


	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	SET NOCOUNT OFF


END
*/