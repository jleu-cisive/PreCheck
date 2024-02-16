--Steve  9/26/2005
-- How many minutes in the business day prior to the given time
CREATE FUNCTION dbo.BusinessMinutesPrior (@EndDate datetime)
RETURNS int AS  
BEGIN 
	DECLARE @EndDate2 datetime
	DECLARE @Time int
	DECLARE @Amount int
	
	SET @EndDate2 = CONVERT(DATETIME, (CONVERT(varchar(11), @EndDate, 106))) -- drop time past midnight
	SET @Time = DateDiff(mi, @EndDate2, @EndDate)
--	SET @Time = DateDiff(hh, @EndDate2, @EndDate)

	if(@Time < 8*60) --8am
		SET @Amount = 0
	else if @Time < 12*60 --noon
		SET @Amount=@Time - 8*60
	else if @Time < 13*60 --1pm
		SET @Amount = 4*60
	else if @Time < 17*60 --5pm
		SET @Amount = @Time - 9*60
	else
		SET @Amount = 8*60

	RETURN @Amount
END

--  BusinessMinutesAfter  = 8*60 - BusinessMinutesPrior(@EndDate)

