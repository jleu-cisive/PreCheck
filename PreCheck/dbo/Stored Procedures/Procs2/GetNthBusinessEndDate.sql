

--[dbo].[GetNthBusinessEndDate] '01/23/2017', 2
--[dbo].[GetNthBusinessEndDate] '01/24/2017', 2
--[dbo].[GetNthBusinessEndDate] '01/25/2017', 2
--[dbo].[GetNthBusinessEndDate] '01/26/2017', 2
--[dbo].[GetNthBusinessEndDate] '01/27/2017', 2
--[dbo].[GetNthBusinessEndDate] '01/28/2017', 2
--[dbo].[GetNthBusinessEndDate] '01/29/2017', 2


--[dbo].[GetNthBusinessEndDate] '01/23/2017', 7
--[dbo].[GetNthBusinessEndDate] '01/24/2017', 7
--[dbo].[GetNthBusinessEndDate] '01/25/2017', 7
--[dbo].[GetNthBusinessEndDate] '01/26/2017', 7
--[dbo].[GetNthBusinessEndDate] '01/27/2017', 7
--[dbo].[GetNthBusinessEndDate] '01/28/2017', 7
--[dbo].[GetNthBusinessEndDate] '01/29/2017', 7

CREATE PROCEDURE [dbo].[GetNthBusinessEndDate] --'01/23/2017', 2
(
     @StartDate datetime = null,
     @NthDay int
) 

 as
 Begin
   
   declare @BusinessDays int
   declare @DiffDays int
   declare @NthBusinessDate  datetime
   declare @TempDate  datetime
   declare @endDate datetime
   declare @addOne int
	
   set @BusinessDays = @NthDay
   set @addOne = 0
   set @TempDate = @StartDate
   --if(DateName(dw,@StartDate) = 'Saturday' or DateName(dw, @StartDate) = 'Sunday')
   --begin
   --set @StartDate = Dateadd(d,(1),@StartDate)
   --end
IF @NthDay > 0
	BEGIN
		 
			while @NthDay > 0
			begin
			
			if(MainDB.dbo.IsDateAHoliday(@TempDate) = 1 or DateName(dw, @TempDate) = 'Saturday' or DateName(dw, @TempDate) = 'Sunday' )
			begin
			 set @BusinessDays = @BusinessDays + 1
			 set @NthDay = @NthDay + 1
			 end
			set @TempDate = Dateadd(d,(1),@TempDate)
			
			 set @NthDay = @NthDay - 1
			end
			if(MainDB.dbo.IsDateAHoliday(@StartDate) = 1 or DateName(dw, @StartDate) = 'Saturday' or DateName(dw, @StartDate) = 'Sunday' ) set @BusinessDays = @BusinessDays -1
	END
ELSE  -- if @NthDay = 0
	BEGIN
		   While @BusinessDays <= @NthDay
			BEGIN
				IF @BusinessDays > 0
					set @DiffDays = @DiffDays + (@NthDay - @BusinessDays)
				ELSE
					set @DiffDays =(@NthDay - @BusinessDays)
		
				set @endDate = Dateadd(d,(@DiffDays),@StartDate)
				set @BusinessDays =  MainDB.dbo.fnGetBusinessDays(@startdate,@endDate)
				IF @BusinessDays = 0 set @StartDate = Dateadd(d,(1),@StartDate)  --Added by santosh on 07/21/05 - if the end date falls on a holiday....
			END
	END

	
  set @NthBusinessDate = Dateadd(d,(@BusinessDays),@StartDate) 
  while MainDB.dbo.IsDateAHoliday(@NthBusinessDate) = 1 or DateName(dw, @NthBusinessDate) = 'Saturday' or DateName(dw, @NthBusinessDate) = 'Sunday' 
  begin
    set @NthBusinessDate = Dateadd(d,(1),@NthBusinessDate)
	
  end

  --if(@addOne = 1) set @NthBusinessDate = Dateadd(d,(1),@NthBusinessDate)
 select  @NthBusinessDate
END

   --select MainDB.dbo.fnGetBusinessDays('01/28/2017','01/30/2017')
   --select Dateadd(d,(9),'01/23/2017') 