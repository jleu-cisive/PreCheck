-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 08/18/2016
-- Description:	Surcharges (service charge billed) to the clients based on the state

-- EXEC [MVR_Surcharge_Billed_To_Clients] '02/01/2017', '02/28/2017'
-- =============================================
CREATE PROCEDURE [dbo].[MVR_Surcharge_Billed_To_Clients]
	-- Add the parameters for the stored procedure here
	@StartDate datetime,
	@EndDate datetime
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	select  a.Apno, a.Apstatus, a.Apdate, a.compdate, C.Name, id.Description, id.Amount, d.DateOrdered, rc.ClientType, rb.BillingCycle
	from Appl a
	inner join DL d on d.apno = a.apno
	inner join Client C on c.clno = a.clno
	inner join refAffiliate rf on rf.AffiliateID = c.AffiliateID
	inner join refClientType rc on rc.ClientTypeID = c.ClientTypeID
	inner join refBillingCycle rb on rb.BillingCycleId = c.BillingCycleID
	inner join InvDetail id on id.apno = a.apno
	where (CONVERT(DATETIME, FLOOR(CONVERT(FLOAT, d.DateOrdered))) >= @StartDate AND CONVERT(DATETIME, FLOOR(CONVERT(FLOAT, d.DateOrdered))) < = @EndDate)
	--where (d.DateOrdered between @StartDate and @EndDate) 
	and (id.Description like '%MVR Full%' or id.Description like '%MVR Adjusted%'  or id.Description like '%MVR State%' or id.Description like '%MVR Fee%' or id.Description like '%MVR  Fee%')
	 -- id.Description like '%MVR%' 
	and Type =1
	Order by 1 Desc

END
