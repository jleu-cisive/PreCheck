--Steve  9/26/2005
-- How many minutes in the business day prior to the given time
CREATE FUNCTION dbo.BusinessHoursPrior (@EndDate datetime)
RETURNS int AS  
BEGIN 
	DECLARE @EndDate2 datetime
	DECLARE @Time int
	DECLARE @Amount int
	
	SET @EndDate2 = CONVERT(DATETIME, (CONVERT(varchar(11), @EndDate, 106))) -- drop time past midnight
	SET @Time = DateDiff(hh, @EndDate2, @EndDate)
--	SET @Time = DateDiff(hh, @EndDate2, @EndDate)

	if(@Time < 8) --8am
		SET @Amount = 0
	else if @Time < 12 --noon
		SET @Amount=@Time - 8
	else if @Time < 13 --1pm
		SET @Amount = 4
	else if @Time < 17 --5pm
		SET @Amount = @Time - 9
	else
		SET @Amount = 8

	RETURN @Amount
END

--  BusinessMinutesAfter  = 8 - BusinessMinutesPrior(@EndDate)

