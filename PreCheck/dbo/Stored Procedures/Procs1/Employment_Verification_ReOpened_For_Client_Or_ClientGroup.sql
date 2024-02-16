-- =============================================  
-- Author:  Radhika Dereddy  
-- Create date: 03/14/2019  
-- Requester: Dana Sangerhausen  
-- Description: Qreport that identifies Employment verifications that are reopened by a CAM after they have been placed in a closing status  
-- IsOneHR - if 1, and Affiliate is 4, pulls only those verifications for reports associated with OneHR  
-- EXEC [Employment_Verification_ReOpened_For_Client_Or_ClientGroup] 0,'12/11/2020','12/12/2020',0  
-- Modified By: Deepak Vodethela  
-- Modified On: 03/22/2019  
-- Description: I have rewritten/ modified the conditions to show the correct values  
-- Added Reopen TAT for the Report on 12/10/2020 by Radhika Dereddy and Addedd iSOneHR as a Column instead of the parameter and fixed the left join on the Facility tbale and refaffiliate  

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
EXEC [Employment_Verification_ReOpened_For_Client_Or_ClientGroup] 1041,'08/01/2018','06/06/2022','0'
EXEC [Employment_Verification_ReOpened_For_Client_Or_ClientGroup] 1041,'08/01/2018','06/06/2022','4:177'
*/
-- =============================================  
  
CREATE PROCEDURE [dbo].[Employment_Verification_ReOpened_For_Client_Or_ClientGroup]  
@Clno VARCHAR(MAX) = 0,  
@StartDate DateTime,    
@EndDate DateTime,    
@AffiliateID Varchar(Max)   -- Added on the behalf for HDT #54480
-- @AffiliateID int  		 -- Comnt for HDT #54480 
--,@IsOneHR int  
AS  
BEGIN  
  
    SET ANSI_WARNINGS OFF   
 SET NOCOUNT ON;  
 SET TRANSACTION ISOLATION LEVEL  READ UNCOMMITTED  
 
 IF(@AffiliateID = '' OR LOWER(@AffiliateID) = 'null' OR @AffiliateID = '0')   -- Added on the behalf for HDT #54480
 Begin    
  SET @AffiliateID = NULL    
 END

 Set @EndDate = dateadd(s,-1,dateadd(d,1,@EndDate))   
  
  
 -- Get Re-Open reports  
 SELECT * INTO #tmpReOpen  
 FROM  
 (  
  SELECT  cl.ID, cl.ChangeDate AS [ReOpen Date], cl.UserID, cl.OldValue, cl.NewValue, cl.ChangeDate,  
    ROW_NUMBER() over (partition by cl.ID order by cl.changeDate ASC) AS RowNumber     
  FROM dbo.ChangeLog cl (NOLOCK)  
  WHERE cl.OldValue IN ('5','6','7')    
    AND cl.NewValue IN ('9')  
    AND cl.TableName = 'Empl.SectStat'  
    AND cl.ChangeDate between @StartDate and @EndDate   
 ) y   
 WHERE y.RowNUmber=1  
  
 -- Get Closed reports  
 SELECT * INTO #tmpClose  
 FROM  
 (  
  SELECT  cl.ID, cl.ChangeDate AS [Original Verification Close Date], cl.UserID, cl.OldValue, cl.NewValue, cl.ChangeDate,  
    ROW_NUMBER() over (partition by cl.ID order by cl.changeDate ASC) AS RowNUmber     
  FROM #tmpReOpen AS R  
  INNER JOIN dbo.changelog AS cl(NOLOCK)  ON R.ID = cl.ID AND cl.tableName ='Empl.SectStat'  
  WHERE cl.NewValue IN ('5','6','7')    
    AND cl.OldValue IN ('9')  
 ) y   
 WHERE y.RowNUmber=1  
  
 SELECT * FROM #tmpReOpen R ORDER BY R.ID DESC  
 SELECT * FROM #tmpClose C ORDER BY C.ID DESC  
  
 --SELECT *   
 --FROM #tmpReOpen R  
 --LEFT OUTER JOIN #tmpClose C ON R.ID = C.ID  
 --ORDER BY C.ID DESC  
  
 SELECT DISTINCT E.Apno, A.CLNO AS [CLNO], Cl.[Name] AS [Client Name], rf.Affiliate AS Affiliate, E.Employer AS [Employer Name],--  A.ApDate AS ReportCreatedDate,  
   C.[Original Verification Close Date],  
   C.UserID AS [Closed User],  
   R.[ReOpen Date],R.UserID AS [ReOpened User], A.ReopenDate,  
   [dbo].[ElapsedBusinessDays_2](A.ReopenDate, A.CompDate) [ReOpenTAT], -- Added by Radhika on 12/10/2020  
   (CASE WHEN ISNULL(F.IsOneHR,0) = 0 THEN 'False' ELSE 'True' END) AS IsOneHR  
 FROM #tmpReOpen R  
 LEFT OUTER JOIN #tmpClose C ON R.ID = C.ID  
 INNER JOIN dbo.Empl AS E WITH(NOLOCK) ON R.ID = E.EmplID  
 INNER JOIN dbo.Appl AS A WITH(NOLOCK) ON E.APNO = A.APNO        
 INNER JOIN dbo.Client AS Cl WITH(NOLOCK) ON A.CLNO = Cl.CLNO  
 INNER JOIN dbo.SectStat AS S WITH(NOLOCK) ON E.SectStat = S.Code  
 INNER JOIN refAffiliate AS rf WITH(NOLOCK) ON Cl.AffiliateID = rf.AffiliateID  
 LEFT OUTER JOIN [HEVN].[dbo].[Facility] f WITH(NOLOCK) ON ISNULL(a.DeptCode,0) = f.FacilityNum and ISNULL(A.CLNO,0)=F.FacilityCLNO    
 WHERE E.IsHidden = 0  
   AND E.IsOnReport = 1   
  AND (@AffiliateID IS NULL OR rf.AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #54480
   --AND rf.AffiliateID = IIF(@AffiliateID=0, rf.AffiliateID, @AffiliateID)						-- Comnt for HDT #54480	 
    
   --AND Cl.CLNO = IIF(@CLNO=0, Cl.CLNO, @CLNO)  
   --AND A.apdate Between @StartDate and DateAdd(d,1,@EndDate)   
  -- AND F.IsOneHR = IIF(@IsOneHR=0, ISNULL(F.IsOneHR,0), @IsOneHR)  
  
 DROP TABLE #tmpClose  
 DROP TABLE #tmpReOpen  
  
 END