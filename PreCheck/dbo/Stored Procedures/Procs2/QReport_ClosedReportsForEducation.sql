-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 07/14/2021
-- Description:	Closed Reports for Education
-- EXEC [QReport_ClosedReportsForEducation] '07/23/2021','07/23/2021',0,0
-- Commenting the ISOneHR column from the QReport as per Brian Silver on 07/26/2021 by Radhika Dereddy
-- =============================================
CREATE PROCEDURE [dbo].[QReport_ClosedReportsForEducation] 
	-- Add the parameters for the stored procedure here
@StartDate datetime,
@EndDate Datetime,
@CLNO int,
@AffiliateID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#tempOverseas') IS NOT NULL DROP TABLE #tempOverseas
IF OBJECT_ID('tempdb..#tempClosedCountEducation') IS NOT NULL DROP TABLE #tempClosedCountEducation


    -- Insert statements for procedure here
SELECT    
	  A.CLNO as[Client ID],   
	  C.Name as [Client Name],
	  RA.Affiliate,
	  --CASE WHEN F.IsOneHR = 1 THEN 'True' WHEN F.IsOneHR = 0 THEN 'False' WHEN F.IsOneHR IS NULL THEN 'N/A' END AS [IsOneHR],  
	  A.Investigator,   
	  [Report Number] = A.APNO,   
	  E.School AS Education,   
	  E.Studies_V AS Studies,   
	  E.Degree_V AS [Degree Type],   
	  E.To_V AS [Degree Date],  
	  E.city AS [Edu City],  
	  E.State AS [Edu State],  
	  [First Name] = A.First,   
	  [Last Name]=A.Last, 
	  [SSN] = A.SSN,  
	  CASE WHEN E.IsIntl IS NULL THEN 'NO' WHEN E.IsIntl = 0 THEN 'NO' ELSE 'YES' END AS [International/Overseas],   
	  dbo.elapsedbusinessdays_2(A.CreatedDate, A.CompDate) AS Turnaround,    
	  dbo.elapsedbusinessdays_2(A.ReopenDate, A.CompDate) AS [ReOpen Turnaround],   
	  dbo.elapsedbusinessdays_2(E.CreatedDate, E.Last_Updated) AS [Component TAT],   
	  S.[Description] AS Status, sss.SectSubStatus as [SubStatus], 
	  isnull(sss.SectSubStatus,'') as SecSubStatus,
	  format(A.CreatedDate,'MM/dd/yyyy hh:mm tt') AS [Created Date],   
	  format(A.OrigCompDate,'MM/dd/yyyy hh:mm tt')  AS [OriginalClose],  
	  format(A.CompDate,'MM/dd/yyyy hh:mm tt') AS [Close Date],   
	  A.UserID AS CAM,  
	  W.description as [Web Status],    
	  [Is Hidden Report] = E.IsHidden,  
	  [Is On Report] =  e.IsOnReport
	INTO #tempOverseas
FROM dbo.Appl AS A(NOLOCK)  
INNER JOIN dbo.Educat AS E(NOLOCK) ON E.APNO = A.APNO  
INNER JOIN dbo.SectStat AS S(NOLOCK) ON S.CODE = E.SectStat  
INNER JOIN dbo.Client C(NOLOCK) on C.CLNO = A.CLNO  
INNER JOIN refAffiliate RA(NOLOCK) on RA.AffiliateID = C.AffiliateID  
INNER JOIN dbo.Websectstat AS W(NOLOCK) ON W.code = E.web_status 
--LEFT JOIN HEVN.dbo.Facility F (NOLOCK) ON isnull(A.DeptCode,0) = F.FacilityNum  
Left join dbo.SectSubStatus sss (nolock) on E.SectStat = sss.SectStatusCode and E.SectSubStatusID = sss.SectSubStatusID and sss.ApplSectionID = 1
WHERE 
	A.OrigCompDate >= @StartDate 
AND A.OrigCompDate < DATEADD(DAY, 1, @EndDate)
AND E.SectStat NOT IN ( '9','0','H','R')
AND C.CLNO = IIF(@CLNO=0,C.CLNO,@CLNO)
AND C.AffiliateID = IIF(@AffiliateID=0,C.AffiliateID,@AffiliateID) 
AND E.IsHidden = 0
AND E.IsOnReport = 1
ORDER BY A.CLNO  



SELECT  
		[Client ID], [Client Name], 
		[Report Number], [Education], Studies,   
		[Degree Type],   
		[Degree Date],  
		[Edu City],  
		[Edu State],  
		[First Name], [Last Name], 
		[Status], [SubStatus],
		[OriginalClose],[Close Date]
	INTO #tempClosedCountEducation
FROM #tempOverseas AS O

SELECT * FROM #tempClosedCountEducation
	UNION ALL
SELECT '', 'Total Closed Reports',Count( [Report Number]),'','','','','','','','','','','',''
FROM #tempClosedCountEducation


END
