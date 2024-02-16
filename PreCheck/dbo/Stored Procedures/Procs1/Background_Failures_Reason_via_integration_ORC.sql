
  
/*created By - Sunil Mandal 30Sep22    
Exec [dbo].[Background_Failures_Reason_via_integration_ORC] 16784    
Exec [dbo].[Background_Failures_Reason_via_integration_ORC] '0'    
Exec [dbo].[Background_Failures_Reason_via_integration_ORC] '12444',null,NULL,NULL    
Exec [dbo].[Background_Failures_Reason_via_integration_ORC] '12444:14765'    
*/    
  
CREATE Proc [dbo].[Background_Failures_Reason_via_integration_ORC]   
--DECLARE    
(  
 @CLNO varchar(max) = 12444,           
 @ChildCLNO int = null,        
 @FromDate DateTime = null,  
 @ToDate DateTime = null   
)  
AS  
  
 IF @FromDate is null        
 SET @FromDate = CAST(CAST(GETDATE() AS DATE) AS DATETIME)         
        
IF @ToDate is null        
 SET @ToDate = GETDATE()  
  
-- SELECT @FromDate,@ToDate  
       
drop table if exists #candidateBackgroundCheck    
drop table if exists #CreateNewOrderWithEmail    
drop table if exists #OnlyCandidateBackgroundCheck    
drop table if exists #TopFailedRecord    
drop table if exists #MissingCreateNewOrderWithEmail    
drop table if exists #FailedCreateNewOrderWithEmail    
drop table if exists #FailedhasErrortrue    
drop table if exists #CallbackRequestIdsForDate    
drop table if exists #FailedCandidateDetails    
drop table if exists #PartnerCallbackError  
drop table if exists #PartnerCallbackErrorIDs  
  
DECLARE @errorDetail VARCHAR(MAX) = null;  
DECLARE @facility VARCHAR(MAX) = null;  
DECLARE @payload VARCHAR(MAX) = null;  
  
  
select   
distinct   
IOR.Partner_Reference As [Candidate ID],    
IOR.UserName As Requestor,    
IOR.Partner_Tracking_Number As [Requisition ID],                                     
IOR.RequestDate,    
IOR.APNO,    
IOR.RequestID,    
IOR.FacilityCLNO,  
IOR.CLNO  
,PRP.ResponsePayload as [Candidate Information]  
,IOR.Request as Request  
--,@facility as [Facility]  
--,@errorDetail as [Error Details]  
into #CallbackRequestidsForDate    
from dbo.PartnerRequestParameters prp inner join Integration_OrderMgmt_Request ior    
on prp.RequestId = ior.RequestId    
where   
prp.RequestPayload like '%clientRefKey%' + @CLNO + '%'    
and  
cast(prp.CreateDate as date)  between @FromDate AND @ToDate    
  
--select * from #CallbackRequestidsForDate  
      
Select    
 distinct pc.*,cbrfd.*    
into #PartnerCallbackError   
From partnercallback pc     
inner join #CallbackRequestIdsForDate cbrfd on pc.OrderNumber = cbrfd.APNO    
where pc.RetryCounter > 0 and pc.PartnerCallbackDate like '%1900%'  
  
--select * from #PartnerCallbackError   
  
  
  
Select    
 distinct prp.*    
into #candidateBackgroundCheck    
From PartnerRequestParameters prp     
inner join #CallbackRequestIdsForDate cbrfd on prp.RequestId = cbrfd.RequestId    
Where    
 PartnerOperation = 'candidateBackgroundCheck'    
     
    
--select * from #candidateBackgroundCheck    
  
select    
 distinct prp.*    
 into #CreateNewOrderWithEmail    
From PartnerRequestParameters prp     
inner join #CallbackRequestIdsForDate cbrfd on prp.RequestId = cbrfd.RequestId    
where    
 PartnerOperation = 'CreateNewOrderWithEmail'    
  
 --select * from #CreateNewOrderWithEmail    
--select * from #candidateBackgroundCheck    
    
select bg.*    
into #OnlyCandidateBackgroundCheck    
from #candidateBackgroundCheck bg    
left join #CreateNewOrderWithEmail coe on bg.RequestId = coe.RequestId    
where coe.RequestId is null    
    
--select * from #OnlyCandidateBackgroundCheck    
  
