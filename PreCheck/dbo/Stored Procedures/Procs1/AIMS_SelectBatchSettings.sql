-- =============================================
-- Author:		An Vo
-- Create date: 7/13/2018
-- Description:	
-- =============================================
CREATE PROCEDURE AIMS_SelectBatchSettings
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
select Dataxtract_RequestMapping.SectionKeyId, AIMS_BatchSettings.IsBatchRetryEnabled from AIMS_BatchSettings inner join DataXtract_RequestMapping on AIMS_BatchSettings.Dataxtract_RequestMappingXMLId = DataXtract_RequestMapping.Dataxtract_RequestMappingXMLID
order by DataXtract_RequestMapping.SectionKeyId asc
END
