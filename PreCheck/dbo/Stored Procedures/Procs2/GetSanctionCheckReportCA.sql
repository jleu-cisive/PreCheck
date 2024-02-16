-- =============================================
-- Author:		Vairavan
-- Create date: 06/17/2022
-- Description:	Gets SanctionCheck Report - CA 
--Ticket no - 42128
--Requested by  - Jessie Yarborough

--Testing 
--[dbo].[GetSanctionCheckReportCA] 0,'06/01/2015','05/31/2016',0
-- =============================================
CREATE PROCEDURE [dbo].[GetSanctionCheckReportCA]
	-- Add the parameters for the stored procedure here
	@clno int = 0, @StartDate datetime, @EndDate datetime,@AffiliateID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select appl.Apno as  [Report Number],appl.CLNO as [Client ID],
		   c.Name as [Client Name],rf.Affiliate, rf.AffiliateID,appl.Last,appl.First,appl.Middle,appl.SSN,appl.DOB  as DOB,
	       sectstat.Description as [Component Status],
	       format(appl.ApDate,'MM/dd/yyyy hh:mm tt') as Sanction_Create_date,
		   format(appl.CompDate,'MM/dd/yyyy hh:mm tt')  as Sanction_complete_date,
		  Case when appl.CompDate is null then NULL else 
		           cast([dbo].[ElapsedBusinessDays_2](appl.ApDate,appl.CompDate) as varchar)+ ' days '+cast(datediff(HOUR,appl.ApDate,appl.CompDate)%24 as varchar)+' hours'
		  end as  [Sanction TAT by Days & Hours]
	from Appl appl with(nolock)
	inner join MedInteg medInteg with(nolock) on appl.apno = medInteg.apno
	inner join SectStat sectstat with(nolock) on CAST(medInteg.SectStat as char(1)) = CAST(sectstat.Code as char(1))
	INNER JOIN client c with(nolock)  on appl.clno = c.clno
	INNER JOIN refAffiliate rf with(nolock)  ON c.affiliateID = rf.AffiliateID
	where CAST(medInteg.SectStat as char(1)) <> '1' 
	and appl.ApDate between @StartDate  and  Dateadd(d,1,@EndDate)
	and	c.CLNO = IIF(@clno=0,c.CLNO,@CLNO)
	AND rf.AffiliateID = IIF(@AffiliateID=0,rf.AffiliateID,@AffiliateID)

  	SET NOCOUNT OFF;
END
