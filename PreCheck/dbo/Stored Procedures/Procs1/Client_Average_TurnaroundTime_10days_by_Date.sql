﻿
-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 09/21/2017
-- Description: Client based have two Big 4 clients CHI and HCA has requested us for TAT reports specific accounts for 10+days
--EXEC [Client_Average_TurnaroundTime_10days_by_Date] 0,'3/1/2017','3/31/2017','MD Anderson'
-- =============================================

/**
Used Apdate instead of compdate to get the records recieved in the given time frame and also finalized
**/


CREATE PROCEDURE [dbo].[Client_Average_TurnaroundTime_10days_by_Date] 
@CLNO int, 
@from_date datetime, 
@to_date datetime,
@Affiliate varchar(50)

AS

if(@CLNO is null)
begin
set @Clno=0
end

set @Affiliate = LTRIM(RTRIM(@Affiliate))

if(@Affiliate is null or @Affiliate='null' or @Affiliate='')
begin
set @Affiliate=''
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
where A.Apdate >= @from_date and A.Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ))=0   --  + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 0 
group by RA.Affiliate) as 'Count', 0 as 'Product',
CAST( 100. * (select COUNT( A.APNO ) from appl A with (nolock) 
              inner join Client C on A.CLNO = C.CLNO
			  inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ))=0 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 0 
   group by RA.Affiliate) /
  (select count( A.APNO ) from appl A with (nolock) 
   inner join Client C on A.CLNO = C.CLNO
   inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') --11
   group by RA.Affiliate) AS NUMERIC( 5, 2 ) ) AS 'Percentage',
CAST( 100. * (select COUNT( A.APNO ) from appl A with (nolock) 
   inner join Client C on A.CLNO = C.CLNO
   inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ))=0 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 0 
   group by RA.Affiliate) /
  (select count(A.APNO ) from appl A with (nolock) 
   inner join Client C on A.CLNO = C.CLNO
   inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') --11
   group by RA.Affiliate) AS NUMERIC( 5, 2 ) ) as 'Cumulative %'
from appl ap with (nolock) 
   inner join Client C on Ap.CLNO = C.CLNO
   inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID
where Apdate >= @from_date and Apdate < @to_date and apstatus in ('W','F') AND (@CLNO=0 OR Ap.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) 
group by RA.Affiliate
UNION
SELECT '1 Day',
(select COUNT( A.APNO ) from appl A with (nolock)
   inner join Client C on A.CLNO = C.CLNO
   inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)  and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ))=1 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 1 
group by RA.Affiliate), 
(SELECT SUM(dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) FROM appl A with (nolock) inner join Client C on A.CLNO = C.CLNO inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) = 1 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 1 
   group by RA.Affiliate),
CAST( 100. * (select COUNT( A.APNO ) from appl A with (nolock) 
   inner join Client C on A.CLNO = C.CLNO
   inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) = 1 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 1 
   group by RA.Affiliate) /
  (select count( A.APNO ) from appl A with (nolock) 
   inner join Client C on A.CLNO = C.CLNO
   inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') --11
   group by RA.Affiliate) AS NUMERIC( 5, 2 ) ),
CAST( 100. * (select COUNT( A.APNO ) from appl A with (nolock) 
   inner join Client C on A.CLNO = C.CLNO
   inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) <= 1 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) <= 1 
   group by RA.Affiliate) /
  (select count( A.APNO ) from appl A with (nolock) 
  inner join Client C on A.CLNO = C.CLNO
  inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') --11
   group by RA.Affiliate) AS NUMERIC( 5, 2 ) )
from appl ap with (nolock) 
inner join Client C on Ap.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
where Apdate >= @from_date and Apdate < @to_date and apstatus in ('W','F') AND 
(@CLNO=0 OR Ap.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)
group by RA.Affiliate
UNION
SELECT '2 Days',
(select COUNT( A.APNO ) from appl A with (nolock) 
inner join Client C on A.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') and  ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) = 2 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 2 
group by RA.Affiliate),
(SELECT SUM(dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) FROM appl A with (nolock) inner join Client C on A.CLNO = C.CLNO inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) = 2 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 1 
   group by RA.Affiliate),
