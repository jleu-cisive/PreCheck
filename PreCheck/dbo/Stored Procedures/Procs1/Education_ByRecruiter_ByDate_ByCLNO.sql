CREATE PROCEDURE [dbo].[Education_ByRecruiter_ByDate_ByCLNO] 
	@StartDate datetime,
	@EndDate datetime,
    @Client varchar(4000),
    @ContactName varchar(200),
	@ByAppSubmissionDate bit = 0
AS
SET NOCOUNT ON
Declare @sql varchar(4000)
Declare @contactnamerystring varchar(4000)


--exec [Education_ByRecruiter_ByDate_ByCLNO] '01/08/2013','01/18/2013','1934,1932','',1
--exec [Education_ByRecruiter_ByDate_ByCLNO] '01/08/2013','01/18/2013',1934,'Bredy Carline',1

--set @sql = 'select CLNO, Attn as [Contact Name], a. APNO, Last as [Last Name], First as [First Name], ApStatus, UserID as [CAM], ApDate as [Application Date], CompDate as [Completed Date], e.School, e.Pub_Notes as Pub_Notes, e.Degree_V from appl a inner join dbo.Educat e (NOLOCK)  on a.APNO = e.APNO 
--inner join SectStat s (NOLOCK) on e.SectStat = s.code where clno=' + cast(@Client as varchar(12)) + ' and apstatus in ( ''F'', ''P'') '


set @sql = 'select CLNO, Attn as [Contact Name], a. APNO, Last as [Last Name], First as [First Name], ApStatus, UserID as [CAM], ApDate as [Application Date], CompDate as [Completed Date], e.School, e.Degree_V from appl a inner join dbo.Educat e (NOLOCK)  on a.APNO = e.APNO 
inner join SectStat s (NOLOCK) on e.SectStat = s.code where (clno IS NULL OR clno =' + cast(@Client as varchar(12)) + ') and apstatus in ( ''F'', ''P'') '


if isnull(@ByAppSubmissionDate,0) = 0
	set @sql = @sql + 'and compdate>= cast(' + '''' +  cast(@StartDate as varchar(12)) + '''' + ' as datetime) ' + ' and compdate<  cast(' + '''' +  cast(DateAdd(d, 1, @EndDate) as varchar(12)) + '''' + ' as datetime) ' 
else
	set @sql = @sql + 'and ApDate>= cast(' + '''' +  cast(@StartDate as varchar(12)) + '''' + ' as datetime) ' + ' and ApDate<  cast(' + '''' +  cast(DateAdd(d, 1, @EndDate) as varchar(12)) + '''' + ' as datetime) ' 

if (@ContactName <> '')
begin
declare @contactstr varchar(4000)
set @contactnamerystring = replace(@ContactName,',', ' ')
select @contactstr = COALESCE(@contactstr + ' or ', ' ') +  ' Attn like ''%' + [value] + '%''' from dbo.fn_Split(@contactnamerystring, ' ')
set @sql = @sql + ' AND (' + @contactstr + ')'
end
exec (@sql)

