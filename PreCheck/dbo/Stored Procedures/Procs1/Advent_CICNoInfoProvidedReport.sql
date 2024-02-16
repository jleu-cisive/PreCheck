-- =============================================
-- Author:		Deepak Vodethela
-- Create date: 01/10/2020
-- Description:	The report captures Component No Information provided on the Previous Day.
-- Execution: EXEC Advent_CICNoInfoProvidedReport 
-- =============================================
CREATE PROCEDURE Advent_CICNoInfoProvidedReport 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT	a.ApplicantNumber AS [Report Number], o.FacilityId AS [Facility Number], vwc.ClientName, 
			a.FirstName AS [First Name], a.LastName AS [Last Name], 
			a.ClientCandidateId AS [Candidate ID], o.Attention AS [Recruiter Email], 
			SUBSTRING(mdk.KeyName,19, 60) AS [Component Message],
			SUBSTRING(dat.DynamicAttributeTypeName,18, 40) AS Component
	FROM Enterprise.dbo.Applicant a
	INNER JOIN Enterprise.dbo.[Order] o ON o.OrderNumber = a.ApplicantNumber
	INNER JOIN Enterprise.dbo.ApplicantMiscItem ami ON ami.applicantid = a.ApplicantId
	INNER JOIN Enterprise.lookup.MiscDataKey mdk ON mdk.MiscDataKeyId = ami.MiscDataKeyId
	INNER JOIN Enterprise.dbo.DynamicAttribute da ON da.dynamicattributeid = ami.MiscDataKeyValue
	INNER JOIN Enterprise.Precheck.vwclient vwc ON vwc.ClientId = o.FacilityId
	INNER JOIN Enterprise.dbo.DynamicAttributeType dat ON da.DynamicAttributeTypeId = dat.DynamicAttributeTypeId
	INNER JOIN Enterprise.STAGING.ApplicantStage [as] ON A.ApplicantNumber = [as].ApplicantNumber
	WHERE vwc.AffiliateId IN (229,230,231)
	  AND o.CreateDate >= DATEADD(DAY,DATEDIFF(DAY,1,GETDATE()),0)
	  AND o.CreateDate < DATEADD(DAY,DATEDIFF(DAY,0,GETDATE()),0)
	ORDER BY a.ApplicantNumber

END
