-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 02/14/2017
-- Description:	Get the Last name for an Apno and the clno
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_AppDetail_GetLastName] 
	-- Add the parameters for the stored procedure here
	 @APNO int,
	 @CLNO int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT Last FROM [dbo].[Appl](nolock) WHERE APNO = @APNO AND CLNO = @CLNO

END
