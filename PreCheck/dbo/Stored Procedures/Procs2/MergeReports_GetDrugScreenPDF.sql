-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 10/11/2017
-- Description:	Merge Reports Application refers to this stored procedure to get the
-- drug screen pdf when candidateinfoid is the orderidorapno
-- EXEC MergeReports_GetDrugScreenPDF  3818147
-- =============================================
CREATE PROCEDURE [MergeReports_GetDrugScreenPDF]
	-- Add the parameters for the stored procedure here
		 @TID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   
 Select Top(1) PDFReport from OCHS_PDFReports WHERE TID = @TID ORDER BY AddedOn DESC

END
