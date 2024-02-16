-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 11/15/2016
-- Description:	<Description,,>
-- Execution : EXEC [dbo].[ClientAccess_Get_ClientSecurityPrivileges] 'jpiesman','',12444
	--EXEC [dbo].[ClientAccess_Get_ClientSecurityPrivileges] 'lmontoya','', 2167
--			   SELECT * FROM [Security].[GetAuthorizedClients](5570)
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_Get_ClientSecurityPrivileges_test]
	-- Add the parameters for the stored procedure here
	@Username VARCHAR(50),
	@Password Varchar(50),
    @CLNO INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @CLIENTUSERID INT

	DECLARE  @temp Table
	(
		CLNO int,
		Name varchar(100)
	)

	SELECT @CLIENTUSERID = CONTACTID FROM [dbo].[ClientContacts] WHERE CLNO = @CLNO AND USERNAME = @USERNAME AND USERPASSWORD = @PASSWORD

	insert into @temp(CLNO, Name)
	sELECT 0 AS CLNO , 'All' AS Name 
	
	Insert into @temp(CLNO, Name)
	select ClientId AS CLNO, Client AS Name from [Security].[GetAuthorizedClients] (@CLIENTUSERID)
	WHERE ClientId IN (SELECT clno FROM client  WHERE clno=@CLNO OR  WebOrderParentCLNO=@CLNO)

	IF (Select count(*) From @temp)>1
		select Name, CLNO from @temp
	else
		select Name, CLNO from Client where CLNO = @CLNO


END


