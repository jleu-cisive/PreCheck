-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 07/18/2017
-- Description:	Client Notes with Additional Fees
-- =============================================
CREATE PROCEDURE ClientNotes_with_AdditionalFees 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Select CLNO, NoteType, NoteText from ClientNotes where NoteText like '%Searches with Additional Fees are to be performed at No Additional Cost to the Client/Student%'
END
