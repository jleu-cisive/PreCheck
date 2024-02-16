-- =============================================
-- Author:		Douglas DeGenaro
-- Create date: 09/05/2014
-- Description:	Update AIMS job status by Job Id
-- =============================================
CREATE PROCEDURE dbo.AIMS_UpdateJobStatusById 
	-- Add the parameters for the stored procedure here
	@JobStatus char,
	@JobId int
AS	
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE [dbo].[AIMS_Jobs]
   SET 	         
      [AIMS_JobStatus] = @JobStatus      
      ,[JobStart] = null
      ,[JobEnd] = null
      ,[RetryCount] = null
      ,[IsPriority] = 1
      ,[DataXtract_LoggingId] = null
      ,[AgentStatus] = null
      ,[Last_Updated] = CURRENT_TIMESTAMP
 WHERE 
	  [AIMS_JobID] in (@JobId)
END
