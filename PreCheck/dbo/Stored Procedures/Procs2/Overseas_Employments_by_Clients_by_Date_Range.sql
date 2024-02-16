-- =============================================
-- Author: Deepak Vodethela
-- Requester: Valerie K. Salazar
-- Create date: 05/19/2017
-- Description:	To find out the overseas employments by date range
-- Execution: EXEC [dbo].[Overseas_Employments_by_Clients_by_Date_Range] '03/1/2016','05/19/2017','1619:2135:5751',''
--			  EXEC [dbo].[Overseas_Employments_by_Clients_by_Date_Range] '09/01/2019','09/30/2019','3115',0,0
--			  EXEC [dbo].[Overseas_Employments_by_Clients_by_Date_Range] '07/1/2019','07/19/2019','',''
-- Updated 3/5/2019: Humera Ahmed - HDT - 47687 - Please add the unique Component TAT in a column to the Overseas Employment by Clients by Date Range report.  
-- Should reflect the TAT for the specific component displayed in the row.   
-- Modified by Radhika Dereddy on 03/22/2019 to Add OriginalClose date
-- Modified by Humera Ahmed on 5/17/2019 to Add Public notes.
-- Modified by Radhika dereddy on 07/23/2019 to add employment transferred column
-- Modified BY Radhika Dereddy on 07/30/2019 to add AffiliateID as the parameter per Valerie
-- Modified By Humera Ahmed on on 5/11/2020 for HDT#72285 - Please fix this q-report as it is running duplicate employments under the same report number.
-- Modified By AmyLiu on 09/10/2020 for phase3 of project: IntranetModule: Status-SubSatus
/* Modified By: Vairavan A
-- Modified Date: 07/01/2022
-- Description: Ticketno-53763 
Modify existing q-reports that have affiliate ids in their search parameters
Details: 
Change search parameters for the Affiliate Id field
     * search by multiple affiliate ids (ex 4:297)
     * want to also be able to search all affiliates by putting zero - meaning 0 to search all affiliates
     * multiple affiliates to be separated by a colon  
Under Parameter Names - after Affiliate ID include this wording (separate by colon, default 0)
-- Modified By Cameron DeCook on 02/8/2024 ticket 126161 performance improvements
*/
---Testing
/*
EXEC Overseas_Employments_by_Clients_by_Date_Range '03/01/2020','06/25/2020', '13055','0'
EXEC Overseas_Employments_by_Clients_by_Date_Range '03/01/2020','06/25/2020', '13055','4'
EXEC Overseas_Employments_by_Clients_by_Date_Range '03/01/2020','06/25/2020', '13055','10:4'
*/
-- =============================================
CREATE PROCEDURE [dbo].[Overseas_Employments_by_Clients_by_Date_Range]
    @StartDate DATETIME,
    @EndDate DATETIME,
    @CLNO VARCHAR(500) = NULL,
                                     --@AffiliateID int--code commented by vairavan for ticket id -53763
    @AffiliateIDs VARCHAR(MAX) = '0' --code added by vairavan for ticket id -53763
AS
SET NOCOUNT ON;


--code added by vairavan for ticket id -53763 starts
IF @AffiliateIDs = '0'
BEGIN
    SET @AffiliateIDs = NULL;
END;
--code added by vairavan for ticket id -53763 ends

IF (@CLNO = '0' OR @CLNO IS NULL OR @CLNO = 'null')
BEGIN
    SET @CLNO = '';
END;

--Added by Humera Ahmed on 5/11/2020 for HDT#72285
IF OBJECT_ID('tempdb..#tmpOverseas') IS NOT NULL
    DROP TABLE #tmpOverseas;
IF OBJECT_ID('tempdb..#tmpSSN') IS NOT NULL
    DROP TABLE #tmpSSN;
IF OBJECT_ID('tempdb..#Facility') IS NOT NULL
    DROP TABLE #Facility;
IF OBJECT_ID('tempdb..#Apps') IS NOT NULL
    DROP TABLE #Apps;

CREATE TABLE #Apps
(
    CLNO INT,
    APNO INT,
    Investigator VARCHAR(10),
    SSN VARCHAR(15),
    [First] VARCHAR(50),
    [Last] VARCHAR(50),
    CreatedDate DATETIME,
    CompDate DATETIME,
    ReopenDate DATETIME,
    ApDate DATETIME,
    OrigCompDate DATETIME,
    UserID VARCHAR(10),
    DeptCode VARCHAR(20),
    Affiliate NVARCHAR(50),
    WebOrderParentCLNO INT,
    [NAME] VARCHAR(100)
);

IF @AffiliateIDs = NULL
   AND @CLNO = ''
BEGIN
    INSERT INTO #Apps
    (
        CLNO,
        APNO,
        Investigator,
        SSN,
        First,
        Last,
        CreatedDate,
        CompDate,
        ReopenDate,
        ApDate,
        OrigCompDate,
        UserID,
        DeptCode,
        Affiliate,
        WebOrderParentCLNO,
        NAME
    )
    SELECT a.CLNO,
           a.APNO,
           a.Investigator,
           a.SSN,
           a.First,
           a.Last,
           a.CreatedDate,
           a.CompDate,
           a.ReopenDate,
           a.ApDate,
           a.OrigCompDate,
           a.UserID,
           a.DeptCode,
           RA.Affiliate,
           C.WebOrderParentCLNO,
           C.Name
    FROM dbo.Appl a WITH (NOLOCK)
        INNER JOIN dbo.Client AS C WITH (NOLOCK)
            ON a.CLNO = C.CLNO
        INNER JOIN refAffiliate AS RA WITH (NOLOCK)
            ON C.AffiliateID = RA.AffiliateID
    WHERE a.OrigCompDate >= @StartDate
          AND a.OrigCompDate < DATEADD(DAY, 1, @EndDate);