CAST( 100. * (select COUNT( A.APNO ) from appl A with (nolock)
   inner join Client C on A.CLNO = C.CLNO
   inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID  
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ))=2 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 2 
   group by RA.Affiliate) /
  (select count( A.APNO ) from appl A with (nolock) 
  inner join Client C on A.CLNO = C.CLNO
  inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') --11
   group by RA.Affiliate) AS NUMERIC( 5, 2 ) ),
CAST( 100. * (select COUNT( A.APNO ) from appl A with (nolock)
 inner join Client C on A.CLNO = C.CLNO
 inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) ) <=2 --+ dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) <= 2 
   group by RA.Affiliate) /
  (select count( A.APNO ) from appl A with (nolock) 
  inner join Client C on A.CLNO = C.CLNO
  inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') --11
   group by RA.Affiliate) AS NUMERIC( 5, 2 ) )
from appl ap with (nolock)
inner join Client C on Ap.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID  
where Apdate >= @from_date and Apdate < @to_date and apstatus in ('W','F') AND (@CLNO=0 OR Ap.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) 
group by RA.Affiliate
UNION
SELECT '3 Days',
(select COUNT( A.APNO) from appl A with (nolock) 
inner join Client C on A.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ))=3 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 3 
group by RA.Affiliate),
(SELECT SUM(dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) FROM appl A with (nolock) inner join Client C on A.CLNO = C.CLNO inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) = 3 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 1 
   group by RA.Affiliate),
CAST( 100. * (select COUNT( A.APNO ) from appl A with (nolock) 
   inner join Client C on A.CLNO = C.CLNO
   inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ))=3 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 3 
   group by RA.Affiliate) /
  (select count( A.APNO ) from appl A with (nolock) 
  inner join Client C on A.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') --11
   group by RA.Affiliate) AS NUMERIC( 5, 2 ) ), 
CAST( 100. * (select COUNT( A.APNO ) from appl A with (nolock) 
inner join Client C on A.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ))<=3 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) <= 3 
   group by RA.Affiliate) /
  (select count( A.APNO ) from appl A with (nolock) 
  inner join Client C on A.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') --11
   group by RA.Affiliate) AS NUMERIC( 5, 2 ) )
from appl ap with (nolock) 
inner join Client C on Ap.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
where Apdate >= @from_date and Apdate < @to_date and apstatus in ('W','F') AND (@CLNO=0 OR Ap.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)
group by RA.Affiliate
UNION
SELECT '4 Days',
(select COUNT( A.APNO ) from appl A with (nolock) 
inner join Client C on A.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ))=4 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 4 
group by RA.Affiliate),
(SELECT SUM(dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) FROM appl A with (nolock) inner join Client C on A.CLNO = C.CLNO inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) = 4 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 1 
   group by RA.Affiliate),
CAST( 100. * (select COUNT( A.APNO ) from appl A with (nolock) 
inner join Client C on A.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ))=4 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 4 
   group by RA.Affiliate) /
  (select count( A.APNO ) from appl A with (nolock) 
   inner join Client C on A.CLNO = C.CLNO
   inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') --11
   group by RA.Affiliate) AS NUMERIC( 5, 2 ) ),
CAST( 100. * (select COUNT( APNO ) from appl A with (nolock) 
inner join Client C on A.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ))<=4 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) <= 4 
   group by RA.Affiliate) /
  (select count( A.APNO ) from appl A with (nolock)
   inner join Client C on A.CLNO = C.CLNO
   inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') --11
   group by RA.Affiliate) AS NUMERIC( 5, 2 ) )
from appl ap with (nolock) 
inner join Client C on Ap.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
where Apdate >= @from_date and Apdate < @to_date and apstatus in ('W','F') AND (@CLNO=0 OR Ap.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate)
group by RA.Affiliate
UNION
SELECT '5 Days',
(select COUNT( A.APNO ) from appl A with (nolock) 
inner join Client C on A.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID
where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ))=5 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 5 
group by RA.Affiliate),
(SELECT SUM(dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) FROM appl A with (nolock) inner join Client C on A.CLNO = C.CLNO inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) = 5 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 1 
   group by RA.Affiliate),
CAST( 100. * (select COUNT( APNO ) from appl A with (nolock) 
inner join Client C on A.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ))=5 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 5 
   group by RA.Affiliate) /
  (select count( A.APNO ) from appl A with (nolock)
   inner join Client C on A.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') --11
   group by RA.Affiliate) AS NUMERIC( 5, 2 ) ),
