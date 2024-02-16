

/*------------------------------------------------------------------------------------------------  
-- Created By - Radhika Dereddy on 05/10/2018  
-- Requester - Chloe Cooper  

ModifiedBy		ModifiedDate	TicketNo	Description
Shashank Bhoi	12/23/2022		68621		#68621  Education Overdue Status Report Summary - Education column values are not matching with education education total  
											EXEC dbo.Education_Overdue_Status_Report_Summary
---------------------------------------------------------------------------------------------------
ModifiedBy		ModifiedDate	TicketNo	Description
Cameron DeCook	5/10/2023		93923		Matching up with new logic in Qreport_Education_Overdue_Status_Report
---------------------------------------------------------------------------------------------------
ModifiedBy		ModifiedDate	TicketNo	Description
Cameron DeCook	1/30/2024		125029		Perfromance Update for Qreport based on issues
---------------------------------------------------------------------------------------------------*/

CREATE PROCEDURE [dbo].[Qreport_Education_Overdue_Status_Report_Summary]
AS
SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#Qtemp1Educat1') IS NOT NULL
    DROP TABLE #Qtemp1Educat1;

IF OBJECT_ID('tempdb..#Qtemp1Educat2') IS NOT NULL
    DROP TABLE #Qtemp1Educat2;

IF OBJECT_ID('tempdb..#Qtemp1Educat3') IS NOT NULL
    DROP TABLE #Qtemp1Educat3;

IF OBJECT_ID('tempdb..#Qtemp1Educat4') IS NOT NULL
    DROP TABLE #Qtemp1Educat4;

IF OBJECT_ID('tempdb..#ChangeSummaryLogTemp') IS NOT NULL
    DROP TABLE #ChangeSummaryLogTemp;

DECLARE @Education TABLE
(
    Apno INT,
    ApStatus VARCHAR(1),
    UserID VARCHAR(8),
    Investigator VARCHAR(8),
    Apdate DATETIME,
    Last VARCHAR(50),
    First VARCHAR(50),
    Middle VARCHAR(50),
    ReopenDate DATETIME,
    ClientName VARCHAR(100),
    Affiliate VARCHAR(50),
    AffiliateID INT,
    Elapsed DECIMAL,
    InProgressReviewed VARCHAR(20),
    EducatCount INT
);

SELECT A.APNO,
       A.ApStatus,
       A.UserID,
       A.Investigator,
       A.ApDate,
       A.Last,
       A.First,
       A.Middle,
       --Re.ChangeDate AS [ReOpen Date],
       C.Name AS Client_Name,
       RA.Affiliate,
       RA.AffiliateID,
       CONVERT(
                  NUMERIC(7, 2),
                  [dbo].[ElapsedBusinessDays_2](
                                                   ISNULL(
                                                             NULL,
                                                             CASE
                                                                 WHEN YEAR(DateOrdered) = 1900
                                                                      AND DATEFROMPARTS(
                                                                                           YEAR(A.ApDate),
                                                                                           MONTH(DateOrdered),
                                                                                           DAY(DateOrdered)
                                                                                       ) >= A.ApDate THEN
                                                                     DATEFROMPARTS(
                                                                                      YEAR(A.ApDate),
                                                                                      MONTH(DateOrdered),
                                                                                      DAY(DateOrdered)
                                                                                  )
                                                                 WHEN YEAR(DateOrdered) = 1900
                                                                      AND DATEFROMPARTS(
                                                                                           YEAR(A.ApDate),
                                                                                           MONTH(DateOrdered),
                                                                                           DAY(DateOrdered)
                                                                                       ) < A.ApDate THEN
                                                                     DATEFROMPARTS(
                                                                                      YEAR(A.ApDate) + 1,
                                                                                      MONTH(DateOrdered),
                                                                                      DAY(DateOrdered)
                                                                                  )
                                                                 ELSE
                                                                     DateOrdered
                                                             END
                                                         ),
                                                   GETDATE()
                                               )
              ) AS [Elapsed],
       (CASE
            WHEN A.InProgressReviewed = 0 THEN
                'False'
            ELSE
                'True'
        END
       ) AS InProgressReviewed,
       (
           SELECT COUNT(1)
           FROM Educat WITH (NOLOCK)
           WHERE (Educat.APNO = A.APNO)
                 AND (Educat.SectStat = '9')
                 AND (Educat.IsOnReport = 1)
       ) AS EducatCount,
       E.EducatID
