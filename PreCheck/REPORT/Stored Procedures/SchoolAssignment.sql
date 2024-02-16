
-- ================================================
-- Author:		Dongmei He
-- Create date: 03/06/2020
-- Description:	School assigment to export to excel 
-- ================================================

-- [Report].[SchoolAssignment] 3668, 1, '2/18/2020', '5/18/2020', 42, -1, -1, '0', '0', '0'
-- [Report].[SchoolAssignment] 3668, 1, '2/18/2018', '5/18/2020', 0, -1, -1, 'S_3', 'R_1_1', 'S_3'
-- [Report].[SchoolAssignment] 5135, 1, '2/5/2006', '5/30/2020', 0, -1, -1, 'R_1', 'R_1_1', 'R_9'
-- [Report].[SchoolAssignment] 9613, 1, '2/5/2006', '5/30/2020', 0, -1, -1, 'R_1', 'R_1_1', 'R_9'
-- [Report].[SchoolAssignment] 14102, 1, '2/5/2006', '5/30/2020', 0, -1, -1, 'R_1', '0', 'R_9'
-- [Report].[SchoolAssignment] 6334, 1, '2/5/2006', '7/30/2020', 0, -1, -1, 'S_2', '0', '0'

 
CREATE PROCEDURE [REPORT].[SchoolAssignment]
	@ClientNumber INT,
	@ShowReportResult BIT = 0,
	@FromDate DATETIME,
	@ToDate DATETIME,
	@Program INT = null,
	@Clinic INT = null,
	@ClinicAction INT = null,
	@BackgroundResult Varchar(10) = null,
	@DrugScreenResult Varchar(10) = null,
	@ImmunizationResult Varchar(10) = null

AS
BEGIN
DECLARE @IsBResult BIT = 0
DECLARE @bResult INT = NULL
SELECT @bResult = CAST(value AS INT) FROM [dbo].[fn_Split](@BackgroundResult, '_') WHERE Idx = 1 AND ISNULL(@BackgroundResult, '0') != '0'
SELECT @IsBResult = IIF(value='R', 1, 0) FROM [dbo].[fn_Split](@BackgroundResult, '_') WHERE Idx = 0 AND ISNULL(@BackgroundResult, '0') != '0'

DECLARE @IsDResult BIT = 0
DECLARE @dResult INT = NULL

SELECT @dResult = value FROM [dbo].[fn_Split](@DrugScreenResult, '_') WHERE Idx = 2 AND ISNULL(@DrugScreenResult, 0) != '0'

IF @dResult is null  
BEGIN
SELECT @dResult = value FROM [dbo].[fn_Split](@DrugScreenResult, '_') WHERE Idx = 1 AND ISNULL(@DrugScreenResult, 0) != '0'
END
ELSE
BEGIN
SET @IsDResult = 1
END



DECLARE @IsIResult BIT = 0
DECLARE @iResult INT = NULL
SELECT @iResult = value FROM [dbo].[fn_Split](@ImmunizationResult, '_') WHERE Idx = 1 AND ISNULL(@ImmunizationResult, '0') != '0'
SELECT @IsIResult = IIF(value='R', 1, 0) FROM [dbo].[fn_Split](@ImmunizationResult, '_') WHERE Idx = 0  AND ISNULL(@ImmunizationResult, '0') != '0'
--SELECT value FROM [dbo].[fn_Split]('R_1_-1', '_') WHERE Idx = 0

if @BackgroundResult = '0' SET @IsBResult = 1
if @DrugScreenResult = '0' SET @IsDResult = 1
if @ImmunizationResult = '0' SET @IsIResult = 1

SELECT DISTINCT rs.OrderNumber AS [PreCheck Report Number],
       rs.Applicant_FirstName AS [First Name],
       rs.Applicant_LastName AS [Last Name],
       rs.ProgramName AS [Program],
       rs.OrderCreateDate AS [Order Date],
       ISNULL(ASA.ClinicName, 'Not Assigned') AS [Clinical Assigments],
       ISNULL(ASA.Status, 'Not Reviewed') AS [Action By Clinics],
       ASA.DateAssigned AS [Date Assigned],
       ASA.LastUpdateDate AS [Action Date],
       IIF(HasBackground = 1, IIF((@ShowReportResult = 1 AND @IsBResult = 1 AND ISNULL(c.ClientTypeID,0)<>6), BR.DisplayName, BS.DisplayName), 'Not Ordered') AS [Background Result],
       IIF(rs.HasDrugScreen = 1, IIF((@ShowReportResult = 1 AND @IsDResult = 1 AND ISNULL(c.ClientTypeID,0)<>6), DR.DisplayName, DS.DisplayName), 'Not Ordered') AS [DrugScreen Result],
       IIF(rs.HasImmunization = 1, IIF((@ShowReportResult = 1 AND @IsIResult = 1 AND ISNULL(c.ClientTypeID,0)<>6), IR.DisplayName, ISC.DisplayName), 'Not Ordered') AS [Immunization Result],
       OverallStatus = LS.DisplayName       
