-- =========================================================================================
-- Author:		Vairavan A
-- Create date: 02-02-2024
-- Description:	Web Order Information
-- EXEC dbo.Web_Order_Information 0,'01/01/2024','02/05/2024',0,'0'
-- ==========================================================================================

CREATE PROCEDURE [dbo].[Web_Order_Information]
	@ReportNumber	INT =NULL, 
	@StartDate	    DATETIME=NULL,
	@EndDate		DATETIME = NULL,
	@ClientId		INT=NULL ,	
	@AffiliateId	varchar(max)
AS
BEGIN

SET NOCOUNT ON;

	DECLARE @StagingOrderStartDate DATE = DATEADD(DAY, -30, CURRENT_TIMESTAMP)

	Select @REPORTNUMBER = [dbo].[IsDefaultIntOrNull](@REPORTNUMBER,NULL)
	Select @CLIENTID = [dbo].[IsDefaultIntOrNull](@CLIENTID,NULL)
	Select @STARTDATE = [dbo].[IsDefaultDateOrNull](@STARTDATE,NULL,'')
	Select @ENDDATE = [dbo].[IsDefaultDateOrNull](@ENDDATE,NULL,'')

	IF(@REPORTNUMBER IS null AND @STARTDATE IS NULL AND @ENDDATE IS NULL AND @CLIENTID IS NULL)
	BEGIN
		Select @STARTDATE = CONVERT(VARCHAR(2),DATEPART(MONTH, GETDATE())) + '/1/' + CONVERT(VARCHAR(4),DATEPART(year, GETDATE()))
		Select @REPORTNUMBER = null
    end

	IF(@AffiliateID = '' OR LOWER(@AffiliateID) = 'null' or @AffiliateID = '0'  ) 
	BEGIN  
		Select @AffiliateID = NULL  
	END


	SELECT
		[Report Number]=O.OrderNumber,
		[Client Id]=o.ClientId,
		[Client]=C.ClientName,
		[Facility Id]=o.FacilityId,
		[Facility]=ISNULL(f.ClientName,''),
		[Request Number]=o.IntegrationRequestId,
		[Client Reference Number]=O.ClientReferenceId,
		[RequisitionNumber] = ISNULL(IAR.PartnerReferenceNumber, ''),
		[Recruiter Email]=O.Attention,
		[Candidate Name]= a.FirstName + ' ' + ISNULL(a.MiddleName,'') + ' ' +  a.LastName, 
		[Candidate Email] = a.Email,
		[Job State]=od.JobState,
		[Job Title]=OD.JobTitle,
		[Salary Range] = OD.JobSalaryRange,
		[Service/Package/Instructions]=[dbo].[GetOrderServicePackage](o.OrderId),
		[Additional Components] = ISNULL([dbo].[GetOrderServiceComponents] (o.OrderId),'No additional items')
	FROM Enterprise.dbo.[Order] O with(nolock)
	INNER JOIN Enterprise.dbo.Applicant A with(nolock)
		ON o.OrderId=a.OrderId
	  left outer join (
				SELECT 
				RequestID,
				PartnerReferenceNumber = r.TransformedRequest.value('(Application/NewApplicant/RequisitionNumber)[1]','varchar(50)')
				FROM Precheck.dbo.Integration_OrderMgmt_Request r WITH (NOLOCK)
				WHERE r.RequestDate BETWEEN  @StagingOrderStartDate AND CURRENT_TIMESTAMP
			) iar  
			ON O.IntegrationRequestId= iar.RequestID
	INNER JOIN PreCheck.dbo.vwClient C with(nolock)
		ON O.ClientId=C.ClientId 
	LEFT OUTER JOIN PreCheck.dbo.vwClient F with(nolock)
		ON O.FacilityId=F.ClientId
	LEFT OUTER JOIN Enterprise.dbo.OrderJobDetail	OD with(nolock)
		ON O.OrderId=OD.OrderId
	WHERE o.OrderNumber=ISNULL(@REPORTNUMBER, O.OrderNumber)
	AND O.ModifyDate >= ISNULL(@STARTDATE, O.ModifyDate)
	AND O.ModifyDate <= ISNULL(@ENDDATE, O.ModifyDate)
	AND O.ClientId = ISNULL(@CLIENTID, O.ClientId)
	AND (@AffiliateID IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateID,':')))
	ORDER BY O.CreateDate DESC

SET NOCOUNT OFF;
END

