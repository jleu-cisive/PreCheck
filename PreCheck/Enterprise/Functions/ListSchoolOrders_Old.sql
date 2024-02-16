/*************************************************************
-- Author:		Gaurav Bangia
-- Create date: 03/18/2022
-- Description:	Table function to return list of school reports
   DEMO ACCOUNT - LOW VOLUME - 90 DAYS
  SELECT * FROM  Enterprise.ListSchoolOrders(3668, '12/19/2021', '3/19/2022', NULL, NULL, NULL, NULL, NULL, NULL)
   HIGH VOLUME ACCOUNT - 90 DAYS
  SELECT * FROM  Enterprise.ListSchoolOrders(3668, '1/1/2022', '3/30/2022', NULL, NULL, NULL, NULL, NULL, NULL)
**************************************************************/
CREATE FUNCTION [Enterprise].[ListSchoolOrders_Old]
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
	RS.ImmunizationResult
    FROM dbo.Appl A
	INNER JOIN dbo.Client C ON C.CLNO = A.CLNO
	LEFT OUTER JOIN dbo.ClientProgram CP ON CP.ClientProgramID = A.ClientProgramID
	LEFT outer JOIN dbo.ApplFlagStatus fs ON fs.APNO = A.APNO
	LEFT OUTER JOIN dbo.refApplFlagStatus fsd ON fsd.FlagStatusID = fs.FlagStatus
	LEFT OUTER JOIN Enterprise.vwReportStatus rs ON a.APNO=rs.OrderNumber
	WHERE 
	a.CLNO = COALESCE(@SchoolId, a.clno)
	AND A.CreatedDate BETWEEN COALESCE(@FromDate,a.CreatedDate) AND COALESCE(@EndDate,a.CreatedDate)
	AND A.ApStatus = CAST(COALESCE(@ReportStatus, A.APSTATUS) AS CHAR(1))
	AND a.First = COALESCE(@ApplicantFirstName, a.First)
	AND a.Last = COALESCE(@ApplicantLastName, a.Last)
	AND a.APNO  = COALESCE(@ReportNumber, a.APNO)
	
	IF(@ApplicantSocial IS NOT NULL)
		DELETE FROM @Result WHERE SUBSTRING(SSN, LEN(SSN)-4,4) <> @ApplicantSocial
	IF(@ApplicantDOB IS NOT NULL)
		DELETE FROM @Result WHERE DOB <> @ApplicantDOB
	
	
	RETURN 
END
