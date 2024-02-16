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
-- =============================================

CREATE PROCEDURE [REPORT].[GetReport_X]
	@SSN VARCHAR(11),
	@DOB DATETIME,
	@APNO INT = null
AS


SET @SSN = REPLACE(@SSN, '-', '')
IF @SSN = '' SET @SSN = null

DROP TABLE IF EXISTS #vwReportStatus

CREATE TABLE  #vwReportStatus (
    OrderNumber INT, 
    OrderDate DATETIME,
    ApplicantName VARCHAR(150),
    BackgroundStatus VARCHAR(50),
    HasBackground BIT,
    DrugScreenStatus VARCHAR(50),
    HasDrugScreen BIT,
	DrugtestReportID INT
);

INSERT INTO #vwReportStatus

SELECT  
	rs.OrderNumber, 
    rs.Apdate,
    rs.ApplicantName,
    rs.BackgroundStatus,              
    rs.HasBackground,
    CASE 
		WHEN len(rs.DrugScreenResult)>0 THEN rs.DrugScreenResult
		ELSE IIF(rs.DrugScreenStatus ='P', 'In Progress', IIF(rs.HasDrugScreen = 1, 'Status Not Available', 'Not Ordered')) 
	END AS DrugScreenStatus,
    rs.HasDrugScreen,
	rs.DrugTestReportId
FROM 
	Enterprise.[vwReportStatus] rs 
INNER JOIN 
	dbo.Appl a 
	ON rs.OrderNumber=a.Apno
WHERE 
	rs.SSN = ISNULL(@SSN, rs.SSN)
AND rs.OrderNumber = ISNULL(@APNO, rs.OrderNumber)
AND rs.DateOfBirth  = cast(@DOB as date)
AND ISNULL(a.UserID,'') <> 'CVendor'

SELECT 
	rs.OrderNumber, 
    rs.OrderDate,
    rs.ApplicantName,
    rs.BackgroundStatus,
    br.BackgroundReportID,
    rs.HasBackground,
    rs.DrugScreenStatus,
    dr.TID AS DrugtestReportID,
    rs.HasDrugScreen    
FROM #vwReportStatus rs
LEFT JOIN
	(
		SELECT 
			 APNO
			,MAX(BackgroundReportID) BackgroundReportID
           FROM BackgroundReports..BackgroundReport
		GROUP BY
			APNO
	) MaxBackgroundReportID
	ON Apno = rs.OrderNumber
LEFT JOIN 
	BackgroundReports..BackgroundReport br
    ON br.BackgroundReportID = MaxBackgroundReportID.BackgroundReportID
LEFT JOIN 
	OCHS_PDFReports dr 
	ON rs.DrugtestReportID = dr.TID					