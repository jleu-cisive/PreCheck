
-- =============================================
-- Author:		Douglas DeGenaro
-- Create date: 04/23/2014
-- Description:	Show All statuses from refTable
-- =============================================
CREATE PROCEDURE [dbo].[AIMS_GetAllJobStatus] 
	-- Add the parameters for the stored procedure here		
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select AIMS_JobStatus as [Status],Description
	from [dbo].[refAIMS_JobStatus]
END

