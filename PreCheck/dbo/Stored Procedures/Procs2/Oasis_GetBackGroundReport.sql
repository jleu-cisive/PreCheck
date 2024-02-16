


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Oasis_GetBackGroundReport]
	 @APNO int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT BackgroundReportID, CreateDate FROM BackgroundReports.dbo.BackgroundReport WHERE APNO = @APNO 

ORDER BY CreateDate DESC
END



