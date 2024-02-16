

CREATE PROCEDURE [dbo].[ReportApplBySection]
@startdate datetime,
@enddate datetime
AS 

declare @Section char(10)

declare @Month1 datetime
declare @Month2 datetime
declare @Month3 datetime
declare @Month4 datetime
declare @Month5 datetime
declare @Month6 datetime
declare @Month7 datetime
declare @Month8 datetime
declare @Month9 datetime
declare @Month10 datetime
declare @Month11 datetime
declare @Month12 datetime
declare @Month13 datetime

set @Month1=@StartDate
set @Month2 =dateadd(mm,1,@StartDate)
set @Month3 =dateadd(mm,2,@StartDate)
set @Month4 =dateadd(mm,3,@StartDate)
set @Month5 =dateadd(mm,4,@StartDate)
set @Month6 =dateadd(mm,5,@StartDate)
set @Month7 =dateadd(mm,6,@StartDate)
set @Month8 =dateadd(mm,7,@StartDate)
set @Month9 =dateadd(mm,8,@StartDate)
set @Month10=dateadd(mm,9,@StartDate)
set @Month11=dateadd(mm,10,@StartDate)
set @Month12=dateadd(mm,11,@StartDate)
set @Month13=dateadd(mm,12,@StartDate)

select 	'Application' Section
        ,count(case when a.apdate>=@Month1 and a.apdate <@Month2 then (1) end) as Month1
        ,count(case when a.apdate>=@Month2 and a.apdate <@Month3 then (1) end) as Month2
        ,count(case when a.apdate>=@Month3 and a.apdate <@Month4  then (1) end) as Month3
        ,count(case when a.apdate>=@Month4 and a.apdate <@Month5  then (1) end) as Month4
	,count(case when a.apdate>=@Month5 and a.apdate <@Month6  then (1) end) as Month5
       	,count(case when a.apdate>=@Month6 and a.apdate <@Month7  then (1) end) as Month6
        ,count(case when a.apdate>=@Month7 and a.apdate <@Month8  then (1) end) as Month7
	,count(case when a.apdate>=@Month8 and a.apdate <@Month9  then (1) end) as Month8
	,count(case when a.apdate>=@Month9 and a.apdate <@Month10 then (1) end) as Month9
        ,count(case when a.apdate>=@Month10 and a.apdate<@Month11 then (1) end) as Month10
        ,count(case when a.apdate>=@Month11 and a.apdate<@Month12 then (1) end) as Month11
	,count(case when a.apdate>=@Month12 and a.apdate<@Month13 then (1) end) as Month12
        ,(count(1))Total
from appl a (NOLOCK) 
where a.apdate>=@startdate and a.apdate<=@EndDate
--group by Section 

union
select 'Employment' Section
	,count(case when a.apdate>=@Month1 and a.apdate <@Month2  then (1) end) as Month1
        ,count(case when a.apdate>=@Month2 and a.apdate <@Month3  then (1) end) as Month2
        ,count(case when a.apdate>=@Month3 and a.apdate <@Month4  then (1) end) as Month3
        ,count(case when a.apdate>=@Month4 and a.apdate <@Month5  then (1) end) as Month4
	,count(case when a.apdate>=@Month5 and a.apdate <@Month6  then (1) end) as Month5
       	,count(case when a.apdate>=@Month6 and a.apdate <@Month7  then (1) end) as Month6
        ,count(case when a.apdate>=@Month7 and a.apdate <@Month8  then (1) end) as Month7
	,count(case when a.apdate>=@Month8 and a.apdate <@Month9  then (1) end) as Month8
	,count(case when a.apdate>=@Month9 and a.apdate <@Month10 then (1) end) as Month9
        ,count(case when a.apdate>=@Month10 and a.apdate<@Month11 then (1) end) as Month10
        ,count(case when a.apdate>=@Month11 and a.apdate<@Month12 then (1) end) as Month11
	,count(case when a.apdate>=@Month12 and a.apdate<@Month13 then (1) end) as Month12
        ,(count(1))Total 
from empl e (NOLOCK) join appl a (NOLOCK) ON a.apno=e.apno
where a.apdate>=@startdate and a.apdate<=@EndDate and e.IsOnReport = 1
--group by @
union
select 'Education' Section
	,count(case when a.apdate>=@Month1 and a.apdate <@Month2  then (1) end) as Month1
        ,count(case when a.apdate>=@Month2 and a.apdate <@Month3  then (1) end) as Month2
        ,count(case when a.apdate>=@Month3 and a.apdate <@Month4  then (1) end) as Month3
        ,count(case when a.apdate>=@Month4 and a.apdate <@Month5  then (1) end) as Month4
	,count(case when a.apdate>=@Month5 and a.apdate <@Month6  then (1) end) as Month5
       	,count(case when a.apdate>=@Month6 and a.apdate <@Month7  then (1) end) as Month6
        ,count(case when a.apdate>=@Month7 and a.apdate <@Month8  then (1) end) as Month7
	,count(case when a.apdate>=@Month8 and a.apdate <@Month9  then (1) end) as Month8
	,count(case when a.apdate>=@Month9 and a.apdate <@Month10 then (1) end) as Month9
        ,count(case when a.apdate>=@Month10 and a.apdate<@Month11 then (1) end) as Month10
        ,count(case when a.apdate>=@Month11 and a.apdate<@Month12 then (1) end) as Month11
	,count(case when a.apdate>=@Month12 and a.apdate<@Month13 then (1) end) as Month12
        ,(count(1))Total  
