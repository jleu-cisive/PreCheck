-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 03/17/2017
-- Description:	Get Lastname and Apno for all the releaseformid's where enteredVia is CIC
-- =============================================
--EXEC [InternalWebService_GetApnoNameforURL] 2774779,'bryd',0

CREATE PROCEDURE [dbo].[InternalWebService_GetApnoNameforURL]
	-- Add the parameters for the stored procedure here
	@releaseFormID int,
	@lastName varchar(50) output,
	@apno int output

	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT @lastName = lastname, @apno = apno  FROM  Enterprise.vwReleaseForm_Order WITH (NOLOCK)
	WHERE ReleaseFormId = @releaseFormID

	--SELECT @lastName, @apno

	SET NOCOUNT OFF

END
