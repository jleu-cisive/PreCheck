-- =============================================  
-- Author:  Deepak Vodethela  
-- Create date: 10/25/2018  
-- Description: Need Report that Measures Elapsed Hours and Business Hours from Time that Release is Signed to Time that Certification Occurs (App Date) for non-CIC clients, like HCA who uses online release to capture consent and there is an associated order received via XML from Taleo.   
-- Execution: EXEC Elapsed_Time_From_Consent_to_AppDate 1041,'10/01/2018','10/24/2018',4,1  

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
EXEC Elapsed_Time_From_Consent_to_AppDate 1041,'08/01/2018','06/06/2022','0',1
EXEC Elapsed_Time_From_Consent_to_AppDate 1041,'08/01/2018','06/06/2022','4:8',1
*/
-- =============================================  
CREATE PROCEDURE [dbo].[Elapsed_Time_From_Consent_to_AppDate]   
 -- Add the parameters for the stored procedure here  
 @CLNO int,  
 @StartDate datetime,  
 @EndDate datetime,  
 @AffiliateID Varchar(Max),   -- Added on the behalf for HDT #54480
-- @AffiliateID int,  		 -- Comnt for HDT #54480	  
 @IsOneHR bit  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
 
 IF(@AffiliateID = '' OR LOWER(@AffiliateID) = 'null' OR @AffiliateID = '0')   -- Added on the behalf for HDT #54480
 Begin    
  SET @AffiliateID = NULL    
 END
    -- Insert statements for procedure here  
 CREATE TABLE #tmpData(  
  [Client Number] [int] NOT NULL,  
  [Client Name] [varchar](100) NOT NULL,  
  [Affiliate Name] [varchar](100) NOT NULL,  
  [Report Number] [int] NOT NULL,  
  [Applicant First] [varchar](20) NOT NULL,  
  [Applicant Last] [varchar](20) NOT NULL,  
  [App Date (Certification)] [DATETIME] NULL,  
  [Date Release Submitted/Signed] [DATETIME] NULL,  
  [ApDate] [DATETIME] NULL,  
  [SSN] [varchar](15) NULL,  
  [IsOneHR] [varchar](5) NOT NULL,  
  EnteredVia varchar(10),  
  [CreatedDate] [DATETIME] NULL,  
  )  
  
 CREATE TABLE #tmpDates(  
  [ReleaseFormID] [int] NOT NULL,  
  [SSN] [varchar](15) NULL,  
  [ReleaseDate] [datetime] NULL,  
  [CLNO] [int] NOT NULL)  
  
 CREATE CLUSTERED INDEX IX_tmpData_01 ON #tmpData([Report Number])  
 CREATE CLUSTERED INDEX IX_tmpDates_01 ON #tmpDates(ReleaseFormID)  
  
 -- Execute the following statements when a NO Client# is provided, but dates are provided  
 IF (@CLNO = 0 AND @StartDate IS NOT NULL AND @EndDate IS NOT NULL)  
 BEGIN  
  ;WITH tmpReleaseDates AS  
  (  
  SELECT rf.ReleaseFormID, rf.SSN, rf.[DATE], rf.CLNO,  
      ROW_NUMBER() OVER (PARTITION BY rf.SSN ORDER BY rf.ReleaseFormID DESC) AS RowNumber  
  FROM ReleaseForm rf (NOLOCK)  
  WHERE rf.[date] BETWEEN @StartDate AND DATEADD(d,1,@EndDate)   
  )  
  INSERT INTO #tmpDates  
  SELECT T.ReleaseFormID, T.SSN, T.[DATE], T.CLNO FROM tmpReleaseDates AS T   
  WHERE T.RowNumber = 1  
  
  --SELECT * FROM #tmpDates  
    
  INSERT INTO #tmpData  
  SELECT  DISTINCT a.CLNO AS[Client Number], c.Name AS [Client Name], ra.Affiliate [Affiliate Name], a.APNO AS [Report Number], a.First AS [Applicant First], a.Last AS [Applicant Last],   
    cc.ClientCertUpdated AS [App Date (Certification)],  
    R.ReleaseDate AS [Date Release Submitted/Signed],  
    a.ApDate, A.SSN,  
       CASE WHEN F.IsOneHR = 0 THEN 'No' ELSE 'Yes' END IsOneHR,  
    A.EnteredVia, A.CreatedDate  
  FROM dbo.Appl AS a(NOLOCK)  
  INNER JOIN #tmpDates AS R ON REPLACE(A.SSN,'-','') = REPLACE(R.SSN,'-','')  AND A.CLNO = R.CLNO  
  INNER JOIN ClientCertification AS cc(NOLOCK) ON A.APNO = cc.APNO  
  INNER JOIN Client AS c(NOLOCK) ON A.CLNO = c.CLNO  
  INNER JOIN refAffiliate AS ra(NOLOCK) ON C.AffiliateID = ra.AffiliateID  
  LEFT OUTER JOIN [HEVN].[dbo].Facility AS F(NOLOCK) ON C.CLNO = F.FacilityCLNO  
  WHERE A.CLNO NOT IN (3468,2135)  
    AND r.ReleaseDate BETWEEN @StartDate AND DATEADD(d,1,@EndDate)  
    AND cc.ClientCertUpdated BETWEEN @StartDate AND DATEADD(d,1,@EndDate)  
    AND (@AffiliateID IS NULL OR C.AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #54480
   --AND C.AffiliateID = IIF(@AffiliateID=0,C.AffiliateID,@AffiliateID)							-- Comnt for HDT #54480	   
    AND F.IsOneHR = ISNULL(@IsOneHR, 0)  
  
  --SELECT * FROM #tmpData  
  
  SELECT  DISTINCT Q.[Client Number], Q.[Client Name],Q.[Affiliate Name], Q.[Report Number], Q.[Applicant First], Q.[Applicant Last], Q.[App Date (Certification)], Q.[Date Release Submitted/Signed],   
    --DateDiff(hour,Q.[Date Release Submitted/Signed],Q.[App Date (Certification)]) AS [Elapsed Straight Hours],  
    --[dbo].[ElapsedBusinessHours_2](Q.[Date Release Submitted/Signed],Q.[App Date (Certification)]) AS [Straight Hours based on HROC’s operating hours],  
    DateDiff(hh,Q.[Date Release Submitted/Signed],Q.[App Date (Certification)]) AS [Straight Hours based on HROC’s 24/7/365 operating hours],  
    [dbo].[GetWorkingHours](Q.[Date Release Submitted/Signed],Q.[App Date (Certification)] ) AS [Elapsed Business Hours],  
    Q.IsOneHR,EnteredVia  
    --,DATEDIFF(HOUR, Q.[Date Release Submitted/Signed], Q.ApDate) AS [TimeToPending]  
  FROM #tmpData AS Q  
 END  
   
 -- Execute the following statements when a Specific Client# is provided  
 IF (@CLNO != 0 AND @StartDate IS NOT NULL AND @EndDate IS NOT NULL)  
 BEGIN  
  ;WITH tmpReleaseDates AS  
  (  
  SELECT rf.ReleaseFormID, rf.SSN, rf.[DATE], rf.CLNO,  
      ROW_NUMBER() OVER (PARTITION BY rf.SSN ORDER BY rf.ReleaseFormID DESC) AS RowNumber  
  FROM ReleaseForm rf (NOLOCK)  
  WHERE rf.[date] BETWEEN @StartDate AND DATEADD(d,1,@EndDate)   
  )  
  INSERT INTO #tmpDates  
  SELECT T.ReleaseFormID, T.SSN, T.[DATE], T.CLNO FROM tmpReleaseDates AS T   
  WHERE T.RowNumber = 1  
  
  --SELECT * FROM #tmpDates  
    
  INSERT INTO #tmpData  
  SELECT  DISTINCT a.CLNO AS[Client Number], c.Name AS [Client Name], ra.Affiliate [Affiliate Name], a.APNO AS [Report Number], a.First AS [Applicant First], a.Last AS [Applicant Last],   
    cc.ClientCertUpdated AS [App Date (Certification)],  
    R.ReleaseDate AS [Date Release Submitted/Signed],  
    a.ApDate, A.SSN,  
       CASE WHEN F.IsOneHR = 0 THEN 'No' ELSE 'Yes' END IsOneHR,  
    A.EnteredVia, A.CreatedDate  
  FROM dbo.Appl AS a(NOLOCK)  
  INNER JOIN #tmpDates AS R ON REPLACE(A.SSN,'-','') = REPLACE(R.SSN,'-','')  AND A.CLNO = R.CLNO  
  INNER JOIN ClientCertification AS cc(NOLOCK) ON A.APNO = cc.APNO  
  INNER JOIN Client AS c(NOLOCK) ON A.CLNO = c.CLNO  
  INNER JOIN refAffiliate AS ra(NOLOCK) ON C.AffiliateID = ra.AffiliateID  
  LEFT OUTER JOIN [HEVN].[dbo].Facility AS F(NOLOCK) ON C.CLNO = F.FacilityCLNO  
  WHERE A.CLNO NOT IN (3468,2135)  
    AND R.CLNO = IIF(@CLNO=0,R.CLNO,@CLNO)  
    AND r.ReleaseDate BETWEEN @StartDate AND DATEADD(d,1,@EndDate)  
    AND cc.ClientCertUpdated BETWEEN @StartDate AND DATEADD(d,1,@EndDate)  
    AND (@AffiliateID IS NULL OR C.AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #54480
   --AND C.AffiliateID = IIF(@AffiliateID=0,C.AffiliateID,@AffiliateID)							-- Comnt for HDT #54480	   
    AND F.IsOneHR = ISNULL(@IsOneHR, 0)  
  
  --SELECT * FROM #tmpData  
  
  SELECT  DISTINCT Q.[Client Number], Q.[Client Name],Q.[Affiliate Name], Q.[Report Number], Q.[Applicant First], Q.[Applicant Last], Q.[App Date (Certification)], Q.[Date Release Submitted/Signed],   
    --DateDiff(hour,Q.[Date Release Submitted/Signed],Q.[App Date (Certification)]) AS [Elapsed Straight Hours],  
    --[dbo].[ElapsedBusinessHours_2](Q.[Date Release Submitted/Signed],Q.[App Date (Certification)]) AS [Straight Hours based on HROC’s operating hours],  
    DateDiff(hh,Q.[Date Release Submitted/Signed],Q.[App Date (Certification)]) AS [Straight Hours based on HROC’s 24/7/365 operating hours],  
    [dbo].[GetWorkingHours](Q.[Date Release Submitted/Signed],Q.[App Date (Certification)] ) AS [Elapsed Business Hours],  
    Q.IsOneHR,EnteredVia  
    --,DATEDIFF(HOUR, Q.[Date Release Submitted/Signed], Q.ApDate) AS [TimeToPending]  
  FROM #tmpData AS Q  
 END  
  
 DROP TABLE #tmpData  
 DROP TABLE #tmpDates  
END  