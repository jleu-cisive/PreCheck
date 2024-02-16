 
CREATE function [dbo].[fnGetEstimatedBusinessDate]
(
     @endDate datetime = null,
     @NthDay int
)
returns datetime
as
begin
       /**************************************************/
       /* Function returns the Business Day after NthDay */
       /**************************************************/
       declare @NthBusinessDate  datetime;
       with [Dates] as
       (
             /* Make sure that time is trimmed from the passed date*/
             select
                    dateadd(dd, datediff(dd,0, @endDate), 0) [StartDate]
                    ,dateadd(dd, datediff(dd,0, @endDate) + 1, 0) [NextDate]
                    ,@NthDay [RequiredDays]
                    ,cast(1 as int) [DaysAdded]
                    ,cast(0 as int) [FinalDays]
             union all
             select
                    [StartDate]
                    ,dateadd(dd, 1, [NextDate]) [NextDate]
                    ,[RequiredDays]
                    ,[DaysAdded] + 1 [DaysAdded]
                    /* if the next day is saturday or sunday or holiday then dont count that day as business day*/
                    ,case when datename(dw, [NextDate]) in ('Saturday', 'Sunday') or ((select [Date] from [dbo].[TBLPrecheckHolidays] where [Date] = [Dates].[NextDate]) is not null)
                           then [FinalDays] else [FinalDays] + 1 end [FinalDays]
             from
                    [Dates]     
             where [RequiredDays] >= [FinalDays] /* if the current day has to be part of the count then make this condition as Greatethan only */
       )
       select @NthBusinessDate = dateadd(dd, -1, max([NextDate]))
       from [Dates]
       OPTION (MAXRECURSION 1000)
 
       return @NthBusinessDate;
end
 
 
