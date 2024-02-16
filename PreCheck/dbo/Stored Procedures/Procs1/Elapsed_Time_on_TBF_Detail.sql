-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 05/11/2017
-- Description:	Elapsed Time on TBF Detail
-- Modified by:	DEEPAK VODETHELA	
-- Modified Date: 09/28/2017
-- Modified by: Radhika Dereddy on 07/13/2018
-- Modified Reason: Adding the License Section to the Qreport as requested by Brian Silver HDT#35917
-- Modified By: Deepak Vodethela
-- Modified date: 07/17/2018
-- Modified Reason: Added Crim's Last_Updated date when ChangeLog returns NULL.
-- Modified By: Deepak Vodethela
-- Modified date: 08/14/2019
-- Modified Reason: Use the final status date/time for edu, emp, lic and reference, but use the last updated date for crims. And also ignore any changes made by CAM.
-- Execution: EXEC Elapsed_Time_on_TBF_Detail '08/01/2019','08/12/2019', 0, '2331'
/* Modified By: Vairavan A
-- Modified Date: 07/04/2022
-- Description: Ticketno-53763 
Modify existing q-reports that have affiliate ids in their search parameters
Details: 
Change search parameters for the Affiliate Id field
     * search by multiple affiliate ids (ex 4:297)
     * want to also be able to search all affiliates by putting zero - meaning 0 to search all affiliates
     * multiple affiliates to be separated by a colon  
Under Parameter Names - after Affiliate ID include this wording (separate by colon, default 0)
*/
/* Modified By: Cameron DeCook
-- Modified Date: 07/06/2023
-- Description: Ticketno-99338 
Fixed logic to always pull from change log and fix TBF calc logic
Also added ReOpen date, CAM1 time, QAInvest Time
*/
---Testing
/*
EXEC Elapsed_Time_on_TBF_Detail '08/01/2019','08/12/2019', '0', '2331'
EXEC Elapsed_Time_on_TBF_Detail '08/01/2019','08/12/2019', '4', '2331'
EXEC Elapsed_Time_on_TBF_Detail '08/01/2019','08/12/2019', '4:8', '2331'
*/
-- =============================================

CREATE PROCEDURE [dbo].[Elapsed_Time_on_TBF_Detail]
    @StartDate DATE,
    @EndDate DATE,                                   --@AffiliateID int,--code commented by vairavan for ticket id -53763
    @AffiliateIDs VARCHAR(MAX) = '0', --code added by vairavan for ticket id -53763
    @ClientList VARCHAR(MAX) = NULL
