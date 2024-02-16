-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[getWebServicePassword]
	-- Add the parameters for the stored procedure here
	@CLNO int,@PWD varchar(50) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET @PWD = (select ISNULL(password,'') from client where clno = @CLNO);
END