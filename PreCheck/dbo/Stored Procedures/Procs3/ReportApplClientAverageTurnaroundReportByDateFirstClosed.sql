  
  
  
--EXEC [ReportApplClientAverageTurnaroundReportByDateFirstClosed] 0,'3/1/2021','3/31/2021',4  
  
/**  
Used OriginalCompDate to get the records recieved in the given time frame and also finalized  
**/  
  
  
CREATE PROCEDURE [dbo].[ReportApplClientAverageTurnaroundReportByDateFirstClosed]   
@CLNO int,   
@from_date datetime,   
@to_date datetime,  
@AffiliateID int  
  
AS  
  
if(@CLNO is null)  
begin  
set @Clno=0  
end  
  
--set @Affiliate = LTRIM(RTRIM(@Affiliate))  
  
if(@Affiliateid='' or @Affiliateid =0)  
begin  
set @Affiliateid=0  
end  
  
  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
--include the enddate in the results  
Set @to_date = DateAdd(d,1,@to_date)  
  
select [Result].[Turnaround Time],[Result].Count,[Result].Product,[Result].Percentage,[Result].[Cumulative %]   
into #tempTAT  
from  
(  
SELECT '0 Day' AS 'Turnaround Time',  
 (select COUNT( A.APNO ) from appl A with (nolock)   
 inner join Client C on A.CLNO = C.CLNO  
 inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID  
 where A.OrigCompDate >= @from_date and A.OrigCompDate < @to_date   
 and (@CLNO=0 OR A.CLNO = @CLNO)   
 AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)   
 --and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)   
 and apstatus in ('W','F')   
 and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ))=0   --  + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 0   
 ----group by RA.Affiliate)  
 group by RA.AffiliateID) as 'Count', 0 as 'Product',  
CAST( 100. * (select COUNT( A.APNO ) from appl A with (nolock)   
              inner join Client C on A.CLNO = C.CLNO  
     inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID  
   where OrigCompDate >= @from_date and OrigCompDate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO)   
   AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)   
  -- and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)   
   and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ))=0 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 0   
   ----group by RA.Affiliate)  
   group by RA.AffiliateID)/   
  (select count( A.APNO ) from appl A with (nolock)   
   inner join Client C on A.CLNO = C.CLNO  
   inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID  
   where OrigCompDate >= @from_date and OrigCompDate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO)   
   --and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)   
   AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)   
   and apstatus in ('W','F') --11  
   group by RA.AffiliateID --group by RA.Affiliate  
   ) AS NUMERIC( 5, 2 ) ) AS 'Percentage',  
CAST( 100. * (select COUNT( A.APNO ) from appl A with (nolock)   
   inner join Client C on A.CLNO = C.CLNO  
   inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID  
   where OrigCompDate >= @from_date and OrigCompDate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO)   
   --and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)   
      AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)   
   and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ))=0 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 0   
   --group by RA.Affiliate)  
   group by RA.AffiliateID) /  
  (select count(A.APNO ) from appl A with (nolock)   
   inner join Client C on A.CLNO = C.CLNO  
   inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID  
   where OrigCompDate >= @from_date and OrigCompDate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO)   
   --and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)   
      AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)   
   and apstatus in ('W','F') --11  
  -- group by RA.Affiliate  
   group by RA.AffiliateID) AS NUMERIC( 5, 2 ) ) as 'Cumulative %'  
from appl ap with (nolock)   
   inner join Client C on Ap.CLNO = C.CLNO  
   inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID  
where OrigCompDate >= @from_date and OrigCompDate < @to_date and apstatus in ('W','F') AND (@CLNO=0 OR Ap.CLNO = @CLNO)   
--and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)   
AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)   
--group by RA.Affiliate  
group by RA.AffiliateID  
UNION  
SELECT '1 Day',  
(select COUNT( A.APNO ) from appl A with (nolock)  
   inner join Client C on A.CLNO = C.CLNO  
   inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID   
where OrigCompDate >= @from_date and OrigCompDate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO)   
--and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)   
AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)    
and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ))=1 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 1   
group by RA.AffiliateID),   
(SELECT SUM(dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) FROM appl A with (nolock) inner join Client C on A.CLNO = C.CLNO inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID   
   where OrigCompDate >= @from_date and OrigCompDate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO)   
   --and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)   
   AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)  
   and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) = 1 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 1   
   group by RA.AffiliateID),  
