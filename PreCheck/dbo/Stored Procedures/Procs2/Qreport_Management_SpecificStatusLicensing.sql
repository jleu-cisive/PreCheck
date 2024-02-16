/* =============================================
-- Author:		Amy Liu
-- Create date: 11/03/2021
-- Description:	#24667 Licenses Closed Q-Report byHeidi Hernandez 
-- The Qreport is based on the QReport:[dbo].[ManagementReports_Licensing_Qreport] 
-- exec [dbo].[Qreport_Management_SpecificStatusLicensing] '11/03/2021','11/03/2021', 0

ModifiedBy		ModifiedDate(MM/DD/YYYY)	TicketNo	Description
Humera Ahmed	01/19/2022					67397		In the where clause, replaced Last_Worked column with Last_Updated 
Shashank Bhoi	07/17/2023					100829		#100829 Q-Report Management_ClosedStatusLicensingReport  
-- ============================================= */
CREATE PROCEDURE [dbo].[Qreport_Management_SpecificStatusLicensing] 
    @StartDate datetime,
    @EndDate datetime,
	@CLNO int 
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET NOCOUNT ON;
	if (@CLNO=0 or @CLNO is null or @CLNO='' )  set @CLNO=0

	SELECT DISTINCT 
			a.[Apno], 
			pl.ProfLicID,
			a.[Apdate], 
			a.[CLNO],
			c.[name], 
			ra.[Affiliate], 
			ra.[AffiliateID], 
			a.[UserID],  
			pl.[Investigator],
			pl.[Organization] ,  
			pl.[Lic_type], 
			pl.[State], 
			a.[Apstatus] ,
			ss.[Description] [LicenseStatus], 
			sss.[SectSubStatus] [LicenseSubStatus],
			ws.[description] [WebStatus], 
			pl.[Pub_notes], 
			pl.[Priv_Notes] , 
			COALESCE(a.[compDate], a.[last_Updated]) as [ReportCompleteDate],
			pl.[Last_Updated] as [LicenseCompletedate]
	from	[dbo].[Appl]					AS a
			INNER JOIN [dbo].[Client]		AS C  on a.[CLNO] = c.[CLNO]
			INNER JOIN [dbo].[Proflic]		AS pl on a.[APNO] = pl.[APNO]
			INNER JOIN [dbo].[SectStat]		AS ss on pl.[SectStat] = ss.[Code]
			INNER JOIN [dbo].[Websectstat]	AS ws on pl.[Web_status] = ws.[code]
			INNER JOIN [dbo].[refAffiliate] AS ra on c.[AffiliateID] = ra.[AffiliateID]
			LEFT JOIN [dbo].[SectSubStatus] AS sss on sss.[SectStatusCode]= ss.[Code] 
												and sss.[ApplSectionID]=4 
												and pl.SectSubStatusID= sss.SectSubStatusID
	where	pl.[SectStat] in ('4','C','8','U','B')
			--and pl.[Last_Worked]>= @StartDate and pl.[Last_Worked]< = dateadd(s,-1,dateadd(d,1,@EndDate))
			--and pl.[Last_Updated]>= @StartDate and pl.[Last_Updated]< = dateadd(s,-1,dateadd(d,1,@EndDate))	-- Code commented for #100829
			and Pl.Contact_Date>= @StartDate and Pl.Contact_Date< = dateadd(s,-1,dateadd(d,1,@EndDate))		-- Code added for #100829
			and (@CLNO=0 or a.[CLNO]=@CLNO) 

order by a.Apdate asc


END

