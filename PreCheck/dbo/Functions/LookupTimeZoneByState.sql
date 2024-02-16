CREATE FUNCTION dbo.LookupTimeZoneByState (@City varchar(50),@State varchar(10),@currentdate datetime,@cutoff datetime)  
RETURNS varchar(25)
AS  
BEGIN
             DECLARE @MyHour smallint
	DECLARE @MyTimeZone int
             DECLARE @MyCutoffTime INT 
             DECLARE @myCurrentDate datetime
 	DECLARE @MyConvertedDate datetime
             DECLARE @MyConvertedTime INT
             DECLARE @MyOutPut INT
             DECLARE @LocalTimeZone int
             DECLARE @MyMinutes int
             DECLARE @znewdate datetime


  SET @myConvertedtime = datepart(hour,@currentdate)
           
IF (@city <> null) and (@state <> null) and (@cutoff <> null)
BEGIN
            SET @LocalTimeZone = '-6'
            SET @MyTimeZone = (Select distinct time_zone from zipcodeworld where (state = @State and city = @city))
            SET @MyHour = (@LocalTimeZone) - (-1 *(( @myTimeZone)))
            SET @MyCutoffTime =  (Datepart(hour,@cutoff) )

            set @znewdate = cast((convert(varchar(10),@currentdate,101) + ' ' + convert(varchar(14),@cutoff,114)) as datetime)

            SET @myCurrentDate =  dateadd(hour,@myhour,@znewdate)   -- updated vendor cutoffdate with timezone
            set @myconvertedtime = datediff(ms,@currentdate,@mycurrentdate)
            If (@myconvertedtime < 0 )
--          if datediff(ms,@currentdate,@mycurrentdate)  < 0
            Begin
            Set @MyConvertedDate = dateadd(day,1,@mycurrentdate)          
            end
            else
            begin
            set @MyConvertedDate = @mycurrentdate          
            end
END
else
Begin
set @MyConvertedDate = null
end
             RETURN (@myconverteddate)
END


















