
--
-- =============================================
-- Author:		Kiran miryala
-- Create date: 3/23/2020
-- Description:	Projected Billing numbers
-- EXEC LMP_Monthly_Reporting_Numbers
-- =============================================
CREATE PROCEDURE [dbo].[Monthly_Projected_Biling_Numbers]
--@startdate datetime Null,
--@enddate datetime null
AS
BEGIN

	SET NOCOUNT ON;

declare @startdate datetime 
declare @enddate datetime 

set @startdate = DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0) 
set @enddate = DATEADD(ss,-1, DATEADD(MONTH,1,@startdate))

set @startdate = dateAdd(dd,-1,@startdate)

--if @startdate  = CAST(DATEADD(DAY,-DAY(GETDATE())+1, CAST(GETDATE() AS DATE)) AS DATETIME)
--begin
--set @startdate =  DATEADD(month, -1,@startdate) 
--set @enddate = DATEADD(ss,-1, DATEADD(MONTH,1,@startdate))
--End
--Select CONVERT(varchar, @startdate, 1) ,@enddate,CAST(DATEADD(DAY,-DAY(GETDATE())+1, CAST(GETDATE() AS DATE)) AS DATETIME), CONVERT(varchar, GETDATE(), 1)
if CONVERT(varchar, @startdate, 1)  = CONVERT(varchar, GETDATE(), 1)
begin
set @startdate =  DATEADD(month, -1,@startdate) 
set @enddate = DATEADD(ss,-1, DATEADD(MONTH,1,@startdate))
End

--Select @startdate ,@enddate

Select CompDate,day,clno,replace(Name,',',' ') Name,replace([Accounting System Grouping],',',' ') [Accounting System Grouping],Sum(Amount) Amount ,sum([Reports closed]) [Reports closed] ,
sum([Reports Received]) [Reports Received], sum([special project Report count]) [special project Report count]
into #temp1 
from (
select 
--A.Apno,A.clno,c.Name,[Accounting System Grouping],OrigCompDate,Last,First,Middle,ServiceType, SubKey, SubKeyChar, CreateDate, 
--LastUpdateDate, FeeDescription, Amount, IsDeleted 
CONVERT(varchar, OrigCompDate, 1) CompDate,DATEPART(dw,OrigCompDate) as day, 
A.clno,c.Name,[Accounting System Grouping],
Sum(amount) Amount,count(distinct a.APNO) [Reports closed] ,0 [Reports Received],0 [special project Report count]
--into #temp1
from Appl A inner join Client c on a.clno = c.clno
inner join InvDetailsParallel i on a.apno = i.apno
 where   OrigCompDate > @startdate and OrigCompDate < @enddate
  and a.CLNO not in (12453,2135,3079,3668,14059,13110,14079,3468,16022,16023,10324,11104,16024)
  and EnteredVia <> 'System'
 group by CONVERT(varchar, OrigCompDate, 1),DATEPART(dw,OrigCompDate),A.clno,c.Name,[Accounting System Grouping]
 --order by CONVERT(varchar, OrigCompDate, 1)
 union all
 Select CONVERT(varchar, ApDate, 1) CompDate,DATEPART(dw,ApDate) as day,
 A.clno,c.Name,[Accounting System Grouping], 0 Amount, 0 [Reports closed] ,count(distinct a.APNO) [Reports Received],0 [special project Report count]
 from Appl A inner join Client c on a.clno = c.clno
 where   ApDate > @startdate and ApDate < @enddate
 and a.CLNO not in (12453,2135,13110,14079,3468,16022,16023,16024,10324,11104,5559,9388,7335)
 and EnteredVia <> 'System'
 and a.Investigator not in ('DSOnly','Immuniz')
 group by CONVERT(varchar, ApDate, 1),DATEPART(dw,ApDate),A.clno,c.Name,[Accounting System Grouping]
 
 --special project 
 union all
 Select CONVERT(varchar, ApDate, 1) CompDate,DATEPART(dw,ApDate) as day,
 A.clno,c.Name,[Accounting System Grouping], 0 Amount, 0 [Reports closed] ,0 [Reports Received],count(distinct a.APNO) [special project Report count]
 from Appl A inner join Client c on a.clno = c.clno
 where   ApDate > @startdate and ApDate < @enddate
 and a.CLNO not in (12453,2135,3079,3668,14059,13110,14079,3468,3079,14059,14255,16022,16023,16024)
 and (EnteredVia = 'System' or a.clno in (5559,9388,7335,10324,11104))
 group by CONVERT(varchar, ApDate, 1),DATEPART(dw,ApDate),A.clno,c.Name,[Accounting System Grouping]
  )t
 group by CONVERT(varchar, CompDate, 1),day,clno,Name,[Accounting System Grouping]
