

--CAMActivityReport_Humera '','8/3/2019','8/9/2019'

-- =============================================
-- Date: July 4, 2001
-- Author: Pat Coffer
-- =============================================
CREATE PROCEDURE [dbo].[CAMActivityReport_Humera]
@CAM  varchar(8),
@FromDate Datetime,
@Todate DateTime
AS
SET NOCOUNT ON


set @Todate = dateAdd(d,1,@Todate)

Declare @pending int,@5daysold int, @closed int, @TBF int

SELECT   UserID,id into #tempChangeLog
FROM         dbo.ChangeLog with (nolock)
WHERE     (TableName = 'Appl.ApStatus') and Newvalue = 'F' and OldValue = 'P'
and ChangeDate between @FromDate and @Todate
order by UserID


SELECT  UserID, id INTO #tempInProgressReviewd
FROM dbo.ChangeLog WITH (NOLOCK)
WHERE  (TableName = 'Appl.InProgressReviewed') and Newvalue = 'True' and OldValue = 'False'
and ChangeDate between @FromDate and @Todate
and UserID is not null
ORDER BY UserID


SELECT  distinct userID into #tempUSER1
FROM        APPL with (nolock) 
WHERE    
appl.ApStatus IN ('F','W')
and appl.CompDate between @FromDate and @Todate
and UserID is not null
order by UserID

 
insert into #tempUSER1
(userID)
(select  distinct userID
FROM      #tempChangeLog)


insert into #tempUSER1
(userID)
(select distinct userID 
FROM #tempInProgressReviewd)

SELECT  distinct userID into #tempUSER
FROM      #tempUSER1 
order by UserID

--SELECT   userID from #tempUSER


create table #tmpAppl ( Apno int,ApStatus char(1),UserID varchar(8), Investigator varchar(8),
       ApDate Datetime, ReopenDate Datetime,  Last varchar(50), First varchar(50), Middle varchar(50), 
       Client_Name varchar(100))

insert into #tmpAppl
--exec [ApplToBeFinaled]
EXEC [ApplToBeFinaled_Humera]

--select * from #tmpAppl 

Select 'AUTO CLOSE' as UserID,'AUTO CLOSE' as Name,0 as 'Pending',0 as '3daysold',0 as '5daysold', (select count(*) from ApplAutoCloseLog t where ClosedOn  between @FromDate and @Todate) as 'Total Closed where Assigned',
 0 as 'Closed by Own' ,0 as 'Closed of Others' , 0 as 'OriginalClosed' ,0 as 'Total In-Progress Review', 0  as 'TBF'
 union
select U.UserID, US.Name,
(select  count(*)  from appl a1 with (nolock)where    a1.UserID = U.UserID and  a1.ApStatus IN ('P','W')) as 'Pending',
(select count(*) from appl a2 with (nolock) where (CONVERT(numeric(7,2), dbo.ElapsedBusinessDays_3(a2.ApDate, getdate())))>= 3.0 AND a2.ApStatus IN ('P','W')and a2.origcompdate is null and a2.UserID = U.UserID) as '3daysold',
(select count(*) from appl a2 with (nolock) where (CONVERT(numeric(7,2), dbo.ElapsedBusinessDays_3(a2.ApDate, getdate())))>= 5.0 AND a2.ApStatus IN ('P','W')and a2.origcompdate is null and a2.UserID = U.UserID) as '5daysold',
(select count(*) from appl a3 with (nolock) where a3.UserID = U.UserID  and ((a3.CompDate  between @FromDate and @Todate))) as 'Total Closed where Assigned' ,
(select count(*) from #tempChangeLog t where t.UserID = U.UserID and  id in (select a4.APNO from appl a4 with (nolock)where a4.UserID = U.UserID  and (a4.CompDate  between @FromDate and @Todate))  ) as 'Closed by Own' ,
(select count(*) from #tempChangeLog t where t.UserID = U.UserID and  id not in (select a5.APNO from appl a5 with (nolock)where a5.UserID = U.UserID  and (a5.CompDate  between @FromDate and @Todate))  ) as 'Closed of Others' ,
(select count(*) from #tempChangeLog t where t.UserID = U.UserID ) as 'OriginalClosed' ,
(select count(*) from #tempInProgressReviewd t where t.UserID = U.UserID) as 'Total In-Progress Review',
(Select  count(*)  from  #tmpAppl where #tmpAppl.UserID =U.UserID) as 'TBF'
from #tempUSER U
left join Users US on US.UserID = U.UserID


DROP TABLE #tempChangeLog

DROP TABLE #tempUSER

DROP TABLE #tempUSER1

DROP TABLE #tempInProgressReviewd






