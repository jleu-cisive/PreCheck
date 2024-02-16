/*************************************************************
-- Author:		Gaurav Bangia
-- Create date: 03/18/2022
-- Description:	Table function to return list of school reports
   DEMO ACCOUNT - LOW VOLUME - 90 DAYS
  SELECT * FROM  [Enterprise].[ListSchoolOrders](3668, '9/1/2021', '3/30/2022', NULL, NULL, NULL, NULL, NULL, NULL)
   HIGH VOLUME ACCOUNT - 90 DAYS
  SELECT * FROM  [Enterprise].[ListSchoolOrders](16070, '1/1/2022', '3/30/2022', NULL, NULL, NULL, NULL, NULL, NULL)
--==============================================
-- Author: Pradip Adhikari
-- Modify date:07/25/2023
-- Description: added VendorProfileId column in the select statement.

**************************************************************/
CREATE FUNCTION [Enterprise].[ListSchoolOrders]
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
	OrderStatus VARCHAR(1),
	BGOrderStatus VARCHAR(1),
	FlagStatusId INT NULL,
	FlagStatus VARCHAR(50),
	DSScreeningType VARCHAR(25) NULL,
	DSReasonForTest VARCHAR(25) NULL,
	DrugScreenStatus VARCHAR(1) NULL,
	DrugScreenResult VARCHAR(25) NULL,
	ImmOrderStatus VARCHAR(1),
	ImmResult VARCHAR(25),
	HasAssignment BIT,
	HasAcceptance BIT,
	VendorProfileId  VARCHAR(55)
)
AS
BEGIN
	IF(LEN(COALESCE(@ApplicantFirstName,''))=0)
		SET @ApplicantFirstName = null
	IF(LEN(COALESCE(@ApplicantLastName,''))=0)
		SET @ApplicantLastName = NULL
	IF(LEN(COALESCE(@ReportStatus,''))=0)
		SET @ReportStatus = NULL

	INSERT INTO @Result(APNO, SSN, DOB, First, Last, Middle, Email, CLNO, ClientName, ClientProgramId, ProgramName, 
	AppCreatedDate, ApDate, HasBackground, HasDrugScreen, HasImmunization, OrderStatus, BGOrderStatus, FlagStatusId, FlagStatus, 
	DSScreeningType, DSReasonForTest, DrugScreenStatus, DrugScreenResult, 
	ImmOrderStatus, ImmResult, HasAssignment, HasAcceptance, VendorProfileId)
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
	CASE WHEN A.HasBackground=0 AND BS.StatusCode IS NULL THEN 'F' ELSE bs.StatusCode END,
	CASE WHEN A.HasBackground=0 AND BS.StatusCode IS NULL THEN 'F' ELSE bs.StatusCode END,
	AFS.FlagStatus, --LS.OrderSummaryStatusId,
	LAFS.FlagStatus,	--LS.DisplayName,
	'', --Screening type missing
	'', -- ReasonForTest missing
	DS.StatusCode,
	DR.ResultCode,
	ISC.StatusCode,
	IR.ResultCode,
	CASE WHEN RS.APNO IS NULL THEN 0 ELSE 1 END, --HasAssignment: Determine if any rotation assignments exist 
	CASE WHEN ISNULL(RS.Accepted,0)>0 THEN 1 ELSE 0 end  --HasAcceptance: Determine if any rotation assignments have been accepted (StudentActionID = 1)
	,IM.VendorProfileId
    FROM 
	
	Report.OrderSummary A WITH (NOLOCK)
	INNER JOIN dbo.Appl Alt WITH (NOLOCK) ON a.OrderNumber=alt.APNO
	INNER JOIN dbo.Client C WITH (NOLOCK) ON C.CLNO = A.ClientId
	LEFT JOIN (
			SELECT AP.ApplicantNumber
				,AI.VendorProfileId
			FROM [EnterPrise].dbo.Applicant AP WITH (NOLOCK)
			INNER JOIN [EnterPrise].dbo.ApplicantImmunization AI WITH (NOLOCK) ON AI.ApplicantId = AP.ApplicantId
		) im ON im.ApplicantNumber = A.OrderNumber
	LEFT OUTER JOIN dbo.ApplFlagStatus AFS WITH (NOLOCK) 
		ON A.OrderNumber=AFS.APNO
	LEFT OUTER JOIN dbo.refApplFlagStatus LAFS WITH (NOLOCK)
		ON afs.FlagStatus=LAFS.FlagStatusID
    LEFT outer JOIN REPORT.refOrderSummaryStatus LS WITH (NOLOCK)
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

	LEFT OUTER JOIN [StudentCheck].[GetRotationSummary](@SchoolId, NULL, NULL,NULL) RS 
		ON A.OrderNumber=RS.APNO
	WHERE 
	a.ClientId = COALESCE(@SchoolId, a.ClientId)
	AND A.OrderCreateDate BETWEEN COALESCE(@FromDate,a.OrderCreateDate) AND COALESCE(@EndDate,a.OrderCreateDate)
	AND ISNULL(A.BG_OrderStatus,'') = COALESCE(@ReportStatus, ISNULL(A.BG_OrderStatus,''))
	AND a.Applicant_FirstName = COALESCE(@ApplicantFirstName, a.Applicant_FirstName)
	AND a.Applicant_LastName = COALESCE(@ApplicantLastName, a.Applicant_LastName)
	AND a.OrderNumber  = COALESCE(@ReportNumber, a.OrderNumber)
	
	IF(COALESCE(@ApplicantSocial,'')<>'')
		DELETE FROM @Result WHERE SUBSTRING(SSN, LEN(SSN)-4,4) <> @ApplicantSocial
	IF(COALESCE(@ApplicantDOB,'')<>'')
		DELETE FROM @Result WHERE DOB <> @ApplicantDOB
	RETURN 
END
