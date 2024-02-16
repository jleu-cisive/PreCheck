
-- =============================================
-- Author:		<Radhika Dereddy>
-- Create date: <10/15/2013>
-- Description:	<Gets the Run Number for each billing Cycle>
-- =============================================
CREATE PROCEDURE [dbo].[Billing_GetRunNumber]
	-- Add the parameters for the stored procedure here
	@RunNumber int OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
    -- Insert statements for procedure here
	SELECT @RunNumber = Max(RunNumber) + 1 FROM InvRegistrarTotal
SET NOCOUNT OFF
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
END




