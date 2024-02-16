

CREATE FUNCTION [dbo].[ElapsedBusinessDays_3] (@Date1 datetime, @Date2 datetime)  
RETURNS smallint
AS  
BEGIN 
	DECLARE @TheDate datetime
	DECLARE @Cnt smallint
	SET @TheDate = @Date1;
	
	SET @Cnt = 0
	WHILE @TheDate < @Date2 BEGIN
		IF DATEPART(dw, @TheDate) BETWEEN 2 and 6
			--SET @Cnt = @Cnt + 1
		BEGIN --added by schapyala on 12/6/16
			IF MAINDB.[dbo].[IsDateAHoliday](@TheDate) = 0
				SET @Cnt = @Cnt + 1
		END
		SET @TheDate = DateAdd(d,1,@TheDate)
	END
	RETURN (@Cnt)
END


