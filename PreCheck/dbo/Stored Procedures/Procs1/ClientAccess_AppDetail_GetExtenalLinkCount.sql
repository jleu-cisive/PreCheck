-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 02/08/2017
-- Description:	Get the external links count for an Apno if exists
-- =============================================
CREATE PROCEDURE ClientAccess_AppDetail_GetExtenalLinkCount 
	-- Add the parameters for the stored procedure here
	 @APNO int,
	 @CLNO int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT COUNT(*) FROM [ENTERPRISE].[VWEXTERNALLINKS] WHERE APPLICANTNUMBER = @APNO AND CLIENTID = @CLNO

END
