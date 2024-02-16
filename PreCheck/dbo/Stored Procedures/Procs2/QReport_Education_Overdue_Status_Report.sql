
------------------------------------------------------------------------------------------------
-- Created By - Prasanna on 04/08/2021
-- Requester - Michelle Paz
-- EXEC [Education_Overdue_Status_Report]
-- This Stored Procedure is derived from [Employment_Overdue_Status_Report]
-- EXEC [dbo].[QReport_Education_Overdue_Status_Report] 
------------------------------
/* Modified By: Vairavan A
-- Modified Date: 06/14/2022
-- Description: Ticketno-48494 
We had ticket # 3596 originally for education overdue status qreport to include the component assigned date.  
This ticket was closed without resolution.  
We currently have this feature for employment overdue status and wanted to mirror it. 
I have attached the email trail regarding this ticket.
------------------------------
 Modified By: Cameron DeCook
 Modified Date: 5/10/2023
 Description: Ticketno-93923 
 Fixed Reopen date and Aging Assigned Date to use ChangeLog Table
 ------------------------------
 Modified By: Arindam Mitra
 Modified Date: 11/07/2023
 Description: Ticketno-116217
 Added two new columns International and Edu State in the report
*/
---------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[QReport_Education_Overdue_Status_Report]
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..#tmpResult') IS NOT NULL
        DROP TABLE #tmpResult;

    IF OBJECT_ID('tempdb..#tmpResult2') IS NOT NULL
        DROP TABLE #tmpResult2;

    IF OBJECT_ID('tempdb..#tmpResult3') IS NOT NULL
        DROP TABLE #tmpResult3;

    IF OBJECT_ID('tempdb..#ChangeLogTemp') IS NOT NULL
        DROP TABLE #ChangeLogTemp;



    SELECT A.APNO AS [Report Number],
           E.School,
           E.Investigator,
           A.ApDate,
           A.[Last] AS [Last Name],
           A.[First] AS [First Name],
           C.[Name] AS [Client Name],
           C.AffiliateID,
           RA.Affiliate,
           E.OrderId AS [SJV OrderID],
           [dbo].[ElapsedBusinessDays_2](A.ApDate, GETDATE()) AS [Aging of Report],
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
                                        ) AS [Aging Assigned Date], 
           wss.[description] AS WebStatus,
           (
               SELECT COUNT(1)
               FROM Educat WITH (NOLOCK)
               WHERE (Educat.APNO = A.APNO)
                     AND (Educat.SectStat = '9')
                     AND (Educat.IsOnReport = 1)
           ) AS EducatCount,
           CASE
               WHEN E.IsIntl IS NULL THEN
                   'NO'
               WHEN E.IsIntl = 0 THEN
                   'NO'
               ELSE
                   'YES'
           END AS [International],                                  --Code added for ticket# 116217
           E.State AS [Edu State],
           E.EducatID                                               --Code added for ticket# 116217
    INTO #tmpResult
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
    INTO #ChangeLogTemp
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


    SELECT [Report Number]
    INTO #tmpResult2
    FROM #tmpResult
    WHERE EducatCount = 0;


    SELECT *
    INTO #tmpResult3
    FROM #tmpResult
    WHERE [Report Number] NOT IN
          (
              SELECT [Report Number] FROM #tmpResult2
          );



    SELECT [Report Number],
           School,
           Investigator,
           ApDate,
           [Last Name],
           [First Name],
           clt.ChangeDate AS [Reopen Date],
           [Client Name],
           AffiliateID,
           Affiliate,
           [SJV OrderID],
           [Aging of Report],
           [Aging Assigned Date],
           WebStatus,
           EducatCount AS [Education Counts],
           International, --Code added for ticket# 116217
           [Edu State]    --Code added for ticket# 116217
    FROM #tmpResult3 t3
        LEFT OUTER JOIN #ChangeLogTemp clt
            ON clt.EducatID = t3.EducatID;




    SET ANSI_NULLS OFF;
    SET QUOTED_IDENTIFIER OFF;

END;


