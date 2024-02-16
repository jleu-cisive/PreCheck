
/*
Created By: Deepak Vodethela
Purpose: To get the Number of Hours between two dates excluding WeekEnd days
Execution: SELECT dbo.GetHoursExcludingWeekEnd('2014-06-25 20:26:32.950','2014-06-26 20:25:59.950')
*/

CREATE FUNCTION [dbo].[GetHoursExcludingWeekEnd](@StartDate datetime2,@EndDate datetime2)
returns decimal(38,2)
AS
BEGIN
     if datepart(weekday,@StartDate) = 1
         set @StartDate = dateadd(day,datediff(day,0,@StartDate),1)
     if datepart(weekday,@StartDate) = 7
         set @StartDate = dateadd(day,datediff(day,0,@StartDate),2)

     -- if @EndDate happens on the weekend, set to previous Saturday 12AM
     -- to count all of Friday's hours
     if datepart(weekday,@EndDate) = 1
         set @EndDate = dateadd(day,datediff(day,0,@EndDate),-2)
     if datepart(weekday,@EndDate) = 7
         set @EndDate = dateadd(day,datediff(day,0,@EndDate),-1)

     declare @return decimal(38,2)
     set @return = ((datediff(minute,@StartDate,@EndDate)/60.0) - (datediff(week,@StartDate,@EndDate)*48))

     return @return

 end
