create procedure dbo.Integration_ShowCallbackQueue
as

CREATE TABLE #temp
(StatusUpdateCallbackTempID  [int] IDENTITY(1,1) NOT NULL,
 CallbackSource varchar(50) NOT NULL,
 IdFieldName varchar(50) NOT NULL,
 RequestID int NOT NULL,
 CLNO int NOT NULL,
 APNO int NOT NULL,
 CallbackStatus varchar(20) NOT NULL,
 Partner_Reference varchar(50) NOT NULL,
 Partner_Tracking_Number varchar(50) NULL,
 UserName varchar(50) NULL,
 CallbackFailureCount int NOT NULL)


Insert Into #temp
SELECT 
    'dbo.Integration_OrderMgmt_Request' CallbackSource,'RequestID' as IdFieldName, RequestID,CLNO,		
		APNO,
	  (CASE 
           WHEN (Process_CallBack_Acknowledge = 1) THEN 'InProcess' 
		   WHEN (Process_CallBack_Final = 1) THEN 'Complete'
		  --WHEN (Process_CallBack_Final = 1) THEN 'Concluded'
       END) as CallbackStatus,
	 Partner_Reference,Partner_Tracking_Number,UserName,IsNull(CallbackFailures,0) as CallbackFailureCount  
FROM 
      dbo.Integration_OrderMgmt_Request with (NOLOCK)
      WHERE 
  	     	  refUserActionID = 1 
      and ( (Process_CallBack_Acknowledge = 1 and CallBack_Acknowledge_Date IS NULL) 
           or (Process_CallBack_Final = 1 and CallBack_Final_Date IS NULL) )
	 and lower(Partner_Reference) not like '%test%'
and IsNull(APNO,0) <> 0 and CLNO not in (2179)	 

Insert Into #temp
Select 'dbo.Integration_PrecheckCallback' CallbackSource,'PrecheckCallbackID' as IdFieldName,PrecheckCallbackID RequestID,CLNO,		
		APNO,
	  (CASE 
           WHEN (Process_CallBack_Acknowledge = 1) THEN 'InProcess' 
		   WHEN (Process_CallBack_Final = 1) THEN 'Complete'
       END) as CallbackStatus,
	  Partner_Reference,null Partner_Tracking_Number,null UserName,CallbackFailures as CallbackFailureCount
From dbo.[Integration_PrecheckCallback] with (NOLOCK)
 WHERE  
 /* 
 */

 ( (Process_CallBack_Acknowledge = 1 and CallBack_Acknowledge_Date IS NULL) 
           or (Process_CallBack_Final = 1 and CallBack_Final_Date IS NULL) ) and  lower(Partner_Reference) not like '%test%'


		   SELECT CallbackSource,IdFieldName,Temp.RequestID,Temp.CLNO,Temp.APNO,temp.CallBackStatus,
(CASE Lower(CallbackStatus)
	WHEN  'inprocess' then Config.URL_CallBack_Acknowledge 
	WHEN  'complete' then Config.URL_CallBack_Final 
	WHEN 'Concluded' then Config.URL_CallBack_Final 
end) 
as CallBack_URL,CallBackMethod,IntegrationMethod,Temp.Partner_Reference,Temp.Partner_Tracking_Number,Config.OperationName,UserName,CallbackFailureCount
FROM  #temp Temp 
LEFT JOIN  dbo.XLATECLNO Client 
ON Temp.CLNO = Client.CLNOin
LEFT JOIN dbo.ClientConfig_Integration Config 
ON isnull(Client.CLNOin,0) = Config.CLNO 
WHERE Partner_Reference IS NOT NULL
AND temp.CallBackStatus IS NOT NULL 
AND CallBackMethod IS NOT NULL 
AND IntegrationMethod IS NOT NULL
and IsNull(Config.IsActive,0) = 1
--and 1=0
drop table #temp	