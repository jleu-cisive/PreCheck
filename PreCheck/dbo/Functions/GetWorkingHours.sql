-- =============================================
-- Author:		DEEPAK VODETHELA
-- Create date: 10/04/2018
-- Description:	Funtion to calculate Business Hours/Minutes between any two dates. It also takes into account any holidays.
-- Execution: SELECT dbo.GetWorkingHours(getdate(),getdate() + 1)
--			  SELECT dbo.GetWorkingHours('2018-11-21 14:04:15.623','2018-11-26 14:04:15.623')
-- =============================================
CREATE FUNCTION GetWorkingHours(@StartDate DateTime, @EndDate DateTime) Returns Int
AS
Begin
    Declare @WorkMin int = 0   -- Initialize counter
    Declare @Reverse bit       -- Flag to hold if direction is reverse
    Declare @StartHour int = 6   -- Start of business hours (can be supplied as an argument if needed)
    Declare @EndHour int = 18    -- End of business hours (can be supplied as an argument if needed)

    -- If dates are in reverse order, switch them and set flag
    If @StartDate>@EndDate 
    Begin
        Declare @TempDate DateTime=@StartDate
        Set @StartDate=@EndDate
        Set @EndDate=@TempDate
        Set @Reverse=1
    End
    Else Set @Reverse = 0

    If DatePart(HH, @StartDate)<@StartHour Set @StartDate = DateAdd(hour, @StartHour, DateDiff(DAY, 0, @StartDate))  -- If Start time is less than start hour, set it to start hour
    If DatePart(HH, @StartDate)>=@EndHour+1 Set @StartDate = DateAdd(hour, @StartHour+24, DateDiff(DAY, 0, @StartDate)) -- If Start time is after end hour, set it to start hour of next day
    If DatePart(HH, @EndDate)>=@EndHour+1 Set @EndDate = DateAdd(hour, @EndHour, DateDiff(DAY, 0, @EndDate)) -- If End time is after end hour, set it to end hour
    If DatePart(HH, @EndDate)<@StartHour Set @EndDate = DateAdd(hour, @EndHour-24, DateDiff(DAY, 0, @EndDate)) -- If End time is before start hour, set it to end hour of previous day

    If @StartDate>@EndDate Return 0

    -- If Start and End is on same day
    If DateDiff(Day,@StartDate,@EndDate) <= 0
    Begin
        If Datepart(dw,@StartDate)>1 And DATEPART(dw,@StartDate)<7  -- If day is between sunday and saturday
			IF MAINDB.[dbo].[IsDateAHoliday](@StartDate) = 0 -- If day is not a holiday
                If @EndDate<@StartDate Return 0 Else Set @WorkMin=DATEDIFF(MI, @StartDate, @EndDate) -- Calculate difference
            Else Return 0
        Else Return 0
    End
    Else Begin
        Declare @Partial int=1   -- Set partial day flag
        While DateDiff(Day,@StartDate,@EndDate) > 0   -- While start and end days are different
        Begin
            If Datepart(dw,@StartDate)>1 And DATEPART(dw,@StartDate)<7    --  If this is a weekday
            Begin
				IF MAINDB.[dbo].[IsDateAHoliday](@StartDate) = 0 -- If day is not a holiday
                Begin
                    If @Partial=1  -- If this is the first iteration, calculate partial time
                    Begin 
                        Set @WorkMin=@WorkMin + DATEDIFF(MI, @StartDate, DateAdd(hour, @EndHour, DateDiff(DAY, 0, @StartDate)))
                        Set @StartDate=DateAdd(hour, @StartHour+24, DateDiff(DAY, 0, @StartDate)) 
                        Set @Partial=0 
                    End
                    Else Begin      -- If this is a full day, add full minutes
                        Set @WorkMin=@WorkMin + (@EndHour-@StartHour)*60        
                        Set @StartDate = DATEADD(DD,1,@StartDate)
                    End
                End
                Else Set @StartDate = DATEADD(DD,1,@StartDate)  
            End
            Else Set @StartDate = DATEADD(DD,1,@StartDate)
        End
        If Datepart(dw,@StartDate)>1 And DATEPART(dw,@StartDate)<7  -- If last day is a weekday
			IF MAINDB.[dbo].[IsDateAHoliday](@StartDate) = 0 -- If day is not a holiday
                If @Partial=0 Set @WorkMin=@WorkMin + DATEDIFF(MI, @StartDate, @EndDate) Else Set @WorkMin=@WorkMin + DATEDIFF(MI, DateAdd(hour, @StartHour, DateDiff(DAY, 0, @StartDate)), @EndDate)
    End 
    If @Reverse=1 Set @WorkMin=-@WorkMin
    Return @WorkMin/60
End