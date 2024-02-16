-- ================================================================================================================  
-- Modified by Mainak Bhadra on 10/14/2022 to add AffiliateId for ticket #67224
-- EXEC [CICEntryValidation] 0,0,'01/01/2021','01/31/2021'
-- ======================================================================================================================  

CREATE PROCEDURE [dbo].[CICEntryValidation] @CLNO INT, @APNO INT, @FromDate DATETIME, @ToDate DATETIME,
		@AffiliateId varchar(MAX) = '10:4'--code added by Mainak for ticket id -67224  
AS  



--code added by Mainak for ticket id -67224 starts
	IF @AffiliateId = '0' 
	BEGIN  
		SET @AffiliateId = NULL  
	END
--code added by Mainak for ticket id -67224 ends  

SELECT CLNO, APNO, First, Last, StepName, DisplayName, CreatedDate   
INTO #tmp  
FROM(  
--RETURNS ALL RECORDS WHERE AN OPTION WAS SELECTED AND 'NO DATA' IS TO BE DISPLAYED  
 SELECT APP.CLNO, APP.APNO, APP.First, APP.Last, CLW.StepName, 'No Data' AS DisplayName, APP.CreatedDate   
 FROM  [PreCheck].[dbo].[Appl] APP   
  INNER JOIN [Enterprise].[dbo].[Applicant] A ON A.ApplicantNumber = APP.APNO  
  INNER JOIN [Enterprise].[dbo].[Order] O ON O.OrderId = A.OrderId  
  INNER JOIN [Enterprise].[dbo].[vwClientWorkflow] CLW ON CLW.ClientId = O.ClientId and CLW.Workflowid = O.DaSourceId and CLW.IsActive = 1  
  INNER JOIN [Enterprise].[dbo].[ApplicantMiscItem] AMI ON A.ApplicantId=AMI.ApplicantId  
  INNER JOIN [Enterprise].[Lookup].[MiscDataKey] MDK ON AMI.MiscDataKeyId = MDK.MiscDataKeyId  
  INNER JOIN [Enterprise].[Config].[WorkflowStepValidation] WSV ON WSV.WorkflowStepId = CLW.WorkflowStepId AND WSV.IsActive = 1  
  INNER JOIN [Enterprise].[dbo].[DynamicAttribute] DA ON AMI.MiscDataKeyValue =  DA.DynamicAttributeId and DA.DynamicAttributeTypeId = WSV.DATDisplayMessageListId 
  INNER JOIN dbo.Client C(NOLOCK) on C.CLNO = APP.CLNO    --code added by Mainak for ticket id -67224
  INNER JOIN refAffiliate RA(NOLOCK) on RA.AffiliateID = C.AffiliateID  --code added by Mainak for ticket id -67224
 WHERE  CLW.StepName in ('Employment','License','Education','Reference') 
 AND (@AffiliateId IS NULL OR RA.AffiliateId IN (SELECT value FROM fn_Split(@AffiliateId,':')))--code added by Mainak for ticket id -67224
 UNION ALL  
--GETS ALL RECORDS WHERE N/A WILL BE DISPLAYED FOR A GIVEN SECTION THAT IS DEACTIVATED  
  SELECT APP.CLNO, APP.APNO, APP.First, APP.Last, CLW.StepName, 'N/A' AS DisplayName, APP.CreatedDate    
 FROM  [PreCheck].[dbo].[Appl] APP   
  INNER JOIN [Enterprise].[dbo].[Applicant] A ON A.ApplicantNumber = APP.APNO  
  INNER JOIN [Enterprise].[dbo].[Order] O ON O.OrderId = A.OrderId  
  INNER JOIN [Enterprise].[dbo].[vwClientWorkflow] CLW ON CLW.ClientId = O.ClientId and CLW.Workflowid = O.DaSourceId and CLW.IsActive = 0   
  INNER JOIN dbo.Client C(NOLOCK) on C.CLNO = APP.CLNO    --code added by Mainak for ticket id -67224
  INNER JOIN refAffiliate RA(NOLOCK) on RA.AffiliateID = C.AffiliateID  --code added by Mainak for ticket id -67224
 WHERE  CLW.StepName in ('Employment','License','Education','Reference')  
 AND (@AffiliateId IS NULL OR RA.AffiliateId IN (SELECT value FROM fn_Split(@AffiliateId,':')))--code added by Mainak for ticket id -67224
 UNION ALL  
--GETS ALL RECORDS WHERE N/A WILL BE DISPLAYED FOR A GIVEN SECTION AND POPUP IS DEACTIVATED  
 SELECT APP.CLNO, APP.APNO, APP.First, APP.Last, CLW.StepName, 'N/A' AS DisplayName, APP.CreatedDate    
 FROM  [PreCheck].[dbo].[Appl] APP   
  INNER JOIN [Enterprise].[dbo].[Applicant] A ON A.ApplicantNumber = APP.APNO  
  INNER JOIN [Enterprise].[dbo].[Order] O ON O.OrderId = A.OrderId  
  INNER JOIN [Enterprise].[dbo].[vwClientWorkflow] CLW ON CLW.ClientId = O.ClientId and CLW.Workflowid = O.DaSourceId and CLW.IsActive = 1  
  INNER JOIN [Enterprise].[Config].[WorkflowStepValidation] WSV ON WSV.WorkflowStepId = CLW.WorkflowStepId AND WSV.IsActive = 0 
  INNER JOIN dbo.Client C(NOLOCK) on C.CLNO = APP.CLNO    --code added by Mainak for ticket id -67224
  INNER JOIN refAffiliate RA(NOLOCK) on RA.AffiliateID = C.AffiliateID  --code added by Mainak for ticket id -67224
 WHERE  CLW.StepName in ('Employment','License','Education','Reference')  
 AND (@AffiliateId IS NULL OR RA.AffiliateId IN (SELECT value FROM fn_Split(@AffiliateId,':')))--code added by Mainak for ticket id -67224
 ) AS Y  
  
