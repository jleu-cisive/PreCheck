-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 07/30/2021
-- Description:	Update Parameters from Qreportusermap
-- =============================================
CREATE PROCEDURE [dbo].[QReport_UpdateQReportParameters]
	-- Add the parameters for the stored procedure here
@LastParams varchar(max),
@qreportUserMapID int


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
Update [ALA-SQL-05].Precheck.dbo.QReportUserMap set LastParameters = @LastParams WHERE QReportUserMapID = @qreportUserMapID 




END
