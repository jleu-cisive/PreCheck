CREATE procedure dbo.ReportApplFinaledByCAM 

@businessDate datetime
AS

select isnull(UserID, 'WebEntry') UserID,count (1)Count from Appl 
 --where CompDate >= @businessDate and CompDate <= @businessDate+1 
 where (case when compdate>origcompdate then Compdate else origcompdate end) between @businessDate and @businessDate+1
  and ApStatus='F'
group by UserID
order by UserID




