

-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 10/18/2021
-- Description:	HCA Initiative - Automated Inventory Report for C-Suite
-- EXEC dbo.[AutomatedDailyInventoryReport_Schedule] 1
-- Modified by Radhika Dereddy on 11/08/2021 to use the FormLookUp procedure for AI number.
-- Modified by Joshua Ates on 7/15/2021 to get rid of a conversion error, no ticket number just an adhoc request you can find it by searching --JA20210715
-- Modified by Joshua Ates on 8/8/2022 fixed devide by 0 error, no ticket number just an adhoc request you can find it by searching --JA20210808
-- =============================================
CREATE PROCEDURE [dbo].[AutomatedDailyInventoryReport_Schedule] 
	-- Add the parameters for the stored procedure here
	@IsPriorDay bit = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
DECLARE @StartDate Date 
DECLARE @EndDate Date 

	IF(@IsPriorDay = 1)
		BEGIN
			 SET @StartDate = DATEADD(DAY,-1, DATEDIFF(DAY,0,getdate())) 
			 SET @EndDate = @StartDate
		END
	ELSE
		BEGIN
			SET @StartDate = DATEADD(DAY,0, DATEDIFF(DAY,0,getdate()))
			SET @EndDate = @StartDate
		END


-- Applicant Investigation data
IF OBJECT_ID('tempdb..#tempActivityStatusReport') IS NOT NULL
	DROP TABLE #tempActivityStatusReport 

IF OBJECT_ID('tempdb..#tempBPMCounts') IS NOT NULL
	DROP TABLE #tempBPMCounts 

IF OBJECT_ID('tempdb..#tempCAMPendingDetails') IS NOT NULL
	DROP TABLE #tempCAMPendingDetails 	

IF OBJECT_ID('tempdb..#tempBeginInventory') IS NOT NULL
	DROP TABLE #tempBeginInventory	

IF OBJECT_ID('tempdb..#tempOverdueStatusReport') IS NOT NULL
	DROP TABLE #tempOverdueStatusReport 

IF OBJECT_ID('tempdb..#tempEducationReceived') IS NOT NULL
	DROP TABLE #tempEducationReceived 

IF OBJECT_ID('tempdb..#tempClosedEducation') IS NOT NULL
	DROP TABLE #tempClosedEducation 

IF OBJECT_ID('tempdb..#tempEmploymentReceived') IS NOT NULL
	DROP TABLE #tempEmploymentReceived 	
	
IF OBJECT_ID('tempdb..#tempClosedEmployment') IS NOT NULL
	DROP TABLE #tempClosedEmployment 

IF OBJECT_ID('tempdb..#tempLicenseReceived') IS NOT NULL
	DROP TABLE #tempLicenseReceived 	
	
IF OBJECT_ID('tempdb..#tempClosedLicense') IS NOT NULL
	DROP TABLE #tempClosedLicense 

IF OBJECT_ID('tempdb..#tempSanctionReceived') IS NOT NULL
	DROP TABLE #tempSanctionReceived 	
	
IF OBJECT_ID('tempdb..#tempClosedSanction') IS NOT NULL
	DROP TABLE #tempClosedSanction 

IF OBJECT_ID('tempdb..#tempReferenceReceived') IS NOT NULL
	DROP TABLE #tempReferenceReceived 	
	
IF OBJECT_ID('tempdb..#tempClosedReference') IS NOT NULL
	DROP TABLE #tempClosedReference 

IF OBJECT_ID('tempdb..#tempPublicRecordReceived') IS NOT NULL
	DROP TABLE #tempPublicRecordReceived 

IF OBJECT_ID('tempdb..#tempClosedPublicRecord') IS NOT NULL
	DROP TABLE #tempClosedPublicRecord	

IF OBJECT_ID('tempdb..#tempPublicRecordOutput') IS NOT NULL
	DROP TABLE #tempPublicRecordOutput 

IF OBJECT_ID('tempdb..#tempQulaityControl') IS NOT NULL
	DROP TABLE #tempQulaityControl 

IF OBJECT_ID('tempdb..#tempTotalCaseTBF') IS NOT NULL
	DROP TABLE #tempTotalCaseTBF 

IF OBJECT_ID('tempdb..#tempTotalCases') IS NOT NULL
	DROP TABLE #tempTotalCases 