FROM REPORT.OrderSummary rs
	INNER JOIN dbo.Client C ON RS.ClientId=C.CLNO
    INNER JOIN REPORT.refOrderSummaryStatus LS
        ON rs.OrderStatusId = LS.OrderSummaryStatusId
    LEFT OUTER JOIN REPORT.refOrderSummaryStatus BS
        ON rs.BG_OrderStatusId = BS.OrderSummaryStatusId
    LEFT OUTER JOIN REPORT.refOrderSummaryStatus DS
        ON rs.DT_OrderStatusId = DS.OrderSummaryStatusId
    LEFT OUTER JOIN REPORT.refOrderSummaryStatus ISC
        ON rs.IM_OrderStatusId = ISC.OrderSummaryStatusId
    LEFT OUTER JOIN REPORT.refOrderSummaryResult BR
        ON rs.BG_ResultId = BR.OrderSummaryResultId --AND BRS.ServiceType='B'
    LEFT OUTER JOIN REPORT.refOrderSummaryResult DR
        ON rs.DT_ResultId = DR.OrderSummaryResultId --AND DRS.ServiceType='D'
    LEFT OUTER JOIN REPORT.refOrderSummaryResult IR
        ON rs.IM_ResultId = IR.OrderSummaryResultId --AND IRS.ServiceType='I'
    LEFT OUTER JOIN dbo.vwApplStudentAction ASA
        ON rs.OrderNumber = ASA.APNO
    LEFT OUTER JOIN dbo.refStudentAction RSA
	    ON ASA.Status = RSA.StudentAction
WHERE rs.ClientId = @ClientNumber
      AND rs.OrderCreateDate BETWEEN @FromDate AND @ToDate
      AND ISNULL(rs.ProgramId, 0) = IIF(ISNULL(@Program, 0) = 0, ISNULL(rs.ProgramId, 0), @Program)
	  AND ISNULL(ASA.ActionId, 0) = IIF(ISNULL(@ClinicAction, -1) = -1, ISNULL(ASA.ActionId, 0), @ClinicAction)
	  AND ISNULL(ASA.ClinicId, 0) = IIF(ISNULL(@Clinic, -1) = -1, ISNULL(ASA.ClinicId, 0), @Clinic)
      
	  AND ISNULL(RS.BG_OrderStatusId, 0) = IIF(ISNULL(@bResult,0)=0, ISNULL(RS.BG_OrderStatusId, 0), IIF(@IsBResult=1, ISNULL(RS.BG_OrderStatusId, 0), ISNULL(@bResult,0)))	
	  AND ISNULL(RS.BG_ResultId, 0) = IIF(ISNULL(@bResult,0)=0, ISNULL(RS.BG_ResultId, 0), IIF(@IsBResult=1, ISNULL(@bResult,0), ISNULL(RS.BG_ResultId, 0)))	
	  --AND RS.BG_ResultId = @bResult
	  --AND ISNULL(RS.BG_OrderStatusId, 0) = CASE WHEN 
	  
	  --/*
	  AND ISNULL(RS.DT_OrderStatusId, 0) = IIF(ISNULL(@dResult, 0)=0, ISNULL(RS.DT_OrderStatusId, 0), IIF(@IsDResult=1, ISNULL(RS.DT_OrderStatusId, 0), ISNULL(@dResult, 0)))
	  --AND ISNULL(RS.DT_ResultId, 0) in (IIF(ISNULL(@dResult, 0)=0, ISNULL(RS.DT_ResultId, 0), IIF(ISNULL(@dResult, 0)=1, IIF(ISNULL(@dResult, 0)=1, '3', '4,5,6'), ISNULL(RS.DT_ResultId, 0))))
	  AND ISNULL(DR.ResultGroup, 0) = IIF(ISNULL(@dResult, 0)=0, ISNULL(DR.ResultGroup, 0), IIF(@IsDResult=1, ISNULL(@dResult, 0), ISNULL(DR.ResultGroup, 0)))
 
	  AND ISNULL(RS.IM_OrderStatusId, 0) = IIF(ISNULL(@iResult, 0)=0, ISNULL(RS.IM_OrderStatusId, 0), IIF(@IsIResult=1, ISNULL(RS.IM_OrderStatusId, 0), ISNULL(@iResult, 0)))
	  AND ISNULL(RS.IM_ResultId, 0) = IIF(ISNULL(@iResult, 0)=0, ISNULL(RS.IM_ResultId, 0), IIF(@IsIResult=1, ISNULL(@iResult, 0), ISNULL(RS.IM_ResultId, 0)))					  
	 --*/
	  
	
ORDER BY RS.OrderCreateDate

		 
END