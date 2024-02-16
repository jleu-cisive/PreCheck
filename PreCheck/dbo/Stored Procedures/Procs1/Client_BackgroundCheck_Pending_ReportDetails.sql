-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Execution: [dbo].[Client_BackgroundCheck_Pending_ReportDetails] '12836','Tenet'
-- =============================================
CREATE PROCEDURE [dbo].[Client_BackgroundCheck_Pending_ReportDetails]
	-- Add the parameters for the stored procedure here
	@CLNO varchar(max) = NULL,
	@Affiliate varchar(50) =''

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT a.Apno as 'Report Number', c.Name as 'Client Name', a.first as 'First Name', a.last as 'Last Name', a.Apdate as 'Report Created Date', 
			case when (dbo.elapsedbusinessdays_2( a.Apdate, a.Origcompdate) 
				   + dbo.elapsedbusinessdays_2(a.Reopendate, a.Compdate)) < 6 then (dbo.elapsedbusinessdays_2(a.Apdate, a.Origcompdate) 
				   + dbo.elapsedbusinessdays_2(a.Reopendate, a.Compdate))
		   else 6 end as 'Elapsed Business Days'
	FROM Appl a with (Nolock)
	INNER JOIN Client c with (Nolock) on c.clno = a.clno
	INNER JOIN refAffiliate ra with (Nolock) on ra.AffiliateID = c.AffiliateID
	WHERE a.Apstatus='P' AND c.AffiliateID IN (Select AffiliateID from refAffiliate where Affiliate like '%' + @Affiliate + '%')
	  AND  (@Clno IS NULL OR A.CLNO IN (SELECT * from [dbo].[Split](':',@Clno)))

END