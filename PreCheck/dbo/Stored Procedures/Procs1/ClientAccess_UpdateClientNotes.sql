
-- =============================================
-- Author:		<Liel Alimole>
-- Create date: <05/20/2013>
-- Description:	<Gets change log of employer>
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_UpdateClientNotes]
	-- Add the parameters for the stored procedure here
	@apno int,
	@notes varchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
update appl  set ClientNotes = @notes where apno = @apno; 
 
END


