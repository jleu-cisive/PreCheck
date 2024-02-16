
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Inova_Active_UserbyClientAccount]
	-- Add the parameters for the stored procedure here
	@StartDate DateTime,
	 @EndDate Datetime

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here


Select c.CLNO, c.Name as ClientName, a.First as FirstName, a.Last as LastName, a.Email as Email
from Appl a
Inner join Client C on C.CLNO = A.CLNO
where (a.Apdate between @StartDate and @EndDate)
and (c.clno in (1934,9747,3068,9717,1935,2993,1932,5615,9704,2081,1937,5559,8789,9719,3814,3696,3791,1936,9696,3047))
order by c.CLNO

END
