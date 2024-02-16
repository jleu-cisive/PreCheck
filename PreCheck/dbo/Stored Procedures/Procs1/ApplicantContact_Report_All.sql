-- =============================================  
-- Author:  Yves Fernandes  
-- Create date: 2019-03-15 08:32:07.080  
-- Description: Created for Dana  
-- MOdified by Radhika Dereddy on 11/12/2019 for valerie to include AffiliateID as the parameter.  
-- Modified by Amy liu on 09/09/2020 for phase3 of project: IntranetModule: Status-SubStatus  
--------------------------------------------------------------------
/* Modified By: YSharma 
-- Modified Date: 07/01/2022
-- Description: Ticketno-#54480 
Modify existing q-reports that have affiliate ids in their search parameters
Details: 
Change search parameters for the Affiliate Id field
     * search by multiple affiliate ids (ex 4:297)
     * want to also be able to search all affiliates by putting zero - meaning 0 to search all affiliates
     * multiple affiliates to be separated by a colon  
Under Parameter Names - after Affiliate ID include this wording (separate by colon, default 0)
*/
---Testing
/*
EXEC ApplicantContact_Report_All '02/01/2021','02/08/2021',0,'125:4'
EXEC ApplicantContact_Report_All '02/01/2021','02/08/2021',0,'0'
EXEC ApplicantContact_Report_All '02/01/2021','02/08/2021',3115,'0'
*/
-- =============================================  
  
CREATE PROCEDURE [dbo].[ApplicantContact_Report_All]  
 @StartDate DATE,  
 @EndDate DATE,   
 @CLNO int,
 @AffiliateID VArchar(Max)   -- Added on the behalf for HDT #54480
-- @AffiliateID int,  		 -- Comnt for HDT #54480
 
AS  
 SET NOCOUNT ON;  
  --DECLARE @StartDate DATE = '06/01/2020',  
  --  @EndDate DATE ='08/31/2020',   
  --  @CLNO int = 0,  
  --  @AffiliateID int = 230  
 
 IF(@AffiliateID = '' OR LOWER(@AffiliateID) = 'null' OR @AffiliateID = '0')   -- Added on the behalf for HDT #54480
 Begin    
  SET @AffiliateID = NULL    
 END
 
 SELECT  
  a.APNO as 'Report Number',  
  CONCAT(a.First, ' ', a.Last) AS 'Applicant Name',  
  applS.Description AS 'Component Type',  
  CASE ac.ApplSectionID  
   WHEN 1 THEN (SELECT e.Employer FROM Empl AS e WHERE e.EmplID = ac.SectionUniqueID)  
   WHEN 2 THEN (SELECT e.School FROM Educat AS e WHERE e.EducatID = ac.SectionUniqueID)  
   WHEN 3 THEN (SELECT p.Name FROM PersRef AS p WHERE p.PersRefID = ac.SectionUniqueID)  
   WHEN 4 THEN (SELECT p.Lic_Type FROM ProfLic AS p WHERE p.ProfLicID = ac.SectionUniqueID)  
  END AS 'Component Description',  
  CASE ac.ApplSectionID  
   WHEN 1 THEN (SELECT ss.Description FROM Empl AS e INNER JOIN dbo.SectStat ss ON e.SectStat=ss.Code WHERE e.EmplID = ac.SectionUniqueID)  
   WHEN 2 THEN (SELECT ss.Description FROM Educat AS e INNER JOIN dbo.SectStat ss ON e.SectStat=ss.Code WHERE e.EducatID = ac.SectionUniqueID)  
   WHEN 3 THEN (SELECT ss.Description FROM PersRef AS p INNER JOIN dbo.SectStat ss ON p.SectStat=ss.Code WHERE p.PersRefID = ac.SectionUniqueID)  
   WHEN 4 THEN (SELECT ss.Description FROM ProfLic AS p INNER JOIN dbo.SectStat ss ON p.SectStat=ss.Code WHERE p.ProfLicID = ac.SectionUniqueID)  
  END AS 'Status',  
    CASE ac.ApplSectionID  
   WHEN 1 THEN (SELECT ISNULL(SSS.SectSubStatus,'') FROM Empl AS e LEFT JOIN dbo.SectSubStatus SSS ON e.SectStat=SSS.SectStatusCode AND E.SectSubStatusID= SSS.SectSubStatusID WHERE e.EmplID = ac.SectionUniqueID)  
   WHEN 2 THEN (SELECT ISNULL(SSS.SectSubStatus,'') FROM Educat AS e LEFT JOIN dbo.SectSubStatus SSS ON e.SectStat=SSS.SectStatusCode AND E.SectSubStatusID= SSS.SectSubStatusID WHERE e.EducatID = ac.SectionUniqueID)  
   WHEN 3 THEN (SELECT ISNULL(SSS.SectSubStatus,'') FROM PersRef AS p LEFT JOIN dbo.SectSubStatus SSS ON P.SectStat=SSS.SectStatusCode AND P.SectSubStatusID= SSS.SectSubStatusID WHERE p.PersRefID = ac.SectionUniqueID)  
   WHEN 4 THEN (SELECT ISNULL(SSS.SectSubStatus,'') FROM ProfLic AS p LEFT JOIN dbo.SectSubStatus SSS ON P.SectStat=SSS.SectStatusCode AND P.SectSubStatusID= SSS.SectSubStatusID WHERE p.ProfLicID = ac.SectionUniqueID)  
  END AS 'SubStatus',  
  a.EnteredVia AS 'Order Method',  
  a.UserID AS CAM,  
  c.CLNO as 'Client Number',  
  c.Name AS 'Client Name',  
  refAf.AffiliateID AS 'AffiliateID',  
  refAf.Affiliate,  
  ISNULL(hevFacil.IsOneHR,0) AS IsOneHR,  
  rmc.ItemName AS 'Method Of Contact',  
  rrc.ItemName AS 'Reason for Contact',  
  ac.Investigator,  
  FORMAT(ac.CreateDate, 'MM/dd/yyyy hh:mm tt') AS 'Date of Contact'  
 FROM ApplicantContact AS ac WITH (NOLOCK)  
  INNER JOIN Appl AS a WITH (NOLOCK) ON a.APNO = ac.APNO  
  INNER JOIN Client AS c WITH (NOLOCK) ON c.CLNO = a.CLNO  
  INNER JOIN refMethodOfContact AS rmc WITH (NOLOCK) ON rmc.refMethodOfContactID = ac.refMethodOfContactID  
  INNER JOIN refReasonForContact AS rrc WITH (NOLOCK) ON rrc.refReasonForContactID = ac.refReasonForContactID  
  INNER JOIN ApplSections AS applS WITH (NOLOCK) ON applS.ApplSectionID = ac.ApplSectionID  
  LEFT JOIN (   
   SELECT DISTINCT   
    FacilityNum,   
    IsOneHR  
   FROM HEVN.dbo.Facility WITH (NOLOCK)) AS hevFacil ON hevFacil.FacilityNum = a.DeptCode AND hevFacil.IsOneHR = 1  
  LEFT JOIN refAffiliate as refAf WITH (NOLOCK) ON refAf.AffiliateID = c.AffiliateID  
 WHERE CONVERT(DATE, ac.CreateDate) >= @StartDate  
  AND CONVERT(DATE, ac.CreateDate) <= @EndDate  
  AND (@AffiliateID IS NULL OR C.AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #54480
   --AND C.AffiliateID = IIF(@AffiliateID=0,C.AffiliateID,@AffiliateID)							-- Comnt for HDT #54480	
  AND c.CLNO = IIF(@CLNO=0,C.CLNO,@CLNO)