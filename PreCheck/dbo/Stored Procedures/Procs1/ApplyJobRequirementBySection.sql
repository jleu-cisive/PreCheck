-- =============================================
-- Author:		<Karan Sen>
-- Create date: <10-09-2022>
-- Description:	<This proc. will update isOnReport value on basis of order job requirement provided by client and then will be used in zipcrim
---for not processing below updated records for verfication >
-- update date: <20-01-2023> updated column secstat = H on all below section.
-- update date: <01-02-2023> updated column secstat = (case when oal.OrderJobRequirement_ApplicantLicenseId is null then SectStat else 'H' end) on all below section.
-- =============================================
--Exec [dbo].[ApplyJobRequirementBySection]
CREATE PROCEDURE [dbo].[ApplyJobRequirementBySection]
	--@appno int,
	--@ClientId int
AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT  ap.Apno, ap.CLNO--,Ior.CLNO 
	into #tmp1 
	FROM dbo.Appl ap with(nolock)
	join dbo.Integration_OrderMgmt_Request ior with(nolock) on  ior.APNO=ap.APNO
	join dbo.ClientConfiguration cc with(nolock) on cc.CLNO=ior.CLNO and cc.ConfigurationKey='ZipCrim_StrictlyEnforceCICRequirements' and cc.Value='True'
	WHERE ap.NeedsReview like '%2' and ap.InUse ='CNTY_S' 

	declare @tempApno varchar(max)=(SELECT ISNULL(stuff((
    SELECT ', ' + cast(Apno as varchar(max))
    FROM #tmp1
    FOR XML PATH('')
    ), 1, 2, ''),'N\A'))



	Exec [Job].[WriteToTraceLog] 'UpdAp', 'ApplyJobRequirementBySection', @tempApno , 'Info'
	-- We can use ClientJobRequirementBySection for getting job requiremtn
	-- Select (case when oal.OrderJobRequirement_ApplicantLicenseId is not null then 1 else 0 end) ToBeVerified_Flag, ap.applicantnumber, APNO, al.*,pl.*
	
		/*---------------------------------------------------------Licese Update----------------------------------------*/
		Update pl Set IsOnReport = (case when oal.OrderJobRequirement_ApplicantLicenseId is null then IsOnReport else 1 end)
		,Priv_Notes = (case when oal.OrderJobRequirement_ApplicantLicenseId is null then '' else 'Record Staged based on Client Requirements;' end) + isnull(Priv_notes,'')
		,SectStat=(case when oal.OrderJobRequirement_ApplicantLicenseId is null then SectStat else 'H' end)
		FROM [Enterprise].dbo.Applicant ap with(nolock)
		JOIN [Enterprise].dbo.ApplicantLicense al with(nolock) on ap.ApplicantId=al.ApplicantId
		JOIN [Precheck].[dbo].[ProfLic] pl with(nolock) on pl.apno = ap.applicantnumber and pl.lic_type = al.Licensetype and pl.[State] = al.[state]
		LEFT JOIN [Enterprise].dbo.OrderJobRequirement_ApplicantLicense oal with(nolock) on al.ApplicantLicenseId=oal.ApplicantLicenseId
		join #tmp1 n on ap.ApplicantNumber=n.Apno

		/*---------------------------------------------------------Employment Update----------------------------------------*/

		--Select (case when oae.OrderJobRequirement_ApplicantEmployment is not null then 1 else 0 end) ToBeVerified_Flag, ap.applicantnumber, APNO, ae.*,emp.*
		Update emp Set IsOnReport = (case when oae.OrderJobRequirement_ApplicantEmploymentId is null then IsOnReport else 1 end)
		,Priv_Notes = (case when oae.OrderJobRequirement_ApplicantEmploymentId is null then '' else 'Record Staged based on Client Requirements;' end) + isnull(Priv_notes,'')
		,SectStat=(case when oae.OrderJobRequirement_ApplicantEmploymentId is null then SectStat else 'H' end)
		FROM [Enterprise].dbo.Applicant ap with(nolock)
		JOIN [Enterprise].[dbo].[ApplicantEmployment] ae with(nolock) on ap.ApplicantId=ae.ApplicantId
		JOIN [Precheck].[dbo].[empl] emp with(nolock) on emp.apno = ap.applicantnumber 
		and SUBSTRING(LTRIM(RTRIM(emp.Employer)),1,30)=SUBSTRING(LTRIM(RTRIM(AE.EmployerName)),1,30)
		and ISNULL([Enterprise].[dbo].[ConvertToMonthYear](CONVERT(VARCHAR(10),ae.EmploymentFrom,101)),'') = ISNULL([Enterprise].[dbo].[ConvertToMonthYear](emp.From_A),'')
		and SUBSTRING(ISNULL(ae.StartDesignation,''),1,25) = SUBSTRING(ISNULL(emp.Position_A,''),1,25)
		LEFT JOIN [Enterprise].dbo.OrderJobRequirement_ApplicantEmployment oae with(nolock) on ae.ApplicantEmploymentId=oae.ApplicantEmploymentId
		join #tmp1 n on ap.ApplicantNumber=n.Apno

		----Employment code for further enhancing join-----
		--AND SUBSTRING( LTRIM(RTRIM(AE.EmployerName)),1,30) = SUBSTRING(LTRIM(RTRIM(pe.Employer)),1,30)
		--	AND ISNULL(DBO.ConvertToMonthYear(CONVERT(VARCHAR(10),ae.EmploymentFrom,101)),'') = ISNULL([dbo].[ConvertToMonthYear](pe.From_A),'')
		--	AND SUBSTRING(ISNULL(ae.StartDesignation,''),1,25) = SUBSTRING(ISNULL(pe.Position_A,''),1,25)


		/*---------------------------------------------------------Education Update----------------------------------------*/

		--Select (case when oae.OrderJobRequirement_ApplicantEducationId is not null then 1 else 0 end) ToBeVerified_Flag, ap.applicantnumber, APNO, ae.*,edu.*
		Update edu Set IsOnReport = (case when oae.OrderJobRequirement_ApplicantEducationId is null then IsOnReport else 1 end)
		,Priv_Notes = (case when oae.OrderJobRequirement_ApplicantEducationId is null then '' else 'Record Staged based on Client Requirements;' end) + isnull(Priv_notes,'')
		,SectStat=(case when oae.OrderJobRequirement_ApplicantEducationId is null then SectStat else 'H' end)
		FROM [Enterprise].dbo.Applicant ap with(nolock)
		JOIN [Enterprise].[dbo].[ApplicantEducation] ae with(nolock) on ap.ApplicantId=ae.ApplicantId
		JOIN [Precheck].[dbo].[Educat] edu with(nolock) on edu.apno = ap.applicantnumber and edu.School=AE.SchoolName
		and SUBSTRING(ISNULL(ae.CampusName,''),0,25) = ISNULL(edu.CampusName,'') and ISNULL(edu.Studies_A,'')=ISNULL(ae.Major,'')
		LEFT JOIN [Enterprise].dbo.OrderJobRequirement_ApplicantEducation oae with(nolock) on ae.ApplicantEducationId=oae.ApplicantEducationId
		join #tmp1 n on ap.ApplicantNumber=n.Apno
	
END