from educat e (NOLOCK) join appl a (NOLOCK) ON a.apno=e.apno
where a.apdate>=@startdate and a.apdate<=@EndDate and e.IsOnReport = 1
--group by Section 

union
select 'MVR' Section
	,count(case when a.apdate>=@Month1 and a.apdate <@Month2  then (1) end) as Month1
        ,count(case when a.apdate>=@Month2 and a.apdate <@Month3  then (1) end) as Month2
        ,count(case when a.apdate>=@Month3 and a.apdate <@Month4  then (1) end) as Month3
        ,count(case when a.apdate>=@Month4 and a.apdate <@Month5  then (1) end) as Month4
	,count(case when a.apdate>=@Month5 and a.apdate <@Month6  then (1) end) as Month5
       	,count(case when a.apdate>=@Month6 and a.apdate <@Month7  then (1) end) as Month6
        ,count(case when a.apdate>=@Month7 and a.apdate <@Month8  then (1) end) as Month7
	,count(case when a.apdate>=@Month8 and a.apdate <@Month9  then (1) end) as Month8
	,count(case when a.apdate>=@Month9 and a.apdate <@Month10 then (1) end) as Month9
        ,count(case when a.apdate>=@Month10 and a.apdate<@Month11 then (1) end) as Month10
        ,count(case when a.apdate>=@Month11 and a.apdate<@Month12 then (1) end) as Month11
	,count(case when a.apdate>=@Month12 and a.apdate<@Month13 then (1) end) as Month12
        ,(count(1))Total  
from dl e (NOLOCK) join appl a (NOLOCK) ON a.apno=e.apno
where a.apdate>=@startdate and a.apdate<=@EndDate 
--group by Section 

union
select 'Med' Section
	,count(case when a.apdate>=@Month1 and a.apdate <@Month2  then (1) end) as Month1
        ,count(case when a.apdate>=@Month2 and a.apdate <@Month3  then (1) end) as Month2
        ,count(case when a.apdate>=@Month3 and a.apdate <@Month4  then (1) end) as Month3
        ,count(case when a.apdate>=@Month4 and a.apdate <@Month5  then (1) end) as Month4
	,count(case when a.apdate>=@Month5 and a.apdate <@Month6  then (1) end) as Month5
       	,count(case when a.apdate>=@Month6 and a.apdate <@Month7  then (1) end) as Month6
        ,count(case when a.apdate>=@Month7 and a.apdate <@Month8  then (1) end) as Month7
	,count(case when a.apdate>=@Month8 and a.apdate <@Month9  then (1) end) as Month8
	,count(case when a.apdate>=@Month9 and a.apdate <@Month10 then (1) end) as Month9
        ,count(case when a.apdate>=@Month10 and a.apdate<@Month11 then (1) end) as Month10
        ,count(case when a.apdate>=@Month11 and a.apdate<@Month12 then (1) end) as Month11
	,count(case when a.apdate>=@Month12 and a.apdate<@Month13 then (1) end) as Month12
        ,(count(1))Total  
from medinteg e (NOLOCK) join appl a (NOLOCK) ON a.apno=e.apno
where a.apdate>=@startdate and a.apdate<=@EndDate 
--group by Section  

union
select 'PersonalRef' Section
	,count(case when a.apdate>=@Month1 and a.apdate <@Month2  then (1) end) as Month1
        ,count(case when a.apdate>=@Month2 and a.apdate <@Month3  then (1) end) as Month2
        ,count(case when a.apdate>=@Month3 and a.apdate <@Month4  then (1) end) as Month3
        ,count(case when a.apdate>=@Month4 and a.apdate <@Month5  then (1) end) as Month4
	,count(case when a.apdate>=@Month5 and a.apdate <@Month6  then (1) end) as Month5
       	,count(case when a.apdate>=@Month6 and a.apdate <@Month7  then (1) end) as Month6
        ,count(case when a.apdate>=@Month7 and a.apdate <@Month8  then (1) end) as Month7
	,count(case when a.apdate>=@Month8 and a.apdate <@Month9  then (1) end) as Month8
	,count(case when a.apdate>=@Month9 and a.apdate <@Month10 then (1) end) as Month9
        ,count(case when a.apdate>=@Month10 and a.apdate<@Month11 then (1) end) as Month10
        ,count(case when a.apdate>=@Month11 and a.apdate<@Month12 then (1) end) as Month11
	,count(case when a.apdate>=@Month12 and a.apdate<@Month13 then (1) end) as Month12
        ,(count(1))Total  
