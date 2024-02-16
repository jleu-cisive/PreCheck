/*************************************************************
-- Author:		Gaurav Bangia
-- Create date: 03/18/2022
-- Description:	Table function to return list of school reports
   DEMO ACCOUNT - LOW VOLUME - 90 DAYS
  SELECT * FROM  [Enterprise].[ListSchoolOrders_New](3668, '12/19/2021', '3/30/2022', NULL, NULL, NULL, NULL, NULL, NULL)
   HIGH VOLUME ACCOUNT - 90 DAYS
  SELECT * FROM  [Enterprise].[ListSchoolOrders_New](3668, '1/1/2022', '3/30/2022', NULL, NULL, NULL, NULL, NULL, NULL)
**************************************************************/
CREATE FUNCTION [Enterprise].[ListSchoolOrders_New]
(
	@SchoolId int NULL,
	@FromDate datetime NULL,
	@EndDate datetime NULL,
	@ReportStatus VARCHAR(1) NULL,
	@ApplicantFirstName varchar(50) NULL,
	@ApplicantLastName varchar(50) NULL,
	@ApplicantDOB DATE NULL,
	-- last 4 digits
	@ApplicantSocial VARCHAR(4) NULL,
	@ReportNumber INT null
)
RETURNS 
@Result TABLE 
(
	-- Add the column definitions for the TABLE variable here
	APNO INT,
	SSN VARCHAR(12),
	DOB DATE,
	First VARCHAR(50),
	Last VARCHAR(50),
	Middle VARCHAR(50),
	Email VARCHAR(500),
	CLNO INT,
	ClientName VARCHAR(100),
	ClientProgramId INT,
	ProgramName VARCHAR(50),
	AppCreatedDate DATETIME,
	ApDate DATETIME NULL,
	HasBackground BIT,
	HasDrugScreen BIT,
	HasImmunization BIT,
	BGOrderStatus VARCHAR(1),
	FlagStatusId INT NULL,
	FlagStatus VARCHAR(50),
	DSScreeningType VARCHAR(25) NULL,
	DSReasonForTest VARCHAR(25) NULL,
	DrugScreenStatus VARCHAR(1) NULL,
	DrugScreenResult VARCHAR(25) NULL,
	ImmOrderStatus VARCHAR(1),
	ImmResult VARCHAR(25)
)
AS
BEGIN
	INSERT INTO @Result(APNO, SSN, DOB, First, Last, Middle, Email, CLNO, ClientName, ClientProgramId, ProgramName, 
	AppCreatedDate, ApDate, HasBackground, HasDrugScreen, HasImmunization, BGOrderStatus, FlagStatusId, FlagStatus, 
	DSScreeningType, DSReasonForTest, DrugScreenStatus, DrugScreenResult, 
	ImmOrderStatus, ImmResult)
	SELECT
	A.OrderNumber,
	A.Applicant_UID,
	Alt.DOB,
	A.Applicant_FirstName,
	A.Applicant_LastName,
	A.Applicant_MiddleName,
	Alt.Email,
	A.ClientId,
	C.Name,
	A.ProgramId,
	a.ProgramName,
	A.OrderCreateDate,
	A.ApDate,
	A.HasBackground,
	A.HasDrugScreen,
	A.HasImmunization,
	BS.StatusCode,
	LS.OrderSummaryStatusId,
	LS.DisplayName,
	'', --Screening type missing
	'', -- ReasonForTest missing
	DS.StatusCode,
	DR.ResultCode,
	ISC.StatusCode,
	IR.ResultCode
    FROM 
	
	Report.OrderSummary A
	INNER JOIN dbo.Appl Alt ON a.OrderNumber=alt.APNO
	INNER JOIN dbo.Client C ON C.CLNO = A.ClientId
  INNER JOIN REPORT.refOrderSummaryStatus LS
        ON A.OrderStatusId = LS.OrderSummaryStatusId
    LEFT OUTER JOIN REPORT.refOrderSummaryStatus BS
        ON A.BG_OrderStatusId = BS.OrderSummaryStatusId
    LEFT OUTER JOIN REPORT.refOrderSummaryStatus DS
        ON A.DT_OrderStatusId = DS.OrderSummaryStatusId
    LEFT OUTER JOIN REPORT.refOrderSummaryStatus ISC
        ON A.IM_OrderStatusId = ISC.OrderSummaryStatusId
    LEFT OUTER JOIN REPORT.refOrderSummaryResult BR
        ON A.BG_ResultId = BR.OrderSummaryResultId --AND BRS.ServiceType='B'
    LEFT OUTER JOIN REPORT.refOrderSummaryResult DR
        ON A.DT_ResultId = DR.OrderSummaryResultId --AND DRS.ServiceType='D'
    LEFT OUTER JOIN REPORT.refOrderSummaryResult IR
        ON A.IM_ResultId = IR.OrderSummaryResultId --AND IRS.ServiceType='I'
	WHERE 
	a.ClientId = COALESCE(@SchoolId, a.ClientId)
	AND A.OrderCreateDate BETWEEN COALESCE(@FromDate,a.OrderCreateDate) AND COALESCE(@EndDate,a.OrderCreateDate)
	AND A.BG_OrderStatus = CAST(COALESCE(@ReportStatus, A.BG_OrderStatus) AS CHAR(1))
	AND a.Applicant_FirstName = COALESCE(@ApplicantFirstName, a.Applicant_FirstName)
	AND a.Applicant_LastName = COALESCE(@ApplicantLastName, a.Applicant_LastName)
	AND a.OrderNumber  = COALESCE(@ReportNumber, a.OrderNumber)
	
	IF(@ApplicantSocial IS NOT NULL)
		DELETE FROM @Result WHERE SUBSTRING(SSN, LEN(SSN)-4,4) <> @ApplicantSocial
	IF(@ApplicantDOB IS NOT NULL)
		DELETE FROM @Result WHERE DOB <> @ApplicantDOB
	RETURN 
END