CAST( 100. * (select COUNT( A.APNO ) from appl A with (nolock)   
   inner join Client C on A.CLNO = C.CLNO  
   inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID   
   where OrigCompDate >= @from_date and OrigCompDate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO)   
   --and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)   
   AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)  
   and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) = 1 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 1   
   group by RA.AffiliateID) /  
  (select count( A.APNO ) from appl A with (nolock)   
   inner join Client C on A.CLNO = C.CLNO  
   inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID   
   where OrigCompDate >= @from_date and OrigCompDate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO)   
   --and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)   
   AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)  
   and apstatus in ('W','F') --11  
   group by RA.AffiliateID) AS NUMERIC( 5, 2 ) ),  
CAST( 100. * (select COUNT( A.APNO ) from appl A with (nolock)   
   inner join Client C on A.CLNO = C.CLNO  
   inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID   
   where OrigCompDate >= @from_date and OrigCompDate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO)   
  -- and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)   
  AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)  
   and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) <= 1 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) <= 1   
   group by RA.AffiliateID) /  
  (select count( A.APNO ) from appl A with (nolock)   
  inner join Client C on A.CLNO = C.CLNO  
  inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID   
   where OrigCompDate >= @from_date and OrigCompDate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO)   
   --and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)   
   AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)  
   and apstatus in ('W','F') --11  
   group by RA.AffiliateID) AS NUMERIC( 5, 2 ) )  
from appl ap with (nolock)   
inner join Client C on Ap.CLNO = C.CLNO  
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID   
where OrigCompDate >= @from_date and OrigCompDate < @to_date and apstatus in ('W','F') AND   
(@CLNO=0 OR Ap.CLNO = @CLNO)   
--and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)  
AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)  
group by RA.AffiliateID  
UNION  
SELECT '2 Days',  
(select COUNT( A.APNO ) from appl A with (nolock)   
inner join Client C on A.CLNO = C.CLNO  
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID   
where OrigCompDate >= @from_date and OrigCompDate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO)   
--and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)  
AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)   
and apstatus in ('W','F') and  ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) = 2 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 2   
group by RA.AffiliateID),  
(SELECT SUM(dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) FROM appl A with (nolock) inner join Client C on A.CLNO = C.CLNO   
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID   
   where OrigCompDate >= @from_date and OrigCompDate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO)   
  -- and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)   
  AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)   
   and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) = 2 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 1   
   group by RA.AffiliateID),  
CAST( 100. * (select COUNT( A.APNO ) from appl A with (nolock)  
   inner join Client C on A.CLNO = C.CLNO  
   inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID    
   where OrigCompDate >= @from_date and OrigCompDate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO)  
    --and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)   
 AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)   
 and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ))=2 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 2   
   group by RA.AffiliateID) /  
  (select count( A.APNO ) from appl A with (nolock)   
  inner join Client C on A.CLNO = C.CLNO  
  inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID   
   where OrigCompDate >= @from_date and OrigCompDate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO)   
   --and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)   
   AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)   
   and apstatus in ('W','F') --11  
   group by RA.AffiliateID) AS NUMERIC( 5, 2 ) ),  
CAST( 100. * (select COUNT( A.APNO ) from appl A with (nolock)  
 inner join Client C on A.CLNO = C.CLNO  
 inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID  
   where OrigCompDate >= @from_date and OrigCompDate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO)   
  -- and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)   
  AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)   
   and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) ) <=2 --+ dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) <= 2   
   group by RA.AffiliateID) /  
  (select count( A.APNO ) from appl A with (nolock)   
  inner join Client C on A.CLNO = C.CLNO  
  inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID  
   where OrigCompDate >= @from_date and OrigCompDate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO)   
   --and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)  
     AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)   
    and apstatus in ('W','F') --11  
   group by RA.AffiliateID) AS NUMERIC( 5, 2 ) )  
