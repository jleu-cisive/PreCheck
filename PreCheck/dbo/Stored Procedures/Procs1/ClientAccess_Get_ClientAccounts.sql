-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 08/31/2016
-- Description: Client access Forgot Password
-- =============================================
CREATE PROCEDURE ClientAccess_Get_ClientAccounts
	-- Add the parameters for the stored procedure here
	@email varchar(150),
	@CLNO int,
	@password varchar(14)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;	
	

	IF EXISTS (SELECT ContactID FROM ClientContacts WHERE email = @email and CLNO = @CLNO)
		BEGIN
			UPDATE ClientContacts SET UserPassword= @password WHERE email = @email and CLNO = @CLNO
		END
	
	SELECT * FROM ClientContacts WHERE email = @email and CLNO = @CLNO
END