END;
ELSE
BEGIN

    INSERT INTO #Apps
    (
        CLNO,
        APNO,
        Investigator,
        SSN,
        First,
        Last,
        CreatedDate,
        CompDate,
        ReopenDate,
        ApDate,
        OrigCompDate,
        UserID,
        DeptCode,
        Affiliate,
        WebOrderParentCLNO,
        NAME
    )
    SELECT a.CLNO,
           a.APNO,
           a.Investigator,
           a.SSN,
           a.First,
           a.Last,
           a.CreatedDate,
           a.CompDate,
           a.ReopenDate,
           a.ApDate,
           a.OrigCompDate,
           a.UserID,
           a.DeptCode,
           RA.Affiliate,
           C.WebOrderParentCLNO,
           C.Name
    FROM dbo.Appl a WITH (NOLOCK)
        INNER JOIN dbo.Client AS C WITH (NOLOCK)
            ON a.CLNO = C.CLNO
        INNER JOIN refAffiliate AS RA WITH (NOLOCK)
            ON C.AffiliateID = RA.AffiliateID
    WHERE a.OrigCompDate >= @StartDate
          AND a.OrigCompDate < DATEADD(DAY, 1, @EndDate)
          AND
          (
              ISNULL(@CLNO, '') = ''
              OR a.CLNO IN
                 (
                     SELECT splitdata FROM dbo.fnSplitString(@CLNO, ':')
                 )
          )
          AND
          (
              @AffiliateIDs IS NULL
              OR RA.AffiliateID IN
                 (
                     SELECT value FROM fn_Split(@AffiliateIDs, ':')
                 )
          );

END;

--Added by Humera Ahmed on 5/11/2020 for HDT#72285
SELECT DISTINCT
       f.FacilityNum,
       f.IsOneHR,
       f.ParentEmployerID,
       f.EmployerID
INTO #Facility
FROM HEVN.dbo.Facility f WITH (NOLOCK);

SELECT A.CLNO AS [Client ID],
       A.NAME AS [Client Name],
       A.Affiliate,
       A.Investigator,
       A.APNO AS [Report Number],
       A.SSN,
       E.Employer AS Employer,
       E.city AS [Emp City],
       E.[state] AS [Emp State],
       A.First AS [First Name],
       A.Last AS [Last Name],
       CASE
           WHEN E.IsIntl IS NULL THEN
               'NO'
           WHEN E.IsIntl = 0 THEN
               'NO'
           ELSE
               'YES'
       END AS [International/Overseas],
       dbo.ElapsedBusinessDays_2(A.CreatedDate, A.CompDate) AS Turnaround,
       dbo.ElapsedBusinessDays_2(A.ReopenDate, A.CompDate) AS [ReOpen Turnaround],
       dbo.ElapsedBusinessDays_2(E.CreatedDate, E.Last_Updated) AS [Component TAT], --Added by Humera Ahmed on 3/5/2019 for HDT#47687
       S.[Description] AS [Status],
       ISNULL(sss.SectSubStatus, '') AS [SubStatus],
       FORMAT(A.ApDate, 'MM/dd/yyyy hh:mm tt') AS [Received Date],
       FORMAT(A.OrigCompDate, 'MM/dd/yyyy hh:mm tt') AS [OriginalClose],
       FORMAT(A.CompDate, 'MM/dd/yyyy hh:mm tt') AS [Close Date],
       A.UserID AS CAM,
       E.Investigator AS [Investigator1],
       CASE
           WHEN E.IsHidden = 0 THEN
               'False'
           ELSE
               'True'
       END AS [Is Hidden Report],
       CASE
           WHEN E.IsOnReport = 0 THEN
               'False'
           ELSE
               'True'
       END AS [Is On Report],
       E.Pub_Notes [Public Notes],
       E.Priv_Notes AS [Private Notes],
       ISNULL(A.DeptCode, 0) AS [DeptCode],
       A.WebOrderParentCLNO
INTO #tmpOverseas
FROM #Apps AS A
    INNER JOIN dbo.Empl AS E WITH (NOLOCK)
        ON A.APNO = E.Apno
    INNER JOIN dbo.SectStat AS S WITH (NOLOCK)
        ON E.SectStat = S.Code
    LEFT JOIN dbo.SectSubStatus sss WITH (NOLOCK)
        ON E.SectStat = sss.SectStatusCode
           AND E.SectSubStatusID = sss.SectSubStatusID;

SELECT [Client ID],
       [Client Name],
       Affiliate,
       CASE
           WHEN COALESCE(F.IsOneHR, F2.IsOneHR) = 1 THEN
               'True'
           WHEN COALESCE(F.IsOneHR, F2.IsOneHR) = 0 THEN
               'False'
           WHEN COALESCE(F.IsOneHR, F2.IsOneHR) IS NULL THEN
               'N/A'
       END AS [IsOneHR],
       Investigator,
       [Report Number],
       Employer,
       [Emp City],
       [Emp State],
       [First Name],
       [Last Name],
       [International/Overseas],
       Turnaround,
       [ReOpen Turnaround],
       [Component TAT],
       [Status],
       O.[SubStatus],
       [Received Date],
       [OriginalClose],
       [Close Date],
       CAM,
       [Investigator1],
       [Is Hidden Report],
       [Is On Report],
       [Public Notes],
       [Private Notes]
FROM #tmpOverseas AS O
    LEFT JOIN #Facility F
        ON O.DeptCode = F.FacilityNum
           AND O.WebOrderParentCLNO = F.ParentEmployerID
    LEFT JOIN #Facility F2
        ON O.DeptCode = F2.FacilityNum
           AND O.WebOrderParentCLNO = F2.EmployerID;



SET NOCOUNT OFF;
