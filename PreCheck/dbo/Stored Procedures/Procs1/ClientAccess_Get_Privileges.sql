-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 06/24/2016
-- Description:	<Description,,>
-- Execution : EXEC [dbo].[ClientAccess_Get_Privileges] 'dharris',12444
--			   SELECT * FROM [Security].[GetAuthorizedClients](43783)
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_Get_Privileges]
	-- Add the parameters for the stored procedure here
	@Username VARCHAR(50),
	--@Password Varchar(50),
    @CLNO INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @CLIENTUSERID INT

	SELECT @CLIENTUSERID = CONTACTID FROM [dbo].[ClientContacts] WHERE CLNO = @CLNO AND USERNAME = @USERNAME -- AND USERPASSWORD = @PASSWORD
	
	select Client AS Name, ClientId AS CLNO  from [Security].[GetAuthorizedClients] (@CLIENTUSERID) Order By Client

END


