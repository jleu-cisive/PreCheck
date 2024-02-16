-- =============================================
-- Author:		Johnny Keller
-- Create date: 9/18/2019
-- Description:	Reprocess logging entries that are 
--				stuck/failed SSIS processing
-- =============================================
CREATE PROCEDURE [dbo].[AIMS_ReProcessThroughSSISByLoggingId] 
	-- Add the parameters for the stored procedure here
	(@loggingid int = 0)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	if(@loggingid > 0)
	BEGIN
		update DataXtract_Logging 
		set ProcessFlag = 1, ProcessDate = null 
		where DataXtract_LoggingId = @loggingid

		select DataXtract_LoggingId, ProcessFlag, ProcessDate
		From DataXtract_Logging 
		where DataXtract_LoggingId = @loggingid 
	END
END
