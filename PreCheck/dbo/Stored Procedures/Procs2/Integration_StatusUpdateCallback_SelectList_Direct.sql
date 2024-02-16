  
  
  
  
  
  
--[dbo].[Integration_StatusUpdateCallback_SelectList_Direct]  
CREATE PROCEDURE [dbo].[Integration_StatusUpdateCallback_SelectList_Direct]   
  
AS  
BEGIN  
SET NOCOUNT ON  
   
 declare @defaultDate datetime  
 set @defaultDate = current_timestamp   
 set @defaultDate = replace(@defaultdate,year(@defaultdate),'1900')  
  
 /*Select APNO INTO #InProcessCallbacks  
 From Integration_CallbackLogging with (NOLOCK)   
 where callbackstatus = 'InProcess' and CallbackDate > Dateadd(MONTH,-1,current_timestamp)   
 group by apno  
 having sum(cast(CallbackCompletedStatus as int))<10  
  
 Select APNO  INTO #CompletedCallbacks  
 From Integration_CallbackLogging with (NOLOCK)   
 where callbackstatus = 'Complete' and CallbackDate > Dateadd(MONTH,-1,current_timestamp)   
 group by apno  
 having sum(cast(CallbackCompletedStatus as int))<10  
  
 -- InProgress updates on integration_ordermgmt_request table  
 update R  
 set CallBack_Acknowledge_Date = null  
 FROM dbo.Integration_OrderMgmt_Request R with (NOLOCK)  
  --WHERE DATEDIFF( MINUTE,CAST(CallBack_Acknowledge_Date AS DATETIME),@defaultDate)>120  
 --AND CallBack_Acknowledge_Date <> '01/01/1900'  
 --and isnull(callbackfailures,0)<6  
 inner join #InProcessCallbacks  C on r.apno=c.apno  
 WHERE DATEDIFF( MINUTE,CallBack_Acknowledge_Date ,@defaultDate)>120  
 --AND CallBack_Acknowledge_Date <> '01/01/1900'  
 AND RequestDate > Dateadd(MONTH,-6,current_timestamp)  
 AND Year(CallBack_Acknowledge_Date) = '1900'  
 and isnull(callbackfailures,0)<10   
   
 --Completed updates on the integration_ordermgmt_request  
 update R  
 set CallBack_Final_Date = null  
 FROM dbo.Integration_OrderMgmt_Request R with (NOLOCK)  
 --WHERE DATEDIFF( MINUTE,CAST(CallBack_Final_Date AS DATETIME),@defaultDate)>120  
 --AND CallBack_Final_Date <> '01/01/1900'  
 --and isnull(callbackfailures,0)<10  
 inner join #CompletedCallbacks  C on r.apno=c.apno    
 WHERE DATEDIFF( MINUTE,Callback_Final_Date,@defaultDate)>120  
 --AND CallBack_Acknowledge_Date <> '01/01/1900'  
 AND RequestDate > Dateadd(MONTH,-6,current_timestamp)  
 AND Year(Callback_Final_Date) = '1900'  
 and isnull(callbackfailures,0)<10   
  
  
 update R  
 set CallBack_Acknowledge_Date = null  
 FROM dbo.[Integration_PrecheckCallback] R with (NOLOCK)  
 --WHERE DATEDIFF( MINUTE,CAST(CallBack_Acknowledge_Date AS DATETIME),@defaultDate)>120  
 --AND CallBack_Acknowledge_Date <> '01/01/1900'  
 --and isnull(callbackfailures,0)<10  
 inner join #InProcessCallbacks C on r.apno=c.apno  
 WHERE DATEDIFF( MINUTE,CallBack_Acknowledge_Date ,@defaultDate)>120  
 --AND CallBack_Acknowledge_Date <> '01/01/1900'  
 AND CreatedDate > Dateadd(MONTH,-6,current_timestamp)  
 AND Year(CallBack_Acknowledge_Date) = '1900'  
 and isnull(callbackfailures,0)<10   
   
   
  
 update R  
 set CallBack_Final_Date = null  
 FROM dbo.[Integration_PrecheckCallback] R with (NOLOCK)  
 --WHERE DATEDIFF( MINUTE,CAST(CallBack_Final_Date AS DATETIME),@defaultDate)>120  
 --AND CallBack_Final_Date <> '01/01/1900'   
 --and isnull(callbackfailures,0)<10  
 inner join #CompletedCallbacks C on r.apno=c.apno    
 WHERE DATEDIFF( MINUTE,Callback_Final_Date ,@defaultDate)>120  
 --AND CallBack_Acknowledge_Date <> '01/01/1900'  
 AND CreatedDate  > Dateadd(MONTH,-6,current_timestamp)  
 AND Year(Callback_Final_Date) = '1900'  
 and isnull(callbackfailures,0)<10   
  
   
DROP TABLE #InProcessCallbacks  
DROP TABLE #CompletedCallbacks  
 */ 
