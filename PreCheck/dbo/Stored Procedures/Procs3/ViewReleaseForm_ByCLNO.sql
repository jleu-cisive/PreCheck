
-- =============================================
-- Author:		<Radhika Dereddy>
-- Create date: <10/25/2013>
-- Description:	<returns the Invocie pdf for a particular CLNo and InvoiceNumber>

--EXEC [ViewReleaseForm_ByCLNO] 12367, 167217
-- =============================================
CREATE PROCEDURE [dbo].[ViewReleaseForm_ByCLNO]
	-- Add the parameters for the stored procedure here
	@CLNO int,
	@InvoiceNumber int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON;
    	

	Select pdf from [Precheck_PreProd].dbo.[ReleaseForm] rf
	inner join Appl a on a.CLNO = rf.CLNO 
	where rf.CLNO = @CLNO and a.Apno = @InvoiceNumber

	
SET NOCOUNT OFF

END




