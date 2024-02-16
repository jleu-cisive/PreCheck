-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Billing_PullInvDetailInformation]
	-- Add the parameters for the stored procedure here
	@InvoiceNumber int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT D.*,A.Last,A.First,A.Middle,A.CompDate,A.APNO,A.DeptCode
	FROM InvDetail D,Appl A WHERE D.InvoiceNumber = @InvoiceNumber
	AND D.apno = A.apno
	order by A.last,A.first,A.middle,A.apno,D.type, D.Description -- Added D.Description -Radhika Dereddy 12/05/2013

SET NOCOUNT OFF
END




