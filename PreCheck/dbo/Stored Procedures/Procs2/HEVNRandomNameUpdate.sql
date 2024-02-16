-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[HEVNRandomNameUpdate]
	-- Add the parameters for the stored procedure here
	(@clno int,@lastrundate datetime)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
   Update ClientConfig set HRNGLastRunDate = @lastrundate WHERE CLNO = @clno
END