IF OBJECT_ID('tempdb..#tempInventory') IS NOT NULL
	DROP TABLE #tempInventory 

IF OBJECT_ID('tempdb..#tempClosedByAutomation') IS NOT NULL
	DROP TABLE #tempClosedByAutomation 

IF OBJECT_ID('tempdb..#tempAI') IS NOT NULL
	DROP TABLE #tempAI

IF OBJECT_ID('tempdb..#tempEducation') IS NOT NULL
DROP TABLE #tempEducation

IF OBJECT_ID('tempdb..#tempEmployment') IS NOT NULL
DROP TABLE #tempEmployment

IF OBJECT_ID('tempdb..#tempLicense') IS NOT NULL
DROP TABLE #tempLicense

IF OBJECT_ID('tempdb..#tempSanction') IS NOT NULL
DROP TABLE #tempSanction

IF OBJECT_ID('tempdb..#tempReference') IS NOT NULL
DROP TABLE #tempReference

IF OBJECT_ID('tempdb..#tempPublicRecord') IS NOT NULL
DROP TABLE #tempPublicRecord


IF OBJECT_ID('tempdb..#tempCAMActivityReportDetail') IS NOT NULL
DROP TABLE #tempCAMActivityReportDetail

CREATE Table #tempActivityStatusReport
(
UserId varchar(20),
EnteredBy int,
DEMI int,
Operator int,
PendingStatus int,
OnHoldStatus int,
FinaledByCam int,
Automated int
)
	
INSERT INTO #tempActivityStatusReport
EXEC [dbo].[ActivityStatusReport] @StartDate, @EndDate


CREATE TABLE #tempBPMCounts
(
	UserId varchar(20),
	Countnum int
)

INSERT INTO #tempBPMCounts
EXEC [Metastorm9_2].DBO.BPM_AppCounts @StartDate, @EndDate


CREATE TABLE #tempOverdueStatusReport
(
	Apno int, 
	ApStatus varchar(1),
	UserId varchar(8),
	Investigator varchar(8),
	ApDate datetime, 
	[Last] varchar(50), 
	[First] varchar(50), 
	Middle varchar(50), 
	Reopendate datetime,
	OriginalCloseDate datetime,
	Client_Name varchar(100),
	CLNO int,
	Affiliate varchar(100),
	Elapsed decimal(7,2),
	InProgressReviewed varchar(5),
	Crim_Count int,
	Civil_Count int,
	Credit_Count int,
	DL_Count int,
	Empl_Count int,
	Educat_Count int,
	ProfLic_Count int,
	PersRef_Count int,
	Medinteg_Count int
)

INSERT INTO #tempOverdueStatusReport
EXEC [dbo].[Overdue_status_report]	