Select   
replace(SA.First,',',' ') As FirstName,    
replace(SA.Last,',',' ') As LastName,    
cast(cbrfd.[Candidate ID] as varchar(100)) As [Candidate ID],    
cbrfd.Requestor As Requestor,    
cast(cbrfd.[Requisition ID] as varchar(100)) As [Requisition ID],    
cbrfd.RequestDate,    
null As [Time/Date stamp of failure],    
cbrfd.APNO,    
'No response received' As [Error message received],    
cbrfd.Request as Payload,  
--PRP.RequestPayload [Payload],  
cbrfd.RequestID,    
cbrfd.CLNO,  
cbrfd.FacilityCLNO  
,PRP.ResponsePayload AS [Candidate Information]  
,@facility AS [Facility]  
,@errorDetail AS [Error Details]  
,ROW_NUMBER() OVER(PARTITION BY prp.RequestID  ORDER BY prp.CreateDate DESC) AS row_number    
Into #PartnerCallbackErrorIDs    
From    
#CallbackRequestidsForDate cbrfd   
inner join #PartnerCallbackError pcbe on cbrfd.RequestId = pcbe.RequestId    
Inner join [dbo].[PartnerRequestParameters] PRP With (nolock) ON cbrfd.RequestID = PRP.RequestId   
inner join dbo.Appl SA on SA.APNO = cbrfd.Apno    
where ISJSON(prp.responsepayload) > 0  
  
  
  
Select  distinct  
null  As FirstName,    
null As LastName,    
cast(cbrfd.[Candidate ID] as varchar(100)) As [Candidate ID],    
cbrfd.Requestor As Requestor,    
cast(cbrfd.[Requisition ID] as varchar(100)) As [Requisition ID],    
cbrfd.RequestDate,    
null As [Time/Date stamp of failure],    
cbrfd.APNO,    
@payload As [Error message received],    
cbrfd.Request AS [Payload],  
cbrfd.RequestID,    
cbrfd.CLNO,  
cbrfd.FacilityCLNO  
,PRP.ResponsePayload as [Candidate Information]  
,JSON_VALUE(PRP.ResponsePayload, '$.RequisitionOrganization') AS [Facility]  
,@errorDetail AS [Error Details],  
ROW_NUMBER() OVER(PARTITION BY prp.RequestID  ORDER BY PRP.CreateDate DESC) AS row_number    
Into #MissingCreateNewOrderWithEmail    
From    
#CallbackRequestidsForDate cbrfd    
inner join #OnlyCandidateBackgroundCheck bg on cbrfd.RequestID = bg.RequestId    
Inner join [dbo].[PartnerRequestParameters] PRP With (nolock) ON cbrfd.RequestID = PRP.RequestId    
--left Join [Enterprise].Staging.vwStageApplicant SA With (nolock) ON SA.IntegrationRequestId = IOR.RequestID   
where ISJSON(prp.responsepayload) > 0 --and PRP.PartnerOperation='candidateBackgroundCheck'   
  
--select * from #MissingCreateNewOrderWithEmail    
  
