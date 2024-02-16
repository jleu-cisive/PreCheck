CREATE FUNCTION dbo.NewElapsedBusinessDays (@NewDate datetime, @Date1 datetime, @Date2 datetime)  
RETURNS smallint
AS  
BEGIN 
	DECLARE @TheDate datetime
	DECLARE @Cnt smallint
             SET @Cnt = 0	
        If @newdate is null
	begin
             SET @TheDate = CONVERT(DATETIME, (CONVERT(varchar(11), @Date1, 106)))
	end
             
            If @newdate is not null
             begin
             SET @TheDate = CONVERT(DATETIME, (CONVERT(varchar(11), @newdate, 106)))
	end 

	WHILE @TheDate < @Date2 BEGIN
		IF DATEPART(dw, @TheDate) BETWEEN 2 and 6
			SET @Cnt = @Cnt + 1
		SET @TheDate = @TheDate + 1
	END
	RETURN (@Cnt)
END

