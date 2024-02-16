-- =============================================
-- Author:		DEEPAK VODETELA
-- Create date: 09/12/2017
-- Description:	Provide details for the TAT for Client (Breakdown up to 20+ Days). Meaning For each entry - what report number, 
-- and what employer/education/license/reference or criminal county it was?  
-- Execution: EXEC [dbo].[TurnaroundTimeForClient_Breakdown_Details] 0,'02/01/2020','02/15/2020', 4, 'Empl'
-- Modified By Radhika Dereddy on 02/24/2020 for HDT 67826
 --Modified by Humera Ahmed on 2/25/2020 to Add @IsOneHR parameter so the numbers match with the Qreport - TAT for Client (Component Breakdown)
 --  MOdified By Radhika Dereddy on 09/10/2020 to Add App Date, App Closed Date, Client Name, CLNO, Affiliate, Component Created Date, Component Completed Date. 
 /* Modified By: Vairavan A
-- Modified Date: 07/05/2022
-- Description: Ticketno-53763 
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
EXEC [dbo].[TurnaroundTimeForClient_Breakdown_Details] 0,'02/01/2020','02/15/2020','0', 'Empl'
EXEC [dbo].[TurnaroundTimeForClient_Breakdown_Details] 0,'02/01/2020','02/15/2020','4', 'Empl'
EXEC [dbo].[TurnaroundTimeForClient_Breakdown_Details] 0,'02/01/2020','02/15/2020','4:8', 'Empl'
*/
-- =============================================
CREATE PROCEDURE [dbo].[TurnaroundTimeForClient_Breakdown_Details]
(
  @CLNO int,
  @StartDate datetime,
  @EndDate datetime,
 -- @AffiliateID int--code commented by vairavan for ticket id -53763
  @AffiliateIDs varchar(MAX) = '0',--code added by vairavan for ticket id -53763
  @ComponentType varchar(10),
  @IsOneHR BIT = 1
)
AS
begin
--IF(@CLNO IS NULL)
--BEGIN
--	SET @CLNO=0
--END

--IF(@Affiliate IS NULL OR @Affiliate = 'null' OR @Affiliate = '')
--BEGIN
--	SET @Affiliate = ''
--END

		--code added by vairavan for ticket id -53763 starts
	IF @AffiliateIDs = '0' 
	BEGIN  
		SET @AffiliateIDs = NULL  
	END
	--code added by vairavan for ticket id -53763 ends

IF(@ComponentType IS NULL OR @ComponentType = 'null' OR @ComponentType = '')
BEGIN
	SET @ComponentType = ''
END

DECLARE @EmplTable TABLE 
( 
    Section varchar(10), 
	APNO INT,
	CLNO INT,
	ClientName varchar(100),
	Affiliate varchar(100),
	ReferenceName varchar(100),
	Employer varchar(100),
	CreatedDate datetime, 
	LastWorked datetime,
    Turnaround int,
	Investigator varchar(8),
	[App Date] datetime,
	[App Closed Date] datetime
)   
INSERT INTO @EmplTable (Section, APNO, CLNO, ClientName, Affiliate, Employer, CreatedDate, LastWorked, Turnaround, Investigator,  [App Date], [App Closed Date])
SELECT 'Empl' AS Section,
		A.APNO,
		C.CLNO,
		C.Name as ClientName,
		RA.Affiliate, 
		E.Employer,
		E.CreatedDate,
		E.Last_Worked,
		(CASE WHEN [dbo].[ElapsedBusinessDays_2]( E.CreatedDate, E.last_worked ) < 20 THEN [dbo].[ElapsedBusinessDays_2]( E.CreatedDate, E.last_worked ) 
        ELSE 20 END) AS Turnaround,
		E.Investigator,
		A.Apdate as [App Date],
		A.CompDate as [App Closed Date]
