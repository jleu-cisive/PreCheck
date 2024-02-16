-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 11/02/2017
-- Description:	Merge reports Pull client configuration
-- EXEC [MergeReports_PullClientConfigurations] 4575880
-- =============================================
CREATE PROCEDURE [dbo].[MergeReports_PullClientConfigurations]
	-- Add the parameters for the stored procedure here
	@APNO int
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT ClientConfiguration.ConfigurationKey, ClientConfiguration.Value 
	FROM DBO.ClientConfiguration 
	INNER JOIN DBo.Appl ON ClientConfiguration.CLNO = Appl.CLNO 
	WHERE (Appl.APNO = @APNO) AND ((ClientConfiguration.ConfigurationKey LIKE 'wo_merge%') or (ClientConfiguration.ConfigurationKey='ShowSummaryPage'))
END
