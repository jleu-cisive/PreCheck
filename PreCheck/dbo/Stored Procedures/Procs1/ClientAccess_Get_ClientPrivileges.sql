-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Execution : EXEC [dbo].[ClientAccess_Get_ClientPrivileges] 'dharris',12444
	--EXEC [dbo].[ClientAccess_Get_ClientPrivileges] 'lmontoya',2167
--			   SELECT * FROM [Security].[GetAuthorizedClients](5570)
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_Get_ClientPrivileges]
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

	DECLARE  @TEMP TABLE
	(
		CLNO INT,
		NAME VARCHAR(100)
	)

	SELECT @CLIENTUSERID = CONTACTID FROM [DBO].[CLIENTCONTACTS] WHERE CLNO = @CLNO AND USERNAME = @USERNAME -- AND USERPASSWORD = @PASSWORD

	INSERT INTO @TEMP(CLNO, NAME)
	SELECT 0 AS CLNO , 'All' AS NAME 
	
	INSERT INTO @TEMP(CLNO, NAME)
	SELECT CLIENTID AS CLNO, CLIENT AS NAME FROM [SECURITY].[GETAUTHORIZEDCLIENTS] (@CLIENTUSERID)
	WHERE CLIENTID IN (SELECT CLNO FROM CLIENT  WHERE CLNO=@CLNO OR  WEBORDERPARENTCLNO=@CLNO)

	IF (SELECT COUNT(*) FROM @TEMP)>1
		SELECT NAME, CLNO FROM @TEMP ORDER BY CASE WHEN NAME ='All' THEN 0 ELSE 1 END ASC, NAME ASC
	ELSE
		SELECT NAME, CLNO FROM CLIENT WHERE CLNO = @CLNO


END


