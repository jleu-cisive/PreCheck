-- =============================================
-- Author:		Radhika Dreeddy
-- Create date: 09/09/2016
-- Description:	MVR Count by Report Number ad Client
-- =============================================
CREATE PROCEDURE [dbo].[MVR_Count_By_Client]

@StartDate Datetime,
@EndDate Datetime,
@CLNO int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select  a.CLNO, A.Apno, A.First, A.Last, A.DL_Number, A.DL_State, 
 cr.Rate
--, d.apno
	from Appl a
	inner join DL d on d.apno = a.apno
	inner join Client C on c.clno = a.clno
	inner join ClientRates cr on cr.CLNO = a.clno
	inner join DefaultRates dr on dr.ServiceID = cr.ServiceID 	
	inner join refAffiliate ra on ra.AffiliateID = c.AffiliateID
	where (d.Last_Updated between @StartDate and @EndDate) and dr.ServiceID = 3 and a.CLNO = @CLNO
	group by A.Apno, a.Clno, A.DL_Number, A.DL_State, A.First, A.Last
	,cr.Rate
	--,d.apno
    Order by 1 Desc
END
