CREATE FUNCTION [dbo].[ElapsedBusinessDays] (@Date1 datetime, @Date2 datetime)  
RETURNS smallint
AS  
BEGIN 
	DECLARE @TheDate datetime
	DECLARE @Cnt smallint
	
	SET @TheDate = CONVERT(DATETIME, (CONVERT(varchar(11), @Date1, 106)))
	SET @Cnt = 0
	WHILE @TheDate < @Date2 BEGIN
		IF DATEPART(dw, @TheDate) BETWEEN 2 and 6
		BEGIN
			IF MAINDB.[dbo].[IsDateAHoliday](@TheDate) = 0
				SET @Cnt = @Cnt + 1
		END
		--SET @TheDate = @TheDate + 1
		SET @TheDate = DateAdd(d,1,@TheDate)
	END
	RETURN (@Cnt)
END