--SELECT * FROM #tmp  
  
IF @clno != '' AND @apno !=''  
  
SELECT CLNO, APNO, First, Last, [Employment], [Education], [License], [Reference], CreatedDate  
FROM (  
 SELECT CLNO, APNO, First, Last, StepName, DisplayName, CreatedDate  
 FROM #tmp  
) T  
PIVOT (MAX(DisplayName) FOR StepName IN (Employment, Education, License, Reference)) AS pvt  
WHERE  ((Convert(date, CreatedDate)>= CONVERT(date, @FromDate))   
AND (Convert(date, CreatedDate) <= CONVERT(date, @ToDate)))  
AND APNO = @apno  
AND CLNO = @clno  
ORDER BY Last ASC, CLNO ASC, CreatedDate DESC  
  
ELSE IF @clno = '' AND @apno != ''  
  
SELECT CLNO, APNO, First, Last, [Employment], [Education], [License], [Reference], CreatedDate  
FROM (  
 SELECT CLNO, APNO, First, Last, StepName, DisplayName, CreatedDate  
 FROM #tmp  
) T  
PIVOT (MAX(DisplayName) FOR StepName IN (Employment, Education, License, Reference)) AS pvt  
WHERE ((Convert(date, CreatedDate)>= CONVERT(date, @FromDate))   
AND (Convert(date, CreatedDate) <= CONVERT(date, @ToDate)))  
AND APNO = @apno  
ORDER BY Last ASC, CLNO ASC, CreatedDate DESC  
  
ELSE IF @clno ! = '' AND @apno = ''  
  
SELECT CLNO, APNO, First, Last, [Employment], [Education], [License], [Reference], CreatedDate  
FROM (  
 SELECT CLNO, APNO, First, Last, StepName, DisplayName, CreatedDate  
 FROM #tmp  
) T  
PIVOT (MAX(DisplayName) FOR StepName IN (Employment, Education, License, Reference)) AS pvt  
WHERE ((Convert(date, CreatedDate)>= CONVERT(date, @FromDate))   
AND (Convert(date, CreatedDate) <= CONVERT(date, @ToDate)))  
AND CLNO = @clno  
ORDER BY Last ASC, CLNO ASC, CreatedDate DESC  
  
ELSE   
  
SELECT CLNO, APNO, First, Last, [Employment], [Education], [License], [Reference], CreatedDate  
FROM (  
 SELECT CLNO, APNO, First, Last, StepName, DisplayName, CreatedDate  
 FROM #tmp  
) T  
PIVOT (MAX(DisplayName) FOR StepName IN (Employment, Education, License, Reference)) AS pvt  
WHERE ((Convert(date, CreatedDate)>= CONVERT(date, @FromDate))   
AND (Convert(date, CreatedDate) <= CONVERT(date, @ToDate)))  
ORDER BY Last ASC, CLNO ASC, CreatedDate DESC  
  
DROP TABLE #tmp  
  