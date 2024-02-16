
/*
	SELECT [dbo].[ElapsedBusinessDaysInDecimal] ('10/1/2018 12:41:51.000','10/5/2018 10:47:28.907')
	select [dbo].[ElapsedBusinessDaysInDecimal]('2020-04-04 19:28:36','2020-04-04 19:28:28')
	select [dbo].[ElapsedBusinessDaysInDecimal]('2020-02-23 08:10:14.060','2020-02-24 13:28:39.083')
*/
CREATE FUNCTION [dbo].[ElapsedDaysInDecimal] (@Date1 datetime, @Date2 datetime)  
RETURNS decimal(10,2)
AS  
BEGIN 
	DECLARE @TheDate datetime
	DECLARE @Cnt smallint
	DECLARE @diffhours decimal(10,2)
	DECLARE @returnHours decimal(10,2)           
      
    SET @diffhours = datepart(hh,@date2) - datepart(hh,@date1)

	SET @TheDate = CONVERT(DATETIME, (CONVERT(varchar(11), @Date1, 106)))

	SET @Cnt = 0
	WHILE @TheDate < @Date2 BEGIN
		--IF DATEPART(dw, @TheDate) BETWEEN 2 and 6
			--SET @Cnt = @Cnt + 1
		BEGIN --added by schapyala on 12/6/16
			--IF MAINDB.[dbo].[IsDateAHoliday](@TheDate) = 0
				SET @Cnt = @Cnt + 1
		END
		SET @TheDate = DateAdd(d,1,@TheDate)
	END
	SET @returnHours = CASE WHEN @Cnt = 0 THEN 0 -- Added by Radhika on 06/04/2020 to remove NEGATIVE NUMBERS
							WHEN ((@Cnt -1) * 24) = 0 THEN ABS(@diffhours) ELSE ((@Cnt -1) * 24) + @diffhours
					   END -- KIRAN 8/20/2018 -- TO GET POSITIVE NO OF HOURS

	--SELECT (@retHours)/24

	RETURN ((@returnHours)/24)
END


