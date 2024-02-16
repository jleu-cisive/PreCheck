-- =============================================
-- Author:		Dongmei He
-- Create date: 03/24/2022
-- Description:	Update last execution time for 
--              StudentCheck Order Summary data load
-- =============================================
CREATE PROCEDURE [StudentCheck].[UpdateNextExecutionTime]
@NextExecutionTime DATETIME = NULL
AS
BEGIN 
--TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
   
    UPDATE ClientConfiguration SET Value = @NextExecutionTime
	 WHERE ConfigurationKey = 'Job.StudentCheck.LastExecutionTime'
                                                                    
END 