AS
BEGIN

    SET ANSI_WARNINGS OFF;

    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    --code added by vairavan for ticket id -53763 starts
    IF @AffiliateIDs = '0'
    BEGIN
        SET @AffiliateIDs = NULL;
    END;
    --code added by vairavan for ticket id -53763 ends

    IF (@ClientList = '' OR LOWER(@ClientList) = 'null')
    BEGIN
        SET @ClientList = NULL;
    END;

    --DECLARE temp tables (helps to maintain the same plan regardless of stats change)
    CREATE TABLE #tmp
    (
        [APNO] [INT] NOT NULL,
        [CLNO] [SMALLINT] NOT NULL,
        [ClientName] [VARCHAR](100) NULL,
        [Applicant First Name] [VARCHAR](20) NOT NULL,
        [Applicant Last Name] [VARCHAR](20) NOT NULL,
        [ApDate] [DATETIME] NULL,
        [CompDate] [DATETIME] NULL,
        [OrigCompDate] [DATETIME] NULL,
        [ReOpenDate] DATETIME NULL,
        [CAM] [VARCHAR](8) NULL,
        [Pos_Sought] [VARCHAR](100) NULL,
        [CAM1StartDate] DATETIME NULL,
        [CAM1EndDate] DATETIME NULL,
        [QAStartDate] DATETIME NULL,
        [QAEndDate] DATETIME NULL,
        [InProgressReview] BIT NULL
    ); --By HAhmed on 10/15/2018 - Added the column Position sought per HDT# 41417

    CREATE TABLE #tmpAllRec
    (
        [ComponentType] [VARCHAR](20) NOT NULL,
        [APNO] [INT] NOT NULL,
        [Value] [VARCHAR](250) NOT NULL,
        [User Who CLosed] [VARCHAR](100) NULL,
        [Last Updated Date] [DATETIME] NULL
    );

    CREATE TABLE #tmpFinalClosedDateForComponent
    (
        [ComponentType] [VARCHAR](20) NOT NULL,
        [APNO] [INT] NOT NULL,
        [Value] [VARCHAR](250) NOT NULL,
        [User Who CLosed] [VARCHAR](100) NULL,
        [Last Updated Date] [DATETIME] NULL
    );

	--#99338 New temp tables for new time calcs
    CREATE TABLE #CAM1Start
    (
        [APNO] [INT] NOT NULL,
        [CAM1StartDate] DATETIME NULL
    );

    CREATE TABLE #CAM1End
    (
        [APNO] [INT] NOT NULL,
        [CAM1EndDate] DATETIME NULL
    );

    CREATE TABLE #QAStart
    (
        [APNO] [INT] NOT NULL,
        [QAStartDate] DATETIME NULL
    );

    CREATE TABLE #QAEnd
    (
        [APNO] [INT] NOT NULL,
        [QAEndDate] DATETIME NULL
    );


    --Index on temp tables
    CREATE CLUSTERED INDEX IX_tmp_01 ON #tmp (APNO);
    CREATE CLUSTERED INDEX IX_tmp2_01
    ON #tmpFinalClosedDateForComponent (APNO);


    -- Get all the "Finalized" reports
    INSERT INTO #tmp
    SELECT APNO,
           A.CLNO,
           C.Name AS ClientName,
           A.First AS [Applicant First Name],
           A.Last AS [Applicant Last Name],
           ApDate,
           CompDate,
           A.OrigCompDate,
           A.ReopenDate,
           A.UserID AS CAM,
           A.Pos_Sought,
           NULL AS [CAM1StartDate],
           NULL AS [CAM1EndDate],
           NULL AS [QAStartDate],
           NULL AS [QAEndDate],
           A.InProgressReviewed
    FROM dbo.Appl AS A WITH (NOLOCK)
        INNER JOIN dbo.Client AS C WITH (NOLOCK)
            ON A.CLNO = C.CLNO
        INNER JOIN dbo.refAffiliate AS RA WITH (NOLOCK)
            ON C.AffiliateID = RA.AffiliateID
    WHERE ApStatus = 'F'
          AND A.CLNO NOT IN ( 2135, 3468 )
          AND CAST(OrigCompDate AS DATE)
          BETWEEN @StartDate AND DATEADD(d, 1, @EndDate)
          AND
          (
              @ClientList IS NULL
              OR C.CLNO IN
                 (
                     SELECT value FROM fn_Split(@ClientList, ':')
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

    -- Get all the "Open" in a CAM1 or QAInvest CAM reports #99338 
    INSERT INTO #tmp
    SELECT APNO,
           A.CLNO,
           C.Name AS ClientName,
           A.First AS [Applicant First Name],
           A.Last AS [Applicant Last Name],
           ApDate,
           CompDate,
           A.OrigCompDate,
           A.ReopenDate,
           A.UserID AS CAM,
           A.Pos_Sought,
           NULL AS [CAM1StartDate],
           NULL AS [CAM1EndDate],
           NULL AS [QAStartDate],
           NULL AS [QAEndDate],
           A.InProgressReviewed
    FROM dbo.Appl AS A WITH (NOLOCK)
        INNER JOIN dbo.Client AS C WITH (NOLOCK)
            ON A.CLNO = C.CLNO
        INNER JOIN dbo.refAffiliate AS RA WITH (NOLOCK)
            ON C.AffiliateID = RA.AffiliateID
    WHERE ApStatus = 'P'
          AND A.CLNO NOT IN ( 2135, 3468 )
          AND
          (
              A.UserID LIKE '%1'
              OR A.UserID LIKE 'QA%'
          )
          AND CAST(A.ApDate AS DATE)
          BETWEEN @StartDate AND DATEADD(d, 1, @EndDate)
          AND
          (
              @ClientList IS NULL
              OR C.CLNO IN
                 (
                     SELECT value FROM fn_Split(@ClientList, ':')
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

--#99338 Loading of new temp tables
    INSERT INTO #CAM1Start
    (
        APNO,
        CAM1StartDate
    )
    SELECT A.APNO,
           MAX(cl.ChangeDate) AS [CAM1StartDate]
    FROM #tmp A
        INNER JOIN
        (
            SELECT ID,
                   ChangeDate,
                   OldValue,
                   NewValue
            FROM dbo.ChangeLog
            WHERE TableName = 'Appl.UserID'
                  AND NewValue LIKE '%1'
        ) cl
            ON A.APNO = cl.ID
    GROUP BY A.APNO;

    INSERT INTO #CAM1End
    (
        APNO,
        CAM1EndDate
    )
    SELECT A.APNO,
           MAX(cl.ChangeDate) AS [CAM1EndDate]
    FROM #tmp A
        INNER JOIN
        (
            SELECT ID,
                   ChangeDate,
                   OldValue,
                   NewValue
            FROM dbo.ChangeLog
            WHERE TableName = 'Appl.UserID'
                  AND OldValue LIKE '%1'
        ) cl
            ON A.APNO = cl.ID
    GROUP BY A.APNO;



    UPDATE t
    SET t.CAM1StartDate = c1s.CAM1StartDate,
        t.CAM1EndDate = c1e.CAM1EndDate
    FROM #tmp t
        LEFT OUTER JOIN #CAM1Start c1s
            ON c1s.APNO = t.APNO
        LEFT OUTER JOIN #CAM1End c1e
            ON c1e.APNO = t.APNO;

    INSERT INTO #QAStart
    (
        APNO,
        QAStartDate
    )
    SELECT A.APNO,
           MAX(cl.ChangeDate) AS [QAStartDate]
    FROM #tmp A
        INNER JOIN
        (
            SELECT ID,
                   ChangeDate,
                   OldValue,
                   NewValue
            FROM dbo.ChangeLog
            WHERE TableName = 'Appl.UserID'
                  AND NewValue LIKE 'QA%'
        ) cl
            ON A.APNO = cl.ID
    GROUP BY A.APNO;

    INSERT INTO #QAEnd
    (
        APNO,
        QAEndDate
    )
    SELECT A.APNO,
           MAX(cl.ChangeDate) AS [QAEndDate]
    FROM #tmp A
        INNER JOIN
        (
            SELECT ID,
                   ChangeDate,
                   OldValue,
                   NewValue
            FROM dbo.ChangeLog
            WHERE TableName = 'Appl.UserID'
                  AND OldValue LIKE 'QA%'
        ) cl
            ON A.APNO = cl.ID
    GROUP BY A.APNO;

    UPDATE t
    SET t.QAStartDate = qs.QAStartDate,
        t.QAEndDate = qe.QAEndDate
    FROM #tmp t
        LEFT OUTER JOIN #QAStart qs
            ON qs.APNO = t.APNO
        LEFT OUTER JOIN #QAEnd qe
            ON qe.APNO = t.APNO;

    -- Get all the Employment records which were completed from the ChangeLog
    ;
    WITH Employment
    AS (SELECT 'Employment' AS ComponentType,
               E.Apno,
               E.Employer AS [Value],
               (CASE
                    WHEN CHARINDEX('-', C.UserID) = 0 THEN
                        C.UserID
                    ELSE
                        LEFT(C.UserID, CHARINDEX('-', C.UserID) - 1)
                END
               ) AS [User Who CLosed],
               C.ChangeDate AS [Last Updated Date],
               CASE
                   WHEN C.ChangeDate >= T.CompDate THEN
                       1
                   ELSE
                       0
               END AS [Negative Flag],
               ROW_NUMBER() OVER (PARTITION BY C.ID ORDER BY C.ChangeDate DESC) AS RowNumber
        FROM #tmp T
            INNER JOIN dbo.Empl AS E WITH (NOLOCK)
                ON T.APNO = E.Apno
            INNER JOIN dbo.ChangeLog AS C WITH (NOLOCK)
                ON C.ID = E.EmplID
        WHERE E.IsOnReport = 1
              AND C.NewValue IN ( '2', '3', '4', '5', '1', '6', '7', '8', 'B', 'C', 'E', 'U' ) --#99338 Including unverified
			  AND C.ChangeDate < DATEADD(SECOND,3499,T.CompDate)
              --      AND 
              --(CASE --#99338 Removing this logic
              --               WHEN CHARINDEX('-', C.UserID) = 0 THEN
              --                   C.UserID
              --               ELSE
              --                   LEFT(C.UserID, CHARINDEX('-', C.UserID) - 1)
              --           END
              --          ) NOT IN
              --          (
              --              SELECT U.UserID FROM Users U WHERE U.CAM = 1
              --          )
              AND C.ChangeDate
              BETWEEN DATEADD(MM, -4, @StartDate) AND CURRENT_TIMESTAMP)
    INSERT INTO #tmpAllRec
    SELECT ComponentType,
           Apno,
           [Value],
           [User Who CLosed],
           [Last Updated Date]
    FROM Employment
    WHERE RowNumber = 1


    -- Get all the Education records which were completed from the ChangeLog
    ;
    WITH Education
    AS (SELECT 'Education' AS ComponentType,
               E.APNO,
               E.School AS [Value],
               (CASE
                    WHEN CHARINDEX('-', C.UserID) = 0 THEN
                        C.UserID
                    ELSE
                        LEFT(C.UserID, CHARINDEX('-', C.UserID) - 1)
                END
               ) AS [User Who CLosed],
               C.ChangeDate AS [Last Updated Date],
               ROW_NUMBER() OVER (PARTITION BY C.ID ORDER BY C.ChangeDate DESC) AS RowNumber
        FROM #tmp T
            INNER JOIN dbo.Educat AS E WITH (NOLOCK)
                ON T.APNO = E.APNO
            INNER JOIN dbo.ChangeLog AS C WITH (NOLOCK)
                ON C.ID = E.EducatID
        WHERE E.IsOnReport = 1
              AND C.NewValue IN ( '2', '3', '4', '5', '1', '6', '7', '8', 'B', 'C', 'E', 'U' )
			  AND C.ChangeDate < DATEADD(SECOND,3499,T.CompDate)
              --      AND 
              --(CASE
              --               WHEN CHARINDEX('-', C.UserID) = 0 THEN
              --                   C.UserID
              --               ELSE
              --                   LEFT(C.UserID, CHARINDEX('-', C.UserID) - 1)
              --           END
              --          ) NOT IN
              --          (
              --              SELECT U.UserID FROM Users U WHERE U.CAM = 1
              --          )
              AND C.ChangeDate
              BETWEEN DATEADD(MM, -4, @StartDate) AND CURRENT_TIMESTAMP)
    INSERT INTO #tmpAllRec
    SELECT ComponentType,
           APNO,
           [Value],
           [User Who CLosed],
           [Last Updated Date]
    FROM Education
    WHERE RowNumber = 1



    -- Get all the Personal Reference records which were completed from the ChangeLog
    ;
    WITH PersonalReference
    AS (SELECT 'Personal Reference' AS ComponentType,
               P.APNO,
               P.Name AS [Value],
               (CASE
                    WHEN CHARINDEX('-', C.UserID) = 0 THEN
                        C.UserID
                    ELSE
                        LEFT(C.UserID, CHARINDEX('-', C.UserID) - 1)
                END
               ) AS [User Who CLosed],
               C.ChangeDate AS [Last Updated Date],
               ROW_NUMBER() OVER (PARTITION BY C.ID ORDER BY C.ChangeDate DESC) AS RowNumber
        FROM #tmp T
            INNER JOIN dbo.PersRef AS P WITH (NOLOCK)
                ON T.APNO = P.APNO
            INNER JOIN dbo.ChangeLog AS C WITH (NOLOCK)
                ON C.ID = P.PersRefID
        WHERE P.IsOnReport = 1
              AND C.NewValue IN ( '2', '3', '4', '5', '1', '6', '7', '8', 'B', 'C', 'E', 'U' )
              --      AND 
              --(CASE
              --               WHEN CHARINDEX('-', C.UserID) = 0 THEN
              --                   C.UserID
              --               ELSE
              --                   LEFT(C.UserID, CHARINDEX('-', C.UserID) - 1)
              --           END
              --          ) NOT IN
              --          (
              --              SELECT U.UserID FROM Users U WHERE U.CAM = 1
              --          )
              AND C.ChangeDate
              BETWEEN DATEADD(MM, -4, @StartDate) AND CURRENT_TIMESTAMP)
    INSERT INTO #tmpAllRec
    SELECT ComponentType,
           APNO,
           [Value],
           [User Who CLosed],
           [Last Updated Date]
    FROM PersonalReference
    WHERE RowNumber = 1

	;
    WITH Sanctions
    AS (
 SELECT 'Sanctions' AS ComponentType,
       P.APNO,
       P.Status AS [Value],
       (CASE
            WHEN CHARINDEX('-', p.Username) = 0 THEN
                p.Username
            ELSE
                LEFT(p.Username, CHARINDEX('-', p.Username) - 1)
        END
       ) AS [User Who CLosed],
       T.ApDate,
       T.CompDate,
       T.OrigCompDate,
       p.ChangeDate AS [Last Updated Date],
       ROW_NUMBER() OVER (PARTITION BY p.MedIntegLogID ORDER BY P.ChangeDate DESC) AS RowNumber
FROM dbo.Appl T
    INNER JOIN dbo.MedIntegLog AS P WITH (NOLOCK)
        ON T.APNO = P.APNO
WHERE  P.ChangeDate
              BETWEEN DATEADD(MM, -4, @StartDate) AND CURRENT_TIMESTAMP)
    INSERT INTO #tmpAllRec
    SELECT ComponentType,
           APNO,
           [Value],
           [User Who CLosed],
           [Last Updated Date]
    FROM Sanctions
    WHERE RowNumber = 1
    -- Get all the License records which were completed from the ChangeLog
    ;
    WITH License
    AS (SELECT 'License' AS ComponentType,
               P.Apno,
               P.Lic_Type AS [Value],
               (CASE
                    WHEN CHARINDEX('-', C.UserID) = 0 THEN
                        C.UserID
                    ELSE
                        LEFT(C.UserID, CHARINDEX('-', C.UserID) - 1)
                END
               ) AS [User Who CLosed],
               C.ChangeDate AS [Last Updated Date],
               ROW_NUMBER() OVER (PARTITION BY C.ID ORDER BY C.ChangeDate DESC) AS RowNumber
        FROM #tmp T
            INNER JOIN dbo.ProfLic AS P WITH (NOLOCK)
                ON T.APNO = P.Apno
            INNER JOIN dbo.ChangeLog AS C WITH (NOLOCK)
                ON C.ID = P.ProfLicID
        WHERE P.IsOnReport = 1
              AND C.NewValue IN ( '2', '3', '4', '5', '1', '6', '7', '8', 'B', 'C', 'E', 'U' )
              --      AND 
              --(CASE
              --               WHEN CHARINDEX('-', C.UserID) = 0 THEN
              --                   C.UserID
              --               ELSE
              --                   LEFT(C.UserID, CHARINDEX('-', C.UserID) - 1)
              --           END
              --          ) NOT IN
              --          (
              --              SELECT U.UserID FROM Users U WHERE U.CAM = 1
              --          )
              AND C.ChangeDate
              BETWEEN DATEADD(MM, -4, @StartDate) AND CURRENT_TIMESTAMP)
    INSERT INTO #tmpAllRec
    SELECT ComponentType,
           Apno,
           [Value],
           [User Who CLosed],
           [Last Updated Date]
    FROM License
    WHERE RowNumber = 1;
    WITH Criminal
    AS (SELECT DISTINCT
               'Criminal' AS ComponentType,
               X.APNO,
               X.CrimID,
               X.County AS [Value],
               (CASE
                    WHEN CHARINDEX('-', C.UserID) = 0 THEN
                        C.UserID
                    ELSE
                        LEFT(C.UserID, CHARINDEX('-', C.UserID) - 1)
                END
               ) AS [User Who CLosed],
               --(CASE
               --     WHEN X.CNTY_NO = 2480 THEN
               --         C.ChangeDate
               --     ELSE
               --         X.Last_Updated
               -- END
               --) 
               C.ChangeDate AS [Last Updated Date],
               ROW_NUMBER() OVER (PARTITION BY C.ID ORDER BY C.ChangeDate DESC) AS RowNumber
        FROM #tmp T
            INNER JOIN Crim AS X WITH (NOLOCK)
                ON T.APNO = X.APNO
            INNER JOIN ChangeLog AS C WITH (NOLOCK)
                ON X.CrimID = C.ID
        WHERE X.IsHidden = 0
		AND C.ChangeDate < DATEADD(SECOND,3499,T.CompDate)
    --      AND 
    --(CASE
    --               WHEN CHARINDEX('-', C.UserID) = 0 THEN
    --                   C.UserID
    --               ELSE
    --                   LEFT(C.UserID, CHARINDEX('-', C.UserID) - 1)
    --           END
    --          ) NOT IN
    --          (
    --              SELECT U.UserID FROM Users U WHERE U.CAM = 1
    --          )
    )
    INSERT INTO #tmpAllRec
    SELECT ComponentType,
           APNO,
           [Value],
           [User Who CLosed],
           [Last Updated Date]
    FROM Criminal
    WHERE RowNumber = 1

    -- Get all the Crim records which were completed from Criminal Vendor Website
    ;
    WITH CrimVendorWebsite
    AS (SELECT DISTINCT
               'Criminal' AS ComponentType,
               L.APNO,
               L.County AS [Value],
               '' AS [User Who CLosed],
               L.EnteredDate AS [Last Updated Date],
               ROW_NUMBER() OVER (PARTITION BY L.APNO ORDER BY L.EnteredDate DESC) AS RowNumber
        FROM #tmp T
            INNER JOIN [dbo].[CriminalVendor_Log] AS L WITH (NOLOCK)
                ON T.APNO = L.APNO)
    INSERT INTO #tmpAllRec
    SELECT ComponentType,
           APNO,
           [Value],
           [User Who CLosed],
           [Last Updated Date]
    FROM CrimVendorWebsite
    WHERE RowNumber = 1;


    -- Get the Latest Updated date for each report#
    ;
    WITH FinalClosedDateForComponent
    AS (SELECT ComponentType,
               APNO,
               [Value],
               [User Who CLosed],
               [Last Updated Date],
               ROW_NUMBER() OVER (PARTITION BY APNO ORDER BY [Last Updated Date] DESC) AS RowNumber
        FROM #tmpAllRec)
    INSERT INTO #tmpFinalClosedDateForComponent
    SELECT ComponentType,
           APNO,
           [Value],
           [User Who CLosed],
           [Last Updated Date]
    FROM FinalClosedDateForComponent WITH (NOLOCK)
    WHERE RowNumber = 1;


    -- Get everything into one place to display
    SELECT T.CLNO,
           T.ClientName,
           T.APNO,
           CASE
               WHEN autoclose.Apno IS NULL THEN
                   'No'
               ELSE
                   'Yes'
           END AS [AutoClosed],
           T.InProgressReview,
           CONVERT(VARCHAR(20), T.ApDate, 22) AS ApDate,
           CONVERT(VARCHAR(20), T.OrigCompDate, 22) AS OrigCompDate,
           CONVERT(VARCHAR(20), T.CompDate, 22) AS CompDate,
           CONVERT(VARCHAR(20), T.ReOpenDate, 22) AS [ReOpenDate],
           T.[Applicant First Name],
           T.[Applicant Last Name],
           T.Pos_Sought AS [Position Sought], --By HAhmed on 10/15/2018 - Added the column Position sought per HDT# 41417
           T.CAM,
           F.[User Who CLosed],
           [dbo].[ElapsedBusinessDays_2](   CASE
                                                WHEN ISNULL(T.CAM1EndDate, '1900-01-01') > F.[Last Updated Date] THEN
                                                    T.CAM1EndDate
                                                ELSE
                                                    F.[Last Updated Date]
                                            END,
                                            T.CompDate
                                        ) [ElapsedDaysOnTBF],--#99338 New TBF logic
           CAST([dbo].[ElapsedBusinessDaysInDecimal](CASE WHEN ISNULL(T.CAM1EndDate, '1900-01-01') > F.[Last Updated Date] THEN T.CAM1EndDate ELSE F.[Last Updated Date] END, T.CompDate)*24 AS INT) AS ElapsedHoursOnTBF,--#99338 New TBF logic
           CONVERT(VARCHAR(20), F.[Last Updated Date], 22) AS [Last Updated Time on Section],
           F.ComponentType AS [Last Section Completed],
           F.Value,
           REPLACE(REPLACE(RA.Affiliate, CHAR(10), ';'), CHAR(13), ';') AS Affiliate,
           RA.AffiliateID,
           dbo.ElapsedBusinessDays_2(T.ApDate, T.OrigCompDate) TAT,
           CONVERT(VARCHAR(20), T.CAM1EndDate, 22) AS [Left CAM1 Date],
           CAST([dbo].[ElapsedBusinessDaysInDecimal](T.CAM1StartDate, T.CAM1EndDate)*24 AS INT) [ElapsedHoursOnCAM1],
           CAST([dbo].[ElapsedBusinessDaysInDecimal](T.QAStartDate, T.QAEndDate)*24 AS INT) [ElapsedHoursOnQA]
    FROM #tmpFinalClosedDateForComponent AS F WITH (NOLOCK)
        INNER JOIN #tmp AS T WITH (NOLOCK)
            ON F.APNO = T.APNO
        INNER JOIN dbo.Client C WITH (NOLOCK)
            ON T.CLNO = C.CLNO
        INNER JOIN dbo.refAffiliate AS RA WITH (NOLOCK)
            ON C.AffiliateID = RA.AffiliateID
        LEFT OUTER JOIN dbo.ApplAutoCloseLog autoclose WITH (NOLOCK)
            ON autoclose.Apno = T.APNO
    WHERE (
              @ClientList IS NULL
              OR T.CLNO IN
                 (
                     SELECT value FROM fn_Split(@ClientList, ':')
                 )
          )
          -- AND RA.AffiliateID = IIF(@AffiliateID = 0,RA.AffiliateID, @AffiliateID)--code commented by vairavan for ticket id -53763
          AND
          (
              @AffiliateIDs IS NULL
              OR RA.AffiliateID IN
                 (
                     SELECT value FROM fn_Split(@AffiliateIDs, ':')
                 )
          ) --code added by vairavan for ticket id -53763
    ORDER BY T.ApDate ASC,
             [Last Updated Date] DESC;


    DROP TABLE #tmp;
    DROP TABLE #tmpAllRec;
    DROP TABLE #tmpFinalClosedDateForComponent;
    DROP TABLE #CAM1Start;
    DROP TABLE #CAM1End;
    DROP TABLE #QAStart;
    DROP TABLE #QAEnd;



END;