CREATE TABLE #StatusUpdateCallbackTemp  
(StatusUpdateCallbackTempID  [int] IDENTITY(1,1) NOT NULL,  
 CallbackSource varchar(50) NOT NULL,  
 IdFieldName varchar(50) NOT NULL,  
 RequestID int NOT NULL,  
 CLNO int NOT NULL,  
 APNO int NULL,  
 CallbackStatus varchar(20) NOT NULL,  
 Partner_Reference varchar(50) NULL,  
 Partner_Tracking_Number varchar(50) NULL,  
 UserName varchar(50) NULL,  
 CallbackFailureCount int NOT NULL,  
 PartnerConfigId int NULL  
)    
/*  
Insert Into #StatusUpdateCallbackTemp  
SELECT   
    'dbo.Integration_OrderMgmt_Request' CallbackSource,'RequestID' as IdFieldName, RequestID,CLNO,    
  APNO,  
   (CASE   
           WHEN (Process_CallBack_Acknowledge = 1) THEN 'InProcess'   
     WHEN (Process_CallBack_Final = 1) THEN 'Complete'  
    --WHEN (Process_CallBack_Final = 1) THEN 'Concluded'  
       END) as CallbackStatus,  
  Partner_Reference,Partner_Tracking_Number,UserName,IsNull(CallbackFailures,0) as CallbackFailureCount,null  
FROM   
      dbo.Integration_OrderMgmt_Request with (NOLOCK)  
      WHERE     
            refUserActionID = 1   
      and ( (Process_CallBack_Acknowledge = 1 and CallBack_Acknowledge_Date IS NULL)   
           or (Process_CallBack_Final = 1 and CallBack_Final_Date IS NULL) )  
  and lower(Partner_Reference) not like '%test%'  
and IsNull(APNO,0) <> 0 and CLNO not in (2179)  
and  DateDiff(year,RequestDate,CURRENT_TIMESTAMP)  <= 1     
and IsNull(CallbackFailures,0) <= 4  
UNION ALL  
SELECT   
    'dbo.Integration_OrderMgmt_Request' CallbackSource,'RequestID' as IdFieldName, RequestID,CLNO,    
  APNO,  
  (CASE  
    WHEN (Process_Callback_Acknowledge=1) THEN ru.UserAction END) as CallbackStatus,  
  Partner_Reference,Partner_Tracking_Number,UserName,IsNull(CallbackFailures,0) as CallbackFailureCount,null  
FROM   
      dbo.Integration_OrderMgmt_Request r with (NOLOCK) inner join dbo.Integration_OrderMgmt_refUserAction ru  
   on r.refUserActionID = ru.refUserActionID  
      WHERE r.refUserActionID > 3 and  
        (Process_CallBack_Acknowledge = 1 and CallBack_Acknowledge_Date IS NULL)            
  and lower(Partner_Reference) not like '%test%'  
  and  DateDiff(year,RequestDate,CURRENT_TIMESTAMP)  <= 1     
and IsNull(CallbackFailures,0) <= 4  
 --RequestID in (343439)  
  
--temporaryily removing HCA Alpha and Beta COMPLETED callbacks - based on client  - for alpha/beta go live on 2/9/15  
--Delete #StatusUpdateCallbackTemp  
--Where CLNO =7519 AND   
--RequestID in (Select RequestID From dbo.Integration_OrderMgmt_Request R inner join HEVN.DBO.Facility F ON CLNO = ParentEmployerID AND isnull(R.FacilityCLNO,0) = isnull(F.FacilityCLNO,0) Where IsOneHR = 1 and (Process_CallBack_Final = 1 and CallBack_Fina
l_Date IS NULL))  
  
--Lock callback acknowledgement dates to default date  
-- so other updatecallback services do not interfere with the date  
update  dbo.Integration_OrderMgmt_Request   
 set CallBack_Acknowledge_Date = @defaultDate  
 where  Process_CallBack_Acknowledge = 1   
 and RequestID in (select RequestID from #StatusUpdateCallbackTemp Where CallbackSource = 'dbo.Integration_OrderMgmt_Request')  
  
update  dbo.Integration_OrderMgmt_Request   
 set CallBack_Final_Date = @defaultDate  
 where  Process_CallBack_Final = 1   
 and RequestID in (select RequestID from #StatusUpdateCallbackTemp  Where CallbackSource = 'dbo.Integration_OrderMgmt_Request')  

Insert Into #StatusUpdateCallbackTemp  
Select 'dbo.Integration_PrecheckCallback' CallbackSource,'PrecheckCallbackID' as IdFieldName,PrecheckCallbackID RequestID,CLNO,    
  APNO,  
   (CASE   
           WHEN (Process_CallBack_Acknowledge = 1) THEN 'InProcess'   
     WHEN (Process_CallBack_Final = 1) THEN 'Complete'  
       END) as CallbackStatus,  
   Partner_Reference,null Partner_Tracking_Number,null UserName,isnull(callbackfailures,0) as CallbackFailureCount,null as PartnerConfigId   
From dbo.[Integration_PrecheckCallback] with (NOLOCK)  
 WHERE    
  ( (Process_CallBack_Acknowledge = 1 and CallBack_Acknowledge_Date IS NULL)   
           or (Process_CallBack_Final = 1 and CallBack_Final_Date IS NULL) ) and  lower(Partner_Reference) not like '%test%'  
--and  DateDiff(year,CreatedDate,CURRENT_TIMESTAMP)  <= 1   
and CLNO not in (3115)   
and IsNull(CallbackFailures,0) <= 4 
and PrecheckCallbackID = 86594 
--and isnull(callbackfailures,0) = 0  
    */
  
  