from appl ap with (nolock)  
inner join Client C on Ap.CLNO = C.CLNO  
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID    
where OrigCompDate >= @from_date and OrigCompDate < @to_date and apstatus in ('W','F') AND (@CLNO=0 OR Ap.CLNO = @CLNO)   
--and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)   
  AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)   
group by RA.AffiliateID  
UNION  
SELECT '3 Days',  
(select COUNT( A.APNO) from appl A with (nolock)   
inner join Client C on A.CLNO = C.CLNO  
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID   
where OrigCompDate >= @from_date and OrigCompDate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO)   
--and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)   
  AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)   
and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ))=3 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 3   
group by RA.AffiliateID),  
(SELECT SUM(dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) FROM appl A with (nolock) inner join Client C on A.CLNO = C.CLNO inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID   
   where OrigCompDate >= @from_date and OrigCompDate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO)   
   --and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)  
     AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)    
   and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) = 3 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 1   
   group by RA.AffiliateID),  
CAST( 100. * (select COUNT( A.APNO ) from appl A with (nolock)   
   inner join Client C on A.CLNO = C.CLNO  
   inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID   
   where OrigCompDate >= @from_date and OrigCompDate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO)   
   --and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)   
   AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)  
   and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ))=3 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 3   
   group by RA.AffiliateID) /  
  (select count( A.APNO ) from appl A with (nolock)   
  inner join Client C on A.CLNO = C.CLNO  
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID   
   where OrigCompDate >= @from_date and OrigCompDate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO)   
   --and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)   
   AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)  
   and apstatus in ('W','F') --11  
   group by RA.AffiliateID) AS NUMERIC( 5, 2 ) ),   
CAST( 100. * (select COUNT( A.APNO ) from appl A with (nolock)   
inner join Client C on A.CLNO = C.CLNO  
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID   
   where OrigCompDate >= @from_date and OrigCompDate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO)   
  -- and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)   
  AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)  
   and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ))<=3 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) <= 3   
   group by RA.AffiliateID) /  
  (select count( A.APNO ) from appl A with (nolock)   
  inner join Client C on A.CLNO = C.CLNO  
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID   
   where OrigCompDate >= @from_date and OrigCompDate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO)   
  -- and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)  
  AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)   
   and apstatus in ('W','F') --11  
   group by RA.AffiliateID) AS NUMERIC( 5, 2 ) )  
from appl ap with (nolock)   
inner join Client C on Ap.CLNO = C.CLNO  
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID   
where OrigCompDate >= @from_date and OrigCompDate < @to_date and apstatus in ('W','F') AND (@CLNO=0 OR Ap.CLNO = @CLNO)   
--and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)  
   AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)   
group by RA.AffiliateID  
UNION  
SELECT '4 Days',  
(select COUNT( A.APNO ) from appl A with (nolock)   
inner join Client C on A.CLNO = C.CLNO  
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID   
where OrigCompDate >= @from_date and OrigCompDate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO)   
--and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)   
   AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)   
and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ))=4 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 4   
group by RA.Affiliate),  
(SELECT SUM(dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) FROM appl A with (nolock) inner join Client C on A.CLNO = C.CLNO inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID   
   where OrigCompDate >= @from_date and OrigCompDate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO)   
   --and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)   
      AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)   
   and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) = 4 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 1   
   group by RA.AffiliateID),  
CAST( 100. * (select COUNT( A.APNO ) from appl A with (nolock)   
inner join Client C on A.CLNO = C.CLNO  
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID   
   where OrigCompDate >= @from_date and OrigCompDate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO)   
   --and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)   
      AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)   
   and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ))=4 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 4   
   group by RA.AffiliateID) /  
  (select count( A.APNO ) from appl A with (nolock)   
   inner join Client C on A.CLNO = C.CLNO  
   inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID   
   where OrigCompDate >= @from_date and OrigCompDate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO)  
      AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)   
   -- and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)   
 and apstatus in ('W','F') --11  
   group by RA.AffiliateID) AS NUMERIC( 5, 2 ) ),  
