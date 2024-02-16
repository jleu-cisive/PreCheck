CREATE PROCEDURE [dbo].[Recruiter_Submissions_Report] 
	@StartDate datetime,
	@EndDate datetime,
    @Client int,
    @ContactName varchar(200),
	@ByAppSubmissionDate bit = 0, --schapyala Added this based on Adair's Request to pull apps by ApDate and not completionDate on 01/29/2013
	@AffiliateName varchar(max) = NULL
AS
SET NOCOUNT ON
Declare @sql varchar(4000)
Declare @contactnamerystring varchar(4000)

if(@Client is null or ltrim(rtrim(cast(@Client as varchar(12))))='' or ltrim(rtrim(lower(cast(@Client as varchar(12)))))='null')
begin
  set @Client=0
end

--exec [Recruiter_Submissions_Report] '01/08/2013','01/18/2013',7898,'',1,'None'

set @sql = 'select a.CLNO as [Client ID], ra.Affiliate,Attn as [Contact Name], a.APNO as [Report Number], Last as [Last Name], First as [First Name], ApStatus, UserID as [CAM], (dbo.elapsedbusinessdays_2( Apdate, CompDate ) ) as [TAT], ApDate as [Application Date], CompDate as [Completed Date]  
from appl a inner join client c on a.clno = c.clno inner join refAffiliate ra on ra.AffiliateID = c.AffiliateID where ('+cast(@Client as varchar(12)) +'=0 or a.clno=' + cast(@Client as varchar(12)) + ') and apstatus in ( ''F'', ''P'') and ('''+@AffiliateName+''' IS NULL OR RA.Affiliate LIKE ''%' + @AffiliateName + '%'')'

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

