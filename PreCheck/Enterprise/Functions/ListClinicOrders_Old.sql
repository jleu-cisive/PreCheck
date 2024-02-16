/*********************************************************************
-- Author:		Gaurav Bangia
-- Create date: 03/18/2022
-- Description:	Table function to return list of reports for the clinic
   DEMO ACCOUNT - LOW VOLUME - 90 DAYS
  SELECT * FROM  Enterprise.ListClinicOrders(9282, '1/1/2022', '3/30/2022', NULL, NULL, NULL, NULL, NULL, NULL)
   HIGH VOLUME ACCOUNT - 90 DAYS
  SELECT * FROM  Enterprise.ListClinicOrders(3665, '1/1/2022', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
*************************************************************************/
CREATE FUNCTION [Enterprise].[ListClinicOrders_Old]
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
	A.APNO,
	A.SSN,
	A.DOB,
	A.First,
	A.Last,
	A.Middle,
	A.Email,
	A.CLNO,
	C.Name,
	A.ClientProgramID,
	CP.Name,
	A.CreatedDate,
	A.ApDate,

	ASA.ApplStudentActionID,
	ASA.StudentActionID,
	ASA.DateHospitalAssigned,
	ASA.ModifyDate,

	AH.CurrentStatus,
	AH.DateAdverseStarted,
	AH.StatusDescription,
	ASA.CLNO_Hospital,


	RS.HasBackground,
	RS.HasDrugScreen,
	RS.HasImmunization,
	A.ApStatus,
	FS.FlagStatus,
	FSD.FlagStatus,
	RS.ScreeningType,
	RS.ReasonForTest,
	RS.DrugScreenStatus,
	RS.DrugScreenResult,
	RS.ImmunizationStatus,
	RS.ImmunizationResult,
	CASE WHEN rh.InReview=1 THEN 1 ELSE 0 end,
	CASE WHEN rh.InReview=1 or rh.PreAdverse=1 THEN 0 ELSE 1 END,
	CASE WHEN rh.PreAdverse=1 THEN 1 ELSE 0 end
	
    FROM 
	dbo.ApplStudentAction ASA
	INNER JOIN dbo.Appl A ON A.APNO = ASA.APNO
	INNER JOIN dbo.Client C ON C.CLNO = A.CLNO
	LEFT OUTER JOIN dbo.ClientProgram CP ON CP.ClientProgramID = A.ClientProgramID
	LEFT outer JOIN dbo.ApplFlagStatus fs ON fs.APNO = A.APNO
	LEFT OUTER JOIN dbo.refApplFlagStatus fsd ON fsd.FlagStatusID = fs.FlagStatus
	LEFT OUTER JOIN Enterprise.vwReportStatus rs ON a.APNO=rs.OrderNumber
	LEFT OUTER JOIN dbo.vwAdverseHistory AH ON AH.APNO = A.APNO
	LEFT OUTER JOIN StudentCheck.GetRotationSummary(NULL, @FromDate, NULL, @ClinicId) RH 
		ON ASA.APNO=RH.APNO
	WHERE 
	ASA.CLNO_Hospital = COALESCE(@ClinicId, asa.CLNO_Hospital)
	AND ASA.DateHospitalAssigned BETWEEN COALESCE(@FromDate,ASA.DateHospitalAssigned) AND COALESCE(@EndDate, GETDATE())
	AND A.ApStatus = 'F'
	AND a.First = COALESCE(@ApplicantFirstName,  a.First)
	AND a.Last = COALESCE(@ApplicantLastName, a.Last)
	AND ASA.APNO  = COALESCE(@ReportNumber, a.APNO)
	ORDER BY ASA.DateHospitalAssigned DESC
	RETURN 
END
