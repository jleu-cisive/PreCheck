

CREATE PROCEDURE [dbo].[usp_Capture_License_Status]
AS
BEGIN

	SET NOCOUNT ON;
	DECLARE @LogID int
	DECLARE @CommitDatetime datetime
	DECLARE @CurrentDatetime datetime

	SELECT @CurrentDatetime  = DATEADD(MINUTE,-1,CURRENT_TIMESTAMP)
	SELECT @CurrentDatetime =  dateadd(millisecond, -datepart(millisecond, @CurrentDatetime  ), @CurrentDatetime  ) ;

	--SELECT @CommitDatetime = dateadd(millisecond, datediff(millisecond, 0, [LastSyncDate]), 0) FROM [dbo].[Sync_Config] WHERE TableName = 'Appl_CT_TRG'
	SELECT @CommitDatetime =  [LastSyncDate] FROM [dbo].[Sync_Config] WHERE TableName = 'License_CT_TRG'
	
	SELECT @LogID  = ChangelogID FROM dbo.CDCChangelog WHERE DATABASEName = 'HEVN' AND TableName = 'License' AND ColumnName = 'Status'
	
	INSERT INTO dbo.CDCChangelogDetail
	(ChangeLogId	,
	KeyColumnValue	,
	OldValue	,
	NewValue	,
	[ChangeDate]	,
	[ChangedBy]	)	
	SELECT distinct
	@LogID , 
	LicenseID, 
	Old_Status, 
	New_Status, 
	dateadd(millisecond, -datepart(millisecond, CommitDateTime), CommitDateTime) AS CommitDateTime,
	LastModifiedBy
	FROM  [HEVN].[CTCFG].[vwLicence_Status]
	WHERE CommitDateTime >= @CommitDatetime;


	UPDATE [dbo].[Sync_Config] SET[LastSyncDate] =  @CurrentDatetime WHERE TableName = 'License_CT_TRG'
END;


