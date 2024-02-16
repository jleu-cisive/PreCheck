-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 07/19/2017
-- Description:	Pass thru charges greater than certain amount
-- Modified by Aashima on 19/08/2022 - Fixed logic in where clause for Apdate to only compare date value with @StartDate and @EndDate's date value only
-- EXEC PassThru_Charge_Greaterthan_Amount 0, '06/01/2017', '06/30/2017'
-- =============================================
CREATE PROCEDURE [dbo].[PassThru_Charge_Greaterthan_Amount]
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
	SELECT  a.Apno, c.CLNO, c.Name as 'Client Name', rf.Affiliate, a.UserID as CAM, a.Investigator, description, i.Amount, a.ApDate as 'App Created Date', a.CompDate as 'App Closed Date'
	FROM dbo.Appl a WITH(nolock)
	inner join InvDetail i with(nolock) on a.APNO = I.APNO 
	inner join Client c with(nolock) on a.clno = c.clno
	inner join refAffiliate rf with(nolock) on c.AffiliateID = rf.AffiliateID
	WHERE c.CLNO <>'3468' 
	and (Description  not LIKE '%Package%') 
	and (Amount >= @Amount) 
	and (cast(Apdate as date) >= cast(@StartDate as date) and cast(Apdate as date) <= cast(@EndDate as date))
END
