      
--dbo.SP_GetCallbackItemByApno null,'larry123',3097      

CREATE procedure [dbo].[SP_GetCallbackItemByApno](@apno int = null,@partner_reference varchar(20) = null,@clno int = null)      
as      
      
CREATE TABLE #tmpCallback
(StatusUpdateCallbackTempID  [int] IDENTITY(1,1) NOT NULL,
 CallbackSource varchar(50) NOT NULL,
 IdFieldName varchar(50) NOT NULL,
 RequestID int NOT NULL,
 CLNO int NOT NULL,
 APNO int NULL,
 CallbackStatus varchar(300) NOT NULL,
 Partner_Reference varchar(50) NULL,
 Partner_Tracking_Number varchar(50) NULL,
 UserName varchar(50) NULL,
 CallbackFailureCount int NOT NULL,
 PartnerConfigId int NULL
)   
      
/*      
insert into #tmpCallback      
SELECT       
    'dbo.Integration_OrderMgmt_Request' CallbackSource,'RequestID' as IdFieldName, RequestID,CLNO,        
  APNO,      
   (CASE       
           WHEN (Process_CallBack_Acknowledge = 1) THEN 'InProcess'       
     WHEN (Process_CallBack_Final = 1) THEN 'Complete'      
  -- else 'Complete'      
    --WHEN (Process_CallBack_Final = 1) THEN 'Concluded'      
       END) as CallbackStatus,      
  Partner_Reference,Partner_Tracking_Number,UserName,IsNull(CallbackFailures,0) as CallbackFailureCount ,null as PartnerConfigId        
FROM       
      dbo.Integration_OrderMgmt_Request (NOLOCK)         
      WHERE  Apno = @apno      
 UNION ALL      
SELECT       
    'dbo.Integration_OrderMgmt_Request' CallbackSource,'RequestID' as IdFieldName, RequestID,CLNO,        
  APNO,      
  (CASE      
    WHEN (Process_Callback_Acknowledge=1) THEN ru.UserAction END) as CallbackStatus,      
  Partner_Reference,Partner_Tracking_Number,UserName,IsNull(CallbackFailures,0) as CallbackFailureCount,null as PartnerConfigId          
FROM       
      dbo.Integration_OrderMgmt_Request r with (NOLOCK) inner join dbo.Integration_OrderMgmt_refUserAction ru      
   on r.refUserActionID = ru.refUserActionID      
      WHERE r.refUserActionID > 3      
   and Partner_Reference = @partner_reference and CLNO = @clno--RequestID = @apno      
           
      
      
insert into #tmpCallback      
SELECT       
    'dbo.Integration_PrecheckCallback' CallbackSource,'PrecheckCallbackID' as IdFieldName, PrecheckCallbackID as RequestID,CLNO,        
  APNO,      
   (CASE       
           WHEN (Process_CallBack_Acknowledge = 1) THEN 'InProcess'       
     WHEN (Process_CallBack_Final = 1) THEN 'Complete'      
    --WHEN (Process_CallBack_Final = 1) THEN 'Concluded'      
       END) as CallbackStatus,      
  Partner_Reference,null,null,IsNull(CallbackFailures,0) as CallbackFailureCount,null as PartnerConfigId         
FROM       
      dbo.integration_PrecheckCallback (NOLOCK)      
      WHERE  Apno = @apno      
*/
Insert Into #tmpCallback
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
	  where
  --    WHERE refUserActionID = 1 
  --    --and PartnerCallbackReady=1
	 -- and PartnerCallbackDate is null	 
	 -- and pcli.IsActive = 1	
	 -- and pc.IsActive = 1
	 --   and aa.CLNO = pcli.ClientId	
		--and IsNull(pc.RetryCounter,0) <= 4
		--and
		 PartnerCallbackId=33


      
--select * from #tmpCallback      
      
SELECT CallbackSource,IdFieldName,Temp.RequestID,Temp.CLNO,Temp.APNO,temp.CallBackStatus,      
(CASE Lower(CallbackStatus)      
 WHEN  'inprocess' then Config.URL_CallBack_Acknowledge       
 WHEN  'complete' then Config.URL_CallBack_Final       
 WHEN 'Concluded' then Config.URL_CallBack_Final       
 ELSE Config.URL_CallBack_Acknowledge      
end)       
as CallBack_URL,CallBackMethod,IntegrationMethod,Temp.Partner_Reference,Temp.Partner_Tracking_Number,Config.OperationName,UserName,CallbackFailureCount,PartnerConfigId      
FROM  #tmpCallback Temp       
LEFT JOIN  dbo.XLATECLNO Client       
ON Temp.CLNO = Client.CLNOin      
LEFT JOIN dbo.ClientConfig_Integration Config       
ON isnull(Client.CLNOin,0) = Config.CLNO       
WHERE Partner_Reference IS NOT NULL      
AND temp.CallBackStatus IS NOT NULL       
AND CallBackMethod IS NOT NULL       
AND IntegrationMethod IS NOT NULL      
and IsNull(Config.IsActive,0) = 1      
--and Temp.RequestID not in (select RequestID from dbo.Integration_OrderMgmt_Request (nolock) where DateDiff(year,RequestDate,CURRENT_TIMESTAMP)  > 1)       
UNION ALL
SELECT CallbackSource,IdFieldName,Temp.RequestID,Temp.CLNO,Temp.APNO,temp.CallBackStatus,
cast(config.ConfigSettings as xml).value('(//EndpointUrl)[1]','varchar(150)') as CallBack_URL,
null as CallBackMethod,null as IntegrationMethod,Temp.Partner_Reference,Temp.Partner_Tracking_Number,Config.PartnerOperation,UserName,CallbackFailureCount,config.PartnerConfigId
FROM  #tmpCallback Temp 
inner join dbo.PartnerConfig config on temp.PartnerConfigId = config.PartnerConfigId
WHERE IsNull(Config.IsActive,0) = 1      
drop table #tmpCallback       
      