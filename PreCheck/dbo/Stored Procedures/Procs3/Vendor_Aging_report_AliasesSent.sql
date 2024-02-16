-- Alter Procedure Vendor_Aging_report_AliasesSent
-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 05/08/2017
-- Description:	Vendor Aging Report 
-- Execution : EXEC [dbo].[Vendor_Aging_report_AliasesSent]
-- =============================================
--EXEC Vendor_Aging_Report 
CREATE PROCEDURE [dbo].[Vendor_Aging_report_AliasesSent]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @StartDate datetime
	DECLARE @EndDate datetime

	SET @EndDate = GETDATE()
	SET @StartDate = DATEADD(day, -30, GetDate())

--Step 1: 

	CREATE TABLE #tempAverage (Average decimal, CNTY_NO int, VendorID int)
	INSERT INTO #tempAverage
	SELECT ROUND((AVG(CONVERT(NUMERIC(7,2), (dbo.GETBUSINESSDAYS(C.IRISORDERED,C.LAST_UPDATED) + ((CASE WHEN DATEDIFF(HH,C.IRISORDERED,C.LAST_UPDATED) < 24 THEN DATEDIFF(HH,C.IRISORDERED,C.LAST_UPDATED) ELSE 0 END)/24.0)))) * 24),0) AS AVERAGE,
			C.CNTY_NO, C.VENDORID
	FROM   CRIM C  WITH (NOLOCK) 
	INNER JOIN dbo.TblCounties CC  WITH (NOLOCK) ON C.CNTY_NO = CC.CNTY_NO
	WHERE C.IRISORDERED IS NOT NULL 
	  AND C.LAST_UPDATED IS NOT NULL 
	  AND IRISORDERED BETWEEN CONVERT(DATE,  CONVERT(VARCHAR(20), @STARTDATE, 103), 103) AND  CONVERT(DATE, CONVERT(VARCHAR(20), @ENDDATE, 103), 103)
	GROUP BY C.CNTY_NO, VENDORID


	--Step 2: 

	CREATE TABLE #tempVendorAging (CrimID int, APNO int, OrderedDate datetime,Vendor varchar(50), Apdate datetime, PC_Time_Stamp datetime, OrderReceivedDate datetime, 
									LastName varchar(50), MiddleName varchar(50), FirstName varchar(50),CNTY_NO int, County varchar(100), --NamesSent varchar(max),
									Elapsed smallint, AgingVendor smallint, ApplicationElapsed smallint, AverageTAT30Days decimal)
	CREATE CLUSTERED INDEX IX_Aging_tmp_01 ON #tempVendorAging(APNO,CrimID)

	INSERT INTO #tempVendorAging
	SELECT  dbo.Crim.CrimID, dbo.Crim.APNO, dbo.Crim.Ordered, dbo.Iris_Researchers.R_Name AS vendor,   --- Removed the Top 100 percent since the query is taking longer than 15mins RD on 06/14/2017
			dbo.Appl.ApDate, dbo.Appl.PC_Time_Stamp,  dbo.Crim.Crimenteredtime as 'Order Received Date', 
			dbo.Appl.[Last], dbo.Appl.Middle, dbo.Appl.[First], 
			dbo.Crim.CNTY_NO, dbo.Counties.A_County + ' , ' + dbo.Counties.State AS county, --dbo.Crim.Priv_notes as NamesSent,
			CONVERT(numeric(7, 2), dbo.ElapsedBusinessDays(convert(datetime,dbo.Crim.Crimenteredtime,1), GETDATE())) AS Elapsed, 
			CONVERT(numeric(7, 2), dbo.ElapsedBusinessDays(convert(varchar(16),dbo.Crim.Ordered,1), GETDATE())) AS 'Aging Vendor', 
			CONVERT(numeric(7, 2), dbo.ElapsedBusinessDays(convert(datetime,dbo.Appl.PC_Time_Stamp,1), GETDATE())) AS 'Application Elapsed', 					  
						  isnull(CONVERT(DECIMAL(10,2),p.average/24), 0) as AverageTAT30Days                      
	FROM dbo.Iris_Researcher_Avg_Turnaround WITH (NOLOCK) 
	RIGHT JOIN dbo.Iris_Researchers WITH (NOLOCK) ON dbo.Iris_Researcher_Avg_Turnaround.R_ID = dbo.Iris_Researchers.R_id 
	RIGHT OUTER JOIN dbo.Appl WITH (NOLOCK) 
	INNER JOIN dbo.Crim WITH (NOLOCK) ON dbo.Appl.APNO = dbo.Crim.APNO 
	INNER JOIN dbo.Counties WITH (NOLOCK) ON dbo.Crim.CNTY_NO = dbo.Counties.CNTY_NO
	LEFT JOIN #tempAverage P ON P.CNTY_NO = dbo.Counties.CNTY_NO
	LEFT OUTER JOIN dbo.Client WITH (NOLOCK) ON dbo.Appl.CLNO = dbo.Client.CLNO 
	LEFT OUTER JOIN dbo.Iris_Researcher_Charges WITH (NOLOCK) ON dbo.Crim.CNTY_NO = dbo.Iris_Researcher_Charges.cnty_no AND 
	dbo.Crim.vendorid = dbo.Iris_Researcher_Charges.Researcher_id ON dbo.Iris_Researchers.R_id = dbo.Crim.vendorid
	WHERE (dbo.Crim.IRIS_REC = 'yes') 
	  AND (dbo.Crim.Clear in ('O','W')) 
	  AND (dbo.Appl.ApStatus <> 'M') 
	  AND (dbo.Iris_Researcher_Charges.RESEARCHER_DEFAULT = 'YES')
	  AND ((P.VENDORID IS NULL AND dbo.Iris_Researcher_Charges.RESEARCHER_ID IS NOT NULL) 
		OR (P.VENDORID = dbo.Iris_Researcher_Charges.RESEARCHER_ID))
	GROUP BY dbo.Crim.status, dbo.Crim.Ordered, dbo.Crim.CNTY_NO, 
			dbo.Counties.A_County, dbo.Counties.State, dbo.Crim.Priv_Notes, dbo.Crim.APNO, 
			dbo.Iris_Researchers.R_Name, dbo.Appl.[Last], dbo.Appl.Middle,
			dbo.Appl.[First], dbo.Crim.Crimenteredtime, dbo.Appl.ApDate,
			Appl.ApStatus,dbo.Crim.batchnumber, dbo.Appl.PC_Time_Stamp, p.AVERAGE, dbo.Crim.CrimID					
	HAVING   (dbo.Appl.ApStatus = 'p' OR dbo.Appl.ApStatus = 'w')
			 AND (NOT (dbo.Crim.batchnumber IS NULL))
	ORDER BY dbo.Crim.Ordered desc

	--SELECT * FROM #tempVendorAging

