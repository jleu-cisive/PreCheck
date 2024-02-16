

CREATE PROCEDURE [dbo].[Crim_Needs_Research_Status_Where_All_Other_Crims_are_Completed] 
	@StartDate datetime,
	@EndDate datetime,
    @Client int,
    @County_State_Country varchar(200)
AS
SET NOCOUNT ON
Declare @sql varchar(4000)
Declare @daterange varchar(500)
Declare @clientnumber varchar(500)
Declare @countystatecountrystring varchar(4000)

set @sql = 'SELECT distinct a.apno as [APNO], a.apdate as [Date], a.last as [Last Name], a.first as [First Name], a.middle as [Middle Name] 
FROM Appl a join Crim c
  ON a.apno = c.apno
WHERE a.apno not in
(select apno from crim where clear in(''O'',''R'','''',''V'',''X'',null,''E'',''M'',''N'',''W'')) and c.clear = ''I'''

if (cast(@StartDate as varchar(12)) <> '' and cast(@EndDate as varchar(12)) <> '')
begin
set @daterange = ' AND a.apDate >=  cast(' + '''' +  cast(@StartDate as varchar(12)) + '''' + ' as datetime) ' + ' AND a.apDate < cast(' + '''' + cast(DateAdd(d,1,@EndDate) as varchar(12)) + '''' + ' as datetime) '
set @sql = @sql + @daterange
end
if (@Client > 0)
begin
set @clientnumber = ' AND a.clno = '  + cast(@Client as varchar(12)) 
set @sql = @sql + @clientnumber
end

if (@County_State_Country <> '')
begin
declare @countystr varchar(4000)
set @countystatecountrystring = replace(@County_State_Country,',', ' ')
select @countystr = COALESCE(@countystr + ' or ', ' ') +  ' county like ''%' + [value] + '%''' from dbo.fn_Split(@countystatecountrystring, ' ')
set @sql = @sql + ' AND (' + @countystr + ')'
end
exec (@sql)





