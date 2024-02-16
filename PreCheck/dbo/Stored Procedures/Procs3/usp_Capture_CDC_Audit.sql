
CREATE  PROCEDURE [dbo].[usp_Capture_CDC_Audit]
@Delay	int = 0
AS
BEGIN

	SET NOCOUNT ON;
	DECLARE @LogID int
	DECLARE @CommitDatetime datetime
	DECLARE @CurrentDatetime datetime
	DECLARE @RowCnt int
	DECLARE  @DbName sysname
			, @ColumnName  sysname
			, @TableName sysname
			, @ViewName  sysname
			, @PKColName sysname
			, @sql  nvarchar(4000)
	SELECT @CurrentDatetime  = DATEADD(SECOND, @Delay,CURRENT_TIMESTAMP)
	SELECT @CurrentDatetime =  dateadd(millisecond, -datepart(millisecond, @CurrentDatetime  ), @CurrentDatetime  ) ;

	SELECT PKColumnName, ChangelogID, DatabaseName, TableName,  ColumnName INTO #Sync FROM dbo.CDCChangelog;
	SET @RowCnt  = @@ROWCOUNT

	WHILE @RowCnt > 0
	BEGIN
		SELECT TOP 1  @LogID =ChangelogID, @PKColName = PKColumnName, @TableName = TableName, @ColumnName =ColumnName ,@DbName= DatabaseName  FROM #Sync;
		SELECT @ViewName = '[CTCFG].[vw' + ltrim(rtrim(@TableName))+ '_' + ltrim(rtrim(@ColumnName)) + ']'
	
		--SELECT @DbName,@TableName,@ColumnName,@PKColName,@ViewName

		SELECT @CommitDatetime =  CONVERT(DATETIME,CONVERT(VARCHAR(20),[LastSyncDate],120))  FROM [dbo].[Sync_Config] WHERE TableName = @TableName + '_TRG' AND ISNULL(ColumnName, '') = @ColumnName
--		SELECT @CommitDatetime 
		
		SET @sql = N'SELECT distinct ' +
		CAST(@LogID AS Varchar)+  ' AS LogID, ' +
		@PKColName + ' AS KeyColumnValue, ' +
		'Old_' + @ColumnName + ' , ' + 
		'New_' + @ColumnName + ' , ' +
		'dateadd(millisecond, -datepart(millisecond, CommitDateTime), CommitDateTime)  AS CommitDateTime, 
		LastModifiedBy
		FROM  ' + @ViewName 
		+ ' WHERE CONVERT(DATETIME,CONVERT(VARCHAR(20),CommitDateTime,120)) >= ' + '''' + CAST(@CommitDatetime AS varchar) + ''''
		SELECT @sql 
		INSERT INTO dbo.CDCChangelogDetail
		(ChangeLogId	,
		KeyColumnValue	,
		OldValue	,
		NewValue	,
		[ChangeDate]	,
		[ChangedBy]	)	
		EXEC dbo.sp_executesql @statement = @sql;


		UPDATE [dbo].[Sync_Config] SET[LastSyncDate] =  @CurrentDatetime WHERE TableName = @TableName + '_TRG'
		DELETE FROM #Sync WHERE TableName = @TableName AND  ColumnName = @ColumnName AND  DatabaseName  = @DbName;
		SET @RowCnt = @RowCnt -1;
	END;
END;