-- AI Inventory Report structure
SELECT FORMAT(@StartDate, 'MM/dd/yyyy') as [ReportDate],
	'AI' as [ItemType],
	(SELECT COUNT(A.APNO) FROM dbo.Appl A WITH(NOLOCK) WHERE A.ApStatus in ('P','W')) as [TotalCount],
	(SELECT EnteredBy FROM #tempActivityStatusReport WHERE Userid ='TOTAL') as [Items_Input],
	(SELECT Countnum FROM #tempBPMCounts WHERE Userid ='AIMI - TotalCount') as [Items_Output],
	(SELECT COUNT(A.APNO) as [InventoryCount] 
		FROM dbo.Appl A with (nolock)  
		INNER JOIN dbo.Client C with (nolock)  ON A.CLNO = C.CLNO
		WHERE A.ApStatus in ('P','W') 
		AND A.ReopenDate IS NULL 
		AND A.OrigCompDate IS NULL
		AND ISNULL(A.UserID, C.CAM) NOT IN ('Agonzale','Complian','RTREVINO','cbingham','Cisive','CVendor','AEnsming', '')
		AND A.Investigator IS NULL
	) as [End_Item_Inventory],
	(SELECT PendingStatus FROM #tempActivityStatusReport WHERE Userid ='AUTO') as [Closed By Automation]
INTO #tempBeginInventory		

--SELECT * FROM #tempBeginInventory

-- AI Inventory Report structure
SELECT [ReportDate],
	   [ItemType],
	   --AVG(Elapsed) as [Begin_Item_Inventory_Age],
	  --CAST([End_Item_Inventory] as decimal(7,2))/CAST([TotalCount] as decimal(7,2)) as [Begin_Item_Inventory_Age],
	  (SELECT CAST(AVG([dbo].[ElapsedBusinessHours_2](A.ApDate, getdate()) ) as decimal(7,2)) /CAST (24 as decimal(7,2))
		FROM dbo.Appl A with (nolock)  
		INNER JOIN dbo.Client C with (nolock)  ON A.CLNO = C.CLNO
		WHERE A.ApStatus in ('P','W') 
		AND A.ReopenDate IS NULL 
		AND A.OrigCompDate IS NULL
		AND ISNULL(A.UserID, C.CAM) NOT IN ('Agonzale','Complian','RTREVINO','cbingham','Cisive','CVendor','AEnsming', '')
		AND A.Investigator IS NULL) as [Begin_Item_Inventory_Age],
	   [Items_Input],
	   [Items_Output],
	   [End_Item_Inventory],
	   [Closed By Automation]
INTO #tempAI 
FROM #tempBeginInventory


--SELECT * FROM #tempAI


---- AI Inventory Report structure
--SELECT [ReportDate],[ItemType],(([End_Item_Inventory] + [Items_Output]) - [Items_Input]) as [Begin_Item_Inventory],
--	   [Begin_Item_Inventory_Age],[Items_Input],[Items_Output],[End_Item_Inventory],[Closed By Automation]
--FROM #tempAI 


-- Education Lead Data

CREATE TABLE #tempEducationReceived
(
	EducationReceived int
)

INSERT INTO #tempEducationReceived
EXEC dbo.[QReport_EducationVerificationsReceived] @StartDate,@EndDate

-- Closed Reports for Education
SELECT    
	  Count(A.APNO) as 'ClosedEducation'
INTO #tempClosedEducation
FROM dbo.Appl AS A(NOLOCK)  
INNER JOIN dbo.Educat AS E(NOLOCK) ON A.APNO =E.APNO AND E.IsHidden = 0 AND E.IsOnReport = 1
INNER JOIN dbo.SectStat AS S(NOLOCK) ON E.SectStat = S.CODE 
WHERE 
	A.OrigCompDate >= @StartDate 
AND A.OrigCompDate < DATEADD(DAY, 1, @EndDate)
AND E.SectStat NOT IN ( '9','0','H','R') 

-- Education Inventory Report structure
SELECT FORMAT(@StartDate, 'MM/dd/yyyy') as [ReportDate],
	'Education' as [ItemType],
	(SELECT AVG(Elapsed) FROM #tempOverdueStatusReport WHERE Educat_Count <> 0) as [Begin_Item_Inventory_Age],
	(SELECT EducationReceived FROM #tempEducationReceived) as [Items_Input],
	(SELECT ClosedEducation FROM #tempClosedEducation) as [Items_Output],
	(SELECT Sum(Educat_Count) FROM #tempOverdueStatusReport) as [End_Item_Inventory],
	0 as [Closed By Automation]
INTO #tempEducation


-- Education  Inventory Report structure
--SELECT [ReportDate],[ItemType],(([End_Item_Inventory] + [Items_Output]) - [Items_Input]) as [Begin_Item_Inventory],
--	   [Begin_Item_Inventory_Age],[Items_Input],[Items_Output],[End_Item_Inventory],[Closed By Automation]
--FROM #tempEducation 


-- Employment Lead Data
CREATE TABLE #tempEmploymentReceived
(
	EmploymentReceived int
)

INSERT INTO #tempEmploymentReceived
EXEC [dbo].[EmploymentVerificationsReceived] @StartDate,@EndDate


-- Closed Reports for Employment
SELECT 
	  COUNT(A.APNO) AS 'ClosedEmployment'	
INTO #tempClosedEmployment				
FROM dbo.Appl AS A(NOLOCK)
INNER JOIN dbo.Empl AS Em(NOLOCK) ON A.APNO = Em.APNO AND Em.IsHidden = 0 AND Em.IsOnReport = 1
INNER JOIN dbo.SectStat AS S(NOLOCK) ON Em.SectStat = S.CODE
WHERE 
		A.OrigCompDate >= @StartDate  
	AND A.OrigCompDate < DATEADD(DAY, 1, @EndDate)
	AND Em.SectStat NOT IN ( '9','0','H','R')	  

-- Employment Inventory Report structure
SELECT FORMAT(@StartDate, 'MM/dd/yyyy') as [ReportDate],
	'Employment' as [ItemType],
	(SELECT AVG(Elapsed) FROM #tempOverdueStatusReport WHERE Empl_Count <> 0) as [Begin_Item_Inventory_Age],
	(SELECT EmploymentReceived FROM #tempEmploymentReceived) as [Items_Input],
	(SELECT ClosedEmployment FROM #tempClosedEmployment) as [Items_Output],
	(SELECT Sum(Empl_Count) FROM #tempOverdueStatusReport) as [End_Item_Inventory],
	 0 as [Closed By Automation]
INTO #tempEmployment

-- Employment  Inventory Report structure
--SELECT [ReportDate],[ItemType],(([End_Item_Inventory] + [Items_Output]) - [Items_Input]) as [Begin_Item_Inventory],
--	   [Begin_Item_Inventory_Age],[Items_Input],[Items_Output],[End_Item_Inventory],[Closed By Automation]
--FROM #tempEmployment	

-- License Lead Data  
CREATE TABLE #tempLicenseReceived
(
	LicenseReceived int
)

INSERT INTO #tempLicenseReceived
EXEC [dbo].[QReport_LicenseVerificationReceived] @StartDate,@EndDate


-- Closed Reports for License
SELECT 
		COUNT(A.APNO) AS 'ClosedLicense'	
INTO #tempClosedLicense			
FROM dbo.Appl AS A(NOLOCK)
INNER JOIN dbo.Proflic AS P(NOLOCK) ON A.APNO = P.APNO AND P.IsHidden = 0 AND P.IsOnReport = 1
INNER JOIN dbo.SectStat AS S(NOLOCK) ON P.SectStat = S.CODE
WHERE 
	   A.OrigCompDate >= @StartDate  
	AND A.OrigCompDate < DATEADD(DAY, 1, @EndDate)
	AND P.SectStat NOT IN ( '9','0','H','R')	  

-- Closed by License Automation
SELECT IsInvestigator_Qualified = CASE WHEN Is_Investigator_Qualified = 0 THEN 'False' ELSE 'True' END,
		a.Apno as ReportNumber
INTO #tempClosedByAutomation
FROM dbo.Appl a (NOLOCK)
INNER JOIN dbo.Proflic pl (NOLOCK) ON a.APNO = pl.Apno AND pl.Ishidden = 0 AND pl.IsOnreport = 1 AND pl.SectStat = '9'
WHERE a.Apdate >= '01/01/2021'


-- License Inventory Report structure
SELECT FORMAT(@StartDate, 'MM/dd/yyyy') as [ReportDate],
	'License' as [ItemType],
	(SELECT AVG(Elapsed) FROM #tempOverdueStatusReport WHERE ProfLic_Count <> 0) as [Begin_Item_Inventory_Age],
	(SELECT LicenseReceived FROM #tempLicenseReceived) as [Items_Input],
	(SELECT ClosedLicense FROM #tempClosedLicense) as [Items_Output],
	(SELECT Sum(ProfLic_Count) FROM #tempOverdueStatusReport) as [End_Item_Inventory],
	(SELECT COUNT(ReportNumber) FROM #tempClosedByAutomation WHERE IsInvestigator_Qualified ='False') as [Closed By Automation]
INTO #tempLicense

-- License  Inventory Report structure
--SELECT [ReportDate],[ItemType],(([End_Item_Inventory] + [Items_Output]) - [Items_Input]) as [Begin_Item_Inventory],
--	   [Begin_Item_Inventory_Age],[Items_Input],[Items_Output],[End_Item_Inventory],[Closed By Automation]
--FROM #tempLicense	


-- SanctionCheck Lead Data  
CREATE TABLE #tempSanctionReceived
(
	SanctionReceived int
)

INSERT INTO #tempSanctionReceived
EXEC [dbo].[QReport_SanctionVerificationReceived] @StartDate,@EndDate


-- Closed Reports for Sanction
SELECT 
	  COUNT(A.APNO) AS 'ClosedSanction'
INTO #tempClosedSanction
FROM dbo.Appl AS A(NOLOCK)
INNER JOIN dbo.MedInteg AS M(NOLOCK) ON A.APNO = M.APNO AND M.IsHidden = 0
INNER JOIN dbo.SectStat AS S(NOLOCK) ON M.SectStat = S.CODE
WHERE 
	A.OrigCompDate >= @StartDate  
AND A.OrigCompDate < DATEADD(DAY, 1, @EndDate)
AND M.SectStat NOT IN ( '9','0','H','R')
	  

-- Sanction Inventory Report structure
SELECT FORMAT(@StartDate, 'MM/dd/yyyy') as [ReportDate],
	'Sanction' as [ItemType],
	(SELECT AVG(Elapsed) FROM #tempOverdueStatusReport WHERE MedInteg_Count <> 0) as [Begin_Item_Inventory_Age],
	(SELECT SanctionReceived FROM #tempSanctionReceived) as [Items_Input],
	(SELECT ClosedSanction FROM #tempClosedSanction) as [Items_Output],
	(SELECT Sum(MedInteg_Count) FROM #tempOverdueStatusReport) as [End_Item_Inventory],
	0 as [Closed By Automation]
INTO #tempSanction

-- Sanction  Inventory Report structure
--SELECT [ReportDate],[ItemType],(([End_Item_Inventory] + [Items_Output]) - [Items_Input]) as [Begin_Item_Inventory],
--	   [Begin_Item_Inventory_Age],[Items_Input],[Items_Output],[End_Item_Inventory],[Closed By Automation]
--FROM #tempSanction	


-- Reference Lead Data  
CREATE TABLE #tempReferenceReceived
(
	ReferenceReceived int
)

INSERT INTO #tempReferenceReceived
EXEC [dbo].[QReport_ReferenceVerificationReceived] @StartDate,@EndDate


-- Closed Reports for Reference
SELECT 
		COUNT(A.APNO) AS 'ClosedReference'
	INTO #tempClosedReference
	FROM dbo.Appl AS A(NOLOCK)
	INNER JOIN dbo.PersRef AS PR(NOLOCK) ON A.APNO = PR.APNO AND PR.IsHidden = 0 AND PR.IsOnReport = 1
	INNER JOIN dbo.SectStat AS S(NOLOCK) ON PR.SectStat = S.CODE
	WHERE 
		  A.OrigCompDate >= @StartDate  
	  AND A.OrigCompDate < DATEADD(DAY, 1, @EndDate)
	  AND PR.SectStat NOT IN ( '9','0','H','R')
	  

-- Reference Inventory Report structure
SELECT FORMAT(@StartDate, 'MM/dd/yyyy') as [ReportDate],
	'Reference' as [ItemType],
	(SELECT AVG(Elapsed) FROM #tempOverdueStatusReport WHERE PersRef_Count <> 0) as [Begin_Item_Inventory_Age],
	(SELECT ReferenceReceived FROM #tempReferenceReceived) as [Items_Input],
	(SELECT ClosedReference FROM #tempClosedReference) as [Items_Output],
	(SELECT Sum(PersRef_Count) FROM #tempOverdueStatusReport) as [End_Item_Inventory],
	0 as [Closed By Automation]
INTO #tempReference

-- Reference  Inventory Report structure
--SELECT [ReportDate],[ItemType],(([End_Item_Inventory] + [Items_Output]) - [Items_Input]) as [Begin_Item_Inventory],
--	   [Begin_Item_Inventory_Age],[Items_Input],[Items_Output],[End_Item_Inventory],[Closed By Automation]
--FROM #tempReference	


-- PublicRecord Lead Data
SELECT
	  COUNT(*) PublicRecordReceived
	INTO #tempPublicRecordReceived
FROM dbo.Crim C(NOLOCK)
WHERE C.ishidden = 0 
AND C.CrimEnteredTime >= @StartDate 
AND C.CrimEnteredTime < DATEADD(DAY, 1, @EndDate) 


-- Closed Reports for PublicRecord
CREATE TABLE #tempClosedPublicRecord
(
UserID varchar(20),
[Clear] int,
[Record_Found] int,
[More_Info_Needed] int,
[Ordered] int,
[Ready_To_Order] int,
[Transferred_Record] int,
[Needs_Research] int,
[Waiting] int,
[Error_Getting_Results] int,
[Error_Sending_Results] int,
[Ordering] int,
[Vendor_Reviewed] int,
[Alias_Name_Ordered] int,
[Needs_QA] int,
[Review_Reportability] int,
[Reinvestigations] int,
[Clear_Internal] int,
Cancelled_by_Client_Incomplete_Results int,
Cancelled_InternalError_Incomplete_Results int, SeeAttached int, Do_Not_ReReport int, Do_Not_Report int, Completed int
)

INSERT INTO #tempClosedPublicRecord
EXEC [dbo].[PublicRecordsReportSummaryDetails] @StartDate,@EndDate


CREATE TABLE #tempPublicRecordOutput
(
	Apno int,
	ApStatus varchar(1),
	UserID varchar(8),
	Investigator varchar(8),
	Apdate datetime,
	Last varchar(50),
	First varchar(50),
	Middle varchar(50),
	ReopenDate datetime,
	ClientName varchar(100),
	Affiliate varchar(50),
	AffiliateID int,
	Elapsed decimal,
	InProgressReviewed varchar(10),
	CrimCount int
)

INSERT INTO #tempPublicRecordOutput
EXEC [Public_Records_Overdue_Status_Report]

-- PublicRecord Inventory Report structure
SELECT FORMAT(@StartDate, 'MM/dd/yyyy') as [ReportDate],
	'PublicRecord' as [ItemType],
	(SELECT AVG(Elapsed) FROM #tempOverdueStatusReport WHERE Crim_Count <> 0) as [Begin_Item_Inventory_Age],
	(SELECT PublicRecordReceived FROM #tempPublicRecordReceived) as [Items_Input],
	(SELECT ([Clear] + [Record_Found] + [More_Info_Needed]) FROM #tempClosedPublicRecord WHERE Userid = 'Totals') as [Items_Output],
	(SELECT CrimCount FROM #tempPublicRecordOutput WHERE InProgressReviewed ='Total') as [End_Item_Inventory],
	 0 as [Closed By Automation]
INTO #tempPublicRecord

-- PublicRecord  Inventory Report structure
--SELECT [ReportDate],[ItemType],(([End_Item_Inventory] + [Items_Output]) - [Items_Input]) as [Begin_Item_Inventory],
--	   [Begin_Item_Inventory_Age],[Items_Input],[Items_Output],[End_Item_Inventory],[Closed By Automation]
--FROM #tempPublicRecord	


-- Quality Control Lead Data
CREATE TABLE #tempTotalCaseTBF
( 
	UserID varchar(20),
	TotalClosed int,
	TBF int
)
​
INSERT INTO #tempTotalCaseTBF
EXEC [dbo].[QualityControlLeadData_Schedule] @StartDate, @EndDate

CREATE TABLE #tempCAMActivityReportDetail
(
	APNO int,
	ElapsedDaysOnTBF INT,	--JA20210715 changed to Int 
	ElapsedHoursOnTBF INT	--JA20210715 changed to INT 
)
​
INSERT INTO #tempCAMActivityReportDetail
EXEC dbo.[QualityControlInventoryData_Schedule]

-- QualityControl Lead Data
SELECT FORMAT(@StartDate, 'MM/dd/yyyy') as [ReportDate],
	'QualityControl' as [ItemType],
	(SELECT AVG(ElapsedDaysOnTBF) FROM #tempCAMActivityReportDetail) as [Begin_Item_Inventory_Age],
	0 as [Items_Input],
	(SELECT Sum(TotalClosed) FROM #tempTotalCaseTBF ) as [Items_Output],
	(SELECT Sum(TBF) FROM #tempTotalCaseTBF) as [End_Item_Inventory],
	(SELECT Sum(TotalClosed) FROM #tempTotalCaseTBF WHERE UserID ='AUTO CLOSE') as [Closed By Automation]
INTO #tempQualityControl

-- Total Cases (Report Number) Data
SELECT FORMAT(@StartDate, 'MM/dd/yyyy') as [ReportDate],
	'TotalCases' as [ItemType],
	 (
		SELECT AVG(Elapsed) FROM #tempOverdueStatusReport 
			WHERE UserID NOT IN ('Agonzale','Complian','RTREVINO','cbingham','Cisive','CVendor','AEnsming', '')
	 ) as [Begin_Item_Inventory_Age],
	(
		SELECT COUNT(A.APNO) FROM dbo.Appl A(NOLOCK) 
		WHERE (a.Apdate >= @StartDate AND a.Apdate < DATEADD(DAY,1,@EndDate)) 
				AND UserID NOT IN ('Agonzale','Complian','RTREVINO','cbingham','Cisive','CVendor','AEnsming', '')
	) as [Items_Input],
	(
		SELECT COUNT(o.apno) FROM dbo.APPL o(NOLOCK) 
		WHERE (o.OrigCompDate >= @StartDate AND o.OrigCompDate < Dateadd(DAY,1,@EndDate))
				AND UserID NOT IN ('Agonzale','Complian','RTREVINO','cbingham','Cisive','CVendor','AEnsming', '')
	) as [Items_Output],
	(
		SELECT Count(APNO) FROM #tempOverdueStatusReport
		WHERE UserID NOT IN ('Agonzale','Complian','RTREVINO','cbingham','Cisive','CVendor','AEnsming', '')
	) as [End_Item_Inventory],
	0 as [Closed By Automation]
INTO #tempTotalCases

SELECT * INTO #tempInventory FROM
(
SELECT [ReportDate],[ItemType],(([End_Item_Inventory] + [Items_Output]) - [Items_Input]) as [Begin_Item_Inventory],
	   [Begin_Item_Inventory_Age],[Items_Input],[Items_Output],[End_Item_Inventory],[Closed By Automation]
FROM #tempAI

	UNION ALL

SELECT [ReportDate],[ItemType],(([End_Item_Inventory] + [Items_Output]) - [Items_Input]) as [Begin_Item_Inventory],
	   [Begin_Item_Inventory_Age],[Items_Input],[Items_Output],[End_Item_Inventory],[Closed By Automation]
FROM #tempEducation

	UNION ALL

SELECT [ReportDate],[ItemType],(([End_Item_Inventory] + [Items_Output]) - [Items_Input]) as [Begin_Item_Inventory],
	   [Begin_Item_Inventory_Age],[Items_Input],[Items_Output],[End_Item_Inventory],[Closed By Automation]
FROM #tempEmployment

	UNION ALL

SELECT [ReportDate],[ItemType],(([End_Item_Inventory] + [Items_Output]) - [Items_Input]) as [Begin_Item_Inventory],
	   [Begin_Item_Inventory_Age],[Items_Input],[Items_Output],[End_Item_Inventory],[Closed By Automation]
FROM #tempLicense

	UNION ALL

SELECT [ReportDate],[ItemType],(([End_Item_Inventory] + [Items_Output]) - [Items_Input]) as [Begin_Item_Inventory],
	   [Begin_Item_Inventory_Age],[Items_Input],[Items_Output],[End_Item_Inventory],[Closed By Automation]
FROM #tempSanction

	UNION ALL

SELECT [ReportDate],[ItemType],(([End_Item_Inventory] + [Items_Output]) - [Items_Input]) as [Begin_Item_Inventory],
	   [Begin_Item_Inventory_Age],[Items_Input],[Items_Output],[End_Item_Inventory],[Closed By Automation]
FROM #tempReference

	UNION ALL

SELECT [ReportDate],[ItemType],(([End_Item_Inventory] + [Items_Output]) - [Items_Input]) as [Begin_Item_Inventory],
	   [Begin_Item_Inventory_Age],[Items_Input],[Items_Output],[End_Item_Inventory],[Closed By Automation]
FROM #tempPublicRecord

	UNION ALL

SELECT [ReportDate],[ItemType],(([End_Item_Inventory] + [Items_Output]) - [Items_Input]) as [Begin_Item_Inventory],
	   [Begin_Item_Inventory_Age],[Items_Input],[Items_Output],[End_Item_Inventory],[Closed By Automation]
FROM #tempQualityControl

	UNION ALL

SELECT [ReportDate],[ItemType],(([End_Item_Inventory] + [Items_Output]) - [Items_Input]) as [Begin_Item_Inventory],
	   [Begin_Item_Inventory_Age],[Items_Input],[Items_Output],[End_Item_Inventory],[Closed By Automation]
FROM #tempTotalCases
) A

SELECT  
	 [ReportDate]
	,[ItemType]
	,[Begin_Item_Inventory]
	,[Begin_Item_Inventory_Age]
	,[Items_Input]
	,[Items_Output]
	,CASE 
		WHEN [Items_Output] = 0 THEN 0 
		ELSE ROUND(CAST([Begin_Item_Inventory] as FLoat)/CAST ([Items_Output] as FLoat), 4)  --JA20210808
	 END AS [Items_Output_TS]
	,[End_Item_Inventory]
	,[Closed By Automation]
FROM #tempInventory


END
