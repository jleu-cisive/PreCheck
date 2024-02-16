

-- =============================================    
-- Author: Cameron DeCook   
-- Requester: Brian Silver   
-- Create date: 02/17/2023    
-- Description: To find out the overseas education by date range for specific Schools 
--				Very similar to [dbo].[Overseas_Education_by_Clients_by_Date_Range]
-- Execution: EXEC [dbo].[Qreport_OperationNightingalEducationSearch] '1/1/2023','1/1/2023','1619:2135:5751',''    
--     EXEC [dbo].[Qreport_OperationNightingalEducationSearch] '03/01/2022','03/31/2022','3115','' 
-- Modified on 2/24/2023 HDT#84511 Updated school list
-- =============================================    
CREATE PROCEDURE [dbo].[Qreport_OperationNightingalEducationSearch]
    @StartDate DATETIME,
    @EndDate DATETIME,
    @CLNO VARCHAR(500) = NULL,
    @AffiliateId VARCHAR(MAX) = '0'
AS
SET NOCOUNT ON;


IF @AffiliateId = '0'
BEGIN
    SET @AffiliateId = NULL;
END;


IF (@CLNO = '0' OR @CLNO IS NULL OR @CLNO = 'null')
BEGIN
    SET @CLNO = '';
END;

SELECT [Client ID] = A.CLNO,
       [Client Name] = C.Name,
       RA.Affiliate,
       [Report Number] = A.APNO,
       E.School AS Education,
       E.Studies_V AS Studies,
       E.Degree_V AS [Degree Type],
       E.To_V AS [Degree Date],
       E.city AS [Edu City],
       E.State AS [Edu State],
       [First Name] = A.First,
       [Last Name] = A.Last,
       [SSN] = A.SSN,
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
       dbo.ElapsedBusinessDays_2(E.CreatedDate, E.Last_Updated) AS [Component TAT],
       S.[Description] AS Status,
       ISNULL(sss.SectSubStatus, '') AS SecSubStatus,
       FORMAT(A.CreatedDate, 'MM/dd/yyyy hh:mm tt') AS [Created Date],
       FORMAT(A.OrigCompDate, 'MM/dd/yyyy hh:mm tt') AS [OriginalClose],
       FORMAT(A.CompDate, 'MM/dd/yyyy hh:mm tt') AS [Close Date],
       W.description AS [Web Status]
FROM dbo.Appl AS A (NOLOCK)
    INNER JOIN dbo.Educat AS E (NOLOCK)
        ON E.APNO = A.APNO
    INNER JOIN dbo.SectStat AS S (NOLOCK)
        ON S.Code = E.SectStat
    INNER JOIN dbo.Client C (NOLOCK)
        ON C.CLNO = A.CLNO
    INNER JOIN refAffiliate RA (NOLOCK)
        ON RA.AffiliateID = C.AffiliateID
    INNER JOIN dbo.Websectstat AS W (NOLOCK)
        ON W.code = E.web_status
    LEFT JOIN HEVN.dbo.Facility F (NOLOCK)
        ON ISNULL(A.DeptCode, 0) = F.FacilityNum
    LEFT JOIN dbo.SectSubStatus sss (NOLOCK)
        ON E.SectStat = sss.SectStatusCode
           AND E.SectSubStatusID = sss.SectSubStatusID
WHERE A.OrigCompDate >= @StartDate
      AND A.OrigCompDate < DATEADD(DAY, 1, @EndDate)
      AND E.IsOnReport = 1
      AND E.IsHidden = 0
      AND
      (
          E.School LIKE '%Carleen%'
          OR E.School LIKE '%Center for Advanced Training and Studies%'
          OR E.School LIKE '%CEUFast%'
          OR E.School LIKE '%Docu-Flex%'
          OR E.School LIKE '%EDUconnect%'
          OR E.School LIKE '%Florida College%'
          OR E.School LIKE '%Jean''s%'
          OR E.School LIKE '%Jemeron%'
          OR E.School LIKE '%Med-Life%'
          OR E.School LIKE '%Myrielle%'
          OR E.School LIKE '%New Era%'
          OR E.School LIKE '%Nursing Bridges%'
          OR E.School LIKE '%Nursing Education Agency%'
          OR E.School LIKE '%Palm Beach International%'
          OR E.School LIKE '%Palm Beach School%'
          OR E.School LIKE '%Palm Beach College%'
          OR E.School LIKE '%PowerfulU%'
          OR E.School LIKE '%Quisqueya%'
          OR E.School LIKE '%Sacred Heart International%'
          OR E.School LIKE '%Sacred Heart College%'
          OR E.School LIKE '%Siena College%'
          OR E.School LIKE '%Success Review%'
          OR E.School LIKE '%Suncoast College%'
          OR E.School LIKE '%Sunrise Academy%'
          OR E.School LIKE '%Techni-Pro%'
          OR E.School LIKE '%New York State Ed%'
          OR E.School LIKE '%Nursing Education Resource%'
          OR E.School LIKE '%United Hearts%'
          OR E.School LIKE '%Unity Health Care%'
          OR E.School LIKE '%Unparalleled%'
      )
      AND
      (
          ISNULL(@CLNO, '') = ''
          OR A.CLNO IN
             (
                 SELECT splitdata FROM dbo.fnSplitString(@CLNO, ':')
             )
      )
      AND
      (
          @AffiliateId IS NULL
          OR RA.AffiliateID IN
             (
                 SELECT value FROM fn_Split(@AffiliateId, ':')
             )
      )
ORDER BY A.CLNO;

SET NOCOUNT OFF;
