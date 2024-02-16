-- =============================================
-- Author:		Veena Ayyagari	
-- Create date: 02/08/08
-- Description:	Updates Winserviceschedule table based on the success or failure of the process 
--				to reschedule to reprocess the same process based on the configuration within
--				the winserviceschedle table
-- =============================================
CREATE PROCEDURE [dbo].[UpdateServiceTimeWinService]
@success bit,
@ServiceName varchar(50) AS
BEGIN

declare @varServiceRetryType varchar(50)
declare @varServiceRetryTimeValue int
declare @varServiceRetryRunTime datetime

select 
@varServiceRetryType=serviceretrytype,
@varServiceRetryTimevalue=serviceretrytimevalue
from WinServiceSchedule where servicename=@ServiceName


IF (@success=0) 
	update WinServiceSchedule set ServiceRetryRunTime=
		Case(@varServiceRetryType)
			when 'Day' then DateAdd(dd,@varServiceRetryTimevalue,getdate())
			when 'Week' then DateAdd(wk,@varServiceRetryTimevalue,getdate())
			when 'Month' then DateAdd(mm,@varServiceRetryTimevalue,getdate())
			when 'Hour' then  DateAdd(hh,@varServiceRetryTimevalue,getdate())
			when 'Minute' then DateAdd(mi,@varServiceRetryTimevalue,getdate())
			when 'Second' then DateAdd(ss,@varServiceRetryTimevalue,getdate())
		End
		where ServiceName=@ServiceName
ELSE
  update WinServiceSchedule set ServiceRetryRunTime=Null where ServiceName=@ServiceName

END 
