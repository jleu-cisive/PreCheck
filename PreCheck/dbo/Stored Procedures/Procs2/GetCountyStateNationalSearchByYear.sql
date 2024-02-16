-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE dbo.GetCountyStateNationalSearchByYear
	-- Add the parameters for the stored procedure here
@SearchYear Int

AS
BEGIN
	-- Region Parameters


DECLARE @totalCount int
DECLARE @stateCount int
DECLARE @nationalCount int
DECLARE @dpsCount int
DECLARE @countyCount int
DECLARE @statewide VarChar(1000) = '%**STATEWIDE**%'
DECLARE @dps VarChar(1000) = '%DPS%'
DECLARE @national VarChar(1000) = '%National%'
DECLARE @countyAvg decimal(3, 2)
DECLARE @stateAvg decimal(3, 2)
DECLARE @nationalAvg decimal(3, 2)

Declare @searchTable table
(
 Year int,
 total int,
 statetotal int,
 countytotal int,
 nationaltotal int,
 avgstate float,
 avgcounty float,
 avgnational float
)
-- EndRegion
 set @totalCount = (SELECT COUNT(*) AS [value]
FROM [Crim] AS [t0]
WHERE (DATEPART(Year, [t0].[Crimenteredtime]) = @SearchYear))


set @stateCount = (SELECT COUNT(*) AS [value]
FROM [Crim] AS [t0]
WHERE ([t0].[County] LIKE @statewide) AND (DATEPART(Year, [t0].[Crimenteredtime]) = @SearchYear)) 


set @dpsCount  = (SELECT COUNT(*) AS [value]
FROM [Crim] AS [t0]
WHERE ([t0].[County] LIKE @dps) AND (DATEPART(Year, [t0].[Crimenteredtime]) = @SearchYear)) 


set @nationalCount = (SELECT COUNT(*) AS [value]
FROM [Crim] AS [t0]
WHERE ([t0].[County] LIKE @national) AND (DATEPART(Year, [t0].[Crimenteredtime]) = @SearchYear)) 

set @nationalCount = @nationalCount + @dpsCount;
set @countyCount = @totalCount - (@stateCount + @nationalCount);

set @stateAvg = CAST(@stateCount AS float) / CAST(@totalCount AS float); 
set @countyAvg = CAST(@countyCount AS float) / CAST(@totalCount AS float); 
set @nationalAvg = CAST(@nationalCount AS float) / CAST(@totalCount AS float);

insert into @searchTable (year, total, statetotal, countytotal, nationaltotal, avgstate, avgcounty, avgnational)
select @SearchYear, @totalCount, @stateCount, @countyCount, @nationalCount, @stateAvg, @countyAvg, @nationalAvg;


select Year, total as '# of Applicants', statetotal as '# of State Searches', countytotal as '# of County Searches', nationaltotal as 
'# of National Searches', avgstate as 'Avg. state search p/report', avgcounty as 'Avg. county search p/report', avgnational as 
'Avg. national search p/report' from @searchTable;


END