CAST( 100. * (select COUNT( APNO ) from appl A with (nolock)   
inner join Client C on A.CLNO = C.CLNO  
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID   
   where OrigCompDate >= @from_date and OrigCompDate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO)   
   --and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)   
      AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)   
   and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ))<=4 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) <= 4   
   group by RA.AffiliateID) /  
  (select count( A.APNO ) from appl A with (nolock)  
   inner join Client C on A.CLNO = C.CLNO  
   inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID   
   where OrigCompDate >= @from_date and OrigCompDate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO)   
      AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)   
   --and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)   
   and apstatus in ('W','F') --11  
   group by RA.AffiliateID) AS NUMERIC( 5, 2 ) )  
from appl ap with (nolock)   
inner join Client C on Ap.CLNO = C.CLNO  
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID   
where OrigCompDate >= @from_date and OrigCompDate < @to_date and apstatus in ('W','F') AND (@CLNO=0 OR Ap.CLNO = @CLNO)   
   AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)   
--and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)  
group by RA.AffiliateID  
UNION  
SELECT '5 Days',  
(select COUNT( A.APNO ) from appl A with (nolock)   
inner join Client C on A.CLNO = C.CLNO  
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID  
where OrigCompDate >= @from_date and OrigCompDate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO)   
--and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)  
   AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)   
 and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ))=5 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 5   
group by RA.AffiliateID),  
(SELECT SUM(dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) FROM appl A with (nolock) inner join Client C on A.CLNO = C.CLNO inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID   
   where OrigCompDate >= @from_date and OrigCompDate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO)   
   --and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)   
   AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)   
   and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) = 5 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 1   
   group by RA.AffiliateID),  
CAST( 100. * (select COUNT( APNO ) from appl A with (nolock)   
inner join Client C on A.CLNO = C.CLNO  
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID   
   where OrigCompDate >= @from_date and OrigCompDate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO)   
   --and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)  
   AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)    
   and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ))=5 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 5   
   group by RA.AffiliateID) /  
  (select count( A.APNO ) from appl A with (nolock)  
   inner join Client C on A.CLNO = C.CLNO  
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID   
   where OrigCompDate >= @from_date and OrigCompDate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO)  
   -- and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)   
   AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)   
 and apstatus in ('W','F') --11  
   group by RA.AffiliateID) AS NUMERIC( 5, 2 ) ),  
CAST( 100. * (select COUNT( A.APNO ) from appl A with (nolock)   
inner join Client C on A.CLNO = C.CLNO  
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID   
   where OrigCompDate >= @from_date and OrigCompDate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO)   
  -- and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)  
   AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)   
    and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ))<=5 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) <= 5   
   group by RA.AffiliateID) /  
  (select count( A.APNO ) from appl A with (nolock)   
  inner join Client C on A.CLNO = C.CLNO  
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID  
   where OrigCompDate >= @from_date and OrigCompDate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO)   
   --and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)   
   AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)   
   and apstatus in ('W','F') --11  
   group by RA.AffiliateID) AS NUMERIC( 5, 2 ) )  
from appl ap with (nolock)   
inner join Client C on Ap.CLNO = C.CLNO  
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID   
where OrigCompDate >= @from_date and OrigCompDate < @to_date and apstatus in ('W','F')   
AND (@CLNO=0 OR Ap.CLNO = @CLNO)   
--and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)   
AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)   
group by RA.AffiliateID  
UNION  
SELECT '6+ Days',  
(select COUNT(A.APNO ) from appl A with (nolock)   
inner join Client C on A.CLNO = C.CLNO  
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID   
where OrigCompDate >= @from_date and OrigCompDate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO)   
--and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)   
AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)   
and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ))>=6 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) >= 6   
group by RA.AffiliateID),  
(SELECT SUM(dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) FROM appl A with (nolock) inner join Client C on A.CLNO = C.CLNO   
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID   
   where OrigCompDate >= @from_date and OrigCompDate < @to_date   
   and (@CLNO=0 OR A.CLNO = @CLNO)   
  -- and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)   
  AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)   
   and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) >= 6 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 1   
   group by RA.AffiliateID),  
