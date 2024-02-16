
-- =============================================
-- Author:		Douglas DeGenaro
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[WS_GetInvalidCharacters] 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Select * from [dbo].InvalidXmlChars
END

