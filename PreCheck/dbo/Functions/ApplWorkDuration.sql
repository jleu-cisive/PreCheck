--Calculates total time an application is worked on
--  assumes no more than one reopen
--Steve Krenek
--4/26/2005
CREATE FUNCTION dbo.ApplWorkDuration (@Apdate datetime, @OrigCompDate datetime, @ReopenDate datetime, @Compdate datetime)  
RETURNS int
AS  
BEGIN 
	DECLARE @WorkOriginal int
	DECLARE @WorkReopen int
	DECLARE @Cnt int

	SET @WorkOriginal = dbo.elapsedbusinessdays_2(@Apdate, @Origcompdate) 
	SET @WorkReopen = dbo.elapsedbusinessdays_2(@Reopendate, @Compdate)
	SET @Cnt = @WorkOriginal + @WorkReopen

	RETURN (@Cnt)
END


