
--[dbo].[CountyAverageHoursDaysByDateRangeStateCountyVendor] '04/08/2019', '04/15/2019', '', '', ''
CREATE PROCEDURE [dbo].[CountyAverageHoursDaysByDateRangeStateCountyVendor]
	@StartDate Date,
	@EndDate Date,
    @County varchar(40) = NULL,
    @State varchar(25) = NULL,
    @Vendor varchar(50) =NULL

AS

--DECLARE @StartDate datetime,@EndDate datetime,@County varchar(100),@State varchar(10), @Vendor varchar(500), @SQL varchar(4000);
--SET @StartDate = '1/1/2017';
--SET @EndDate = '2/1/2017';
--SET @County = 'KINNEY, TX';
--SET @State = 'TX';
--SET @Vendor = 'TEXAS DPS DATABASE**INHOUSE**';
DECLARE @SQL varchar(4000);
if DATEDIFF(m,@StartDate,@EndDate) >= 13
BEGIN
select 'Date range is equal or larger than 13 months.'
END
ELSE
BEGIN


SET @County = isnull(@County, '');
SET @State = isnull(@State, '');
SET @Vendor = isnull(@Vendor, '');

SET @SQL = 
'select distinct cc.county County, cc.State, isnull(CONVERT(DECIMAL(10,2),p.average), 0) [Avg Hrs], isnull(CONVERT(DECIMAL(10,2),p.average/24), 0) as [Avg Day], r.R_Name Vendor, Isnull(p.SearchCount, 0) as [Search Count]
from counties cc with (nolock) 
left join [dbo].[Iris_Researcher_Charges] ic on ic.cnty_no = cc.cnty_no
left join [dbo].[Iris_Researchers] r on ic.researcher_id = r.R_id
left join 
(SELECT round((avg(CONVERT(numeric(7,2), 
(dbo.GetBusinessDays( ISNULL(irisordered,CONVERT(DATETIME, C.Ordered)),c.last_updated) + ((case when datediff(hh, ISNULL(irisordered,CONVERT(DATETIME, C.Ordered)),c.last_updated) < 24 then datediff(hh, ISNULL(irisordered,CONVERT(DATETIME, C.Ordered)),c.last_updated) else 0 end)/24.0)))) * 24),0) as average,
c.cnty_no, c.vendorid, count(c.crimid) as SearchCount
FROM   counties cc   with (nolock) 
left join Crim c  with (nolock) on cc.cnty_no = c.cnty_no
where ' --c.irisordered is not null and 
+ ' c.last_updated is not null and 
 ISNULL(C.irisordered,CONVERT(DATETIME, case when ISDATE(C.Ordered) = 1 Then C.Ordered else null end)) between CONVERT(Date, ''' +  convert(varchar(20), @StartDate, 103) + ''', 103) and  CONVERT(Date, ''' + convert(varchar(20), @EndDate, 103) + ''', 103)
  group by c.cnty_no, vendorid) p
on r.R_id = p.vendorid and cc.cnty_no = p.cnty_no

where ((ic.researcher_default = ''Yes'') or (ic.researcher_default = ''No'' and p.SearchCount > 0))'
--p.vendorid is null and ic.Researcher_id is not null) or (p.vendorid = ic.Researcher_id))
--'
--ic.researcher_default = ''Yes'' and 

IF @State IS NOT NULL and @State <> ''
 SET @SQL = @SQL + ' and State like ''%'  +  @State  + '%'''

 IF @County IS NOT NULL and @County <> ''
 SET @SQL = @SQL + ' and County like ''%' + @County + '%'''

 IF @Vendor IS NOT NULL and @Vendor <> '' 
 SET @SQL = @SQL + ' and R_Name like ''%' + @Vendor + '%'''

 --print @SQL
 
EXEC(@SQL)

END





