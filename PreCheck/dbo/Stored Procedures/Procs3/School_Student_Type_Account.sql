-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 01/24/2017
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[School_Student_Type_Account]
	-- Add the parameters for the stored procedure here
	@CLNO int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here


 select  a.CLNO, c.Name, rc.ClientType, BillCycle, a.Apno, a.apdate, c.BillCycle, c.SchoolWillPay, a.Billed, a.ApStatus,  cp.rate, a.EnteredVia  
 from Appl a
 inner join CLient c on a.clno = c.clno
 inner join ClientPackages cp on c.CLNO = cp.clno
 inner join refClientType rc on c.ClientTypeID = rc.ClientTypeID
 where a.EnteredVia = 'WEB' and c.ClientTypeID = 8 and c.IsInactive = 0 and c.SchoolWillPay = 0
 and a.CLNO = IIF(@CLNO=0,A.CLNO,@CLNO)


END
