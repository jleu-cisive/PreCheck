
-- =============================================
-- Date: 05/07/2018
-- Author: Gaurav Bangia
-- Description: Function returns clinical rotation data for a given school, and reports
--SELECT * FROM [Enterprise].[StudentClinicRotation](3668,'172796,172798,172796,172836,172886')
--SELECT * FROM Enterprise.vwReportStatus WHERE OrderNumber IN (172796,172798,172796,172836,172886)
-- =============================================

CREATE FUNCTION [Enterprise].[StudentClinicRotation] 
(@SchoolClientId INT,
@ReportNumbers VARCHAR(MAX))

Returns @Result Table
(
	ReportNumber INT,
	StudentName VARCHAR(150),
	ProgramId INT null,
	ProgramName VARCHAR(50),
	IsReportAvailable BIT,
	HasBackground bit,
	BackgroundResult VARCHAR(100),
	HasDrugScreen BIT,
	DrugScreenResult VARCHAR(100),
	HasImmunization BIT,
	ImmunizationResult VARCHAR(100),
	AcceptCount INT,
	PreAdverseCount INT,
	AdverseCount INT,
	NoPositionCount INT,
	NotReviewCount INT
)

AS
BEGIN

INSERT INTO @Result
        ( ReportNumber, StudentName, ProgramId, ProgramName, IsReportAvailable,
			HasBackground , BackgroundResult, HasDrugScreen, DrugScreenResult, HasImmunization,  ImmunizationResult, 
			AcceptCount, PreAdverseCount, AdverseCount,NoPositionCount, NotReviewCount
		)
SELECT DISTINCT
	A.apno,
	CONCAT(a.First , ' ' ,  ISNULL(a.Middle + ' ','') , a.Last) AS StudentName,
	a.ClientProgramID,
	ProgramName=p.ProgramName,
	IsReportAvailable=CONVERT(BIT, 1),
	rs.HasBackground,
	rs.BackgroundResult,
	rs.HasDrugScreen,
	CASE WHEN ISNULL(rs.DrugScreenResult,'')='Negative' THEN 'C' ELSE '' END,
	rs.HasImmunization,
	rs.ImmunizationResult,
	ISNULL((SELECT ISNULL(TotalCount,0) FROM  [Enterprise].[GetReportRotationSummary](A.APNO,1)),0),
	ISNULL((SELECT ISNULL(TotalCount,0) FROM  [Enterprise].[GetReportRotationSummary](A.APNO,2)),0),
	ISNULL((SELECT ISNULL(TotalCount,0) FROM  [Enterprise].[GetReportRotationSummary](A.APNO,3)),0),
	ISNULL((SELECT ISNULL(TotalCount,0) FROM  [Enterprise].[GetReportRotationSummary](A.APNO,4)),0),
	ISNULL((SELECT ISNULL(TotalCount,0) FROM  [Enterprise].[GetReportRotationSummary](A.APNO,0)),0)
FROM dbo.Appl a 
	INNER JOIN Enterprise.vwReportStatus rs ON a.APNO=rs.OrderNumber 
	INNER JOIN dbo.Split(',',@ReportNumbers) sReports ON a.APNO =sReports.Item
	LEFT OUTER join Enterprise.PreCheck.vwClientProgram p ON a.ClientProgramID=p.ClientProgramId AND a.CLNO=p.ClientId
WHERE a.clno=@SchoolClientId

  RETURN
END



