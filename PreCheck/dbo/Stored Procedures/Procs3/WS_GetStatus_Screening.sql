-- =============================================
-- Author:		sChapyala
-- Create date: 07/25/2011
-- Description:	Returns the Screening (component/section) level statuses for status updates to Integration clients. Built specifically for Taleo Passport but intend to use this based on configuration.
-- =============================================
-- Modified By: Doug DeGenaro
-- Modify Date: 11/27/2021 
-- Description : Added additional union for SSN/DOB and Offer status
--[WS_GetStatus_Screening] 6175431 -- apno
--[WS_GetStatus_Screening] 1378547 -- requestid
--select * from [Enterprise].[dbo].[GetCandidateOfferByRequestId](8109)
CREATE PROCEDURE [dbo].[WS_GetStatus_Screening] 
--DECLARE
	@APNO INT
AS
BEGIN	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	-- getting the requestid regardless if it is a requestid or apno
	declare @integrationrequestid int
	declare @integrationAPNO int	
	
	select @integrationrequestid = requestid,@integrationAPNO = apno from dbo.integration_ordermgmt_request ior (nolock) where ior.APNO = @APNO or ior.RequestId = @APNO
	if (@apno = @integrationrequestid and IsNull(@integrationapno,0) = 0)
		set @apno = null
	SELECT  distinct
		'SSN/DOB' as ScreeningType,
		REPLACE(astg.SocialNumber,'-','') as OrderStatus,
		CONVERT(VARCHAR(19),astg.DateOfBirth,120) as ResultStatus
	FROM 
		dbo.Integration_OrderMgmt_Request ior (nolock)
	INNER JOIN dbo.ClientConfig_Integration cci on ior.CLNO= cci.CLNO 	
	INNER JOIN [Enterprise].Staging.OrderStage ostg on ostg.IntegrationRequestId = ior.Requestid 
	INNER JOIN [Enterprise].Staging.ApplicantStage astg on ostg.StagingOrderid = astg.StagingOrderId
	WHERE 
		(ior.APNO = @APNO or ior.RequestId = @integrationrequestid) and 
	(IsNull(astg.SocialNumber,'') <> '' or IsNull(astg.DateOfBirth,'') <> '') 
	and cci.ConfigSettings.value('(//IncludeSSNDOB)[1]','varchar(10)') = 'true' 
	UNION ALL 	
	SELECT 
		 'Offer' as ScreeningType,
		tf.OfferStatus as OrderStatus, -- Dongmei will need to have this new field in the offer function
		CONVERT(VARCHAR(19),tf.ResponseDate,120) as ResultStatus
	FROM 
		dbo.Integration_OrderMgmt_Request ior (nolock)
	INNER JOIN 
		dbo.ClientConfig_Integration cci on ior.CLNO= cci.CLNO 
	LEFT JOIN [Enterprise].[dbo].[GetCandidateOfferByRequestId](@integrationrequestid) tf on ior.Requestid = tf.IntegrationRequestId 	
	WHERE (ior.APNO = @APNO or ior.RequestId = @integrationrequestid) 
	and cci.ConfigSettings.value('(//CIC_EnableInitiateOffer)[1]','varchar(10)') = 'true'	
	UNION ALL
	SELECT  distinct
	    'Email Used' as ScreeningType, CO.CandidateEmail + '; Link Exp:' as OrderStatus,
		CONVERT(VARCHAR(19),[ExpireDate],120)  as ResultStatus
	FROM 
		[Enterprise].Staging.CandidateOffer CO 
	INNER JOIN 
		SecureBridge..Token T on CO.OfferTokenId = TokenId 
	WHERE 
		(CO.IntegrationRequestId = @integrationrequestid)  

	UNION ALL
	SELECT  ('Crim: ' + County) ScreeningType, ReportedStatus_Integration OrderStatus, (Case When ApStatus ='F' then ISNULL(CustomStatus.CustomFlagStatus,RefApplFlagStatus.FlagStatus) else NULL end) ResultStatus
	FROM dbo.Appl A (nolock)
		INNER JOIN dbo.Crim E (nolock) ON A.APNO = E.APNO
		LEFT JOIN dbo.CrimSectStat S (nolock) on E.Clear = S.crimsect 
		LEFT JOIN DBO.RefApplFlagStatus (nolock) ON E.ClientAdjudicationStatus=RefApplFlagStatus.FLAGSTATUSID
		LEFT JOIN DBO.RefApplFlagStatusCustom CustomStatus ON CustomStatus.CLNO in (7519,13131) AND E.ClientAdjudicationStatus = CustomStatus.FLAGSTATUSID 
	WHERE 	 E.IsHidden=0 
	AND A.APNO = @APNO
	UNION ALL 
	SELECT ('Empl: ' + Employer) ScreeningType,ReportedStatus_Integration OrderStatus, (Case When ApStatus ='F' then ISNULL(CustomStatus.CustomFlagStatus,RefApplFlagStatus.FlagStatus) else NULL end) ResultStatus
	FROM dbo.Appl A (nolock)
		INNER JOIN dbo.Empl E (nolock) ON A.APNO = E.APNO
		LEFT JOIN dbo.SectStat S (nolock) on E.SectStat = S.Code 
		LEFT JOIN DBO.RefApplFlagStatus (nolock) ON E.ClientAdjudicationStatus=RefApplFlagStatus.FLAGSTATUSID
		LEFT JOIN DBO.RefApplFlagStatusCustom CustomStatus ON CustomStatus.CLNO in (7519,13131) AND E.ClientAdjudicationStatus = CustomStatus.FLAGSTATUSID 
	WHERE 	 E.IsHidden=0 AND E.IsOnReport=1 
	AND A.APNO = @APNO
	UNION ALL
	SELECT  ('Edu: ' + School) ScreeningType, ReportedStatus_Integration OrderStatus, (Case When ApStatus ='F' then ISNULL(CustomStatus.CustomFlagStatus,RefApplFlagStatus.FlagStatus) else NULL end) ResultStatus
	FROM dbo.Appl A (nolock)
		INNER JOIN dbo.Educat E (nolock) ON A.APNO = E.APNO
		LEFT JOIN dbo.SectStat S (nolock) on E.SectStat = S.Code 
		LEFT JOIN DBO.RefApplFlagStatus (nolock) ON E.ClientAdjudicationStatus=RefApplFlagStatus.FLAGSTATUSID
		LEFT JOIN DBO.RefApplFlagStatusCustom CustomStatus ON CustomStatus.CLNO in (7519,13131) AND E.ClientAdjudicationStatus = CustomStatus.FLAGSTATUSID 
	WHERE 	 E.IsHidden=0 AND E.IsOnReport=1
	AND A.APNO = @APNO
	UNION ALL
	SELECT ('Lic: ' + Lic_Type) ScreeningType,ReportedStatus_Integration OrderStatus, (Case When ApStatus ='F' then ISNULL(CustomStatus.CustomFlagStatus,RefApplFlagStatus.FlagStatus) else NULL end) ResultStatus
	FROM dbo.Appl A (nolock)
		INNER JOIN dbo.ProfLic E (nolock) ON A.APNO = E.APNO
		LEFT JOIN dbo.SectStat S (nolock) on E.SectStat = S.Code 
		LEFT JOIN DBO.RefApplFlagStatus (nolock) ON E.ClientAdjudicationStatus=RefApplFlagStatus.FLAGSTATUSID
		LEFT JOIN DBO.RefApplFlagStatusCustom CustomStatus ON CustomStatus.CLNO in (7519,13131) AND E.ClientAdjudicationStatus = CustomStatus.FLAGSTATUSID 
	WHERE 	 E.IsHidden=0 AND E.IsOnReport=1 
	AND A.APNO = @APNO
	UNION ALL
	SELECT  ('SanctionCheck') ScreeningType, ReportedStatus_Integration OrderStatus, (Case When ApStatus ='F' then ISNULL(CustomStatus.CustomFlagStatus,RefApplFlagStatus.FlagStatus) else NULL end) ResultStatus
	FROM dbo.Appl A (nolock)
		INNER JOIN dbo.MedInteg E (nolock) ON A.APNO = E.APNO
		LEFT JOIN dbo.SectStat S (nolock) on E.SectStat = S.Code 
		LEFT JOIN DBO.RefApplFlagStatus (nolock) ON E.ClientAdjudicationStatus=RefApplFlagStatus.FLAGSTATUSID
		LEFT JOIN DBO.RefApplFlagStatusCustom CustomStatus ON CustomStatus.CLNO in (7519,13131) AND E.ClientAdjudicationStatus = CustomStatus.FLAGSTATUSID 
	WHERE 	 E.IsHidden=0 
	AND A.APNO = @APNO
	UNION ALL
	SELECT  ('Ref:' + [Name]) ScreeningType, ReportedStatus_Integration OrderStatus, (Case When ApStatus ='F' then ISNULL(CustomStatus.CustomFlagStatus,RefApplFlagStatus.FlagStatus) else NULL end) ResultStatus
	FROM dbo.Appl A (nolock)
		INNER JOIN dbo.PERSREF E (nolock) ON A.APNO = E.APNO
		LEFT JOIN dbo.SectStat S (nolock) on E.SectStat = S.Code 
		LEFT JOIN DBO.RefApplFlagStatus (nolock) ON E.ClientAdjudicationStatus=RefApplFlagStatus.FLAGSTATUSID
		LEFT JOIN DBO.RefApplFlagStatusCustom CustomStatus ON CustomStatus.CLNO in (7519,13131) AND E.ClientAdjudicationStatus = CustomStatus.FLAGSTATUSID 
	WHERE 	 E.IsHidden=0 
	AND A.APNO = @APNO

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	SET NOCOUNT OFF	
END
