-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 04/19/2021
-- Description:	Audit for Batch submission to ThomasAndCompany
-- =============================================
CREATE PROCEDURE [dbo].[EmplAuditForThomasAndCompany]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * FROM dbo.EmplAudit (nolock)
END
