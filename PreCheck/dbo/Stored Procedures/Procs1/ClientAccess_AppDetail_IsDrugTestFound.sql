-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 12/27/2017
-- Description:	Find if DrugTestfilefound in Appl is set to true or false for an APNO
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_AppDetail_IsDrugTestFound] 
	-- Add the parameters for the stored procedure here
	 @APNO int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT Client.AutoReportDelivery,Appl.IsDrugTestFileFound FROM Appl 
	INNER JOIN Client ON Appl.CLNO = Client.CLNO 
	WHERE Appl.APNO = @APNO

END