----------------------GATHERING ALIASES SENT--------------------------
----------------------Larry Ouch 06/29/2017---------------------------

	-- Temp table to hold values that are sent out.
	CREATE TABLE #tmpCrimsSentToVendor([ApplAliasID] [int], [APNO] [int],[First] [varchar](50),[Middle] [varchar](50), [Last] [varchar](50), [IsMaiden] [bit], [Generation] [varchar](15), 
										[IsPublicRecordQualified] [bit],[IsPrimaryName] [bit],[ApplAlias_IsActive] [bit], [AddedBy] [varchar](25), [CrimID][int] null)

	CREATE CLUSTERED INDEX IX_Aging_tmp_02 ON #tmpCrimsSentToVendor([ApplAliasID],APNO)

	CREATE TABLE #tmpCrims([ApplAliasID] [int], [APNO] [int],[First] [varchar](50),[Middle] [varchar](50), [Last] [varchar](50), [IsMaiden] [bit], [Generation] [varchar](15), 
											[IsPublicRecordQualified] [bit],[IsPrimaryName] [bit],[ApplAlias_IsActive] [bit], [AddedBy] [varchar](25))

	CREATE CLUSTERED INDEX IX_Aging_tmp_03 ON #tmpCrims([ApplAliasID],APNO)

	-- Get all the Crims for the parameter [Status]
	SELECT ROW_NUMBER() OVER(ORDER BY CrimID DESC) AS CrimRowNumber, CrimID, APNO
		INTO #tmpCrimsForStatus 
	FROM #tempVendorAging(NOLOCK)

	--SELECT * FROM #tmpCrimsForStatus ORDER BY CrimRowNumber

	DECLARE @TotalNumberOfCrimRecords int = (SELECT MAX(CrimRowNumber)FROM #tmpCrimsForStatus);
	DECLARE @CrimRecordRow int;
	DECLARE @Apno int;
	DECLARE @CrimID int;
	DECLARE @DeliveryMethod varchar(50)
	DECLARE @LastCrimID int

	-- Get the true names that were actually sent out to vendors
	WHILE (@TotalNumberOfCrimRecords != 0)
	BEGIN	
			SELECT @CrimRecordRow = CrimRowNumber, @Apno = Apno, @CrimID = CrimID
			FROM #tmpCrimsForStatus
			WHERE CrimRowNumber = @TotalNumberOfCrimRecords
			ORDER BY CrimRowNumber DESC		

			-- Get True names by CrimID
			INSERT INTO #tmpCrims EXEC [dbo].[Crim_GetAliasesToSend] @CrimID
			-- SELECT * FROM #tmpCrims

			INSERT INTO #tmpCrimsSentToVendor ([ApplAliasID] , [APNO] ,[First] ,[Middle] , [Last], [IsMaiden], [Generation], [IsPublicRecordQualified],[IsPrimaryName],[ApplAlias_IsActive], [AddedBy], [CrimID])  
			SELECT *, @CrimID from #tmpCrims

			-- Delete all the values from this table such that the Insert doesn't repeat same values 
			DELETE FROM #tmpCrims
			
			-- SET the counter to -1
			SET @TotalNumberOfCrimRecords = @CrimRecordRow - 1

	END
	
	--SELECT * FROM #tmpCrimsSentToVendor

	SELECT DISTINCT T.*, ISNULL(AliasCount,0) AliasCount
		INTO #tmpAliasCount
	FROM #tmpCrimsSentToVendor AS T
	INNER JOIN (SELECT DISTINCT CrimID, APNO, COUNT(1) AS AliasCount FROM #tmpCrimsSentToVendor(NOLOCK) GROUP BY CrimID, APNO) AS Y ON T.APNO = Y.APNO AND T.CrimID = Y.CrimID

	--SELECT '#tmpAliasCount' TableName, * FROM #tmpAliasCount

	SELECT	CrimID, APNO, ISNULL([Last],'') AS [Last], ISNULL([First],'') AS [First], ISNULL(Middle,'') AS Middle, ISNULL(Generation,'') AS Generation , 
			ISNULL(Last,'') +' '+ ISNULL(First,'') +' '+ ISNULL(Middle,'') +' '+ ISNULL(Generation,'') AS QualifiedNames, ISNULL(AliasCount,0) AliasCount
		INTO #tmpAliasesSentToVendor
	FROM #tmpAliasCount
	--WHERE IsPrimaryName = 0

	--SELECT '#tmpAliasesSentToVendor' TableName, * FROM #tmpAliasesSentToVendor

	SELECT  CrimID, APNO,
			ISNULL([Last],'') AS [Last], 
			ISNULL([First],'') AS [First], 
			ISNULL(Middle,'') AS Middle, 
			ISNULL(Generation,'') AS Generation ,
			ISNULL(AliasCount,0) AliasCount,
			AliasesSentToVendor = STUFF((SELECT '/ ' + QualifiedNames
										FROM #tmpAliasesSentToVendor b 
										WHERE b.CrimID = a.CrimID 
										FOR XML PATH('')), 1, 2, '') 
		INTO #tmpSelectedAliases
	FROM #tmpAliasesSentToVendor A
	GROUP BY CrimID,APNO, Last, First, Middle, Generation, AliasCount
	ORDER BY APNO

	--SELECT '#tmpSelectedAliases' TableName, * FROM #tmpSelectedAliases

--------------------------------------------------------------------

Select DISTINCT TVA.APNO, TVA.Vendor , TVA.Apdate , TVA.OrderReceivedDate , TVA.LastName , TVA.MiddleName , TVA.FirstName , TVA.County , AliasesSentToVendor AS NamesSent, TVA.Elapsed, TVA.AgingVendor,TVA.AverageTAT30Days ,
	   CAST(ROUND(( AgingVendor/Case When FLOOR(AverageTAT30Days) = 0 then 1 Else FLOOR(AverageTAT30Days) END), 1) as Decimal(12,2)) as 'Weighted TAT AVG' 
from #tempVendorAging TVA (nolock)
INNER JOIN #tmpSelectedAliases TNS (nolock) on TVA.CrimID = TNS.CrimID

--Select *,
--CAST(ROUND(( AgingVendor/Case When FLOOR(AverageTAT30Days) = 0 then 1 Else FLOOR(AverageTAT30Days) END), 1) as Decimal(12,2)) as 'Weighted TAT AVG' 
--from #tempVendorAging TVA (nolock)
--INNER JOIN #tmpSelectedAliases TNS (nolock) on TVA.CrimID = TNS.CrimID


DROP TABLE #tempAverage
DROP TABLE #tempVendorAging
DROP TABLE #tmpSelectedAliases
DROP TABLE #tmpAliasCount
DROP TABLE #tmpCrimsSentToVendor
DROP TABLE #tmpCrims
DROP TABLE #tmpCrimsForStatus
DROP TABLE #tmpAliasesSentToVendor


END
