-- =============================================    
-- Author:  Ysharma     
-- Create date: 6/28/2022    
-- Description: New report required  as per HDT reqest 48985  
-- Execution:  EXEC [dbo].[DrugTest_OrderStatus] '1/1/2021','4/30/2022','','14756'    
-- Ref : dbo.[DrugTestDetails_DateRange_Doug]    
-- Ref Reports : All Drugtest Results Received and DrugTestDetails-DateRange    
-- =============================================    
/*
ModifiedBy		ModifiedDate	TicketNo	Description
Shashank Bhoi	10/13/2022		67226		#67226 Update Affiliate ID Parameter Parent HDT#56320
											Modify existing q-reports that have affiliate ids in their search parameters  
											Details:   
											Change search parameters for the Affiliate Id field  
											     * search by multiple affiliate ids (ex 4:297)  
											     * want to also be able to search all affiliates by putting zero - meaning 0 to search all affiliates  
											     * multiple affiliates to be separated by a colon    
											Under Parameter Names - after Affiliate ID include this wording (separate by colon, default 0) 
											EXEC [dbo].[DrugTest_OrderStatus] '10/01/2022','10/13/2022','','7519','4:294'    

*/
  
CREATE PROCEDURE [dbo].[DrugTest_OrderStatus]    
   
 @StartDate Date,    
 @EndDate Date,    
 @CLNO varchar(max),    
 @ParentCLNO varchar(max),   
 @AffiliateIDs varchar(MAX) = '0'	--Code added by Shashank for ticket id -67226
     
    
AS    
BEGIN    

	--Code added by Shashank for ticket id -67226 starts
	SET NOCOUNT ON;
	IF(@AffiliateIDs = '' OR LOWER(@AffiliateIDs) = 'null' OR @AffiliateIDs = '0')   
		SET @AffiliateIDs = NULL;  
	--Code added by Shashank for ticket id -67226 ends
    
 Set @EndDate = DateAdd(dd,1,@EndDate)    
 if(@clno is null or Ltrim(rtrim(@clno))='')    
 begin    
   set @clno=0    
 END    
    
 if(@ParentCLNO is null or Ltrim(rtrim(@ParentCLNO))='')    
 begin    
   set @ParentCLNO=0    
 end    
    
 SELECT  Convert (Varchar,C.OCHS_CandidateInfoID  )AS OCHS_CandidateInfoID,  
   config.CLNO as [Client ID],     
   CLT.[Name] as [Client Name],   
   RA.Affiliate,    
   Case when Isnull(C.APNO,0)=0 then  [OCHS_CandidateInfoID] else C.APNO end OCHS_TransactionID    
   ,C.[LastName]    
   ,C.[FirstName]    
   ,C.[Middle]    
   ,C.Email    
   ,Description [TestReason]    
   ,[CostCenter]    
   ,[ClientIdent]    
   ,FORMAT(C.[CreatedDate],'MM/dd/yyyy hh:mm tt') as CreatedDate,   
   Location,    
   ProdCat,    
   ProdClass,    
   SpecType,    
   IsNull(Customer,'201754') Customer,    
   ISNULL(a.Attn,ISNULL(c.ClientIdent,CSref.OCHS_CandidateInfoScheduleByName)) as [Requested By]   
 ------------------------------- New columns added   
 ,ord.OrderIDOrApno as [OrderNumber],    
  isnull(cast(CLT.WebOrderParentCLNO AS varchar(20)),' ') [ParentCLNO],    
  ISNULL(ord.TID,'')AS [Transaction ID],    
  ISNULL(ord.CoC,'') AS [Chain of Custody],    
  ISNULL(ord.OrderStatus,'') AS [Order Status],    
  ISNULL(ord.TestResult,'') AS [Test Result],    
  ISNULL(format(ord.LastUpdate,'MM/dd/yyyy'),'') AS [Last Update Date]
 FROM [PreCheck].[dbo].[OCHS_CandidateInfo] C (NOLOCK)    
 left join clientconfiguration_Drugscreening config(NOLOCK) on c.[ClientConfiguration_DrugScreeningID] = config.[ClientConfiguration_DrugScreeningID]     
 left join refTestReason r(NOLOCK) On C.TestReason = r.TestReasonID    
 LEFT JOIN dbo.OCHS_CandidateSchedule CS(NOLOCK) ON C.OCHS_CandidateInfoID = CS.OCHS_CandidateID    
 LEFT JOIN dbo.refOCHS_CandidateInfoSchedule CSref(NOLOCK) ON CS.ScheduledByID = CSref.refOCHS_CandidateInfoScheduleByID    
 INNER JOIN dbo.Client CLT(NOLOCK) on CLT.CLNO = config.CLNO    
 INNER JOIN [dbo].[refAffiliate] AS RA WITH(NOLOCK) ON CLT.AffiliateID = RA.AffiliateID    
 LEFT JOIN dbo.Appl a on a.APNO = c.APNO    
 LEFT JOIN OCHS_ResultDetails ord ON Convert(Varchar,A.APNO)=ord.OrderIDOrApno        
 Where C.CreatedDate >= @StartDate     
   and C.CreatedDate < @EndDate     
   and (config.CLNO in (Select value from dbo.fn_Split(@CLNO,':')) or @CLNO ='0')    
   AND (clt.WebOrderParentCLNO IN (Select value from dbo.fn_Split(@ParentCLNO,':')) or @ParentCLNO ='0')    
 --AND (@AffiliateName IS NULL OR RA.Affiliate = @AffiliateName)  
 AND (@AffiliateIDs IS NULL OR CLT.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':'))) --Code added by Shashank for ticket id -67226 
 order by CreatedDate    
END    
  
--Select Top 10 TID,D.ProviderID From OCHS_ResultDetails d   
--LEFT JOIN APPL a ON d.OrderIDOrApNo=A.apNo  
--LEFT JOin OCHS_CandidateInfo O ON O.OCHS_CandidateInfoID=d.ProviderID  
--WHERE D.ProviderID IS NOT NULL OR LTRIM(RTRIM(D.ProviderID)) <>''  
