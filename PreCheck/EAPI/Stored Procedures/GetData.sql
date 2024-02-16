  
  
-- Author:  Nikhil Vairat    
-- Create date: 08/22/2023    
-- Description: Store procedure to get all expanded api data points  based on apno  
-- Update / 2023-10-16 / GKoralturk / performance improvements  
  
/*
 Author: Amisha Mer     
 Updated Date: 2023/11/28    
 Description: Changes for HCA: Re-Opened/Re-Closed Status 
*/
-- modified by Lalit on 2 dec 2024 for #116939

---- exec EAPI.GetData 7589660  6802033--6802052--6801997--6800509--                
---- exec EAPI.GetData 6802033 --6802052--6801997--6800509--                
---- exec EAPI.GetData 7639435--6801997--6800509--                
       
CREATE PROC [EAPI].[GetData]                  
(                  
   @APNO int = NULL                    
)  
               
AS      
BEGIN    
  
--declare  @APNO int = 7639435  
    
 Declare @CANDIDATEINFOID nvarchar(max)            
 select  @CANDIDATEINFOID = ci.OCHS_CandidateInfoID FROM Precheck..OCHS_CandidateInfo ci INNER JOIN Enterprise.dbo.[Order] o ON ci.APNO=o.OrderNumber WHERE o.OrderNumber =@apno            
            
 Declare @cicURL nvarchar(max)                  
 drop table if exists #PreAdverseDate            
            
 drop table if exists #AdverseDate            
 Drop table if exists #tempSummaryByAPNO                   
 set FMTONLY OFF ;               
            
 CREATE TABLE #tempSummaryByAPNO                           
 (                            
  [ReportNumber] int ,                            
  [ReportCreated Date] DateTime,                            
  [ReportStatus] varchar(10),                            
  [ApplicantLastName] varchar(100),                            
  [ApplicantFirstName] varchar(100),                            
  [ApplicantMiddleName] varchar(50),                            
  [SSN] varchar(11),                            
  [ReportReopened Date] Datetime,                            
  [ReportCompletion Date] DateTime,                            
  [ProcessLevel] varchar(50),                            
  [Requisition] varchar(50),                            
  [StartDate] varchar(12),                            
  [AccountName] varchar(250),                            
  [ElapsedDays] int,                             
  [ReportTAT] int,                    
  [AdmittedCrim] varchar(10),                            
  [CriminalSearchesOrdered] int,                            
  [CriminalSearchesPending] int,                            
  [MVROrdered] int,                            
  [MVRPending] int,                            
  [EmploymentVerificationsOrdered] int,                            
  [EmploymentVerificationsPending] int,                            
  [EducationVerificationsOrdered] int,                             
  [EducationVerificationsPending] int,                            
  [LicenseVerificationsOrdered] int,                            
  [LicenseVerificationsPending] int,                            
  [PersonalReferencesOrdered] int,                            
  [PersonalReferencesPending] int,                            
  [SanctionCheckOrdered] int,                            
  [SanctionCheckPending] int,
  [CreditCheckOrdered] int,                            
  [CreditCheckPending] int,                               
  [PercentageCompleted] int,                  
  [ContingentDecisionStatus] varchar(50),                  
  [PendingClosure<24hrs] varchar(50),                  
  [ReportConclusionETA] varchar(50),            
  ResultsURL varchar(MAX)                  
  -- DSEPassportURL varchar(MAX)                  
 )                         
                  
 INSERT INTO #tempSummaryByAPNO                        
  exec [EAPI].[ResultSummaryByAPNO] @apno                   
 -- instead of using with (nolock) in each table this is easier  
 Set Transaction isolation level read uncommitted   
  
 select                 
   case when a.statusid = 8 then a.Date else null end as OrderDate                
  ,case when a.statusid = 7 then a.Date else null end as DisputeDate                
  ,case when a.statusid = 14 then a.Date else null end as FinalDate         
  ,PAS.APNO as APNO                
  ,ROW_NUMBER() OVER(PARTITION BY a.StatusID  ORDER BY a.Date DESC) AS row_number                 
 into   
  #AdverseDate   
 from  
  Precheck..AdverseActionHistory a                 
  inner join Precheck..AdverseAction PAS on PAS.APNO = @APNO  
 where   
  PAS.[AdverseActionID] = a.AdverseActionID   
  and a.StatusID in (8,7,14)                 
                
                
                
 select                 
  max(OrderDate) as OrderDate            
  ,max(DisputeDate) as DisputeDate                
  ,max(FinalDate) as FinalDate                
  ,APNO                 
 into   
  #PreAdverseDate   
 from   
  #AdverseDate                 
 where   
  row_number = 1   
  and apno = @APNO  
 group by   
  APNO              
  -----------------------------------------
