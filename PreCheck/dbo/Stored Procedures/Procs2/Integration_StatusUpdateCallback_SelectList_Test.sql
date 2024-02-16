﻿





--[dbo].[Integration_StatusUpdateCallback_SelectList_Test] 144864
CREATE PROCEDURE [dbo].[Integration_StatusUpdateCallback_SelectList_Test] 
(
--DECLARE
	@requestid int = null
)

AS
BEGIN
SET NOCOUNT ON
	
	declare @defaultDate datetime
	set @defaultDate = current_timestamp	
	set @defaultDate = replace(@defaultdate,year(@defaultdate),'1900')

	

	
		
CREATE TABLE #StatusUpdateCallbackTemp
(StatusUpdateCallbackTempID  [int] IDENTITY(1,1) NOT NULL,
 CallbackSource varchar(50) NOT NULL,
 IdFieldName varchar(50) NOT NULL,
 RequestID int NOT NULL,
 CLNO int NOT NULL,
 APNO int NULL,
 CallbackStatus varchar(100) NOT NULL,
 Partner_Reference varchar(50) NULL,
 Partner_Tracking_Number varchar(50) NULL,
 UserName varchar(50) NULL,
 CallbackFailureCount int NOT NULL,
 PartnerConfigId int NULL
) 


Insert Into #StatusUpdateCallbackTemp
SELECT 
    'dbo.Integration_OrderMgmt_Request' CallbackSource,'RequestID' as IdFieldName, RequestID,r.CLNO,		
		r.APNO,
	  (CASE 
           WHEN (Process_CallBack_Acknowledge = 1 and  isnull(r.refuseractionid,0) in (22)) THEN ru.UserAction 
		   WHEN (Process_CallBack_Acknowledge = 1) THEN 'InProcess' 
		   WHEN (Process_CallBack_Final = 1) THEN 'Complete'
		   WHEN (Process_Callback_Acknowledge = 0) then 'InProcess'
		    WHEN (Process_CallBack_Final = 0) then 'Complete'
		  --WHEN (Process_CallBack_Final = 1) THEN 'Concluded'
       END) as CallbackStatus,
	 Partner_Reference,Partner_Tracking_Number,UserName,IsNull(CallbackFailures,0) as CallbackFailureCount,null
FROM 
      dbo.Integration_OrderMgmt_Request r with (NOLOCK) inner join dbo.Appl a on a.APNO = r.APNO
	  left join dbo.Integration_OrderMgmt_refUserAction ru on r.refUserActionID = ru.refUserActionID
      WHERE 	 
	  	     	  isnull(r.refuseractionid,0) in (1,22)  
      --and ( (Process_CallBack_Acknowledge = 1 and CallBack_Acknowledge_Date IS NULL) 
       --    or (Process_CallBack_Final = 1 and CallBack_Final_Date IS NULL) )
	 --and lower(Partner_Reference) not like '%test%'
and IsNull(r.APNO,0) <> 0 and r.CLNO not in (2179)
and  DateDiff(year,RequestDate,CURRENT_TIMESTAMP)  <= 1	 
and (IsNull(a.ApDate,'') <> '' or isnull(r.refuseractionid,0) = 22)  
--and IsNull(CallbackFailures,0) <= 10
and r.RequestId = @Requestid
--and  DateDiff(year,RequestDate,CURRENT_TIMESTAMP)  <= 1	 
--and IsNull(a.ApDate,'') <> ''  
--and IsNull(CallbackFailures,0) <= 10
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
	-- and lower(Partner_Reference) not like '%test%'
	 and  DateDiff(year,RequestDate,CURRENT_TIMESTAMP)  <= 1	  
and IsNull(CallbackFailures,0) <= 10
and APNO IS NULL
	 and r.RequestId = @Requestid
--and IsNull(CallbackFailures,0) <= 10



--Insert Into #StatusUpdateCallbackTemp
--Select 'dbo.Integration_PrecheckCallback' CallbackSource,'PrecheckCallbackID' as IdFieldName,PrecheckCallbackID RequestID,CLNO,		
--		APNO,
--	  (CASE 
--           WHEN (Process_CallBack_Acknowledge = 1) THEN 'InProcess' 
--		   WHEN (Process_CallBack_Final = 1) THEN 'Complete'
--       END) as CallbackStatus,
--	  Partner_Reference,null Partner_Tracking_Number,null UserName,CallbackFailures as CallbackFailureCount,null as PartnerConfigId
--From dbo.[Integration_PrecheckCallback] with (NOLOCK)
-- WHERE  
--  lower(Partner_Reference) not like '%test%'
--and  DateDiff(year,CreatedDate,CURRENT_TIMESTAMP)  <= 1	
--and CLNO not in (3115) 
--and IsNull(CallbackFailures,0) <= 4
--and CallbackFailures = 0






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
	   inner join dbo.client c on 
	  aa.CLNO = c.CLNO
      WHERE refUserActionID = 1 
      --and PartnerCallbackReady=1
	  --and PartnerCallbackDate is null	 
	  and pcli.IsActive = 1	
	   and pc.IsActive = 1
	   --and aa.CLNO = pcli.ClientId	-- added
	   --and ISNULL(c.weborderparentclno,c.clno) = pcli.ClientId 
	  --and IsNull(RetryCounter,0) <= 10
	  and pc.PartnerCallbackId = @RequestId
