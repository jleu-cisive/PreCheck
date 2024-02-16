
-- =============================================
-- Author:		Gaurav/Sahithi
-- Create date: 10/35/2019
-- Description:	Modified the original function [dbo].[GetScanValuesByJobNumber] 
-- =============================================

-- select * from [Report].[GetCallbackSummary]('11/18/2019','11/19/2019')
CREATE  function [Report].[GetCallbackSummary](@StartTime SMALLDATETIME,@EndTime SMALLDATETIME)
RETURNS @ScanInfo TABLE(ReportCode Varchar(20),ReportValue int,UniqueId VARCHAR(20) NULL, UniqueIdDescription VARCHAR(50) null) 
AS	
BEGIN
	DECLARE @CallBackFailure_MaxCount INT = 5
	DECLARE @UniqueIdDescription VARCHAR(50) = 'RequestId'
	DECLARE @TempTable Table(ID INT Identity(1,1),ReportCode Varchar(20),ReportValue VARCHAR(1000),UniqueId VARCHAR(20) NULL, UniqueIdDescription VARCHAR(50) NULL)
	
	
	INSERT INTO @TempTable(ReportCode, ReportValue, UniqueId, UniqueIdDescription)
	
	-- Below is to determine the number of records that have errored on sending an acknowledgement and reached max attempts on "[Integration_OrderMgmt_Request]" table  .
	SELECT 'CA',  1 ,RequestId, @UniqueIdDescription 
	FROM [dbo].[Integration_OrderMgmt_Request] 
	WHERE DatePart(year,[callback_acknowledge_date])=1900 AND [CallbackFailures]>=@CallBackFailure_MaxCount
	AND [RequestDate] BETWEEN @StartTime and @EndTime
	--and CAST(RequestDate as date) BETWEEN CAST(@StartTime as Date) and CAST(@EndTime as Date)
						  
	--- Below is to determine the number of records that have errored on sending an acknowledgement(Inprocess) and reached max attempts on "[Integration_PrecheckCallback]" table
	UNION ALL
	SELECT 'CA',  1 ,PrecheckCallbackID, 'PreCheckCallBackID'
	FROM [dbo].[Integration_PrecheckCallback] 
	WHERE DatePart(year,[callback_acknowledge_date])=1900 AND [CallbackFailures]>=@CallBackFailure_MaxCount 
	AND CreatedDate BETWEEN @StartTime and @EndTime
	--and CAST(CreatedDate as date) BETWEEN CAST(@StartTime as Date) and CAST(@EndTime as Date)
						
	UNION ALL
	Select 'FA',1,RequestID , @UniqueIdDescription
	FROM [dbo].[Integration_OrderMgmt_Request] 
	WHERE DatePart(year,[Callback_Final_Date])=1900 AND [CallbackFailures]>=@CallBackFailure_MaxCount 
	AND [RequestDate] BETWEEN @StartTime and @EndTime
	--and CAST(RequestDate as date) BETWEEN CAST(@StartTime as Date) and CAST(@EndTime as Date)
						  
	UNION ALL					 
	--Below is to determine the number of records that have errored on sending an final(Completed) and reached max attempts on "[Integration_PrecheckCallback]" table
	SELECT 'FA',1,PrecheckCallbackID, 'PreCheckCallBackID' 
	FROM [dbo].[Integration_PrecheckCallback] 
	WHERE DatePart(year,[Callback_Final_Date])=1900 AND [CallbackFailures]>=@CallBackFailure_MaxCount 
	AND CreatedDate BETWEEN  @StartTime and @EndTime
	--and CAST(CreatedDate as date) BETWEEN CAST(@StartTime as Date) and CAST(@EndTime as Date)
	
	UNION ALL
	SELECT 'RFA', 1,rfa.ReleaseFormId , 'ReleaseFormId'
	FROM [dbo].[ReleaseFormAcknowledgement] rfa  with (NOLOCK)
	INNER JOIN [dbo].[ReleaseForm] rf with (NOLOCK) ON rfa.ReleaseFormId=rf.[ReleaseFormID] 
	WHERE DatePart(year,rfa.[AcknowledgeDate])=1900 
	AND rf.date BETWEEN @StartTime AND @EndTime
	--and CAST(rf.date as date) BETWEEN CAST(@StartTime as Date) and CAST(@EndTime as Date)
	
	UNION ALL
	SELECT 'ACT', COUNT(*),NULL, @UniqueIdDescription 
	FROM  dbo.Integration_OrderMgmt_Request with (NOLOCK)
    WHERE refUserActionID = 1 
	AND ( (Process_CallBack_Acknowledge = 1 and CallBack_Acknowledge_Date IS NULL)  OR 
		(Process_CallBack_Final = 1 and CallBack_Final_Date IS NULL) )
	AND IsNull(APNO,0) <> 0 and CLNO not in (2179) 
	and  DateDiff(year,RequestDate,CURRENT_TIMESTAMP)  <= 1 
	and IsNull(CallbackFailures,0) <= 4
	and RequestDate BETWEEN @StartTime and @EndTime
	--and CAST(RequestDate as date) BETWEEN CAST(@StartTime as Date) and CAST(@EndTime as Date)
	
	UNION ALL
	SELECT 'ACT', COUNT(*),NULL, 'PrecheckCallbackID'  
	FROM dbo.[Integration_PrecheckCallback] with (NOLOCK)
	WHERE  ( (Process_CallBack_Acknowledge = 1 and CallBack_Acknowledge_Date IS NULL) OR 
		(Process_CallBack_Final = 1 and CallBack_Final_Date IS NULL) ) 
	and  DateDiff(year,CreatedDate,CURRENT_TIMESTAMP)  <= 1	
	and CLNO not in (3115) 
	and IsNull(CallbackFailures,0) <= 4
	and CreatedDate BETWEEN @StartTime and @EndTime
	--and CAST(CreatedDate as date) BETWEEN CAST(@StartTime as Date) and CAST(@EndTime as Date)

	UNION ALL
	Select  'ACT', count(*),     IC.callbacklogid,'CallbackLogID'        
             
             from dbo.Integration_CallbackLogging IC with (nolock)
             where
             callbackdate between @StartTime and @EndTime
               and IC.clno =7519 
			   and(CallbackCompletedStatus=1 and (CallbackStatus='BCA' OR CallbackStatus='Complete'))
			   and CallbackError is null 
              group by IC.callbacklogid



	UNION ALL
      select  'BCA',count(*),  IC.callbacklogid,'CallbackLogID'        
             
             from dbo.Integration_CallbackLogging IC with (nolock)
             where
             callbackdate between @StartTime and @EndTime
               and IC.clno =7519 
			  and CallbackStatus='BCA' and callbackerror is not null
               group by IC.callbacklogid


	INSERT INTO @ScanInfo (ReportCode ,ReportValue,UniqueId , UniqueIdDescription ) 
	SELECT ReportCode, ReportValue, UniqueId, UniqueIdDescription FROM  @TempTable

	RETURN
END
