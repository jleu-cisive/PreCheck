-- =============================================
-- Created By: Dongmei He
-- Date: 01/31/2020
-- Description: Get report
-- Modify By:	Joshua Ates
-- Modify Date: 3/8/2021
-- Modified By: Prasanna on 4/7/2021 for HDT#86776 Applicant cannot open background report
-- Modification Description: Removed where clause select statement and made it into a left join.
-- Added inner join to Appl Table and "AND a.UserID <> 'CVendor'" to the where clause
--EXEC [Report].[GetReport] null, '1/1/1980', '4516937'
--EXEC [Report].[GetReport] '514-02-7756', '12/07/1984', null --3966877
--EXEC [Report].[GetReport] '595-40-8604', '2/16/1970', null

-- Modify By:	Gaurav Bangia
-- Modify Date: 12/9/2021
-- Purpose: Perf Optimization
-- Modified by Lalit on 31-august-2022 to change logic so that all 3 fields are required.
-- =============================================

CREATE PROCEDURE [Report].[GetReport]
	@SSN VARCHAR(11),
	@DOB DATETIME,
	@APNO INT = NULL
AS

	DECLARE @dobfix DATETIME
	SET @dobfix = CAST(@DOB AS DATE)


	DROP TABLE IF EXISTS #vwReportStatus

	CREATE TABLE #vwReportStatus (OrderNumber INT,
								  OrderDate DATETIME,
								  ApplicantName VARCHAR(150),
								  BackgroundStatus VARCHAR(50),
								  HasBackground BIT,
								  DrugScreenStatus VARCHAR(50),
								  HasDrugScreen BIT,
								  DrugtestReportID INT);


	INSERT INTO #vwReportStatus

	SELECT OrderNumber = a.APNO,
		   a.ApDate,
		   ApplicantName = CONCAT(a.Last, ', ', a.First),
		   BackgroundStatus = CASE
										   WHEN ISNULL(O.HasBackground, 1) = 1 THEN ISNULL(a.ApStatus, 'P')
										   ELSE NULL END,
		   HasBackground = ISNULL(CAST(CASE
						 WHEN O.HasBackground IS NOT NULL THEN O.HasBackground
						 WHEN FS.FlagStatus IS NULL THEN 0 END AS BIT), 1),
		   DrugScreenStatus = CASE
										   -- if status is completed - return result
										   WHEN (M.PreCheckOrderStatus IS NULL
											  AND (ISNULL(d.OrderStatus, d1.OrderStatus) LIKE 'Completed%')) THEN ISNULL(d.TestResult, d1.TestResult)
										   WHEN ISNULL(O.HasDrugScreen, 0) = 1 THEN 'In Progress'
										   -- if drug test was ordered but not completed - return 'InProgress'
										   ELSE 'Not Ordered' END,
		   HasDrugScreen = ISNULL(CAST(CASE
						 WHEN ISNULL(d.TID, d1.TID) IS NOT NULL THEN CONVERT(BIT, 1)
						 WHEN O.HasDrugScreen IS NULL
						   AND CI.OCHS_CandidateInfoID IS NOT NULL THEN CONVERT(BIT, 1)
						 WHEN O.HasDrugScreen IS NOT NULL THEN O.HasDrugScreen END AS BIT), 0),
		   DrugTestReportId = ISNULL(d.TID, d1.TID)

	  FROM dbo.Appl a WITH (NOLOCK)

	  LEFT OUTER JOIN (SELECT HasBackground,
							  HasDrugScreen,
							  OrderNumber FROM Enterprise..vwApplicantOrder WITH (NOLOCK)) O
		ON a.APNO = O.OrderNumber

	  LEFT OUTER JOIN dbo.ApplFlagStatus FS WITH (NOLOCK)
		ON a.APNO = FS.APNO
	  LEFT OUTER JOIN dbo.OCHS_CandidateInfo CI WITH (NOLOCK)
		ON a.APNO = CI.APNO
	   AND a.CLNO = CI.CLNO
	  LEFT OUTER JOIN dbo.vwDrugResultCurrent d WITH (NOLOCK)
		ON CONVERT(VARCHAR(25), a.APNO) = d.OrderIDOrApno
	  LEFT OUTER JOIN dbo.vwDrugResultCurrent d1 WITH (NOLOCK)
		ON CONVERT(VARCHAR(25), CI.OCHS_CandidateInfoID) = d1.OrderIDOrApno
	  LEFT OUTER JOIN [Enterprise].[vwServiceStatusMap] M WITH (NOLOCK)
		ON M.VendorTestResult = d.TestResult
	   AND M.VendorOrderStatus = d.OrderStatus

	 WHERE a.APNO = ISNULL(@APNO, '')
	   AND a.DOB = CAST(@DOB AS DATE)
	   AND ISNULL(a.UserID, '') <> 'CVendor'
	   AND (a.SSN = @SSN
		  OR (ISNULL(a.SSN, '') = ''
			 AND (SUBSTRING(LTRIM(a.I94), 1, 11) = @SSN
				AND LEN(@SSN) > 3)
			 OR (SUBSTRING(LTRIM(a.I94), 1, 11) = @SSN
				AND SUBSTRING(LTRIM(a.I94), 1, 11) IN ('N/A', 'NA'))))
	   AND LEN(@SSN) > 1
	   AND DATEDIFF(YEAR, ISNULL(a.CreatedDate, '1/1/1900'), GETDATE()) <= 7


	SELECT rs.OrderNumber,
		   rs.OrderDate,
		   rs.ApplicantName,
		   rs.BackgroundStatus,
		   br.BackgroundReportID,
		   rs.HasBackground,
		   rs.DrugScreenStatus,
		   dr.TID AS DrugtestReportID,
		   rs.HasDrugScreen

	  FROM #vwReportStatus rs
	  LEFT JOIN (SELECT APNO,
						MAX(BackgroundReportID) BackgroundReportID FROM BackgroundReports..BackgroundReport WITH (NOLOCK)
		   GROUP BY APNO) MaxBackgroundReportID
		ON MaxBackgroundReportID.APNO = rs.OrderNumber
	  LEFT JOIN BackgroundReports..BackgroundReport br WITH (NOLOCK)
		ON br.BackgroundReportID = MaxBackgroundReportID.BackgroundReportID
	  LEFT JOIN (SELECT TID,
						MAX(ID) ID FROM OCHS_PDFReports WITH (NOLOCK)
		   GROUP BY TID) MaxOCHS_PDFReportsID
		ON MaxOCHS_PDFReportsID.TID = rs.DrugtestReportID
	  LEFT JOIN OCHS_PDFReports dr WITH (NOLOCK)
		ON dr.ID = MaxOCHS_PDFReportsID.ID