CAST( 100. * (select COUNT( A.APNO ) from appl A with (nolock)   
inner join Client C on A.CLNO = C.CLNO  
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID   
   where OrigCompDate >= @from_date and OrigCompDate < @to_date   
   and (@CLNO=0 OR A.CLNO = @CLNO)  
    --and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)   
 AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)   
 and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) >= 6 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) >= 6   
   group by RA.AffiliateID) /  
  (select count( A.APNO ) from appl A with (nolock)  
  inner join Client C on A.CLNO = C.CLNO  
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID    
   where OrigCompDate >= @from_date and OrigCompDate < @to_date   
   and (@CLNO=0 OR A.CLNO = @CLNO)   
   --and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)   
   AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)   
   and apstatus in ('W','F') --11  
   group by RA.AffiliateID) AS NUMERIC( 5, 2 ) ),  
CAST( 100. * (select COUNT( A.APNO ) from appl A with (nolock)   
  inner join Client C on A.CLNO = C.CLNO  
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID   
   where OrigCompDate >= @from_date and OrigCompDate < @to_date and  
(@CLNO=0 OR A.CLNO = @CLNO)   
--and (@Affiliate='' or RA.Affiliate = @Affiliate)  
AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)    
and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) > = 0 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) >= 0  
   group by RA.AffiliateID) /  
  (select count( A.APNO ) from appl A with (nolock)   
  inner join Client C on A.CLNO = C.CLNO  
  inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID   
   where OrigCompDate >= @from_date and OrigCompDate < @to_date   
   and (@CLNO=0 OR A.CLNO = @CLNO)   
   --and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)   
   AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)   
   and apstatus in ('W','F')--11  
   group by RA.AffiliateID) AS NUMERIC( 5, 2 ) )  
from appl ap with (nolock)   
inner join Client C on Ap.CLNO = C.CLNO  
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID   
where OrigCompDate >= @from_date and OrigCompDate < @to_date   
and apstatus in ('W','F')   
AND (@CLNO=0 OR Ap.CLNO = @CLNO)   
--and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate))= @Affiliate)  
AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)   
group by RA.AffiliateID  
UNION  
SELECT 'Total',  
(select COUNT( A.APNO ) from appl A with (nolock)   
inner join Client C on C.CLNO = A.CLNO  
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID  
where OrigCompDate >= @from_date and OrigCompDate < @to_date  
 and (@CLNO=0 OR A.CLNO = @CLNO)   
-- and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)   
AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)   
 and apstatus in ('W','F')  
group by RA.AffiliateID), 0, 100, 100  
from appl ap with (nolock)  
inner join Client C on C.CLNO = Ap.CLNO  
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID   
where OrigCompDate >= @from_date and OrigCompDate < @to_date AND (@CLNO=0 OR Ap.CLNO = @CLNO)   
--and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)   
AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID)   
group by RA.AffiliateID  
) as [Result] order by 1 asc  
  
--select * from  #tempTAT order by Product  
  
  
SELECT [Final].[Turnaround Time],[Final].Count,Final.Percentage,Final.[Cumulative %]  
 FROM(  
SELECT T.[Turnaround Time],T.Count,T.Percentage,T.[Cumulative %],1 [SortOrder] from #tempTAT T  
UNION  
SELECT 'Average TAT'  as [Turnaround Time],  
(SELECT cast(  
              (SUM(#tempTAT.[Product])*1.0)/(select #tempTAT.[Count] from #tempTAT where #tempTAT.[Turnaround Time]='Total')  
     as NUMERIC( 5, 2 ))  as 'Count'   
 from #tempTAT   
 where #tempTAT.[Turnaround Time]<>'Total Count'),NULL as [Percentage],NULL as [Cumulative %],2 [SortOrder] from #tempTAT  
 ) [Final]  
 ORDER BY [SortOrder] asc  
  
drop table #tempTAT  
  
SET TRANSACTION ISOLATION LEVEL READ COMMITTED  
  
  
  
  
  
  
  
  