from persref e (NOLOCK) join appl a (NOLOCK) ON a.apno=e.apno
where a.apdate>=@startdate and a.apdate<=@EndDate and e.IsOnReport = 1
--group by Section

union
select 'ProfLicense' Section
	,count(case when a.apdate>=@Month1 and a.apdate <@Month2  then (1) end) as Month1
        ,count(case when a.apdate>=@Month2 and a.apdate <@Month3  then (1) end) as Month2
        ,count(case when a.apdate>=@Month3 and a.apdate <@Month4  then (1) end) as Month3
        ,count(case when a.apdate>=@Month4 and a.apdate <@Month5  then (1) end) as Month4
	,count(case when a.apdate>=@Month5 and a.apdate <@Month6  then (1) end) as Month5
       	,count(case when a.apdate>=@Month6 and a.apdate <@Month7  then (1) end) as Month6
        ,count(case when a.apdate>=@Month7 and a.apdate <@Month8  then (1) end) as Month7
	,count(case when a.apdate>=@Month8 and a.apdate <@Month9  then (1) end) as Month8
	,count(case when a.apdate>=@Month9 and a.apdate <@Month10 then (1) end) as Month9
        ,count(case when a.apdate>=@Month10 and a.apdate<@Month11 then (1) end) as Month10
        ,count(case when a.apdate>=@Month11 and a.apdate<@Month12 then (1) end) as Month11
	,count(case when a.apdate>=@Month12 and a.apdate<@Month13 then (1) end) as Month12
        ,(count(1))Total  
from proflic e (NOLOCK) join appl a (NOLOCK) ON a.apno=e.apno
where a.apdate>=@startdate and a.apdate<=@EndDate and e.IsOnReport = 1
--group by Section

union
select 'Credit' Section
	,count(case when a.apdate>=@Month1 and a.apdate <@Month2  then (1) end) as Month1
        ,count(case when a.apdate>=@Month2 and a.apdate <@Month3  then (1) end) as Month2
        ,count(case when a.apdate>=@Month3 and a.apdate <@Month4  then (1) end) as Month3
        ,count(case when a.apdate>=@Month4 and a.apdate <@Month5  then (1) end) as Month4
	,count(case when a.apdate>=@Month5 and a.apdate <@Month6  then (1) end) as Month5
       	,count(case when a.apdate>=@Month6 and a.apdate <@Month7  then (1) end) as Month6
        ,count(case when a.apdate>=@Month7 and a.apdate <@Month8  then (1) end) as Month7
	,count(case when a.apdate>=@Month8 and a.apdate <@Month9  then (1) end) as Month8
	,count(case when a.apdate>=@Month9 and a.apdate <@Month10 then (1) end) as Month9
        ,count(case when a.apdate>=@Month10 and a.apdate<@Month11 then (1) end) as Month10
        ,count(case when a.apdate>=@Month11 and a.apdate<@Month12 then (1) end) as Month11
	,count(case when a.apdate>=@Month12 and a.apdate<@Month13 then (1) end) as Month12
        ,(count(1))total
from credit crd (NOLOCK) join appl a (NOLOCK) ON a.apno=crd.apno and RepType='C'
where a.apdate>=@startdate and a.apdate<=@EndDate 
--group by Section

union
select 'Social' Section
	,count(case when a.apdate>=@Month1 and a.apdate <@Month2  then (1) end) as Month1
        ,count(case when a.apdate>=@Month2 and a.apdate <@Month3  then (1) end) as Month2
        ,count(case when a.apdate>=@Month3 and a.apdate <@Month4  then (1) end) as Month3
        ,count(case when a.apdate>=@Month4 and a.apdate <@Month5  then (1) end) as Month4
	,count(case when a.apdate>=@Month5 and a.apdate <@Month6  then (1) end) as Month5
       	,count(case when a.apdate>=@Month6 and a.apdate <@Month7  then (1) end) as Month6
        ,count(case when a.apdate>=@Month7 and a.apdate <@Month8  then (1) end) as Month7
	,count(case when a.apdate>=@Month8 and a.apdate <@Month9  then (1) end) as Month8
	,count(case when a.apdate>=@Month9 and a.apdate <@Month10 then (1) end) as Month9
        ,count(case when a.apdate>=@Month10 and a.apdate<@Month11 then (1) end) as Month10
        ,count(case when a.apdate>=@Month11 and a.apdate<@Month12 then (1) end) as Month11
	,count(case when a.apdate>=@Month12 and a.apdate<@Month13 then (1) end) as Month12
        ,(count(1))total