--/*Add SentryMD Callbacks which have not PartnerClient relationship*/
UNION
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
	  inner join Appl aa on aa.APNO = pc.OrderNumber
      WHERE refUserActionID = 1 
   --   and PartnerCallbackReady=1
	  --and PartnerCallbackDate is null	 
	  and pc.IsActive = 1
	  AND cfg.IsActive = 1
		--and IsNull(pc.RetryCounter,0) <= 4
		AND pc.PartnerId = (SELECT PartnerID FROM dbo.Partner WHERE dbo.Partner.PartnerName = 'SentryMd')
		and PartnerCallbackId = @RequestId

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
and Temp.Requestid=@RequestId
--and Temp.RequestID not in (select RequestID from dbo.Integration_OrderMgmt_Request (nolock) where DateDiff(year,RequestDate,CURRENT_TIMESTAMP)  > 1)
UNION ALL
--- BELOW IS RELATED TO PARTNER CALLBACKS ONLY --
SELECT CallbackSource,IdFieldName,Temp.RequestID,Temp.CLNO,Temp.APNO,temp.CallBackStatus,
cast(config.ConfigSettings as xml).value('(//EndpointUrl)[1]','varchar(150)') as CallBack_URL,
null as CallBackMethod,null IntegrationMethod,Temp.Partner_Reference,Temp.Partner_Tracking_Number,Config.PartnerOperation,UserName,CallbackFailureCount,config.PartnerConfigId
FROM  #StatusUpdateCallbackTemp Temp 
inner join dbo.PartnerConfig config on temp.PartnerConfigId = config.PartnerConfigId
WHERE IsNull(Config.IsActive,0) = 1
and Temp.RequestID = @RequestID

-- END PARTNER CALLBACK
--and Temp.RequestID not in (select RequestID from dbo.Integration_OrderMgmt_Request (nolock) where DateDiff(year,RequestDate,CURRENT_TIMESTAMP)  > 1)
--and 1=0
drop table #StatusUpdateCallbackTemp	
--select * from #StatusUpdateCallbackTemp where RequestID = @RequestID


	 	
--;WITH CTE as
--(
--SELECT 
--	CallbackSource,
--	IdFieldName,
--	Temp.RequestID,
--	Temp.CLNO,
--	Temp.APNO,
--	temp.CallBackStatus,
--(CASE Lower(CallbackStatus)
--	WHEN  'inprocess' then Config.URL_CallBack_Acknowledge 
--	WHEN  'complete' then Config.URL_CallBack_Final 
--	WHEN 'Concluded' then Config.URL_CallBack_Final
--	ELSE Config.URL_CallBack_Final
--end) as 	CallBack_URL,
--	CallBackMethod,
--	IntegrationMethod,
--	Temp.Partner_Reference,
--	Temp.Partner_Tracking_Number,
--	Config.OperationName as PartnerOperation,
--	UserName,
--	CallbackFailureCount,
--	PartnerConfigId
--FROM  
--	#StatusUpdateCallbackTemp Temp LEFT JOIN  dbo.XLATECLNO Client 
--ON 
--	Temp.CLNO = Client.CLNOin
--LEFT JOIN 
--	dbo.ClientConfig_Integration Config 
--ON 
--	isnull(Client.CLNOin,0) = Config.CLNO 
--WHERE 
--	Partner_Reference IS NOT NULL
--	AND temp.CallBackStatus IS NOT NULL 
--	AND CallBackMethod IS NOT NULL 
--	AND IntegrationMethod IS NOT NULL
--	and IsNull(Config.IsActive,0) = 1
--	--and Temp.RequestID not in (select RequestID from dbo.Integration_OrderMgmt_Request (nolock) where DateDiff(year,RequestDate,CURRENT_TIMESTAMP)  > 1)
--UNION ALL
----- BELOW IS RELATED TO PARTNER CALLBACKS ONLY --
--SELECT 
--	CallbackSource,
--	IdFieldName,
--	Temp.RequestID,
--	Temp.CLNO,
--	Temp.APNO,
--	temp.CallBackStatus,
--	cast(config.ConfigSettings as xml).value('(//EndpointUrl)[1]','varchar(150)') as CallBack_URL,
--	null as CallBackMethod,
--	null IntegrationMethod,
--	Temp.Partner_Reference,
--	Temp.Partner_Tracking_Number,
--	Config.PartnerOperation,
--	UserName,
--	CallbackFailureCount,
--	config.PartnerConfigId
--FROM  
--	#StatusUpdateCallbackTemp Temp inner join dbo.PartnerConfig config 
--ON	
--	temp.PartnerConfigId = config.PartnerConfigId
--WHERE 
--	IsNull(Config.IsActive,0) = 1
--)

--select 
--	CallbackSource,
--	IdFieldName,
--	RequestID,
--	c.CLNO,
--	APNO,
--	CallBackStatus,
--	COALESCE(dbo.[GetXMLNodeValue](cci.ConfigSettings,'ClientConfigSettings','NotificationApi'),CallBack_URL) as CallBack_URL,
--	c.CallBackMethod,
--	c.IntegrationMethod,
--	Partner_Reference,
--	Partner_Tracking_Number,
--	c.PartnerOperation as OperationName,
--	UserName,
--	CallbackFailureCount,
--	PartnerConfigId
--from 
--	CTE c left join ClientConfig_Integration cci on c.CLNo = cci.CLNO
--and c.RequestID = @RequestID
---- END PARTNER CALLBACK
----and Temp.RequestID not in (select RequestID from dbo.Integration_OrderMgmt_Request (nolock) where DateDiff(year,RequestDate,CURRENT_TIMESTAMP)  > 1)
----and 1=0
--drop table #StatusUpdateCallbackTemp	
END




SET NOCOUNT OFF


