
--[dbo].[CountyAverageHoursDaysByDateRangeStateCountyVendor09082017] '7/16/2017', '8/15/2017', '', ''
Create PROCEDURE [dbo].[CountyAverageHoursDaysByDateRangeStateCountyVendor09082017]
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
'select cc.county County, cc.State, isnull(CONVERT(DECIMAL(10,2),p.average), 0) [Avg Hrs], isnull(CONVERT(DECIMAL(10,2),p.average/24), 0) as [Avg Day], r.R_Name Vendor, Isnull(p.SearchCount, 0) as [Search Count]
from counties cc with (nolock) 
left join 
(SELECT round((avg(CONVERT(numeric(7,2), 
(dbo.GetBusinessDays(c.irisordered,c.last_updated) + ((case when datediff(hh,c.irisordered,c.last_updated) < 24 then datediff(hh,c.irisordered,c.last_updated) else 0 end)/24.0)))) * 24),0) as average,
c.cnty_no, c.vendorid, count(c.crimid) as SearchCount
FROM   counties cc   with (nolock) 
left join Crim c  with (nolock) on cc.cnty_no = c.cnty_no
where c.irisordered is not null and c.last_updated is not null 
and irisordered between CONVERT(Date, ''' +  convert(varchar(20), @StartDate, 103) + ''', 103) and  CONVERT(Date, ''' + convert(varchar(20), @EndDate, 103) + ''', 103)
  group by c.cnty_no, vendorid) p
on p.cnty_no = cc.cnty_no
left join [dbo].[Iris_Researcher_Charges] ic on ic.cnty_no = cc.cnty_no
left join [dbo].[Iris_Researchers] r on ic.researcher_id = r.R_id
where ic.researcher_default = ''Yes'' and Isnull(cc.County, '''') <> '''''
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