INTO #Qtemp1Educat1
FROM Appl A WITH (NOLOCK)
    INNER JOIN Client C WITH (NOLOCK)
        ON A.CLNO = C.CLNO
           AND (A.ApStatus IN ( 'P', 'W' ))
           AND A.CLNO NOT IN ( 2135, 3468 )
    INNER JOIN Educat E WITH (NOLOCK)
        ON A.APNO = E.APNO
           AND E.SectStat = '9'
           AND E.IsOnReport = 1
    INNER JOIN refAffiliate RA WITH (NOLOCK)
        ON RA.AffiliateID = C.AffiliateID
    INNER JOIN Websectstat wss WITH (NOLOCK)
        ON wss.code = E.web_status
WHERE A.Investigator IS NOT NULL;


SELECT CL.ID AS EducatID,
       CL.ChangeDate
INTO #ChangeSummaryLogTemp
FROM
(
    SELECT ID,
           ChangeDate,
           ROW_NUMBER() OVER (PARTITION BY ID ORDER BY ChangeDate DESC) AS rn
    FROM dbo.ChangeLog c WITH (NOLOCK)
        INNER JOIN dbo.SectStat s WITH (NOLOCK)
            ON c.OldValue = s.Code
    WHERE TableName = 'Educat.SectStat'
          AND NewValue = '9'
          AND s.ReportedStatus_Integration = 'Completed'
) AS CL
WHERE CL.rn = 1;

SELECT APNO
INTO #Qtemp1Educat2
FROM #Qtemp1Educat1
WHERE EducatCount = 0;


SELECT *
INTO #Qtemp1Educat3
FROM #Qtemp1Educat1
WHERE APNO NOT IN
      (
          SELECT APNO FROM #Qtemp1Educat2
      )
ORDER BY Elapsed DESC;

SELECT qte.APNO,
       qte.ApStatus,
       qte.UserID,
       qte.Investigator,
       qte.ApDate,
       qte.Last,
       qte.First,
       qte.Middle,
	   cslt.ChangeDate AS [ReOpen Date],
       qte.Client_Name,
       qte.Affiliate,
       qte.AffiliateID,
	   qte.[Elapsed],
	   qte.InProgressReviewed,
	   qte.EducatCount
INTO #Qtemp1Educat4
FROM #Qtemp1Educat3 qte
    LEFT OUTER JOIN #ChangeSummaryLogTemp cslt
        ON cslt.EducatID = qte.EducatCount;


INSERT INTO @Education
SELECT *
FROM #Qtemp1Educat4;



DECLARE @EducatCountTemp TABLE
(
    AffiliateID INT,
    EducatCount INT,
    Elapsed DECIMAL
);

INSERT INTO @EducatCountTemp
SELECT AffiliateID,
       EducatCount,
       Elapsed
FROM @Education;


--Step 2: Create another table for Days  
DECLARE @SectionTable TABLE
(
    NumberOfDays NVARCHAR(2),
    Order_seq INT
);

INSERT INTO @SectionTable
(
    NumberOfDays,
    Order_seq
)
VALUES
('7+', 1),
('6', 2),
('5', 3),
('4', 4),
('3', 5),
('2', 6),
('1', 7),
('0', 8);


--Step 3: Create a Temp table and get all the values for BIG4 and AllOther Affiliates  
SELECT a.NumberOfDays,
       a.Order_seq,
       b.Affiliate,
       b.Total
INTO #QtempBig4
FROM @SectionTable a
    INNER JOIN
    (
        SELECT (CASE
                    WHEN AffiliateID IN ( 147, 159 ) THEN
                        'CHI'
                    WHEN AffiliateID IN ( 4, 5 ) THEN
                        'HCA'
                    WHEN AffiliateID IN ( 10, 164, 166 ) THEN
                        'Tenet'
                    WHEN AffiliateID IN ( 177 ) THEN
                        'UHS'
                    ELSE
                        'AllOther'
                END
               ) AS Affiliate,
               (CASE
                    WHEN Elapsed >= 7 THEN
                        '7+'
                    ELSE
                        CAST(Elapsed AS NVARCHAR(2))
                END
               ) AS Elapsed,
               SUM([EducatCount]) AS Total
        FROM @EducatCountTemp
        GROUP BY (CASE
                      WHEN AffiliateID IN ( 147, 159 ) THEN
                          'CHI'
                      WHEN AffiliateID IN ( 4, 5 ) THEN
                          'HCA'
                      WHEN AffiliateID IN ( 10, 164, 166 ) THEN
                          'Tenet'
                      WHEN AffiliateID IN ( 177 ) THEN
                          'UHS'
                      ELSE
                          'AllOther'
                  END
                 ),
                 (CASE
                      WHEN Elapsed >= 7 THEN
                          '7+'
                      ELSE
                          CAST(Elapsed AS NVARCHAR(2))
                  END
                 )
    ) b
        ON a.NumberOfDays = b.Elapsed
