-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 03/11/2020
-- Description:	Configuration set up for Drug screening 
-- =============================================
CREATE PROCEDURE ClientConfigurationForDrugscreening
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * from ClientConfiguration_DrugScreening
END
