-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 09/06/2016
-- Description:	MVR Count by Default rates
-- =============================================
CREATE PROCEDURE [dbo].[MVR_Count_By_Rates]
	-- Add the parameters for the stored procedure here
@StartDate Datetime,
@EndDate Datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select  a.CLNO, C.Name, Count(D.APNO) as MVRCount, ra.Affiliate, 
dr.DefaultRate, cr.Rate
--, d.apno
	from Appl a
	inner join DL d on d.apno = a.apno
	inner join Client C on c.clno = a.clno
	inner join ClientRates cr on cr.CLNO = a.clno
	inner join DefaultRates dr on dr.ServiceID = cr.ServiceID 
	inner join refAffiliate ra on ra.AffiliateID = c.AffiliateID
	where (d.DateOrdered between @StartDate and @EndDate) and dr.ServiceID = 3
	group by a.Clno, C.Name, dr.DefaultRate, cr.Rate, ra.Affiliate
	--,d.apno
    Order by 1 Desc
END