Select    
replace(SA.FirstName,',',' ') As FirstName,    
replace(SA.LastName,',',' ') As LastName,    
cast(IOR.[Candidate ID] as varchar(100)) As [Candidate ID],    
IOR.Requestor As Requestor,    
cast(IOR.[Requisition ID] as varchar(100)) As [Requisition ID],    
IOR.RequestDate,    
PRP.CreateDate As [Time/Date stamp of failure],    
IOR.APNO,    
PRP.ResponsePayload As [Error message received],  
PRP.RequestPayload AS [Payload],  
IOR.RequestID,    
IOR.CLNO,    
IOR.FacilityCLNO,  
PRP.ResponsePayload as [Candidate Information],  
@facility AS [Facility],  
@errorDetail AS [Error Details],  
ROW_NUMBER() OVER(PARTITION BY prp.RequestID  ORDER BY PRP.CreateDate DESC) AS row_number    
Into #TopFailedRecord    
from #CallbackRequestidsForDate IOR With (nolock)    
Inner join [dbo].[PartnerRequestParameters] PRP With (nolock) ON IOR.RequestID = PRP.RequestId    
--inner join #OnlyCandidateBackgroundCheck bg on IOR.RequestID = bg.RequestId    
left Join [Enterprise].Staging.vwStageApplicant SA With (nolock) ON SA.IntegrationRequestId = IOR.RequestID   
Where  IsNull(PRP.HttpResponseCode,'') <> '200'     
AND IsNull(PRP.ResponsePayload,'') like '%{%'    
AND cast(prp.CreateDate as date)  between @FromDate AND @ToDate --cast(getdate() as date)     
and  PRP.PartnerOperation <> 'recruitingPartnerCandidateDetails'    
    
    
--select * from #TopFailedRecord    
    
  
Select    
replace(SA.FirstName,',',' ') As FirstName,    
replace(SA.LastName,',',' ') As LastName,    
cast(IOR.[Candidate ID] as varchar(100)) As [Candidate ID],    
IOR.Requestor As Requestor,    
cast(IOR.[Requisition ID] as varchar(100)) As [Requisition ID],     
IOR.RequestDate,    
PRP.CreateDate As [Time/Date stamp of failure],    
IOR.APNO,    
PRP.ResponsePayload As [Error message received],   
PRP.RequestPayload AS [Payload],  
--'Failed to Call CreateNewOrderWithEmail' as [Error message received],    
IOR.RequestID,    
IOR.CLNO,    
IOR.FacilityCLNO,  
PRP.ResponsePayload as [Candidate Information],  
@facility AS [Facility],  
@errorDetail AS [Error Details],  
ROW_NUMBER() OVER(PARTITION BY PRP.RequestID  ORDER BY PRP.CreateDate DESC) AS row_number    
Into #FailedCandidateDetails    
from #CallbackRequestidsForDate IOR With (nolock)    
Inner join [Precheck].[dbo].[PartnerRequestParameters] PRP With (nolock) ON IOR.RequestID = PRP.RequestId    
--inner join #OnlyCandidateBackgroundCheck bg on ior.RequestID = bg.RequestId    
left Join [Enterprise].Staging.vwStageApplicant SA With (nolock) ON SA.IntegrationRequestId = IOR.RequestID   
Where   PRP.PartnerOperation = 'recruitingPartnerCandidateDetails' and  IsNull(PRP.HttpResponseCode,'') <> '200'    
and cast(prp.CreateDate as date)  between @FromDate AND @ToDate  --cast(getdate() as date)    
    
--select * from #FailedCandidateDetails    
  
    
--select * from #FailedCreateNewOrderWithEmail    
    
Select    
replace(SA.FirstName,',',' ') As FirstName,    
replace(SA.LastName,',',' ') As LastName,    
cast(IOR.[Candidate ID] as varchar(100)) As [Candidate ID],    
IOR.Requestor As Requestor,    
cast(IOR.[Requisition ID] as varchar(100)) As [Requisition ID],    
IOR.RequestDate,    
PRP.CreateDate As [Time/Date stamp of failure],    
IOR.APNO,    
--replace(PRP.ResponsePayload,',',' ')  
PRP.RequestPayload As [Error message received],    
IOR.Request AS [Payload],  
IOR.RequestID,    
IOR.CLNO,    
IOR.FacilityCLNO,    
PRP.ResponsePayload as [Candidate Information],  
@facility AS [Facility],  
JSON_VALUE(PRP.RequestPayload, '$.errorMessage') AS [Error Details]  
,ROW_NUMBER() OVER(PARTITION BY PRP.REQUESTID  ORDER BY PRP.CreateDate DESC) AS row_number    
--,ISJSON(isnull(PRP.RequestPayload,'')) as [isjson]  
INTO #FailedhasErrortrue    
from #CallbackRequestidsForDate IOR With (nolock)     
Inner join [Precheck].[dbo].[PartnerRequestParameters] PRP With (nolock) ON IOR.RequestID = PRP.RequestId    
left Join [Enterprise].Staging.vwStageApplicant SA With (nolock) ON SA.IntegrationRequestId = IOR.RequestID   
--inner join #OnlyCandidateBackgroundCheck bg on ior.RequestID = bg.RequestId    
--left join dbo.Appl a on a.APNO = IOR.APNO    
Where   PRP.PartnerOperation = 'CreateNewOrderWithEmail' And PRP.RequestPayload like '%hasError%true%'    
and cast(prp.CreateDate as date)  between @FromDate AND @ToDate --cast(getdate() as date)    
AND ISJSON(isnull(PRP.RequestPayload,'')) = 1   
and ISNULL(IOR.[Candidate Information],'') <> ''   
  
  
--select * from #FailedhasErrortrue  
  