--Lock callback acknowledgement dates to default date  
-- so other updatecallback services do not interfere with the date
 /* 
update  dbo.[Integration_PrecheckCallback]   
 set CallBack_Acknowledge_Date = @defaultDate  
 where  Process_CallBack_Acknowledge = 1   
 and PrecheckCallbackID in (select RequestID from #StatusUpdateCallbackTemp Where CallbackSource = 'dbo.Integration_PrecheckCallback')  
  
update  dbo.[Integration_PrecheckCallback]   
 set CallBack_Final_Date = @defaultDate  
 where  Process_CallBack_Final = 1   
 and PrecheckCallbackID in (select RequestID from #StatusUpdateCallbackTemp  Where CallbackSource = 'dbo.Integration_PrecheckCallback')  
 */ 
/*Adding PartnerCallbacks by Doug 04/02/2019 */  
Insert Into #StatusUpdateCallbackTemp  
SELECT distinct  
    'dbo.PartnerCallback' CallbackSource,  
 'PartnerCallbackId' as IdFieldName,  
 PartnerCallbackId as RequestID,  
 aa.CLNO as CLNO,    
 OrderNumber,  
 'InProcess' as CallbackStatus,  
 PartnerReference,  
 null as Partner_Tracking_Number,  
 null as UserName,  
 IsNull(RetryCounter,0) as CallbackFailureCount,    
 cfg.PartnerConfigId  
FROM   
      dbo.[PartnerCallback] pc with (NOLOCK)   
   inner join dbo.PartnerConfig cfg (NOLOCK)  on   
   pc.[PartnerId] = cfg.PartnerId  
   inner join dbo.PartnerClient pcli (NOLOCK) on  
   pcli.PartnerId = cfg.PartnerId  
   inner join Appl aa on aa.APNO = pc.OrderNumber  
      WHERE refUserActionID = 1   
      and PartnerCallbackReady=1  
   and PartnerCallbackDate is null    
   and pcli.IsActive = 1   
  
  /*  
  update  dbo.[PartnerCallback]  
 set PartnerCallbackDate = @defaultDate  
 where  PartnerCallbackReady = 1   
 and PartnerCallbackId in (select RequestID from #StatusUpdateCallbackTemp Where CallbackSource = 'dbo.PartnerCallback')  
  */
  
SELECT CallbackSource,IdFieldName,Temp.RequestID,Temp.CLNO,Temp.APNO,temp.CallBackStatus,  
(CASE Lower(CallbackStatus)  
 WHEN  'inprocess' then Config.URL_CallBack_Acknowledge   
 WHEN  'complete' then Config.URL_CallBack_Final   
 WHEN 'Concluded' then Config.URL_CallBack_Final  
 ELSE Config.URL_CallBack_Final  
end)   
as CallBack_URL,CallBackMethod,IntegrationMethod,Temp.Partner_Reference,Temp.Partner_Tracking_Number,Config.OperationName,UserName,CallbackFailureCount,PartnerConfigId  
FROM  #StatusUpdateCallbackTemp Temp   
LEFT JOIN  dbo.XLATECLNO Client   
ON Temp.CLNO = Client.CLNOin  
LEFT JOIN dbo.ClientConfig_Integration Config   
ON isnull(Client.CLNOin,0) = Config.CLNO   
WHERE   
Partner_Reference IS NOT NULL  
AND temp.CallBackStatus IS NOT NULL   
AND CallBackMethod IS NOT NULL   
AND IntegrationMethod IS NOT NULL  
and IsNull(Config.IsActive,0) = 1  
--and Temp.RequestID not in (select RequestID from dbo.Integration_OrderMgmt_Request (nolock) where DateDiff(year,RequestDate,CURRENT_TIMESTAMP)  > 1)  
UNION ALL  
--- BELOW IS RELATED TO PARTNER CALLBACKS ONLY --  
SELECT CallbackSource,IdFieldName,Temp.RequestID,Temp.CLNO,Temp.APNO,temp.CallBackStatus,  
cast(config.ConfigSettings as xml).value('(//EndpointUrl)[1]','varchar(150)') as CallBack_URL,  
null as CallBackMethod,null IntegrationMethod,Temp.Partner_Reference,Temp.Partner_Tracking_Number,Config.PartnerOperation,UserName,CallbackFailureCount,config.PartnerConfigId  
FROM  #StatusUpdateCallbackTemp Temp   
inner join dbo.PartnerConfig config on temp.PartnerConfigId = config.PartnerConfigId  
WHERE IsNull(Config.IsActive,0) = 1  
  
drop table #StatusUpdateCallbackTemp  
   
END  
  
  
  
  
SET NOCOUNT OFF  
  
  