DROP TABLE IF EXISTS #tempApplicantStage
DROP TABLE IF EXISTS #tempApplicantfinal
create table #tempApplicantfinal(SecurityTokenId uniqueidentifier,ClientCandidateId varchar(100))

SELECT [SecurityTokenId], [ClientCandidateId]
INTO #tempApplicantStage
FROM Enterprise.Staging.ApplicantStage
WHERE ApplicantNumber = @APNO

if(( SELECT COUNT(1)
FROM #tempApplicantStage) > 0)
BEGIN
INSERT INTO #tempApplicantfinal (SecurityTokenId, ClientCandidateId)
	   SELECT [SecurityTokenId], [ClientCandidateId]
	   FROM #tempApplicantStage
END
ELSE
BEGIN
INSERT INTO #tempApplicantfinal (SecurityTokenId, ClientCandidateId)
	   SELECT [SecurityTokenId], [ClientCandidateId]
	   FROM Enterprise..Applicant
	   WHERE ApplicantNumber = @APNO
END
--SELECT * from #tempApplicantfinal

DROP TABLE IF EXISTS #tempApplicantStage
------------------------------------------

 select TOP 1  
  IOR.Partner_Reference AS ID                
  ,IsNull(ESA.ClientCandidateId,'') as CandidateId                
  ,EAO.FacilityId as FacilityCLNO                
  ,IOR.CLNO as CLNO                
  ,IsNull(A.SSN,'') as SSN                  
  ,IsNull(format(A.DOB,'MM/dd/yyyy'),'') as DOB                  
  ,IsNull(format(getdate(),'MM/dd/yyyy HH:mm:ss tt'),'') as CallbackDate             
  ,Cast(EAO.HasBackground as bit) AS HasBackgroundCheck                  
  ,cast(EAO.HasDrugScreen AS bit) as HasDrugScreen                 
  ,@Apno as APNO                    
  ,IsNull(format(IOR.RequestDate,'MM/dd/yyyy HH:mm:ss tt'),'') AS OrderInitiatedDateTime                  
  ,case when ESA.SecurityTokenId is not null then 'https://HRServices.precheck.com/CIC/Authenticate?token=' + cast(ESA.SecurityTokenId as varchar(1000)) else 'https://HRServices.precheck.com/CIC?requestid=' + cast(EAO.IntegrationRequestId as varchar(1000)
) end as  CICUrl                  
  ,IsNull(format(t.[ExpireDate],'MM/dd/yyyy HH:mm:ss tt'),'') as CICURLExpireDateTime                  
  ,IsNull(format(A.CreatedDate,'MM/dd/yyyy HH:mm:ss tt'),'') as ConsentDate                  
  ,case when IsNull(CC.ClientCertReceived,'') = 'Yes' then format(CC.ClientCertUpdated,'MM/dd/yyyy HH:mm:ss tt') else '' end  as HRCertificationDateTime                  
  ,case when                 
     IsNull(IOR.RefUserActionId,0) in (1,2,3)                
   then                 
   --case                 
   -- when A.ApStatus = 'P' then 'InProgress'                 
   -- when A.ApStatus = 'F' then 'Completed'                 
   -- when A.ApStatus = 'M' then 'OnHold'                  
   --end 
	tp.[ReportStatus]
     else                 
   IORU.UserAction                
    end                
    as [Status]                  
  ,IsNull(format(a.ApDate ,'MM/dd/yyyy HH:mm:ss tt'),'') as StatusDateTime                  
  ,IsNull(FS.CustomFlagStatus,'') as AdditionalDetail                  
  ,IsNull(format(eta.ETADATE,'MM/dd/yyyy HH:mm:ss tt'),'') AS EstimatedCompleteDate                 
  ,IsNull(format(PA.OrderDate,'MM/dd/yyyy HH:mm:ss tt'),'') as PreAdverseOrderedDate                 
  ,IsNull(format(PA.DisputeDate,'MM/dd/yyyy HH:mm:ss tt'),'') as PreAdverseDisputeExpireDate                
  ,IsNull(format(PA.FinalDate,'MM/dd/yyyy HH:mm:ss tt'),'') as PreAdverseFinalAdverseDate                      
  ,IsNull(format(A.Last_Updated,'MM/dd/yyyy HH:mm:ss tt'),'') AS RequestCompletionDate                      
  ,cbr.ActualDrugTestStatus as DrugScreenStatus        
  ,IsNull(format(CBR.DrugScreenLastUpdate,'MM/dd/yyyy HH:mm:ss tt'),'') as DrugScreenLastUpdate                    
  ,case when M.PrecheckTestResult is null   then CBR.[DrugScreenResult] else M.PrecheckTestResult end  as DrugScreenResult              
  ,case when isnull(CBR.DrugTestBaseStatus,'') in ('In MRO Review') then format(DrugScreenLastUpdate,'MM/dd/yyyy') else '' end as MROReceivedDate                
  ,case when isnull(CBR.DrugTestBaseStatus,'') in  ('Received at Lab') then format(DrugScreenLastUpdate,'MM/dd/yyyy') else '' end as ReceivedAtLabDate                
  ,case when isnull(CBR.DrugTestBaseStatus,'') in ('Sent to Lab') then format(DrugScreenLastUpdate,'MM/dd/yyyy') else '' end as SentToLabDate                
  ,IsNull(format(SCH_DR.DateReceived,'MM/dd/yyyy'),'') as DrugScreenScheduledDate     
  ,IsNull(format(COM_DR.LastUpdate,'MM/dd/yyyy'),'') as DrugScreenCompletedDate       
  ,IsNull(DR.PDFReport,'') as DrugScreenReport   
  ,IsNull(BG.BackgroundReport,'') as  BackgroundReport              
  ,IsNull(tp.[CriminalSearchesOrdered],0) as CriminalSearchesOrdered                      
  ,IsNull(tp.[CriminalSearchesPending],0) as CriminalSearchesPending                       
  ,IsNull(tp.[MVROrdered],0) as MVRSearchesOrdered                              
  ,IsNull(tp.[MVRPending],0) as MVRSearchesPending                          
  ,IsNull(tp.[EmploymentVerificationsOrdered],0) as EmploymentSearchesOrdered                          
  ,IsNull(tp.[EmploymentVerificationsPending],0) as EmploymentSearchesPending                           
  ,IsNull(tp.[EducationVerificationsOrdered],0) as EducationSearchesOrdered                         
  ,IsNull(tp.[EducationVerificationsPending],0) as EducationSearchesPending                           
  ,IsNull(tp.[LicenseVerificationsOrdered],0) as LicenseSearchesOrdered                        
  ,IsNull(tp.[LicenseVerificationsPending],0) as LicenseSearchesPending                        
  ,IsNull(tp.[PersonalReferencesOrdered],0) as PersonalReferencesSearchesOrdered                       
  ,IsNull(tp.[PersonalReferencesPending],0) as PersonalReferencesSearchesPending                      
  ,IsNull(tp.[SanctionCheckOrdered],0) as SanctionCheckSearchesOrdered                           
  ,IsNull(tp.[SanctionCheckPending],0) as SanctionCheckSearchesPending 
  ,IsNull(tp.[CreditCheckOrdered],0) as CreditSearchesOrdered                           
,IsNull(tp.[CreditCheckPending],0) as CreditSearchesPending                           
  ,IsNull(tp.[PercentageCompleted],0) as  PercentageCompleted              
  ,'https://weborder.precheck.net/eDrugScreening/eDrug.aspx?ID='+@CANDIDATEINFOID+'&amp;application=StudentCheck' as DSEPassportURL                       
 from   
  Integration_Ordermgmt_Request IOR                   
  Inner Join Appl A ON A.APNO = IOR.APNO                  
  cross apply  
  (  
   Select  
    [SecurityTokenId],  
    [ClientCandidateId]  
   From  
    #tempApplicantfinal  
  ) ESA              
  Inner Join Integration_Ordermgmt_RefUserAction IORU ON IORU.refUserActionID = IOR.refUserActionID                  
  Inner Join Enterprise.dbo.vwApplicantOrder EAO ON EAO.IntegrationRequestId = IOR.RequestID                   
  left Join [Enterprise].[vwCallbackReportDetail] CBR ON CBR.ORDERNUMBER = IOR.APNO    
  Inner Join #tempSummaryByAPNO tp ON tp.[ReportNumber] = IOR.APNO                   
  left Join #PreAdverseDate PA ON PA.APNO = IOR.APNO                
  left join [SecureBridge].dbo.Token t on t.TokenId = ESA.SecurityTokenId         
  LEFT OUTER JOIN [Enterprise].[vwServiceStatusMap] M  ON M.VendorTestResult=CBR.DrugScreenResult AND M.VendorOrderStatus=CBR.DrugTestBaseStatus             
  outer apply   
  (  
   Select  
    [DateReceived]  
   From  
    (  
     Select  
      Convert(Varchar(30),[OCHS_CandidateInfoID]) [OCHS_CandidateInfoID]  
     From  
      [dbo].[OCHS_CandidateInfo]   
     Where   
      [APNO]=@APNO  
    ) OCI  
    inner join [dbo].[OCHS_ResultDetails] on [OrderIDOrApno]=OCI.[OCHS_CandidateInfoID]  
   Where  
    [OrderStatus] in ('SCHEDULED: New Event')  
  ) SCH_DR  
  outer apply   
  (  
   Select  
    [LastUpdate]  
   From  
    (  
     Select  
      Convert(Varchar(30),[OCHS_CandidateInfoID]) [OCHS_CandidateInfoID]  
     From  
      [dbo].[OCHS_CandidateInfo]   
     Where   
      [APNO]=@APNO  
    ) OCI  
    inner join [dbo].[OCHS_ResultDetails] on [OrderIDOrApno]=OCI.[OCHS_CandidateInfoID]   
   Where  
    [OrderStatus] in ('Completed')  
  ) COM_DR  
  outer apply    
  (                
   Select   
    rep.[PDFReport]  
   From  
    [dbo].[OCHS_ResultDetails] CTE   
    inner join  
    (  
     Select  
      R.[OrderIDOrApno],  
      Max(R.LastUpdate) [LastUpdate]  
     From   
      [dbo].[OCHS_ResultDetails] R   
     Where   
      IsNumeric(R.OrderIDOrApno)=1  
     Group by R.[OrderIDOrApno]  
    ) L On CTE.OrderIDOrApno=L.OrderIDOrApno AND CTE.LastUpdate=L.LastUpdate  
    Left Outer Join [dbo].[OCHS_CandidateInfo] ci   
     On   
      ci.[ApNo] = @ApNo   
      and CTE.[OrderIDOrApno]=Convert(Varchar(25),CI.[OCHS_CandidateInfoID])  
     --added join condition to avoid incorrect join. experienced OrderIdOrApno field unexpectedly having clno. This could be changed back if a root cause fix could be applied.   
     AND cte.[LastName]=ci.[LastName]  
    --added join to map new zipcrim statuses  
    Left Outer Join [dbo].[tblZipCrimStatusMapping] zm ON CTE.[OrderStatus]= zm.[Status] and zm.[IsActive]=1  
    inner join [dbo].[OCHS_PDFReports] rep on CTE.[TID]=rep.[TID]    
   where   
    ci.[APNO] = @ApNo  
  ) DR      
  left join   
  (                
   select                 
    Max(vwb.OrderId) as Apno,                
    Max(s) as BackgroundReport                
   from                
    dbo.[vwBackgroundReport] vwb                  
    cross apply (select vwb.ReportImage as '*' for xml path('')) T(s)                 
   where   
    vwb.OrderId = @apno                 
   group by   
    vwb.OrderId                  
   ) BG ON BG.Apno = IOR.Apno         
   
  left join   
  (                
   select                 
    AFL.APNO,AFLC.CustomFlagStatus                
   from                 
    [dbo].[ApplFlagStatus] AFL   
    inner join Integration_Ordermgmt_Request IOR on AFL.APno = IOR.APNO                 
    inner join [dbo].[refApplFlagStatusCustom] AFLC on AFL.FlagStatus = AFLC.FlagStatusID                 
   where                 
    AFL.APNO = @apno   
    and AFLC.CLNO = IOR.clno                
  ) FS ON FS.APNO = ior.APNO                
  left join   
  (                
   select                
    Max(APNO) as APNO,                
    Max(ETADate) as ETADate                
   from                
    ApplSectionsETA ASE                
   where                
    Apno = @apno                
   group by  
    apno                
  ) eta on eta.Apno = IOR.APNO                
  LEFT JOIN ClientCertification CC ON  CC.APNO = IOR.APNO                  
 where   
  EAO.OrderNumber = @APNO                   
 order by 1 desc                  
     DROP TABLE IF EXISTS #tempApplicantfinal
              
END 