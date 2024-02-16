
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Web_ValidateUserNT]
	-- Add the parameters for the stored procedure here
	@UserName varchar(30),@Password varchar(30),@CLNO int
AS
BEGIN	
	
 SELECT ContactID FROM dbo.ClientContacts WHERE username = @UserName
 AND UserPassword = @Password AND CLNO = @CLNO
END