-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 08/31/2017
-- Description:	Get the details of the report for Credit
-- =============================================
CREATE PROCEDURE ClientAccess_AppDetail_pullCredit
	-- Add the parameters for the stored procedure here
	@apno int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT Report FROM Credit where RepType = 'C' and Apno =  @apno
END
