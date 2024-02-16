-- =============================================
-- Author:		Prasanna
-- Create date: 07/01/2020
-- Description:	Pass thru charges for certain amount
-- EXEC [QReport_PassThruChargesByAmount] 0, '06/01/2017', '06/30/2017'
-- =============================================
CREATE PROCEDURE [dbo].[QReport_PassThruChargesByAmount]
	-- Add the parameters for the stored procedure here
	@Amount smallmoney,
	@StartDate datetime,
	@EndDate Datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT  a.Apno, c.CLNO, c.Name as 'Client Name', rf.Affiliate, a.UserID as CAM, a.Investigator, 
	i.description, i.Amount, a.ApDate as 'App Created Date', a.CompDate as 'App Closed Date'
	FROM dbo.Appl a 
	inner join InvDetail i on a.APNO = I.APNO 
	inner join Client c on a.clno = c.clno
	inner join refAffiliate rf on c.AffiliateID = rf.AffiliateID
	WHERE c.CLNO <>'3468' 
	and (i.Description not LIKE '%Package%') 
	and (i.Amount = @Amount) 
	and a.Apdate >= @StartDate and a.Apdate <= @EndDate
END
