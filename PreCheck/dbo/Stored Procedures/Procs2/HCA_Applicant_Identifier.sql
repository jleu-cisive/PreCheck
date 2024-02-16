-- =====================================================================================  
-- Author:  Prasanna  
-- Create date: 06/05/2020  
-- Description: HCA Applicant Indentifier with the filter of app first close(HDT#73473)  
-- EXEC HCA_Applicant_Identifier 0,4,'05/01/2020','06/05/2020'  
-- ======================================================================================  
-- =============================================   
--ModifiedBy  ModifiedDate TicketNo		Description  
--YSharma	 01/03/2023    HDT #84621   HDT #84621 include both affiliate 4 (HCA) & 294 (HCA Velocity).   
--           EXEC HCA_Applicant_Identifier 0,4,'05/01/2020','06/05/2020'
--============================================   
CREATE PROCEDURE [dbo].[HCA_Applicant_Identifier]  
        @CLNO int = 0,  
  @affiliateID int = 0,  
  @StartDate datetime = NULL,  
  @EndDate datetime = NULL  
AS  
BEGIN  
   
  SELECT O.OrderNumber AS [Report Number],concat(A.FirstName,' ',A.LastName) as [Applicant Name],   
  Enterprise.dbo.ParseSocial(A.SocialNumber) AS SSN, ISNULL(IAR.PartnerReferenceNumber, '') AS [HCA Requisition Number],  
  A.ClientCandidateId as [Taleo Candidate ID]  
  INTO #tmpHCAApplicantIdentifier  
  FROM  Enterprise.PreCheck.[vwIntegrationApplicantReport] IAR   
  LEFT OUTER JOIN Enterprise.dbo.[Order] AS O ON IAR.RequestID = O.IntegrationRequestId AND O.OrderNumber = IAR.APNO   
  LEFT OUTER JOIN Enterprise.dbo.Applicant AS A ON O.OrderId = A.OrderId  
  inner join PRECHECK.dbo.Appl appl on appl.apno = o.OrderNumber  
  LEFT OUTER JOIN PRECHECK.dbo.Client c on appl.clno=c.clno   
  where O.ClientId = IIF(@CLNO = 0,O.ClientID, @CLNO) and c.AffiliateID = IIF(@affiliateID = 0,c.AffiliateId, @affiliateID) --COALESCE(@CLNO,O.ClientID)  
  and (ISNULL(appl.OrigCompDate,'1/1/1900') >= @StartDate AND IsNULL(appl.OrigCompDate,'1/1/1900') <= @EndDate) 
  AND C.affiliateid IN (4, 294)					-- Added On request HDT #84621
  
  select [Report Number],[Applicant Name],SSN,[HCA Requisition Number],[Taleo Candidate ID] from #tmpHCAApplicantIdentifier   
  group by [Report Number], [Applicant Name],ssn,[HCA Requisition Number],[Taleo Candidate ID]  
  
  
  drop table #tmpHCAApplicantIdentifier  
  
END  