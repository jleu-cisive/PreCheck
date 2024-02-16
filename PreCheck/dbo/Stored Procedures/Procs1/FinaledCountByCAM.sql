CREATE Procedure DBO.FinaledCountByCAM
(@FromDate DateTime=NULL,
@ToDate DateTime=NULL )
as
IF @FromDate IS NULL
	SET @FromDate = convert(varchar,getdate(),101 )

IF @ToDate IS NULL
	SET @ToDate = convert(varchar,DateAdd(d,1,getdate()),101 )

SELECT  ISNULL(UserID,'External Sources like Student Web,XML etc.') CAM,count(1) FinaledCount from appl 
-- ISNULL isn't needed; Apps are only finaled by the CAM (the source is irrelevant)
where (case when compdate>origcompdate then Compdate else origcompdate end) between @FromDate and @ToDate
-- case statement is redundant -- by definition CompDate is >= OrigCompDate
-- between does not return the correct value, use CompDate >= @StartDate and CompDate < @EndDate
and APStatus = 'F'
group by UserID