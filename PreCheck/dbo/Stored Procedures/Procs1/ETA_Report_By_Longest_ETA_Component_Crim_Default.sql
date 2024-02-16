-- =============================================  
-- Author:  Deepak Vodethela   
-- Create date: 02/08/2019  
-- Description: Create an ETA report for HCA to measure the Precheck SLA time for sections in an APNO and which of them take the longest and when will the verification be concluded.  
-- Execution: EXEC [dbo].[ETA_Report_By_Longest_ETA_Component_Crim_Default] 0,224,'04/01/2019','05/01/2019'  
  
-- EXEC [dbo].[ETA_Report_By_Longest_ETA_Component_Crim_Default] 12771,147,'05/01/2019','05/03/2019'  
/*  
SELECT * FROM Enterprise.precheck.vwClient WHERE Enterprise.PreCheck.vwClient.ParentId =7519 or Enterprise.PreCheck.vwClient.ClientId =7519  
SELECT * FROM Client WHERE clno=7519 OR dbo.Client.WebOrderParentCLNO =7519 and IsInactive = 0  
*/  


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
EXEC ETA_Report_By_Longest_ETA_Component_Crim_Default 1041,'0','08/01/2018','06/06/2022'
EXEC ETA_Report_By_Longest_ETA_Component_Crim_Default 1041,'4:8','08/01/2018','06/06/2022'
*/
-- =============================================  
CREATE PROCEDURE [dbo].[ETA_Report_By_Longest_ETA_Component_Crim_Default]  
 -- Add the parameters for the stored procedure here  
 @CLNO int,  
 @AffiliateID Varchar(Max),   -- Added on the behalf for HDT #54480
