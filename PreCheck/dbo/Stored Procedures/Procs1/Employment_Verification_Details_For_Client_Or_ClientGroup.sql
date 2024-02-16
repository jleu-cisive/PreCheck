/*---------------------------------------------------------------------------------  
Procedure Name : [dbo].[Employment_Verification_Details_For_Client_Or_ClientGroup]  
Requested By: Dana Sangerhausen  
Developer: Deepak Vodethela  
Execution : EXEC [dbo].[Employment_Verification_Details_For_Client_Or_ClientGroup] '10660 : 10675 : 10674: 1524','08/01/2014','09/11/2014',4  
   EXEC [dbo].[Employment_Verification_Details_For_Client_Or_ClientGroup] NULL,'05/01/2019','05/30/2019',0  
Modified BY : Radhika Dereddy on 08/08/2017  
Modified Description: Added Employment CreatedDate, Employment LastUpdateDate, TAT, investigator  
Modified BY : Radhika Dereddy on 09/06/2017  
Modified Description: Added  R.Affiliate, R.AffiliateID  
Modified BY : Deepak Vodethela on 12/07/2017  
Modified Description: Added all section stauses except “Needs Review & Pending”.   
Modified By Radhika Dereddy on 06/27/2019 -- Added Employment TAT in Hours and Report Tat in hours and fixed the Affiliate and CLNO parameters  
/* Modified By: Vairavan A  
-- Modified Date: 06/30/2022  
-- Description: Main Ticketno-53763   
Modify existing q-reports that have affiliate ids in their search parameters  
Details:   
Change search parameters for the Affiliate Id field  
     * search by multiple affiliate ids (ex 4:297)  
     * want to also be able to search all affiliates by putting zero - meaning 0 to search all affiliates  
     * multiple affiliates to be separated by a colon    
Under Parameter Names - after Affiliate ID include this wording (separate by colon, default 0)  
  
Subticket id -54476 Update AffiliateID Parameter 130-429  
Modified BY : Dikshs Salunke on 11/14/2022 
Modified Description: Added  L. VerifiedBy , C. Billcycle For HDT-69618
*/  
---Testing  
/*  
EXEC Employment_Verification_Details_For_Client_Or_ClientGroup 0, '01/01/2018','01/30/2018','0'  
EXEC Employment_Verification_Details_For_Client_Or_ClientGroup 0, '06/01/2019','06/30/2019','125'  
EXEC Employment_Verification_Details_For_Client_Or_ClientGroup 0, '06/01/2019','06/30/2019','177:10'  
*/  
  
*/---------------------------------------------------------------------------------  
  
CREATE PROCEDURE [dbo].[Employment_Verification_Details_For_Client_Or_ClientGroup]  
@Clno VARCHAR(MAX) = 9030,  
@StartDate DateTime='04/24/2017',  
@EndDate DateTime='06/26/2022',  
--@AffiliateID int--code commented by vairavan for ticket id -54476  
@AffiliateIDs varchar(MAX) = '0'--code added by vairavan for ticket id -54476  
 
 As
BEGIN  
  
  
IF(@Clno = '' OR LOWER(@Clno) = 'null' OR @Clno = '0'  )   
Begin    
 SET @Clno = NULL    
END  
  
 --code added by vairavan for ticket id -54476 starts  
 IF @AffiliateIDs = '0'   
 BEGIN    
  SET @AffiliateIDs = NULL    
 END  
 --code added by vairavan for ticket id -54476 ends  
  
SELECT A.APNO, A.ApDate, A.CLNO, C.Name AS ClientName, A.First, A.Last, E.Employer, E.From_A , E.To_A, L. VerifiedBy,E.Investigator,  
  E.CreatedDate as [Employment CreatedDate],  
  E.Last_Updated as [Employment LastUpdatedDate],   
  E.web_updated as [Employment Received Date],  
  [dbo].[elapsedbusinessdays_2](E.CreatedDate, E.Last_Updated) AS [Employment TAT in Days],   
  [dbo].[ElapsedBusinessHours_2](E.CreatedDate, E.Last_Updated) AS [Employment TAT in Hours],  
  [dbo].[elapsedbusinessdays_2](A.Apdate, A.origCompDate) AS [Report TAT in Days],  
  [dbo].[ElapsedBusinessHours_2](A.Apdate, A.origCompDate) AS [Report TAT in Hours],  
  REPLACE(REPLACE(E.Pub_Notes, CHAR(10),';'),CHAR(13),';') AS Pub_Notes,   
  REPLACE(REPLACE(E.Priv_Notes, CHAR(10),';'),CHAR(13),';') AS Priv_Notes,  
  S.[Description] as [SectStat_Description],   
  REPLACE(REPLACE(R.Affiliate, CHAR(10),';'),CHAR(13),';') AS Affiliate,   
  R.AffiliateID,  
  C. Billcycle as [Biiling_Group],
  Case when E.IsOKtoContact = 0 Then 'False' else 'True' end as [Applicant Contact],  
  Case when rmc.ItemName ='Both' Then 'Phone/Email' else rmc.ItemName end as  [Applicant Method of Contact] ,  
  rrc.ItemName as [Applicant Contact Reason]  
FROM dbo.Empl AS E WITH(NOLOCK)  
INNER JOIN dbo.Appl AS A WITH(NOLOCK) ON E.Apno = A.APNO  
INNER JOIN dbo.Client AS C WITH(NOLOCK) ON C.CLNO = A.CLNO  
INNER JOIN dbo.SectStat AS S WITH(NOLOCK) ON S.Code = E.SectStat  
INNER JOIN refAffiliate R WITH(NOLOCK) ON R.AffiliateID = C.AffiliateID  
left join hevn.dbo.license as L WITH(NOLOCK) on C.clno= l.EmployeeRecordID
LEFT JOIN ApplicantContact Ac WITH(NOLOCK) on E.APNO = AC.APNO  and Ac.ApplSectionID = 1  
LEFT JOIN refMethodOfContact  rmc WITH(NOLOCK) on Ac.refMethodOfContactID = rmc.refMethodOfContactID  
LEFT JOIN refReasonForContact rrc WITH(NOLOCK) on AC.refReasonForContactID =rrc.refReasonForContactID  
WHERE (@CLNO IS NULL  OR C.CLNO IN (SELECT VALUE FROM fn_Split(@CLNO,':')))   --A.CLNO = IIF(@CLNO=0, A.CLNO, @CLNO)  
   AND E.IsHidden = 0  
   AND E.IsOnReport = 1  
   AND E.SectStat NOT IN ('0','9')  
  -- AND E.CreatedDate >= @StartDate   
   --AND E.Last_updated <=  DateAdd(d,1,@EndDate)  
   AND A.apdate between @StartDate and DateAdd(d,1,@EndDate)  
      --AND R.AffiliateID = IIF(@AffiliateID = 0, R.AffiliateID, @AffiliateID)--code commeted by vairavan for ticket id -54476  
   and (@AffiliateIDs IS NULL OR R.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -54476  
ORDER BY A.APNO  
  
END  
  --select top 1 * from client
  