CAST( 100. * (select COUNT( A.APNO ) from appl A with (nolock) 
inner join Client C on A.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ))<=5 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) <= 5 
   group by RA.Affiliate) /
  (select count( A.APNO ) from appl A with (nolock) 
  inner join Client C on A.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') --11
   group by RA.Affiliate) AS NUMERIC( 5, 2 ) )
from appl ap with (nolock) 
inner join Client C on Ap.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
where Apdate >= @from_date and Apdate < @to_date and apstatus in ('W','F') AND (@CLNO=0 OR Ap.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) 
group by RA.Affiliate
UNION
SELECT '6 Days',
(select COUNT(A.APNO ) from appl A with (nolock) 
inner join Client C on A.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ))=6 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) >= 6 
group by RA.Affiliate),
(SELECT SUM(dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) FROM appl A with (nolock) inner join Client C on A.CLNO = C.CLNO inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) = 6 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 1 
   group by RA.Affiliate),
CAST( 100. * (select COUNT( A.APNO ) from appl A with (nolock) 
inner join Client C on A.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) = 6 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) >= 6 
   group by RA.Affiliate) /
  (select count( A.APNO ) from appl A with (nolock)
  inner join Client C on A.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID  
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') --11
   group by RA.Affiliate) AS NUMERIC( 5, 2 ) ),
CAST( 100. * (select COUNT( A.APNO ) from appl A with (nolock) 
  inner join Client C on A.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or RA.Affiliate = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) < = 6 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) >= 0
   group by RA.Affiliate) /
  (select count( A.APNO ) from appl A with (nolock) 
  inner join Client C on A.CLNO = C.CLNO
  inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F')--11
   group by RA.Affiliate) AS NUMERIC( 5, 2 ) )
from appl ap with (nolock) 
inner join Client C on Ap.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
where Apdate >= @from_date and Apdate < @to_date and apstatus in ('W','F') AND (@CLNO=0 OR Ap.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate))= @Affiliate)
group by RA.Affiliate
UNION
SELECT '7 Days',
(select COUNT(A.APNO ) from appl A with (nolock) 
inner join Client C on A.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ))=7 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) >= 6 
group by RA.Affiliate),
(SELECT SUM(dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) FROM appl A with (nolock) inner join Client C on A.CLNO = C.CLNO inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) = 7 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 1 
   group by RA.Affiliate),
CAST( 100. * (select COUNT( A.APNO ) from appl A with (nolock) 
inner join Client C on A.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) = 7 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) >= 6 
   group by RA.Affiliate) /
  (select count( A.APNO ) from appl A with (nolock)
  inner join Client C on A.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID  
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') --11
   group by RA.Affiliate) AS NUMERIC( 5, 2 ) ),
CAST( 100. * (select COUNT( A.APNO ) from appl A with (nolock) 
  inner join Client C on A.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and
(@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or RA.Affiliate = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) < = 7 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) >= 0
   group by RA.Affiliate) /
  (select count( A.APNO ) from appl A with (nolock) 
  inner join Client C on A.CLNO = C.CLNO
  inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F')--11
   group by RA.Affiliate) AS NUMERIC( 5, 2 ) )
from appl ap with (nolock) 
inner join Client C on Ap.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
where Apdate >= @from_date and Apdate < @to_date and apstatus in ('W','F') AND (@CLNO=0 OR Ap.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate))= @Affiliate)
group by RA.Affiliate
UNION
SELECT '8 Days',
(select COUNT(A.APNO ) from appl A with (nolock) 
inner join Client C on A.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ))=8 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) >= 6 
group by RA.Affiliate),
(SELECT SUM(dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) FROM appl A with (nolock) inner join Client C on A.CLNO = C.CLNO inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ))= 8 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 1 
   group by RA.Affiliate),
CAST( 100. * (select COUNT( A.APNO ) from appl A with (nolock) 
inner join Client C on A.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) = 8 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) >= 6 
   group by RA.Affiliate) /
  (select count( A.APNO ) from appl A with (nolock)
  inner join Client C on A.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID  
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') --11
   group by RA.Affiliate) AS NUMERIC( 5, 2 ) ),
CAST( 100. * (select COUNT( A.APNO ) from appl A with (nolock) 
  inner join Client C on A.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or RA.Affiliate = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) < = 8 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) >= 0
   group by RA.Affiliate) /
  (select count( A.APNO ) from appl A with (nolock) 
  inner join Client C on A.CLNO = C.CLNO
  inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F')--11
   group by RA.Affiliate) AS NUMERIC( 5, 2 ) )