ORDER BY a.NumberOfDays DESC,
         b.Affiliate ASC;



--Step 4: Use the PIVOT function to get the totals  
DECLARE @tempPivot TABLE
(
    NumberOfDays NVARCHAR(2),
    Order_seq INT,
    HCA INT,
    CHI INT,
    Tenet INT,
    UHS INT,
    AllOther INT
);
INSERT INTO @tempPivot
SELECT NumberOfDays,
       Order_seq,
                             --[HCA], [CHI], [Tenet], [UHS], [ALLOTHER]			--Code commented for 68621
       ISNULL([HCA], 0),
       ISNULL([CHI], 0),
       ISNULL([Tenet], 0),
       ISNULL([UHS], 0),
       ISNULL([ALLOTHER], 0) --Code Added for 68621
FROM
(
    SELECT NumberOfDays,
           Order_seq,
           Affiliate,
           COALESCE(Total, 0) AS Total
    FROM #QtempBig4
) AS SourceTable
PIVOT
(
    SUM(Total)
    FOR Affiliate IN ([HCA], [CHI], [Tenet], [UHS], [ALLOTHER])
) AS PivotTable
ORDER BY NumberOfDays DESC;



--step 4b - Get the totals of all the EducatCount  
DECLARE @TotalSumofEducatCount DECIMAL(10, 2);
SET @TotalSumofEducatCount =
(
    SELECT SUM(HCA) + SUM(CHI) + SUM(Tenet) + SUM(UHS) + SUM(AllOther)
    FROM @tempPivot
);


--Step 5: Get the Totals and the Percentage fo the total volume  
DECLARE @tempTotals TABLE
(
    NumberOfDays NVARCHAR(20),
    Order_seq INT,
    HCA DECIMAL(10, 2),
    CHI DECIMAL(10, 2),
    Tenet DECIMAL(10, 2),
    UHS DECIMAL(10, 2),
    AllOther DECIMAL(10, 2)
);

INSERT INTO @tempTotals
SELECT *
FROM
(
    SELECT *
    FROM @tempPivot
    UNION ALL
    SELECT 'Total' AS NumberOfDays,
           9 AS Order_seq,
           SUM(HCA) AS [HCA],
           SUM(CHI) AS [CHI],
           SUM(Tenet) AS [Tenet],
           SUM(UHS) AS [UHS],
           SUM(AllOther) AS [ALLOTHER]
    FROM @tempPivot
    UNION ALL
    SELECT '% of Total Volume' AS NumberOfDays,
           10 AS Order_seq,
           CAST((SUM(HCA) / (@TotalSumofEducatCount)) * 100 AS DECIMAL(10, 2)) AS 'HCA',
           CAST((SUM(CHI) / (@TotalSumofEducatCount)) * 100 AS DECIMAL(10, 2)) AS 'CHI',
           CAST((SUM(Tenet) / (@TotalSumofEducatCount)) * 100 AS DECIMAL(10, 2)) AS 'Tenet',
           CAST((SUM(UHS) / (@TotalSumofEducatCount)) * 100 AS DECIMAL(10, 2)) AS 'UHS',
           CAST((SUM(AllOther) / (@TotalSumofEducatCount)) * 100 AS DECIMAL(10, 2)) AS 'AllOther'
    FROM @tempPivot
) A;


--Final result of the summary  
SELECT NumberOfDays,
       HCA,
       CHI,
       Tenet,
       UHS,
       AllOther,
       (HCA + CHI + Tenet + UHS + AllOther) AS 'Education',
       CAST(ROUND(   ((HCA + CHI + Tenet + UHS + AllOther) /
                      (
                          SELECT (HCA + CHI + Tenet + UHS + AllOther)
                          FROM @tempTotals
                          WHERE NumberOfDays = 'Total'
                      )
                     ) * 100,
                     2
                 ) AS DECIMAL(10, 2)) AS '% of Work'
FROM @tempTotals
ORDER BY Order_seq ASC;

DROP TABLE #QtempBig4;


SET ANSI_NULLS OFF;


SET QUOTED_IDENTIFIER OFF;
