CREATE PROCEDURE [dbo].[FormTaskGetBusinessHours] 

( 
	@startTime datetime, 
	@endTime datetime
	
)
AS
	
--call the user defined function dbo.BusinessHours()
select dbo.BusinessHours(@startTime, @endTime) as myTime