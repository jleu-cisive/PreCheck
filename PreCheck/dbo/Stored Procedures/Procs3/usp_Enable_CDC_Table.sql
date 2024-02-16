CREATE PROCEDURE dbo.usp_Enable_CDC_Table
(@DbName	sysname
, @TblName sysname
,@ColName	sysname)
AS
BEGIN 
	SET NOCOUNT ON;
	DECLARE @sql nvarchar(4000)
	DECLARE @Cnt int
	CREATE TABLE #Out( Val int )

	SET @sql = N'SELECT COUNT(1) FROM [' + @DbName +'].dbo.[Audit_Tables] WHERE AuditTable = '+ '''' + @TblName  + ''''
	
	INSERT INTO #Out
	EXEC dbo.sp_executesql @statement = @sql;
	SELECT  @Cnt= Val FROM #Out

	IF @Cnt = 0
	BEGIN
	
		EXEC ('INSERT INTO [' + @DbName +'].[dbo].[Audit_Tables] ' +
		'SELECT TABLE_SCHEMA,TABLE_NAme,COLUMN_NAME, 1,0 FROM [' + @DbName +'].INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME =' + '''' + @TblName  + '''')
	END

	EXEC ('EXEC [' + @DbName +'].[dbo].[usp_Enable_CDC_Tables] @Tablename = ' + ''''+  @TblName  + ''', @DisableifExists =1' );
	--SELECT 'EXEC [' + @DbName +'].[dbo].[usp_Enable_CDC_Tables] @Tablename = ' + ''''+  @TblName  + ''', @DisableifExists =1' 

	IF NOT EXISTS (SELECT 1 FROM 	[dbo].[Sync_Config] WHERE TableName = ltrim(rtrim(@TblName)) + '_TRG' AND ISNULL(ColumnName,'') = @ColName)
		INSERT INTO [dbo].[Sync_Config](TableName,ColumnName,LastSyncDate) VALUES (ltrim(rtrim(@TblName))+'_TRG',@ColName , GETDATE()-1);

END