order by CONVERT(varchar, CompDate, 1)



 --select A.Apno,A.clno,c.Name,[Accounting System Grouping],OrigCompDate,Last,First,Middle
 --from Appl A inner join Client c on a.clno = c.clno
 --where Apdate >'3/1/2020'

 select (case when day= 7 then dateadd(d,-1,CompDate) else 
 (case when day= 1 then dateadd(d,1,CompDate) else CompDate end) end) CalculateCompdate
 ,* into #temp2
 from #temp1 order by compdate

 Delete #temp2 where month(CalculateCompdate)<> month(compdate)

 --select * from #temp2  where month(CalculateCompdate)<> month(compdate)

 -- select * from #temp1 order by compdate
 select  'Projected Daily Revenue' FileType,CalculateCompdate as BusinessDate,Sum(Amount) Amount,sum([Reports closed]) [Reports closed],sum([Reports Received]) [Reports Received] ,sum([special project Report count]) [special project Report count]
 from #temp2 --where clno = 16074 
 group by CalculateCompdate
 order by CalculateCompdate


 select 'Daily Revenue By Client' FileType,CalculateCompdate as BusinessDate,clno,Name,[Accounting System Grouping],Sum(Amount) Amount,sum([Reports closed]) [Reports closed],sum([Reports Received]) [Reports Received] ,sum([special project Report count]) [special project Report count]
 from #temp2
 group by CalculateCompdate,clno,Name,[Accounting System Grouping]
 Order by clno,CalculateCompdate

  select 'Monthly Revenue by Client ' FileType,clno,Name,[Accounting System Grouping],Sum(Amount) Amount,sum([Reports closed]) [Reports closed],sum([Reports Received]) [Reports Received] ,sum([special project Report count]) [special project Report count]
 from #temp2
 group by clno,Name,[Accounting System Grouping]
 Order by clno desc

 -- select [Accounting System Grouping],Sum(Amount) Amount,sum([Reports closed]) [Reports closed],sum([Reports Received]) [Reports Received] ,sum([special project Report count]) [special project Report count]
 --from #temp2
 --group by clno,Name,[Accounting System Grouping]
 --Order by clno desc

-- DECLARE 
--    @columns NVARCHAR(MAX) = '';
 
--SELECT 
--  @columns += BusinessDate+ ','
--FROM 
--    (select distinct CONVERT(varchar, CalculateCompdate, 1) as BusinessDate from #temp2) t
--ORDER BY 
--    BusinessDate;

 
--SET @columns = LEFT(@columns, LEN(@columns) - 1);
 
----PRINT @columns;

--SELECT * FROM   
--(
--    SELECT 
--        [Accounting System Grouping], 
--        Amount,
--        CalculateCompdate 
--    FROM 
--        #temp2
--) t 
--PIVOT(
--    Sum(Amount) 
--    FOR CalculateCompdate IN (@columns )
--) AS pivot_table;

--SELECT * FROM   
--(
--    SELECT 
--        category_name, 
--        product_id,
--        model_year
--    FROM 
--        production.products p
--        INNER JOIN production.categories c 
--            ON c.category_id = p.category_id
--) t 
--PIVOT(
--    COUNT(product_id) 
--    FOR category_name IN (
--        [Children Bicycles], 
--        [Comfort Bicycles], 
--        [Cruisers Bicycles], 
--        [Cyclocross Bicycles], 
--        [Electric Bikes], 
--        [Mountain Bikes], 
--        [Road Bikes])
--) AS pivot_table;
 drop Table #temp1
  drop Table #temp2
 END