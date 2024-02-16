-- =============================================
-- Author:		Humera Ahmed
-- Create date: 8/16/2021
-- Description:	MCIC Reports Certified the Previous Day
-- Exec [dbo].[ScheduledReport_MCICReportsCertifiedPreviousDay]
-- =============================================
CREATE PROCEDURE [dbo].[ScheduledReport_MCICReportsCertifiedPreviousDay]
	-- Add the parameters for the stored procedure here

	AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
		a.CLNO [Client Number]
		, c.Name [Client Name]
		, pm.PackageDesc [Package Selected]
		, a.APNO [Report Number]
		, Replace(a.Pos_Sought,',','') [Position]
		,count(al.ApplicantId) [# of licenses provided] 
	FROM dbo.appl a 
		INNER JOIN dbo.ClientCertification cc ON a.APNO = cc.APNO
		INNER JOIN dbo.Client c ON a.CLNO = c.CLNO
		INNER JOIN Enterprise.Staging.ApplicantStage [as] ON a.APNO = [as].ApplicantNumber
		INNER JOIN Enterprise.Staging.OrderStage os ON [as].StagingOrderId = os.StagingOrderId
		INNER JOIN dbo.PackageMain pm ON a.PackageID = pm.PackageID
		INNER JOIN Enterprise.dbo.Applicant a2 ON a.APNO = a2.ApplicantNumber
		INNER JOIN Enterprise.dbo.ApplicantLicense al ON a2.ApplicantId = al.ApplicantId
	WHERE 
		a.clno IN (8987,16997,16998,16999,17000,17001,17002) 
		AND a.ApStatus='P'
		AND os.BatchOrderDetailId IS NOT NULL -- Only MCIC reports
		AND format(cc.ClientCertUpdated,'MM/dd/yyyy') = format(DATEADD(D,-1,GETDATE()),'MM/dd/yyyy') --Certified previous day.
		AND a.PackageID = 1696 --Only Acquisition + License package
	GROUP BY 
		a.CLNO
		, c.name
		, pm.PackageDesc
		, a.APNO
		, a.Pos_Sought
		, al.ApplicantId
END
