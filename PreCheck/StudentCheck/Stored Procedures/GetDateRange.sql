-- =============================================
-- Author:		Dongmei He
-- Create date: 03/24/2022
-- Description:	Get date range for 
--              StudentCheck Order Summary data load
-- =============================================
CREATE PROCEDURE [StudentCheck].[GetDateRange]
AS
BEGIN 
--TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
   
    SELECT CAST(Value AS DATETIME) AS LastExecutionTime, GETDATE() AS NextExecutionTime 
	  FROM ClientConfiguration WHERE ConfigurationKey = 'Job.StudentCheck.LastExecutionTime'
                                                                    
END 



