-- =============================================
-- Author:		Humera Ahmed
-- Create date: 1/19/2021
-- Description:	HDT#81871 - The output should show any report with a license verification in a "Pending Board Actions" web status 
-- EXEC [dbo].[ScheduledReport_LicenseVerificationsWithPendingBoardActions] 7519
-- Modified by :Sahithi: HDT :84271, Added a new column License State 
-- Modified by :Prasanna: HDT#86829 shows only reports where the pending board action is the only component in a pending status
-- Exclude all pending statuses from empl, educat,crim - Sahithi
-- Modified by Radhika Dereddy on 08/30/21 by making the joins to enterprise db as Left joins and add the filter for pending SectStats on the joins
-- Modified by Anil Rai on 04/12/2023 HDT 83195 -Added more Sectstat/Crim.clear conditions for Empl,Educat and crim to filter and show only reports where pending board action for License is the only component in a pending status
-- Modified by Anil Rai on 08/10/2023 HDT 83195 -added new where condition (pl.SectStat= 'B') with union for addidng pending board action report numbers to a new temp table 
-- Modified by Anil Rai on 08/28/2023 HDT 83195 -Commented the Union condition to get only the reports with "Pending Board Actions" as web status
-- =============================================
CREATE PROCEDURE [dbo].[ScheduledReport_LicenseVerificationsWithPendingBoardActions]
	-- Add the parameters for the stored procedure here
	@CLNO int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	DROP TABLE IF EXISTS #tmpPendingBoardAction
    -- Insert statements for procedure here
	SELECT  
       c.WebOrderParentCLNO [Client Number]
       , 'HCA' [Client Name]
       , c.CLNO [Process Level]
       , c.Name [Process Level Name]
       , app.ClientCandidateId as [Applicant ID]
       , viar.PartnerReferenceNumber [Requisition Number]
       , a.First+ ' '+a.Last [Applicant Name]
       , a.APNO [Report Number]
       , format(a.ApDate, 'MM/dd/yyyy') [Report Start Date]
       ,[dbo].[ElapsedBusinessDays_2](a.ApDate, getdate()) [Elapsed(days)]
       , pl.Lic_Type [License Type]
	   , pl.State [License State]-- Added for HDT :84271
       , format(pl.Last_Updated, 'MM/dd/yyyy') [Last Attempt Made]
       , format(ase.ETADate, 'MM/dd/yyyy') ETA 
	INTO #tmpPendingBoardAction  -- Added for HDT :86829
	FROM Precheck.dbo.Appl a (NOLOCK)
	INNER JOIN Precheck.dbo.ProfLic pl(NOLOCK)ON a.APNO = pl.Apno
	INNER JOIN Precheck.dbo.ApplSectionsETA ase(NOLOCK) ON pl.Apno = ase.Apno AND pl.ProfLicID = ase.SectionKeyID
	INNER JOIN Precheck.dbo.Client c(NOLOCK) ON a.CLNO = c.CLNO
	LEFT JOIN Enterprise.PreCheck.vwIntegrationApplicantReport viar(NOLOCK) ON a.APNO = viar.APNO
	LEFT JOIN Enterprise.dbo.[Order] AS O(NOLOCK) ON viar.RequestID = O.IntegrationRequestId AND O.OrderNumber = viar.APNO 
	LEFT JOIN Enterprise.dbo.Applicant AS app(NOLOCK) ON O.OrderId = app.OrderId
	WHERE pl.Web_status= 94
	AND a.ApStatus = 'P'
	AND c.WebOrderParentCLNO = @CLNO
--UNION
--    SELECT  
--       c.WebOrderParentCLNO [Client Number]
--       , 'HCA' [Client Name]
--       , c.CLNO [Process Level]
--       , c.Name [Process Level Name]
--       , app.ClientCandidateId as [Applicant ID]
--       , viar.PartnerReferenceNumber [Requisition Number]
--       , a.First+ ' '+a.Last [Applicant Name]
--       , a.APNO [Report Number]
--       , format(a.ApDate, 'MM/dd/yyyy') [Report Start Date]
--       ,[dbo].[ElapsedBusinessDays_2](a.ApDate, getdate()) [Elapsed(days)]
--       , pl.Lic_Type [License Type]
--	   , pl.State [License State]-- Added for HDT :84271
--       , format(pl.Last_Updated, 'MM/dd/yyyy') [Last Attempt Made]
--       , format(ase.ETADate, 'MM/dd/yyyy') ETA 
--	FROM Precheck.dbo.Appl a (NOLOCK)
--	INNER JOIN Precheck.dbo.ProfLic pl(NOLOCK)ON a.APNO = pl.Apno
--	INNER JOIN Precheck.dbo.ApplSectionsETA ase(NOLOCK) ON pl.Apno = ase.Apno AND pl.ProfLicID = ase.SectionKeyID
--	INNER JOIN Precheck.dbo.Client c(NOLOCK) ON a.CLNO = c.CLNO
--	LEFT JOIN Enterprise.PreCheck.vwIntegrationApplicantReport viar(NOLOCK) ON a.APNO = viar.APNO
--	LEFT JOIN Enterprise.dbo.[Order] AS O(NOLOCK) ON viar.RequestID = O.IntegrationRequestId AND O.OrderNumber = viar.APNO 
--	LEFT JOIN Enterprise.dbo.Applicant AS app(NOLOCK) ON O.OrderId = app.OrderId
--	WHERE pl.SectStat= 'B'
--	AND a.ApStatus = 'P'
--	AND c.WebOrderParentCLNO = @CLNO

     DROP TABLE IF EXISTS #tmpreportnumber
    -- Added for HDT :86829 shows only reports where the pending board action is the only component in a pending status
	-- Exclude all pending statuses from empl, educat,crim - Sahithi -- Modified by Radhika Dereddy on 08/30/21
	--added new temptable below to insert reportnumber on 08/10/2023 by Anil Rai

	select distinct tmp.[Report Number] into #tmpreportnumber from #tmpPendingBoardAction tmp 
	inner join Precheck.dbo.Empl empl(NOLOCK) on tmp.[Report Number] = empl.Apno and empl.SectStat  in ( '9','H','0','C','A','7','6','B','U','R')
	inner join Precheck.dbo.Educat edu(NOLOCK) on tmp.[Report Number] = edu.Apno and edu.SectStat  in ( '9','A','H','R','0','C','7','6','B','U')
	inner join Precheck.dbo.Crim crim(NOLOCK) on tmp.[Report Number] = crim.Apno and (crim.Clear  in ('T','F','P','S','C','A','Z','W') or crim.Clear IS NULL)
	--where  empl.SectStat <> '9' and edu.SectStat <> '9' and crim.Clear <> 'R'

	--to get final report numbers as per HDT 83195
	select distinct tmp.* from #tmpPendingBoardAction tmp
	where [Report Number] not in ( select [Report Number] from #tmpreportnumber)
	

END