FROM Empl AS E with(NOLOCK)
INNER JOIN Appl AS A with(NOLOCK) ON E.Apno = A.Apno
INNER JOIN Client AS C with(NOLOCK) ON A.CLNO = C.CLNO
LEFT JOIN HEVN.dbo.Facility F with(NOLOCK) ON isnull(A.DeptCode,0) = F.FacilityNum
INNER JOIN refAffiliate AS RA with(NOLOCK) ON RA.AffiliateID = C.AffiliateID
WHERE E.CreatedDate >= @StartDate
  AND E.last_worked < DATEADD(DAY, 1, @EndDate) --@EndDate
  AND C.CLNO = IIF(@CLNO=0,C.CLNO,@CLNO)
  AND E.SectStat IN ('2','3','4','5','6','7','8','A')
  AND (ISNULL(F.IsOneHR,0) = @IsOneHR)
 -- AND C.AffiliateID = IIF(@AffiliateID=0,C.AffiliateID,@AffiliateID)--code commented by vairavan for ticket id -53763
  and (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763
  
--SELECT * FROM @EmplTable
 
DECLARE @EducatTable TABLE 
( 
    Section varchar(10), 
	APNO INT,
	CLNO INT,
	ClientName varchar(100),
	Affiliate varchar(100),
	ReferenceName varchar(100),
	School varchar(100),
	CreatedDate datetime, 
	LastWorked datetime,
    Turnaround int,
	Investigator varchar(8),
	[App Date] datetime,
	[App Closed Date] datetime
) 

INSERT INTO @EducatTable (Section, APNO, CLNO, ClientName, Affiliate, School, CreatedDate, LastWorked, Turnaround, Investigator,  [App Date], [App Closed Date])
SELECT 'Educat' AS Section,
		A.APNO,
		C.CLNO,
		C.Name as ClientName,
		RA.Affiliate, 
		E.School,
		E.CreatedDate,
		E.Last_Worked,
		CASE WHEN [dbo].[ElapsedBusinessDays_2]( E.CreatedDate, E.last_worked ) < 20 THEN [dbo].[ElapsedBusinessDays_2]( E.CreatedDate, E.last_worked ) 
        ELSE 20 END AS Turnaround,
		E.Investigator,
		A.Apdate as [App Date],
		A.CompDate as [App Closed Date]
FROM Educat AS E with(NOLOCK) 
INNER JOIN Appl AS A with(NOLOCK) ON E.Apno = A.Apno
INNER JOIN Client AS C with(NOLOCK) ON A.CLNO = C.CLNO
LEFT JOIN HEVN.dbo.Facility F with(NOLOCK) ON isnull(A.DeptCode,0) = F.FacilityNum
INNER JOIN refAffiliate AS RA with(NOLOCK) ON RA.AffiliateID = C.AffiliateID
WHERE E.CreatedDate >= @StartDate
  AND E.last_worked < DATEADD(DAY, 1, @EndDate) --@EndDate
  AND C.CLNO = IIF(@CLNO=0,C.CLNO,@CLNO)
  AND E.SectStat IN ('2','3','4','5','6','7','8','A')
  AND (ISNULL(F.IsOneHR,0) = @IsOneHR)
  --AND C.AffiliateID = IIF(@AffiliateID=0,C.AffiliateID,@AffiliateID)--code commented by vairavan for ticket id -53763
  and (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763
 

--SELECT * FROM @EducatTable

DECLARE @ProfLicTable TABLE 
( 
    Section varchar(10), 
	APNO INT,
	CLNO INT,
	ClientName varchar(100),
	Affiliate varchar(100),
	ReferenceName varchar(100),
	LicenseType varchar(100),
	CreatedDate datetime, 
	LastWorked datetime,
    Turnaround int,
	Investigator varchar(8),
	[App Date] datetime,
	[App Closed Date] datetime
) 

INSERT INTO @ProfLicTable (Section, APNO, CLNO, ClientName, Affiliate, LicenseType, CreatedDate, LastWorked, Turnaround, Investigator,  [App Date], [App Closed Date])
select 'ProfLic' as section,
		A.APNO, 
		C.CLNO,
		C.Name as ClientName,
		RA.Affiliate,
		P.Lic_Type as LicenseType,
		P.CreatedDate,
		P.Last_Worked,
		CASE WHEN [dbo].[ElapsedBusinessDays_2]( P.CreatedDate, P.last_worked ) < 20 THEN [dbo].[ElapsedBusinessDays_2]( P.CreatedDate, P.last_worked ) 
        ELSE 20 END AS Turnaround,
		A.Investigator,
		A.Apdate as [App Date],
		A.CompDate as [App Closed Date]
FROM ProfLic AS P with(NOLOCK) 
INNER JOIN Appl AS A with(NOLOCK) ON P.Apno = A.Apno
INNER JOIN Client AS C with(NOLOCK) ON A.CLNO = C.CLNO
LEFT JOIN HEVN.dbo.Facility F with(NOLOCK) ON isnull(A.DeptCode,0) = F.FacilityNum
INNER JOIN refAffiliate AS RA with(NOLOCK) ON RA.AffiliateID = C.AffiliateID
WHERE P.CreatedDate >= @StartDate
  AND P.last_worked < DATEADD(DAY, 1, @EndDate) --@EndDate
  AND C.CLNO = IIF(@CLNO=0,C.CLNO,@CLNO)
  AND P.SectStat IN ('2','3','4','5','6','7','8','A')
  AND (ISNULL(F.IsOneHR,0) = @IsOneHR)
  --AND C.AffiliateID = IIF(@AffiliateID=0,C.AffiliateID,@AffiliateID)--code commented by vairavan for ticket id -53763
  and (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763



--SELECT * FROM @ProfLicTable

DECLARE @PersRefTable TABLE 
( 
    Section varchar(10), 
	APNO INT,
	CLNO INT,
	ClientName varchar(100),
	Affiliate varchar(100),
	ReferenceName varchar(100),
	CreatedDate datetime, 
	LastWorked datetime,
    Turnaround int,
	Investigator varchar(8),
	[App Date] datetime,
	[App Closed Date] datetime
) 

INSERT INTO @PersRefTable  (Section, APNO,CLNO, ClientName, Affiliate, ReferenceName, CreatedDate, LastWorked, Turnaround, Investigator,  [App Date], [App Closed Date])
SELECT 'PersRef' as section,
		A.APNO, 
		C.CLNO,
		C.Name as ClientName,
		RA.Affiliate,
		P.Name as ReferenceName,
		P.CreatedDate,
		P.Last_Worked,
		CASE WHEN [dbo].[ElapsedBusinessDays_2]( P.CreatedDate, P.last_worked ) < 20 THEN [dbo].[ElapsedBusinessDays_2]( P.CreatedDate, P.last_worked ) 
        ELSE 20 END AS Turnaround,
		P.Investigator,
		A.Apdate as [App Date],
		A.CompDate as [App Closed Date]
FROM PersRef AS P with(NOLOCK)
INNER JOIN Appl AS A with(NOLOCK) ON P.Apno = A.Apno
INNER JOIN Client AS C with(NOLOCK) ON A.CLNO = C.CLNO
LEFT JOIN HEVN.dbo.Facility F with(NOLOCK) ON isnull(A.DeptCode,0) = F.FacilityNum
INNER JOIN refAffiliate AS RA with(NOLOCK) ON RA.AffiliateID = C.AffiliateID
WHERE P.createddate >= @StartDate 
  AND P.last_worked < DATEADD(DAY, 1, @EndDate) --@EndDate
  AND C.CLNO = IIF(@CLNO=0,C.CLNO,@CLNO)
  AND P.SectStat IN ('2','3','4','5','6','7','8','A')
  AND (ISNULL(F.IsOneHR,0) = @IsOneHR)
  --AND C.AffiliateID = IIF(@AffiliateID=0,C.AffiliateID,@AffiliateID)--code commented by vairavan for ticket id -53763
  and (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763
 

--SELECT * FROM @PersRefTable

DECLARE @CrimTable TABLE 
( 
    Section varchar(10), 
	APNO INT,
	CLNO INT,
	ClientName varchar(100),
	Affiliate varchar(100),
	County varchar(100),
	CreatedDate datetime, 
	LastUpdated datetime,
    Turnaround int,
	Investigator varchar(8),
	[App Date] datetime,
	[App Closed Date] datetime
) 

INSERT INTO @CrimTable (Section, APNO, CLNO, ClientName, Affiliate, County, CreatedDate, LastUpdated, Turnaround, Investigator, [App Date], [App Closed Date])
SELECT 'Crim' as section,
		A.APNO, 
		C.CLNO,
		C.Name as ClientName,
		RA.Affiliate,
		CR.County,
		CR.CreatedDate,
		CR.Last_Updated AS LastUpdated,
        CASE WHEN dbo.elapsedbusinessdays_2( CR.Crimenteredtime, CR.Last_Updated ) < 20 THEN dbo.elapsedbusinessdays_2( CR.Crimenteredtime, CR.Last_Updated ) 
        ELSE 20 END AS Turnaround,
		A.Investigator,
		A.Apdate as [App Date],
		A.CompDate as [App Closed Date]
FROM Crim AS CR with(NOLOCK) 
INNER JOIN Appl AS A with(NOLOCK) ON CR.Apno = A.Apno
INNER JOIN Client AS C with(NOLOCK) ON A.CLNO = C.CLNO
LEFT JOIN HEVN.dbo.Facility F with(NOLOCK) ON isnull(A.DeptCode,0) = F.FacilityNum
INNER JOIN refAffiliate AS RA with(NOLOCK) ON RA.AffiliateID = C.AffiliateID
WHERE CR.Crimenteredtime >= @StartDate
  AND CR.Last_Updated < DATEADD(DAY, 1, @EndDate) --@EndDate
  AND C.CLNO = IIF(@CLNO=0,C.CLNO,@CLNO)
  AND CR.[Clear] IN ('T','F','P')
  AND (ISNULL(F.IsOneHR,0) = @IsOneHR)
  --AND C.AffiliateID = IIF(@AffiliateID=0,C.AffiliateID,@AffiliateID)--code commented by vairavan for ticket id -53763
  and (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763


--SELECT * FROM @CrimTable

DECLARE @AllComponents TABLE 
( 
    ComponentType varchar(10), 
	ReportNumber INT,
	CLNO INT,
	ClientName Varchar(100),
	Affiliate varchar(100),
	[Source] varchar(100),
    TAT INT,
	Investigator varchar(8),
	[App Date] datetime, 
	[App Closed Date] datetime, 
	[Component Created Date] datetime, 
	[Component Completed Date] datetime
 
) 

INSERT INTO @AllComponents (ComponentType, ReportNumber, CLNO, ClientName, Affiliate, [Source], TAT, Investigator, [App Date], [App Closed Date], [Component Created Date], [Component Completed Date] )
SELECT ComponentType, Apno, CLNO, ClientName, Affiliate, [Source], [TAT], Investigator, [App Date], [App Closed Date], [Component Created Date], [Component Completed Date] 
FROM 
(
SELECT Section AS ComponentType, APNO, CLNO, ClientName, Affiliate, Employer AS [Source], Turnaround AS [TAT], Investigator, [App Date], [App Closed Date],CreatedDate as [Component Created Date], LastWorked as [Component Completed Date]  FROM @EmplTable
UNION ALL
SELECT Section AS ComponentType, APNO, CLNO, ClientName, Affiliate, School AS [Source], Turnaround AS [TAT], Investigator, [App Date], [App Closed Date],CreatedDate, LastWorked as [Component Completed Date] FROM @EducatTable
UNION ALL
SELECT Section AS ComponentType, APNO, CLNO, ClientName, Affiliate, LicenseType AS [Source], Turnaround AS [TAT], Investigator, [App Date], [App Closed Date],CreatedDate, LastWorked as [Component Completed Date] FROM @ProfLicTable
UNION ALL
SELECT Section AS ComponentType, APNO, CLNO, ClientName, Affiliate, ReferenceName AS [Source], Turnaround AS [TAT], Investigator, [App Date], [App Closed Date],CreatedDate, LastWorked as [Component Completed Date] FROM @PersRefTable
UNION ALL
SELECT Section AS ComponentType, APNO, CLNO, ClientName, Affiliate, County AS [Source], Turnaround AS [TAT], Investigator, [App Date], [App Closed Date], CreatedDate as [Component Created Date], LastUpdated as [Component Completed Date] FROM @CrimTable
) AS Y

SELECT * FROM @AllComponents a
WHERE a.ComponentType = IIF(@ComponentType='',a.ComponentType,@ComponentType)

end


