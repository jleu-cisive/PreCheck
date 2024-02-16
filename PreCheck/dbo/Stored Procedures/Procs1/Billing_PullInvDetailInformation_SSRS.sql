CREATE PROCEDURE [dbo].[Billing_PullInvDetailInformation_SSRS]
	-- Add the parameters for the stored procedure here
	@InvoiceNumber int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT D.*,D.Billed as InvDetailBilled,A.Last,A.First,A.Middle,A.CompDate,A.APNO as ApplAPNO,A.DeptCode,
	CONVERT(varchar(MAX), CONCAT(ISNULL(A.Last,''),',',ISNULL(A.First,''),' ',ISNULL(A.Middle,''),' ',ISNULL(A.DeptCode,''))) as FullName
	FROM InvDetail D,Appl A WHERE D.InvoiceNumber = @InvoiceNumber
	AND D.apno = A.apno
	order by FullName,D.type, D.Description

SET NOCOUNT OFF
END