from credit crd (NOLOCK) join appl a (NOLOCK) ON a.apno=crd.apno
where a.apdate>=@startdate and a.apdate<=@EndDate and RepType='S' 
--group by Section

union
select 'Civil' Section
	,count(case when a.apdate>=@Month1 and a.apdate <@Month2  then (1) end) as Month1
        ,count(case when a.apdate>=@Month2 and a.apdate <@Month3  then (1) end) as Month2
        ,count(case when a.apdate>=@Month3 and a.apdate <@Month4  then (1) end) as Month3
        ,count(case when a.apdate>=@Month4 and a.apdate <@Month5  then (1) end) as Month4
	,count(case when a.apdate>=@Month5 and a.apdate <@Month6  then (1) end) as Month5
       	,count(case when a.apdate>=@Month6 and a.apdate <@Month7  then (1) end) as Month6
        ,count(case when a.apdate>=@Month7 and a.apdate <@Month8  then (1) end) as Month7
	,count(case when a.apdate>=@Month8 and a.apdate <@Month9  then (1) end) as Month8
	,count(case when a.apdate>=@Month9 and a.apdate <@Month10 then (1) end) as Month9
        ,count(case when a.apdate>=@Month10 and a.apdate<@Month11 then (1) end) as Month10
        ,count(case when a.apdate>=@Month11 and a.apdate<@Month12 then (1) end) as Month11
	,count(case when a.apdate>=@Month12 and a.apdate<@Month13 then (1) end) as Month12
        ,(count(1))Total 
from civil e (NOLOCK) 
join appl a (NOLOCK) ON a.apno=e.apno
where a.apdate>=@startdate and a.apdate<=@EndDate 
--group by Section


union
select 'Criminal' Section
	,count(case when a.apdate>=@Month1 and a.apdate <@Month2  then (1) end) as Month1
        ,count(case when a.apdate>=@Month2 and a.apdate <@Month3  then (1) end) as Month2
        ,count(case when a.apdate>=@Month3 and a.apdate <@Month4  then (1) end) as Month3
        ,count(case when a.apdate>=@Month4 and a.apdate <@Month5  then (1) end) as Month4
	,count(case when a.apdate>=@Month5 and a.apdate <@Month6  then (1) end) as Month5
       	,count(case when a.apdate>=@Month6 and a.apdate <@Month7  then (1) end) as Month6
        ,count(case when a.apdate>=@Month7 and a.apdate <@Month8  then (1) end) as Month7
	,count(case when a.apdate>=@Month8 and a.apdate <@Month9  then (1) end) as Month8
	,count(case when a.apdate>=@Month9 and a.apdate <@Month10 then (1) end) as Month9
        ,count(case when a.apdate>=@Month10 and a.apdate<@Month11 then (1) end) as Month10
        ,count(case when a.apdate>=@Month11 and a.apdate<@Month12 then (1) end) as Month11
	,count(case when a.apdate>=@Month12 and a.apdate<@Month13 then (1) end) as Month12
        ,(count(1))Total  
from crim e (NOLOCK) join appl a (NOLOCK) ON a.apno=e.apno
where a.apdate>=@startdate and a.apdate<=@EndDate 
--group by Section
--order by Section

/*
union --for column Total 
select '' Total 
        ,count(case when a.apdate>=@Month1 and a.apdate <@Month2  then (1)end) as Month1
        ,count(case when a.apdate>=@Month2 and a.apdate <@Month3  then (1)end) as Month2
        ,count(case when a.apdate>=@Month3 and a.apdate <@Month4  then (1)end) as Month3
	,count(case when a.apdate>=@Month4 and a.apdate <@Month5  then (1)end) as Month4
	,count(case when a.apdate>=@Month5 and a.apdate <@Month6  then (1)end) as Month5
        ,count(case when a.apdate>=@Month6 and a.apdate <@Month7  then (1)end) as Month6
        ,count(case when a.apdate>=@Month7 and a.apdate <@Month8  then (1)end) as Month7
	,count(case when a.apdate>=@Month8 and a.apdate <@Month9  then (1)end) as Month8
	,count(case when a.apdate>=@Month9 and a.apdate <@Month10 then (1)end) as Month9
        ,count(case when a.apdate>=@Month10 and a.apdate<@Month11 then (1)end) as Month10
        ,count(case when a.apdate>=@Month11 and a.apdate<@Month12 then (1)end) as Month11
	,count(case when a.apdate>=@Month12 and a.apdate<@Month13 then (1)end) as Month12
        ,(count(1))total
from appl a 
where a.apdate>=@startdate and a.apdate<=@EndDate
--group by Section
order by Section 
*/

