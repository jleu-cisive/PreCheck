
-- =============================================
-- Author:		<Radhika Dereddy>
-- Create date: 04/22/2015
-- Description:	<returns the Invocie pdf for a particular CLNo and firstname>
-- =============================================
CREATE PROCEDURE [dbo].[Get_ReleaseFormPDf]
	-- Add the parameters for the stored procedure here
	@CLNO int,
	@first varchar
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON;
    
	SELECT ApplicantInfo_pdf FROM dbo.ReleaseForm where CLNO = @CLNO and first = @first 


	
SET NOCOUNT OFF

END