SELECT          
--RequestId  
ErrorType  
,FirstName  
,LastName  
,[Candidate ID]  
,Requestor  
,[Requisition ID]  
,RequestDate  
,[Time/Date stamp of failure]  
,APNO  
,ISNULL(replace(replace([Error message received],',',''),'  ',''),'No response received') as [Error message received]  
,Replace([Payload],',','') AS [Payload]  
,RequestID  
,CLNO  
,FacilityCLNO  
--,NULL AS [Candidate Information]  
,[Facility]  
,[Error Details]  
,case when [Candidate Information] like '%pending worker%' or [Candidate Information] like '%already exists%' then 'Oracle' else 'Precheck' end as [Source]   
From   
(  
Select 'Callback Error' as ErrorType,cast(FirstName as varchar(100)) as FirstName ,cast(LastName as varchar(100)) as LastName,[Candidate ID],Requestor,[Requisition ID],RequestDate,cast([Time/Date stamp of failure] as varchar) as [Time/Date stamp of failure] ,APNO,[Error message received] , [Payload],RequestID,CLNO,FacilityCLNO , [Candidate Information] , [Facility] ,[Error Details], null as [Source]    
from #TopFailedRecord With (nolock) WHERE row_number = 1 --AND Convert(date,[Time/Date stamp of failure]) = Convert(Date,Getdate()) --And CLNO not in (16784)    
Union all  
Select 'Missing CreateNewOrderWithEmail Error' as ErrorType,cast(FirstName as varchar(100)) as FirstName ,cast(LastName as varchar(100)) as LastName,[Candidate ID],Requestor,[Requisition ID],RequestDate,cast([Time/Date stamp of failure] as varchar) as [Time/Date stamp of failure],APNO,[Error message received], [Payload],RequestID,CLNO,FacilityCLNO ,[Candidate Information] , [Facility],[Error Details] , null as [Source]        
From #MissingCreateNewOrderWithEmail WHERE row_number = 1  -- Convert(date,[Time/Date stamp of failure]) = Convert(Date,Getdate())     
Union all    
Select 'Candidate Details Error' as ErrorType,cast(FirstName as varchar(100)) as FirstName ,cast(LastName as varchar(100)) as LastName,[Candidate ID],Requestor,[Requisition ID],RequestDate, cast([Time/Date stamp of failure] as varchar) as [Time/Date stamp of failure],APNO,[Error message received], [Payload],RequestID,CLNO,FacilityCLNO , [Candidate Information], [Facility]   ,[Error Details]   , null as [Source]     
From #FailedCandidateDetails WHERE row_number = 1 --AND Convert(date,[Time/Date stamp of failure]) = Convert(Date,Getdate())     
Union all    
Select 'CreateNewOrderWithEmail Error' as ErrorType, cast(FirstName as varchar(100)) as FirstName ,cast(LastName as varchar(100)) as LastName,[Candidate ID],Requestor,[Requisition ID],RequestDate, cast([Time/Date stamp of failure] as varchar) as [Time/Date stamp of failure],APNO,[Error message received], [Payload],RequestID,CLNO,FacilityCLNO ,[Candidate Information]  , [Facility]  ,[Error Details]  , null as [Source]     
From #FailedhasErrortrue WHERE row_number = 1  --AND Convert(date,[Time/Date stamp of failure]) = Convert(Date,Getdate())    
Union all    
Select 'Partner Callback Error' as ErrorType, cast(FirstName as varchar(100)) as FirstName ,cast(LastName as varchar(100)) as LastName,[Candidate ID],Requestor,[Requisition ID],RequestDate, cast([Time/Date stamp of failure] as varchar) as [Time/Date stamp of failure],APNO,[Error message received], [Payload],RequestID,CLNO,FacilityCLNO , [Candidate Information] , [Facility],[Error Details] , null as [Source]         
From #PartnerCallbackErrorIDs WHERE row_number = 1  --AND Convert(date,[Time/Date stamp of failure]) = Convert(Date,Getdate())    
) a    
ORDER BY ErrorType,[Time/Date stamp of failure] DESC ,requestid DESC    
  
  
  
   