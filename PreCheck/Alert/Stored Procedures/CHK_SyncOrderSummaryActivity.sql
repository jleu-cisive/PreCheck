
CREATE PROCEDURE [Alert].[CHK_SyncOrderSummaryActivity]
AS 
BEGIN 
	SET NOCOUNT ON 
	SET Transaction ISOLATION  LEVEL READ UNCOMMITTED     
	
	DECLARE @JobSource VARCHAR(5000) = 'SSIS package SyncOrderSummary'
	DECLARE @NotifySourceName VARCHAR(100) = 'CHK_SyncOrderSummaryActivity'
	DECLARE @CAMEmailAlternative VARCHAR(500) = ''
	DECLARE @ThresholdHours INT = 1
	DECLARE @ErrorMessage Varchar(max)
	DECLARE @HasError BIT

	DECLARE @LastRunTime DATETIME 
	
	DECLARE @LastRunId INT

	;WITH cte_latestRun
	AS
    (
		SELECT 
		TOP 1
		DWHLogId,
		StartTime
		FROM StudentCheck.DWHLog
		ORDER BY StartTime desc
	)

	SELECT @LastRunTime=l.StartTime, @LastRunId=l.DWHLogId, @ErrorMessage = ErrorMessage, @HasError = HasError 
	  FROM StudentCheck.DWHLog l
	INNER JOIN cte_latestRun lr ON l.DWHLogId=lr.DWHLogId

	IF @LastRunTime < DATEADD(HOUR,-@ThresholdHours,GETDATE()) Or @HasError = 1
	BEGIN
	SELECT 
		Email			= 'dongmeihe@precheck.com' 
		,CCEmail		= 'gauravbangia@precheck.com'
		,JobName		= 'StudentCheck SyncOrderSummary'
		,NumberOfHours	= DATEDIFF(HOUR,@LastRunTime,GETDATE())
		,LastRunDate	= @LastRunTime
		,[LastRunId]	= @LastRunId
		,JobSource		= @JobSource
		,ConfigHours	= @ThresholdHours
		
		,ErrorMessage    = @ErrorMessage
	END
end