from appl ap with (nolock) 
inner join Client C on Ap.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
where Apdate >= @from_date and Apdate < @to_date and apstatus in ('W','F') AND (@CLNO=0 OR Ap.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate))= @Affiliate)
group by RA.Affiliate
UNION
SELECT '9 Days',
(select COUNT(A.APNO ) from appl A with (nolock) 
inner join Client C on A.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ))=9 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) >= 6 
group by RA.Affiliate),
(SELECT SUM(dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) FROM appl A with (nolock) inner join Client C on A.CLNO = C.CLNO inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) = 9 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 1 
   group by RA.Affiliate),
CAST( 100. * (select COUNT( A.APNO ) from appl A with (nolock) 
inner join Client C on A.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) = 9 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) >= 6 
   group by RA.Affiliate) /
  (select count( A.APNO ) from appl A with (nolock)
  inner join Client C on A.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID  
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') --11
   group by RA.Affiliate) AS NUMERIC( 5, 2 ) ),
CAST( 100. * (select COUNT( A.APNO ) from appl A with (nolock) 
  inner join Client C on A.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or RA.Affiliate = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) < = 9 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) >= 0
   group by RA.Affiliate) /
  (select count( A.APNO ) from appl A with (nolock) 
  inner join Client C on A.CLNO = C.CLNO
  inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F')--11
   group by RA.Affiliate) AS NUMERIC( 5, 2 ) )
from appl ap with (nolock) 
inner join Client C on Ap.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
where Apdate >= @from_date and Apdate < @to_date and apstatus in ('W','F') AND (@CLNO=0 OR Ap.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate))= @Affiliate)
group by RA.Affiliate
UNION
SELECT 'Ten + Days',
(select COUNT(A.APNO ) from appl A with (nolock) 
inner join Client C on A.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ))>=10 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) >= 6 
group by RA.Affiliate),
(SELECT SUM(dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) FROM appl A with (nolock) inner join Client C on A.CLNO = C.CLNO inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) >= 10 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) = 1 
   group by RA.Affiliate),
CAST( 100. * (select COUNT( A.APNO ) from appl A with (nolock) 
inner join Client C on A.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) >= 10 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) >= 6 
   group by RA.Affiliate) /
  (select count( A.APNO ) from appl A with (nolock)
  inner join Client C on A.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID  
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F') --11
   group by RA.Affiliate) AS NUMERIC( 5, 2 ) ),
CAST( 100. * (select COUNT( A.APNO ) from appl A with (nolock) 
  inner join Client C on A.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or RA.Affiliate = @Affiliate) and apstatus in ('W','F') and ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) > = 0 -- + dbo.elapsedbusinessdays_2( Reopendate, Compdate ) ) >= 0
   group by RA.Affiliate) /
  (select count( A.APNO ) from appl A with (nolock) 
  inner join Client C on A.CLNO = C.CLNO
  inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
   where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F')--11
   group by RA.Affiliate) AS NUMERIC( 5, 2 ) )
from appl ap with (nolock) 
inner join Client C on Ap.CLNO = C.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
where Apdate >= @from_date and Apdate < @to_date and apstatus in ('W','F') AND (@CLNO=0 OR Ap.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate))= @Affiliate)
group by RA.Affiliate

UNION
SELECT 'Total',
(select COUNT( A.APNO ) from appl A with (nolock) 
inner join Client C on C.CLNO = A.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID
where Apdate >= @from_date and Apdate < @to_date and (@CLNO=0 OR A.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) and apstatus in ('W','F')
group by RA.Affiliate), 0, 100, 100
from appl ap with (nolock)
inner join Client C on C.CLNO = Ap.CLNO
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID 
where Apdate >= @from_date and Apdate < @to_date AND (@CLNO=0 OR Ap.CLNO = @CLNO) and (@Affiliate='' or LTRIM(RTRIM(RA.Affiliate)) = @Affiliate) 
group by RA.Affiliate
) as [Result] order by 1 asc




SELECT [Final].[Turnaround Time],[Final].Count,Final.Percentage,Final.[Cumulative %]
 FROM(
SELECT T.[Turnaround Time],T.Count,T.Percentage,T.[Cumulative %]
,1 [SortOrder] 
from #tempTAT T
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








