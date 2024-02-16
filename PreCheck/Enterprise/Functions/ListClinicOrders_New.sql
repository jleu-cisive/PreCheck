/*********************************************************************
-- Author:		Gaurav Bangia
-- Create date: 03/18/2022
-- Description:	Table function to return list of reports for the clinic
   DEMO ACCOUNT - LOW VOLUME - 90 DAYS
  SELECT * FROM  Enterprise.ListClinicOrders(9282, '1/1/2022', '3/30/2022', NULL, NULL, NULL, NULL, NULL, NULL)
   HIGH VOLUME ACCOUNT - 90 DAYS
  SELECT * FROM  Enterprise.ListClinicOrders(3665, '1/1/2022', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
*************************************************************************/
CREATE FUNCTION [Enterprise].[ListClinicOrders_New]
(
	@ClinicId int NULL,
	@FromDate datetime NULL,
	@EndDate datetime NULL,
	@IsActionPending bit NULL,
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
	
	--Rotation and status
	ApplStudentActionId INT,
	StudentActionId INT,
	DateHospitalAssigned DATETIME NULL,
	DateStatusSet DATETIME NULL,
	AdverseStatusId INT NULL,
	DateAdverseStarted DATETIME NULL,
	AdverseStatusDescription VARCHAR(50),
	HospitalId INT,

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
	ImmResult VARCHAR(25),
	ActionPending BIT,
	ActionComplete BIT,
	ActionAdverse bit
)
AS
BEGIN
	INSERT INTO @Result(APNO, SSN, DOB, First, Last, Middle, Email, CLNO, ClientName, ClientProgramId, ProgramName, AppCreatedDate, ApDate, 
	ApplStudentActionId, StudentActionId, DateHospitalAssigned, DateStatusSet, 
	AdverseStatusId, DateAdverseStarted, AdverseStatusDescription, HospitalId, 
	HasBackground, HasDrugScreen, HasImmunization, BGOrderStatus, FlagStatusId, FlagStatus, 
	DSScreeningType, DSReasonForTest, DrugScreenStatus, DrugScreenResult, ImmOrderStatus, ImmResult,
	ActionPending, ActionComplete, ActionAdverse)
	
	SELECT
	ASA.APNO,
	A.Applicant_UID,
	ALT.DOB,
	A.Applicant_FirstName,
	A.Applicant_LastName,
	A.Applicant_MiddleName,
	ALT.Email,
	A.ClientId,
	C.Name,
	A.ProgramId,
	A.ProgramName,
	A.OrderCreateDate,
	A.ApDate,

	ASA.ApplStudentActionID,
	ASA.StudentActionID,
	ASA.DateHospitalAssigned,
	ASA.DateStatusSet,

	AH.CurrentStatus,
	AH.DateAdverseStarted,
	AH.StatusDescription,
	ASA.CLNO_Hospital,

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
	IR.ResultCode,
	CASE WHEN RS.InReview=1 THEN 1 ELSE 0 end,
	CASE WHEN RS.InReview=1 or RS.PreAdverse=1 THEN 0 ELSE 1 END,
	CASE WHEN RS.PreAdverse=1 THEN 1 ELSE 0 end
	
    FROM 
	dbo.ApplStudentAction ASA WITH(NOLOCK)
	INNER JOIN Report.OrderSummary A WITH (NOLOCK) ON ASA.APNO=A.OrderNumber
	INNER JOIN dbo.Appl Alt WITH (NOLOCK) ON a.OrderNumber=alt.APNO
	INNER JOIN dbo.Client C WITH (NOLOCK) ON C.CLNO = ALT.CLNO
	LEFT OUTER JOIN dbo.vwAdverseHistory AH WITH (NOLOCK) 
		ON AH.APNO = ASA.APNO
    INNER JOIN REPORT.refOrderSummaryStatus LS WITH (NOLOCK)
        ON A.OrderStatusId = LS.OrderSummaryStatusId
    LEFT OUTER JOIN REPORT.refOrderSummaryStatus BS WITH (NOLOCK)
        ON A.BG_OrderStatusId = BS.OrderSummaryStatusId
    LEFT OUTER JOIN REPORT.refOrderSummaryStatus DS WITH (NOLOCK)
        ON A.DT_OrderStatusId = DS.OrderSummaryStatusId
    LEFT OUTER JOIN REPORT.refOrderSummaryStatus ISC WITH (NOLOCK)
        ON A.IM_OrderStatusId = ISC.OrderSummaryStatusId
    LEFT OUTER JOIN REPORT.refOrderSummaryResult BR WITH (NOLOCK)
        ON A.BG_ResultId = BR.OrderSummaryResultId --AND BRS.ServiceType='B'
    LEFT OUTER JOIN REPORT.refOrderSummaryResult DR WITH (NOLOCK)
        ON A.DT_ResultId = DR.OrderSummaryResultId --AND DRS.ServiceType='D'
    LEFT OUTER JOIN REPORT.refOrderSummaryResult IR WITH (NOLOCK)
        ON A.IM_ResultId = IR.OrderSummaryResultId --AND IRS.ServiceType='I'
	LEFT OUTER JOIN [StudentCheck].[GetRotationSummary](NULL, NULL, NULL,@ClinicId) RS 
		ON A.OrderNumber=RS.APNO
	WHERE 
	ASA.CLNO_Hospital = COALESCE(@ClinicId, ASA.CLNO_Hospital)
	AND ASA.DateHospitalAssigned BETWEEN COALESCE(@FromDate,ASA.DateHospitalAssigned) AND COALESCE(@EndDate, GETDATE())
	AND A.BG_OrderStatus = 'F'
	AND a.Applicant_FirstName = COALESCE(@ApplicantFirstName, a.Applicant_FirstName)
	AND a.Applicant_LastName = COALESCE(@ApplicantLastName, a.Applicant_LastName)
	AND a.OrderNumber  = COALESCE(@ReportNumber, a.OrderNumber)
	ORDER BY ASA.DateHospitalAssigned DESC
	RETURN 
END
