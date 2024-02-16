CREATE Procedure [dbo].[ReportsWithAmendedComponents]
 (@ClientList varchar(8000),
 @StartDate Datetime,
 @EndDate Datetime,
 @ShowDetail bit = 0,
 @HCA_InModel bit = 1,
 @SmartScreenPrediction bit=0)
 AS
 BEGIN
 --ReportsWithAmendedComponents '7519','1/1/2015','10/13/2015',0,1,1

	CREATE TABLE #tmpAppl (CLNO INT,Name varchar(250),APNO INT, APDate Datetime, ApStatus varchar(10),OrigCompDate DateTime,No_of_Days_Complete Int,Amended DateTime,Section varchar(20))

	If @ClientList = '7519'
		Insert Into #tmpAppl
		Select a.clno,t.Name,a.Apno,apdate,ApStatus, OrigCompDate,dbo.elapsedbusinessdays_2(a.apdate,OrigcompDate)  AS No_of_Days_Complete,
		Null Amended,null section  
		--from appl a (nolock) inner join hevn..Facility F on a.clno = isnull(F.FacilityCLNO,0) and Isnull(IsOneHR,0) = 1 and F.ParentEmployerID = 7519 
		from dbo.client t left join appl a (nolock) on t.clno = a.clno
		LEFT JOIN HEVN.dbo.Facility F (nolock) ON isnull(deptcode,0) = facilitynum and parentemployerid = 7519 and Isnull(IsOneHR,0) = @HCA_InModel
		WHERE (t.affiliateid in (4)) 
		AND a.apDate between @StartDate and DateAdd(day,1,@EndDate)
		and OrigCompDate is not null 
	else
		Insert Into #tmpAppl
		Select a.clno,t.Name,a.Apno,apdate,ApStatus, OrigCompDate,dbo.elapsedbusinessdays_2(a.apdate,OrigcompDate)  AS No_of_Days_Complete,
		Null Amended,null section 
		from dbo.client t left join appl a (nolock) on t.clno = a.clno
		inner join dbo.fn_Split(@ClientList,':') b on b.value =a.clno
		WHERE a.apDate between @StartDate and DateAdd(day,1,@EndDate)
		and OrigCompDate is not null 

	Select clno,Name,Apno,apdate,ApStatus,OrigCompDate,No_of_Days_Complete,max(Amended) Amended,Section into #tmpApplReport from 
	(
	Select a.clno,a.Name,a.Apno,apdate,ApStatus, OrigCompDate, No_of_Days_Complete,e.Last_Updated Amended,'Employment' section
	from #tmpAppl a (nolock) left join empl e (nolock) on a.apno = e.apno and e.IsOnReport =1 
	Where e.Last_Updated <= OrigCompDate --and 0 = cast(@SmartScreenPrediction as int) 
	UNION ALL
	Select a.clno,a.Name,a.Apno,apdate,ApStatus, OrigCompDate, No_of_Days_Complete,e.Last_Updated Amended,'Education' section
	from #tmpAppl a (nolock) left join educat e (nolock) on a.apno = e.apno and e.IsOnReport =1 
	Where e.Last_Updated <= OrigCompDate --and 0 = cast(@SmartScreenPrediction as int) 
	UNION ALL
	Select a.clno,a.Name,a.Apno,apdate,ApStatus, OrigCompDate, No_of_Days_Complete,e.Last_Updated Amended,'SanctionCheck' section
	from #tmpAppl a (nolock) left join Medinteg e (nolock) on a.apno = e.apno 
	Where e.Last_Updated <= OrigCompDate  UNION ALL
	Select a.clno,a.Name,a.Apno,apdate,ApStatus, OrigCompDate, No_of_Days_Complete,e.Last_Updated Amended,'License' section
	from #tmpAppl a (nolock) left join Proflic e (nolock) on a.apno = e.apno and e.IsOnReport =1 
	Where e.Last_Updated <= OrigCompDate  UNION ALL
	Select a.clno,a.Name,a.Apno,apdate,ApStatus, OrigCompDate, No_of_Days_Complete,e.Last_Updated Amended,'Reference' section
	from #tmpAppl a (nolock) left join PersRef e (nolock) on a.apno = e.apno and e.IsOnReport =1 --and 0 = cast(@SmartScreenPrediction as int) 
	Where e.Last_Updated <= OrigCompDate  UNION ALL
	Select a.clno,a.Name,a.Apno,apdate,ApStatus, OrigCompDate, No_of_Days_Complete,e.Last_Updated Amended,Case When reptype = 'S' then 'PID' else 'Credit' end section
	from #tmpAppl a (nolock) left join Credit e (nolock) on a.apno = e.apno 
	Where e.Last_Updated <= OrigCompDate  UNION ALL
	Select a.clno,a.Name,a.Apno,apdate,ApStatus, OrigCompDate, No_of_Days_Complete,e.Last_Updated Amended,'Civil' section
	from #tmpAppl a (nolock) left join Civil e (nolock) on a.apno = e.apno
	Where e.Last_Updated <= OrigCompDate  UNION ALL
	Select a.clno,a.Name,a.Apno,apdate,ApStatus, OrigCompDate, No_of_Days_Complete,e.Last_Updated Amended,'MVR' section
	from #tmpAppl a (nolock) left join DL e (nolock) on a.apno = e.apno 
	Where e.Last_Updated <= OrigCompDate  UNION ALL
	Select a.clno,a.Name,a.Apno,apdate,ApStatus, OrigCompDate, No_of_Days_Complete,e.Last_Updated Amended,'Public Records' section
	from #tmpAppl a (nolock) left join Crim e (nolock) on a.apno = e.apno   and e.Ishidden = 0)
	Qry group by clno,Name,Apno,apdate,ApStatus,OrigCompDate,No_of_Days_Complete,section

	CREATE TABLE #tmpReport (CLNO INT,Name varchar(250),[App Number] INT, [App Created Date] Datetime, OrigCompDate DateTime,No_of_Days_Complete Int,[Saved Date/Time] DateTime,Available bit)

	if @SmartScreenPrediction = 0
		Insert into #tmpReport
		select CLNO,Name,apno ,apdate ,OrigCompDate,No_of_Days_Complete,max(amended),0   from #tmpApplReport 
		group by CLNO,Name,apno,apdate,apstatus,OrigCompDate,No_of_Days_Complete
	else
		Insert into #tmpReport
		select CLNO,Name,apno ,apdate ,OrigCompDate,No_of_Days_Complete,max(amended),1   from #tmpApplReport 
		where Section not in ('Employment','Education','Reference')
		group by CLNO,Name,apno,apdate,apstatus,OrigCompDate,No_of_Days_Complete
		union all
		select CLNO,Name,apno ,apdate ,OrigCompDate,No_of_Days_Complete,max(amended) ,0  from #tmpApplReport 
		where Section in ('Employment','Education','Reference')
		group by CLNO,Name,apno,apdate,apstatus,OrigCompDate,No_of_Days_Complete

	--select * from #tmpReport order by [App Number]

	If @ShowDetail = 1 
		select * from #tmpApplReport order by 1 
	else --show summary
		begin
			if @SmartScreenPrediction = 0
				Select a.CLNO ,a.Name ,a.[App Number] , a.[App Created Date] , a.OrigCompDate ,a.No_of_Days_Complete ,a.[Saved Date/Time],b.section [Last Type Saved Prior to Original Completion Date] from #tmpReport a
				inner join #tmpApplReport b on a.[App Number] = b.apno and a.[Saved Date/Time] = b.amended order by a.[App Number] 
			else
				Select a.CLNO ,a.Name ,a.[App Number] , a.[App Created Date] , a.OrigCompDate ,a.No_of_Days_Complete ,a.[Saved Date/Time],b.section [Last Type Saved Prior to Original Completion Date],dbo.elapsedbusinessdays_2(apdate,[Saved Date/Time] ) No_of_Days_Available, (a.No_of_Days_Complete - dbo.elapsedbusinessdays_2(apdate,[Saved Date/Time] )) [Potential Improvement in Days] from #tmpReport a
				inner join #tmpApplReport b on a.[App Number] = b.apno and a.[Saved Date/Time] = b.amended 
				where Available= @SmartScreenPrediction order by a.[App Number] 
		end


	drop table #tmpApplReport
	Drop table #tmpReport
	drop table #tmpAppl
END