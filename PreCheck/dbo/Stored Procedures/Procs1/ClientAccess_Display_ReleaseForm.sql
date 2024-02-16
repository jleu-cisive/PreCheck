-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 10/29/2015
-- Description:	Retrieve the pdf from Releaseform tables either from PrecheckDatabase or PrecheckMain_Archive
-- =============================================

--EXEC ClientAccess_Display_ReleaseForm 820300, 'date'
CREATE PROCEDURE [dbo].[ClientAccess_Display_ReleaseForm]
	-- Add the parameters for the stored procedure here
	@releaseFormID int,
	 @col varchar(50) = 'ApplicantInfo_pdf'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
    -- Insert statements for procedure here
	DECLARE @ReleaseID int


	SET @ReleaseID = (Select ReleaseFormID from Precheck.dbo.ReleaseForm where ReleaseFormID = @releaseFormID)
	
Declare @SQL varchar(500)

	IF @ReleaseID IS NOT NULL
		BEGIN			
		    SET @SQL = 'Select ' +  @col + ' from Precheck.dbo.ReleaseForm where ReleaseFormID = ' +  Cast(@releaseFormID as varchar)
		END
	ELSE
		BEGIN
			SET @SQL = 'Select isnull(' + @col + ',pdf)  as ' + @col + ' from Precheck_MainArchive.dbo.ReleaseForm_Archive where ReleaseFormID = ' + Cast(@releaseFormID as varchar)
		END
	
		EXEC(@SQL)


	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	SET NOCOUNT OFF;
END