-- @AffiliateID int,  		 -- Comnt for HDT #54480  
 @StartDate Date,  
 @EndDate Date  
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
   DECLARE @count INT --,  @CLNO INT = 7519  
  
   SELECT @count = count(CLNO) FROM Client WHERE (CLNO = IIF(@CLNO=0, CLNO, @CLNO) OR WebOrderParentCLNO = IIF(@CLNO=0, CLNO, @CLNO)) 
   and IsInactive = 0 
   AND (@AffiliateID IS NULL OR AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #54480
   --AND AffiliateID = IIF(@AffiliateID=0,AffiliateID,@AffiliateID)							-- Comnt for HDT #54480	 
     
  
--DECLARE temp tables (helps to maintain the same plan regardless of stats change)  
 CREATE TABLE #tmpMainSet(  
  [ApplSectionID] [int] NOT NULL,  
  [SectionName] VARCHAR(25) NOT NULL,  
  [Apno] [int] NOT NULL,  
  [SectionKeyID] [int] NOT NULL,  
  [ETADate] [DATETIME] NULL,  
  [ClientCertUpdated] [DATETIME] NULL,  
  [Client Notes] VARCHAR(MAX) NOT NULL,  
  [SectStat] VARCHAR(25) NOT NULL  
  )  
  
 CREATE TABLE #tmpAll(  
  [ApplSectionID] [int] NOT NULL,  
  [SectionName] VARCHAR(25) NOT NULL,  
  [Apno] [int] NOT NULL,  
  [SectionKeyID] [int] NOT NULL,  
  [ETADate] [DATETIME] NULL,  
  [ClientCertUpdated] [DATETIME] NULL,  
  [Client Notes] VARCHAR(MAX) NOT NULL,  
  [SectStat] VARCHAR(25) NOT NULL,  
  [RowNumber] [int] NOT NULL  
  )  
  
 CREATE TABLE #tmpAllMaxETA(  
  [ApplSectionID] [int] NOT NULL,  
  [SectionName] VARCHAR(25) NOT NULL,  
  [Apno] [int] NOT NULL,  
  [SectionKeyID] [int] NOT NULL,  
  [ETADate] [DATETIME] NULL,  
  [ClientCertUpdated] [DATETIME] NULL,  
  [Client Notes] VARCHAR(MAX) NOT NULL,  
  [SectStat] VARCHAR(25) NOT NULL,  
  [RowNumber] [int] NOT NULL  
  )  
  
 --Index on temp tables  
 CREATE CLUSTERED INDEX IX_tmpMainSet_01 ON #tmpMainSet(APNO, SectionKeyID)  
 CREATE CLUSTERED INDEX IX_tmpAll_02 ON #tmpAll(APNO, SectionKeyID)  
 CREATE CLUSTERED INDEX IX_tmpAllMaxETA_02 ON #tmpAllMaxETA(APNO, SectionKeyID)  
  
 ;WITH Criminal AS  
 (  
  SELECT ETA.ApplSectionID, ETA.Apno, ETA.SectionKeyID, ETA.ETADate, C.ClientCertUpdated  
    ,CASE  WHEN ETA.ApplSectionID = 5 THEN ISNULL(CR.Pub_Notes,'') END AS [Client Notes],     
    CASE  WHEN CR.[Clear] NOT IN ('T','F','P') THEN ISNULL(CR.[Clear],'')  
    END AS [ConclusiveStatus]  
  FROM ApplSectionsETA AS ETA(NOLOCK)  
  INNER JOIN APPL AS A(NOLOCK) ON ETA.APNO = A.Apno   
  LEFT OUTER JOIN ClientCertification C(NOLOCK) ON ETA.APNO = C.APNO  
  LEFT OUTER JOIN dbo.Crim AS CR(NOLOCK) ON ETA.SectionKeyID = CR.CrimID AND ETA.ApplSectionID = 5  
  WHERE CR.[Clear] NOT IN ('T','F','P')   
    AND CR.IsHidden = 0  
    AND A.APSTATUS != 'F'  
    AND C.ClientCertUpdated >= @StartDate   
    AND C.ClientCertUpdated < DateAdd(d,1,@EndDate)   
    AND A.Clno IN (SELECT CLNO FROM Client (NOLOCK) WHERE (CLNO = IIF(@CLNO=0, CLNO, @CLNO) OR WebOrderParentCLNO = IIF(@CLNO=0, CLNO, @CLNO)) 
	AND (@AffiliateID IS NULL OR AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #54480
   --AND AffiliateID = IIF(@AffiliateID=0,AffiliateID,@AffiliateID)							-- Comnt for HDT #54480	 
	--AND AffiliateID = IIF(@AffiliateID=0,AffiliateID,@AffiliateID)
	)   
 )  
 INSERT INTO #tmpMainSet  
 SELECT X.ApplSectionID,   
   CASE WHEN X.ApplSectionID = 7 THEN 'SanctionCheck' ELSE Y.Section END AS Section,   
   Apno, SectionKeyID, ETADate, ClientCertUpdated, ISNULL([Client Notes],'') AS [Client Notes], ISNULL([ConclusiveStatus],'') AS [ConclusiveStatus]  
 FROM Criminal AS X  
 INNER JOIN dbo.ApplSections Y ON X.ApplSectionID = Y.ApplSectionID  
  
 ;WITH Employment AS  
 (  
  SELECT  ETA.ApplSectionID, ETA.Apno, ETA.SectionKeyID, ETA.ETADate, C.ClientCertUpdated  
    ,CASE WHEN ETA.ApplSectionID = 1 THEN ISNULL(E.Pub_Notes,'') END AS [Client Notes],  
    CASE WHEN E.SectStat = '9' THEN ISNULL(E.SectStat,'') END AS [ConclusiveStatus]  
  FROM ApplSectionsETA AS ETA(NOLOCK)  
  INNER JOIN APPL AS A(NOLOCK) ON ETA.APNO = A.Apno   
  LEFT OUTER JOIN ClientCertification C(NOLOCK) ON ETA.APNO = C.APNO  
  LEFT OUTER JOIN dbo.EMPL AS E(NOLOCK) ON ETA.SectionKeyID = E.EmplID AND ETA.ApplSectionID = 1  
  WHERE E.SectStat IN ('9')  
    AND A.APSTATUS != 'F'  
    AND C.ClientCertUpdated >= @StartDate  
    AND C.ClientCertUpdated < DateAdd(d,1,@EndDate)   
    AND A.Clno IN (SELECT CLNO FROM Client (NOLOCK) WHERE (CLNO = IIF(@CLNO=0, CLNO, @CLNO) OR WebOrderParentCLNO = IIF(@CLNO=0, CLNO, @CLNO)) 
	AND (@AffiliateID IS NULL OR AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #54480
   --AND AffiliateID = IIF(@AffiliateID=0,AffiliateID,@AffiliateID)							-- Comnt for HDT #54480	 
   )   
 )  
 INSERT INTO #tmpMainSet  
 SELECT X.ApplSectionID,   
   CASE WHEN X.ApplSectionID = 7 THEN 'SanctionCheck' ELSE Y.Section END AS Section,   
   Apno, SectionKeyID, ETADate, ClientCertUpdated, ISNULL([Client Notes],'') AS [Client Notes], ISNULL([ConclusiveStatus],'') AS [ConclusiveStatus]  
 FROM Employment AS X  
 INNER JOIN dbo.ApplSections Y ON X.ApplSectionID = Y.ApplSectionID  
  
 ;WITH Education AS  
 (  
  SELECT ETA.ApplSectionID, ETA.Apno, ETA.SectionKeyID, ETA.ETADate, C.ClientCertUpdated,  
    CASE WHEN ETA.ApplSectionID = 2 THEN ISNULL(ED.Pub_Notes,'') END AS [Client Notes],  
    CASE WHEN ED.SectStat = '9' THEN ISNULL(ED.SectStat,'') END AS [ConclusiveStatus]  
  FROM ApplSectionsETA AS ETA(NOLOCK)  
  INNER JOIN APPL AS A(NOLOCK) ON ETA.APNO = A.Apno   
  LEFT OUTER JOIN ClientCertification C(NOLOCK) ON ETA.APNO = C.APNO  
  LEFT OUTER JOIN dbo.Educat AS ED(NOLOCK) ON ETA.SectionKeyID = ED.EducatID AND ETA.ApplSectionID = 2  
  WHERE ED.SectStat IN ('9')  
    AND A.APSTATUS != 'F'  
    AND C.ClientCertUpdated >= @StartDate   
    AND C.ClientCertUpdated < DateAdd(d,1,@EndDate)   
   AND A.Clno IN (SELECT CLNO FROM Client (NOLOCK) WHERE (CLNO = IIF(@CLNO=0, CLNO, @CLNO) OR WebOrderParentCLNO = IIF(@CLNO=0, CLNO, @CLNO))
   AND (@AffiliateID IS NULL OR AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #54480
   --AND AffiliateID = IIF(@AffiliateID=0,AffiliateID,@AffiliateID)							-- Comnt for HDT #54480	 
   )   
 )  
 INSERT INTO #tmpMainSet  
 SELECT X.ApplSectionID,   
   CASE WHEN X.ApplSectionID = 7 THEN 'SanctionCheck' ELSE Y.Section END AS Section,   
   Apno, SectionKeyID, ETADate, ClientCertUpdated, ISNULL([Client Notes],'') AS [Client Notes], ISNULL([ConclusiveStatus],'') AS [ConclusiveStatus]  
 FROM Education AS X  
 INNER JOIN dbo.ApplSections Y ON X.ApplSectionID = Y.ApplSectionID  
  
 ;WITH ProfessionalLicense AS  
 (  
  SELECT ETA.ApplSectionID, ETA.Apno, ETA.SectionKeyID, ETA.ETADate, C.ClientCertUpdated  
    ,CASE WHEN ETA.ApplSectionID = 4 THEN ISNULL(P.Pub_Notes,'') END AS [Client Notes],  
    CASE WHEN P.SectStat = '9' THEN ISNULL(P.SectStat,'') END AS [ConclusiveStatus]  
  FROM ApplSectionsETA AS ETA(NOLOCK)  
  INNER JOIN APPL AS A(NOLOCK) ON ETA.APNO = A.Apno   
  LEFT OUTER JOIN ClientCertification C(NOLOCK) ON ETA.APNO = C.APNO  
  LEFT OUTER JOIN dbo.ProfLic AS P(NOLOCK) ON ETA.SectionKeyID = P.ProfLicID AND ETA.ApplSectionID = 4  
  WHERE P.SectStat IN ('9')  
    AND A.APSTATUS != 'F'  
    AND C.ClientCertUpdated >= @StartDate   
    AND C.ClientCertUpdated < DateAdd(d,1,@EndDate)   
    AND A.Clno IN (SELECT CLNO FROM Client (NOLOCK) WHERE (CLNO = IIF(@CLNO=0, CLNO, @CLNO) OR WebOrderParentCLNO = IIF(@CLNO=0, CLNO, @CLNO))
	AND (@AffiliateID IS NULL OR AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #54480
   --AND AffiliateID = IIF(@AffiliateID=0,AffiliateID,@AffiliateID)							-- Comnt for HDT #54480	 
	)  
 )  
 INSERT INTO #tmpMainSet  
 SELECT X.ApplSectionID,   
   CASE WHEN X.ApplSectionID = 7 THEN 'SanctionCheck' ELSE Y.Section END AS Section,   
   Apno, SectionKeyID, ETADate, ClientCertUpdated, ISNULL([Client Notes],'') AS [Client Notes], ISNULL([ConclusiveStatus],'') AS [ConclusiveStatus]  
 FROM ProfessionalLicense AS X  
 INNER JOIN dbo.ApplSections Y ON X.ApplSectionID = Y.ApplSectionID  
  
 ;WITH SanctionCheck AS  
 (  
  SELECT ETA.ApplSectionID, ETA.Apno, ETA.SectionKeyID, ETA.ETADate, C.ClientCertUpdated  
    ,NULL AS [Client Notes],   
    CASE WHEN M.SectStat = '9' THEN ISNULL(M.SectStat,'')  
    END AS [ConclusiveStatus]  
  FROM ApplSectionsETA AS ETA(NOLOCK)  
  INNER JOIN APPL AS A(NOLOCK) ON ETA.APNO = A.Apno   
  LEFT OUTER JOIN ClientCertification C(NOLOCK) ON ETA.APNO = C.APNO  
  LEFT OUTER JOIN dbo.MedInteg AS M(NOLOCK) ON ETA.Apno = M.APNO AND ETA.ApplSectionID = 7  
  WHERE M.SectStat IN ('9')  
    AND A.APSTATUS != 'F'  
    AND C.ClientCertUpdated >= @StartDate   
    AND C.ClientCertUpdated < DateAdd(d,1,@EndDate)   
    AND A.Clno IN (SELECT CLNO FROM Client (NOLOCK) WHERE (CLNO = IIF(@CLNO=0, CLNO, @CLNO) OR WebOrderParentCLNO = IIF(@CLNO=0, CLNO, @CLNO))
	AND (@AffiliateID IS NULL OR AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #54480
   --AND AffiliateID = IIF(@AffiliateID=0,AffiliateID,@AffiliateID)							-- Comnt for HDT #54480	 
	)  
 )  
 INSERT INTO #tmpMainSet  
 SELECT X.ApplSectionID,   
   CASE WHEN X.ApplSectionID = 7 THEN 'SanctionCheck' ELSE Y.Section END AS Section,   
   Apno, SectionKeyID, ETADate, ClientCertUpdated, ISNULL([Client Notes],'') AS [Client Notes],ISNULL([ConclusiveStatus],'') AS [ConclusiveStatus]  
 FROM SanctionCheck AS X  
 INNER JOIN dbo.ApplSections Y ON X.ApplSectionID = Y.ApplSectionID  
  
 ;WITH MVR AS  
 (  
  SELECT ETA.ApplSectionID, ETA.Apno, ETA.SectionKeyID, ETA.ETADate, C.ClientCertUpdated  
    ,CASE WHEN ETA.ApplSectionID = 6 THEN ISNULL(D.Notes,'') END AS [Client Notes],  
    CASE WHEN D.SectStat = '9' THEN ISNULL(D.SectStat,'')  
    END AS [ConclusiveStatus]  
  FROM ApplSectionsETA AS ETA(NOLOCK)  
  INNER JOIN APPL AS A(NOLOCK) ON ETA.APNO = A.Apno   
  LEFT OUTER JOIN ClientCertification C(NOLOCK) ON ETA.APNO = C.APNO  
  LEFT OUTER JOIN dbo.DL AS D(NOLOCK) ON ETA.Apno = D.APNO AND ETA.ApplSectionID = 6  
  WHERE D.SectStat IN ('9')  
    AND A.APSTATUS != 'F'  
    AND C.ClientCertUpdated >= @StartDate   
    AND C.ClientCertUpdated < DateAdd(d,1,@EndDate)   
    AND A.Clno IN (SELECT CLNO FROM Client (NOLOCK) WHERE (CLNO = IIF(@CLNO=0, CLNO, @CLNO) OR WebOrderParentCLNO = IIF(@CLNO=0, CLNO, @CLNO)) 
	AND (@AffiliateID IS NULL OR AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #54480
   --AND AffiliateID = IIF(@AffiliateID=0,AffiliateID,@AffiliateID)							-- Comnt for HDT #54480	 
	)  
 )  
 INSERT INTO #tmpMainSet  
 SELECT X.ApplSectionID,   
   CASE WHEN X.ApplSectionID = 7 THEN 'SanctionCheck' ELSE Y.Section END AS Section,   
   Apno, SectionKeyID, ETADate, ClientCertUpdated, ISNULL([Client Notes],'') AS [Client Notes], ISNULL([ConclusiveStatus],'') AS [ConclusiveStatus]  
 FROM MVR AS X  
 INNER JOIN dbo.ApplSections Y ON X.ApplSectionID = Y.ApplSectionID  
  
 INSERT INTO #tmpAll  
 SELECT *, ROW_NUMBER() OVER (PARTITION BY M.Apno ORDER BY M.ETADate DESC, M.SectionName ASC) AS RowNumber  
 FROM #tmpMainSet M   
 ORDER BY M.Apno   
  
 INSERT INTO #tmpAllMaxETA  
 SELECT * FROM #tmpAll A   
 WHERE A.RowNumber = 1  
  
 IF @count > 0   
 BEGIN  
  SELECT A.CLNO AS [Client Number],   
      C.Name AS [Client Name],   
      ETA.APNO as [Report Number],   
      A.First + ' ' + A.Last AS [Applicant Name] ,   
      P.PackageDesc AS [Package Ordered],   
      A.DeptCode AS [Process Level],  
      ETA.[ClientCertUpdated] AS [Report Start Date],   
      CONVERT(varchar, ETADate, 101) AS [Report Conclusion ETA],  
      ETA.SectionName AS [Component],  
      [dbo].[ElapsedBusinessDays_2](CONVERT(varchar,ETA.[ClientCertUpdated], 101),CONVERT(varchar, ETADate, 101)) AS [ETADays],  
      [dbo].[ElapsedBusinessDays_2](ETA.[ClientCertUpdated],CURRENT_TIMESTAMP) AS [Turnaround Time],  
      REPLACE(REPLACE(ETA.[Client Notes], char(10),';'),char(13),';') AS [Client Notes]  
  FROM #tmpAllMaxETA AS ETA  
  INNER JOIN Appl AS A(NOLOCK) ON ETA.APNO = A.APNO  
  LEFT OUTER JOIN Client AS C(NOLOCK) ON A.CLNO = C.CLNO  
  LEFT OUTER JOIN PackageMain AS P(NOLOCK) ON P.PackageID = A.PackageID  
  WHERE A.ApStatus NOT IN ('F','M')  
  AND A.OrigCompDate IS NULL  
    AND C.IsInactive = 0  
    AND A.Clno IN (SELECT CLNO FROM Client (NOLOCK) WHERE (CLNO = IIF(@CLNO=0, CLNO, @CLNO) OR WebOrderParentCLNO = IIF(@CLNO=0, CLNO, @CLNO)) AND C.IsInactive = 0 
	AND (@AffiliateID IS NULL OR AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #54480
   --AND AffiliateID = IIF(@AffiliateID=0,AffiliateID,@AffiliateID)							-- Comnt for HDT #54480	 
	)  
 END  
 ELSE  
 BEGIN  
  SELECT A.CLNO AS [Client Number],   
      C.Name AS [Client Name],   
      ETA.APNO as [Report Number],   
      A.First + ' ' + A.Last AS [Applicant Name] ,   
      P.PackageDesc AS [Package Ordered],   
      A.DeptCode AS [Process Level],  
      ETA.[ClientCertUpdated] AS [Report Start Date],   
      CONVERT(varchar, ETADate, 101) AS [Report Conclusion ETA],  
      ETA.SectionName AS [Component],  
      [dbo].[ElapsedBusinessDays_2](ETA.[ClientCertUpdated], ETADate) AS [ETADays],  
      [dbo].[ElapsedBusinessDays_2](ETA.[ClientCertUpdated],CURRENT_TIMESTAMP) AS [Turnaround Time],  
      REPLACE(REPLACE(ETA.[Client Notes], char(10),';'),char(13),';') AS [Client Notes]        
  FROM #tmpAllMaxETA AS ETA  
  INNER JOIN Appl AS A(NOLOCK) ON ETA.APNO = A.APNO  
  LEFT OUTER JOIN Client AS C(NOLOCK) ON A.CLNO = C.CLNO  
  LEFT OUTER JOIN PackageMain AS P(NOLOCK) ON P.PackageID = A.PackageID  
  WHERE A.ApStatus NOT IN ('F','M')  
    AND A.OrigCompDate IS NULL  
    AND C.IsInactive = 0  
    AND A.Clno IN (SELECT CLNO FROM Client(NOLOCK) WHERE (Clno = IIF(@CLNO=0, CLNO, @CLNO)) AND C.IsInactive = 0 
	AND (@AffiliateID IS NULL OR AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #54480
   --AND AffiliateID = IIF(@AffiliateID=0,AffiliateID,@AffiliateID)							-- Comnt for HDT #54480	 
	)  
 END  
  
 DROP TABLE #tmpMainSet  
 DROP TABLE #tmpAll  
 DROP TABLE #tmpAllMaxETA  
  
END  