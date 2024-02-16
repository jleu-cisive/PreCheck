-- ================================================================================================================  
-- Author:  Prasanna  
-- Create date: 10-10-2018  
-- Description: Display the contents of  ClientForm (Requirements) in Oasis for all active clients at time of execution  
-- EXEC [ClientRequirements_Active] 14536  
-- Modified by Mainak Bhadra on 10/12/2022 to add AffiliateId for ticket #67224
-- EXEC [ClientRequirements_Active] 0,'10:4'
-- ======================================================================================================================  
CREATE PROCEDURE [dbo].[ClientRequirements_Active]   
  @CLNO int = 0 , 
  @AffiliateId varchar(MAX) = '10:4'--code added by Mainak for ticket id -67224
AS  
BEGIN  




--code added by Mainak for ticket id -67224 starts
	IF @AffiliateId = '0' 
	BEGIN  
		SET @AffiliateId = NULL  
	END
--code added by Mainak for ticket id -67224 ends
  
 SELECT DISTINCT C.CLNO AS [Client #], C.Name AS [Client Name],C.DescriptiveName AS [Client Description], IIF(C.OKtoContact = 1, 'True','False') AS [Ok to Contact Applicant (True/False)],  
  
 (SELECT TOP 1 CONCAT(IIF(CAST(rr.NumOfRecord AS varchar) = CAST(-1 AS varchar),'All records',CONCAT(CAST(rr.NumOfRecord AS varchar),' records')),' ',   
    IIF(rr.TimeSpan = 0,' ',CONCAT(' in ', rr.TimeSpan , ' years')), IIF(rr.IsMostRecent = 1,'Most Recent','')) FROM dbo.refRequirement rr WHERE rr.RecordType = 'Empl' AND rr.CLNO = C.CLNO) AS Empl,   
  
 (SELECT TOP 1 CONCAT(IIF(CAST(rr.NumOfRecord AS varchar) = CAST(-1 AS varchar),'All Counties', CONCAT(CAST(rr.NumOfRecord AS varchar), ' Counties')),' ',   
    IIF(rr.TimeSpan = 0,' ',CONCAT(' in ', rr.TimeSpan , ' years')), IIF(rr.IsCalled = 1,' Called','')) FROM dbo.refRequirement rr WHERE rr.RecordType = 'Crim' AND rr.CLNO = C.CLNO)AS Criminal,  
  
 (SELECT TOP 1 CONCAT(CONCAT('Level:',rr.LevelNum),' ', IIF(rr.IsHighestCompleted = 1,' Highest Completed','')) FROM dbo.refRequirement rr WHERE rr.RecordType = 'Educat' AND rr.CLNO = C.CLNO) AS Educat,  
  
 (SELECT TOP 1 CONCAT(rr.SpecialNote,' ', IIF(rr.IsHCA = 1,'HCA',''), IIF(rr.LevelNum = 0,' ', CONCAT(' Level:',rr.LevelNum))) FROM dbo.refRequirement rr WHERE rr.RecordType = 'ProfLic' AND rr.CLNO = C.CLNO)AS License,  
  
 IIF(C.Social = 1,'True','False') AS [Positive ID (True/False)], IIF(C.[Medicaid/Medicare] = 1,'True','False') AS [SanctionCheck (True/False)], ra.AdverseType AS Adverse, C.MVR AS MVR, C.PersonalRefNotes AS [Personal Reference], rrt.ProfRef AS [Prof Refer
ence],  
  
 rrt.DOT AS DOT, sr.[Description] AS [Special Registries], sc.Description AS Civil, sf.Description AS Federal, sw.[Description] AS Statewide 
 FROM CLIENT C(NOLOCK)  
	  INNER JOIN dbo.refRequirementText rrt(NOLOCK) ON C.CLNO = rrt.CLNO  
	  LEFT OUTER JOIN dbo.refStatewide sr(NOLOCK) ON rrt.SpecialRegID = sr.StateWideID   
	  LEFT OUTER JOIN dbo.refStatewide sc(NOLOCK) ON rrt.CivilID = sc.StateWideID  
	  LEFT OUTER JOIN dbo.refStatewide sw(NOLOCK) ON rrt.StatewideID = sw.StateWideID  
	  LEFT OUTER JOIN dbo.refStatewide sf(NOLOCK) ON rrt.FederalID = sf.StateWideID  
	  INNER JOIN dbo.refAdverse ra(NOLOCK) ON ra.AdverseID = c.Adverse  
	  INNER JOIN refAffiliate R(NOLOCK) on R.AffiliateID = C.AffiliateID  --code added by Mainak for ticket id -67224
 WHERE c.CLNO = IIF(@CLNO = 0, C.CLNO , @CLNO)  AND c.IsInactive = 0  
 AND (@AffiliateId IS NULL OR R.AffiliateId IN (SELECT value FROM fn_Split(@AffiliateId,':')))--code added by Mainak for ticket id -67224
  
END  
  
  
