--Steve 9/26/2005
-- Calculates number of hours between Start & End based on business day of 8am-noon & 1pm-5pm
-- if dates are in worng order returns -1
CREATE FUNCTION dbo.BusinessHours (@StartDate datetime, @EndDate datetime)
RETURNS int AS  
BEGIN 
	DECLARE @EndDateDate datetime
	DECLARE @StartDateDate datetime
	DECLARE @Amount int
	SET @Amount = 0 -- default

	SET @StartDateDate = CONVERT(DATETIME, (CONVERT(varchar(11), @StartDate, 106))) -- drop time past midnight
	SET @EndDateDate = CONVERT(DATETIME, (CONVERT(varchar(11), @EndDate, 106))) -- drop time past midnight

	DECLARE @Days int
	SET @Days = DATEDIFF(dd, @StartDateDate, @EndDateDate)
	if(@StartDate > @EndDate)
		SET @Amount = -1
	else if(@Days = 0) --same day
	BEGIN
		IF DATEPART(dw, @StartDate) BETWEEN 2 and 6
		BEGIN
			SET @Amount = 8 - dbo.BusinessHoursPrior(@StartDate)
			SET @Amount = @Amount + dbo.BusinessHoursPrior(@EndDate)
			SET @Amount = @Amount - 8
		END
	END
	else
	BEGIN
		IF DATEPART(dw, @StartDate) BETWEEN 2 and 6
			SET @Amount = 8 - dbo.BusinessHoursPrior(@StartDate)
		IF DATEPART(dw, @EndDate) BETWEEN 2 and 6
			SET @Amount = @Amount + dbo.BusinessHoursPrior(@EndDate)
		SET @Amount = @Amount + 8*dbo.ElapsedBusinessDays_2(@StartDateDate+1, @EndDateDate)
	END

	RETURN @Amount
END









