﻿CREATE FUNCTION [dbo].[ElapsedBusinessHours] (@Date1 datetime, @Date2 datetime)  
RETURNS smallint
AS  
BEGIN 
	DECLARE @TheDate datetime
	DECLARE @Cnt smallint
             DECLARE @diffhours int
             DECLARE @retHours smallint           
           set @diffhours = datepart(hh,@date2) - datepart(hh,@date1)

	SET @TheDate = CONVERT(DATETIME, (CONVERT(varchar(11), @Date1, 106)))
	SET @Cnt = 0
	WHILE @TheDate < @Date2 BEGIN
		IF DATEPART(dw, @TheDate) BETWEEN 2 and 6
			--SET @Cnt = @Cnt + 1
		BEGIN --added by schapyala on 12/6/16
			IF MAINDB.[dbo].[IsDateAHoliday](@TheDate) = 0
				SET @Cnt = @Cnt + 1
		END
		SET @TheDate = @TheDate + 1
	END
            set @retHours = ((@Cnt -1) * 24) + @diffhours
	RETURN (@retHours)
END




