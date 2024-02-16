-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 06/24/2016
-- Description:	<Description,,>
-- Execution : EXEC [ClientAccess_Get_SecurityPrivilege] 'kdahm',12444
--			   SELECT * FROM [Security].[GetAuthorizedClients](5570)
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_Get_SecurityPrivilege]
	-- Add the parameters for the stored procedure here
	@Username VARCHAR(50),
	@CLNO INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @CLIENTUSERID INT

	SELECT @CLIENTUSERID = CONTACTID FROM [dbo].[ClientContacts] WHERE CLNO = @CLNO AND USERNAME = @USERNAME -- AND USERPASSWORD = @PASSWORD
	
	SELECT ClientId AS CLNO, Client AS Name  from [Security].[GetAuthorizedClients] (@CLIENTUSERID) ORDER BY Client

END


