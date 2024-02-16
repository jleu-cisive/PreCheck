  
---*****************************************************************************************  
---Created by Amy Liu on 03/13/2018 HDT: 29954  
---Description: a version of Employment Verifications Received Q-Report that will display all employment verifications received for CHI, HCA, Tenet, and UHS accounts only  
-- [dbo].[EmploymentVerificationsReceived_CHIHCATenetUHS] '07/23/2021', '07/23/2021'  
---**************************************************************************************** 
-- =============================================   
--ModifiedBy  ModifiedDate TicketNo		Description  
--YSharma	 01/03/2023    HDT #84621   HDT #84621 include both affiliate 4 (HCA) & 294 (HCA Velocity).   
--           EXEC [dbo].[EmploymentVerificationsReceived_CHIHCATenetUHS] '07/23/2021', '07/23/2021'
--============================================ 
CREATE PROCEDURE [dbo].[EmploymentVerificationsReceived_CHIHCATenetUHS]   
@FromDate DateTime,  
@ToDate DateTime  
  
AS  
  
-- get CHI, HCA, Tenet, and UHS accounts only   
---('Catholic Health Initiatives','HCA Corporate','Tenet', 'UHS - Universal Health Services')  
IF OBJECT_ID('tempdb..#VerificationTempTable ') IS NOT NULL  
 Drop Table #VerificationTempTable   
IF OBJECT_ID('tempdb..#ClientsToRun') IS NOT NULL  
    DROP TABLE #ClientsToRun  
  
SELECT * INTO #ClientsToRun  
FROM  
(  
  SELECT c.clno, c.Name, c.WebOrderParentCLNO, 'parent' AS relation,  c.clno AS GroupID  
  FROM client c with(nolock)  
  WHERE c.clno IN (12721,7519,12444,13126)  
   AND c.affiliateid IN (4, 294)					-- Added On request HDT #84621
  UNION    
  SELECT c2.clno, c2.Name, c2.WebOrderParentCLNO, 'child' AS relation, c2.WebOrderParentCLNO AS GroupID  
  FROM client c with(nolock)   
  INNER JOIN client c2 with(nolock) ON c2.WebOrderParentCLNO = c.CLNO  
  WHERE c.clno IN (12721,7519,12444,13126) 
   AND c.affiliateid IN (4, 294)					-- Added On request HDT #84621
)x  
  
--SELECT * FROM #ClientsToRun c ORDER BY GroupID, c.clno  
  
SELECT lg.Apno, ctr.groupID  INTO #VerificationTempTable  
FROM precheckservicelog lg WITH (NOLOCK)  
INNER JOIN dbo.Appl a ON lg.apno = a.apno   
INNER JOIN #ClientsToRun ctr ON ctr.clno  =a.CLNO   
WHERE lg.request.value(  
'declare namespace a="http://schemas.datacontract.org/2004/07/PreCheckBPMServiceHelper";   
declare namespace i="http://www.w3.org/2001/XMLSchema-instance";   
declare namespace m="http://schemas.datacontract.org/2004/07/PreCheck.Services.WCF.DataContracts";   
(/m:UpsertRequest/m:Application/a:NewApplicants/a:NewApplicant/a:Employments/a:Employment/a:SectStat)[1]', 'char') like '%9%' --like '%9%' --order by 1 desc  
AND lg.ServiceDate >= @FromDate AND lg.ServiceDate < DateAdd(day, 1, @ToDate)  
  
--SELECT * FROM  #VerificationTempTable  
  
SELECT count(distinct e.EmplID) TotalApplication, vtt.groupID, c.Name  
From Empl e  
INNER JOIN #VerificationTempTable vtt ON vtt.Apno= e.apno  
INNER JOIN #ClientsToRun c ON c.GroupID = vtt.groupID AND relation='parent'  
WHERE e.IsOnReport =1  
GROUP BY vtt.groupID, c.Name  
ORDER BY vtt.groupID  
  
IF OBJECT_ID('tempdb..#VerificationTempTable ') IS NOT NULL  
 Drop Table #VerificationTempTable   
IF OBJECT_ID('tempdb..#ClientsToRun') IS NOT NULL  
    DROP TABLE #ClientsToRun  
  