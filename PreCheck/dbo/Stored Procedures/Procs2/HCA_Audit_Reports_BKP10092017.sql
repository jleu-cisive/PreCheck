CREATE Procedure [dbo].[HCA_Audit_Reports_BKP10092017] @ExcludeParallon bit = 1 ,@Month int = null,@Year int = NULL,@currentMonth BIT = 0
AS
BEGIN
--[HCA_Audit_Reports] 1,5
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	CREATE TABLE #Report (CLNO INT,Name Varchar(100),APNO INT,DeptCode varchar(50),ClientAPNO varchar(100),APDATE DateTime,CompDate DateTime,OrigCompDate DateTime,ReOpenDate DateTime, ApStatus varchar(1),
						  Division varchar(100),clientfacilitygroup varchar(100),facilitynum varchar(50),FacilityName varchar(500),IsOneHR Bit,No_of_Days_Complete Int)

	declare @Total int,@DaysGrouped Int
	Set @DaysGrouped = 35
	
	IF @currentMonth = 1
		BEGIN
			if @Month is NULL
					Set @Month = month(current_timestamp) --Set Current Month

			if @Year is null
					Set @Year = year(current_timestamp)
		END
	ELSE
		BEGIN
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

	
	IF @ExcludeParallon =1
		Insert into #Report
		SELECT distinct  t.clno,name,apno,deptcode,clientapno,apdate,compDate,OrigCompDate,ReOpenDate,apstatus,isnull(division,'') division,Isnull(clientfacilitygroup,'') clientfacilitygroup,facilitynum,FacilityName,Isnull(IsOneHR,0) IsOneHR,
		dbo.elapsedbusinessdays_2(apdate,OrigcompDate)  AS No_of_Days_Complete  
		from dbo.client t left join appl a (nolock) on t.clno = a.clno
		LEFT JOIN HEVN.dbo.Facility F (nolock) ON isnull(deptcode,0) = facilitynum and parentemployerid = 7519 
		WHERE (t.affiliateid in (4)) 
		AND year(a.apDate) = @Year
		AND month(a.apdate)<= @Month  --added to make sure YTD is adjusted to the specific month in question - 07/29/2015
		AND isnull(clientfacilitygroup,'') not in ('PARALLON BUSINESS SOLUTIONS')
		AND apstatus in ('W','F') 
	ELSE
		Insert into #Report
		SELECT distinct  t.clno,name,apno,deptcode,clientapno,apdate,compDate,OrigCompDate,ReOpenDate,apstatus,isnull(division,'') division,Isnull(clientfacilitygroup,'') clientfacilitygroup,facilitynum,FacilityName,Isnull(IsOneHR,0) IsOneHR,
		dbo.elapsedbusinessdays_2(apdate,OrigcompDate)  AS No_of_Days_Complete  
		from dbo.client t left join appl a (nolock) on t.clno = a.clno
		LEFT JOIN HEVN.dbo.Facility F (nolock) ON isnull(deptcode,0) = facilitynum and parentemployerid = 7519 
		WHERE (t.affiliateid in (4)) 
		AND year(a.apDate) = @Year
		AND month(a.apdate)<= @Month  --added to make sure YTD is adjusted to the specific month in question - 07/29/2015
		AND apstatus in ('W','F') 
	  
	UPDATE R SET Division = F.Division,R.clientfacilitygroup = f.ClientFacilityGroup
	FROM #Report R INNER JOIN HEVN..Facility F ON R.CLNO = F.FacilityCLNO AND F.ParentEmployerID = 7519
	WHERE R.Division = '' AND R.clientfacilitygroup = ''
	
	SET @Total = (select count( APNO ) from #Report )



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

	Select 'YTD_TAT_Detail' FileType,* from #Report

	Select 'Monthly_TAT_Detail' FileType,* from #Report 
	--Where (month(apdate) = @Month or month(OrigCompDate) = @Month ) -- commented by schapyala based on Dana's feedback on 07/29/2015
	Where month(apdate) = @Month



	DROP TABLE #Report


	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	SET NOCOUNT OFF
END