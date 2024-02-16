
CREATE PROCEDURE dbo.usp_CDC_Audit_Log
@ChangeLogID   Int
AS
BEGIN
	DECLARE @PkColName sysname
	, @DbName sysname
	, @ColumnName  sysname
	, @TableName sysname
	, @ViewName  varchar(1000)
	, @objName varchar(1000)
	, @CDCName Varchar(1000)
	, @Sql  nvarchar(4000)
	, @AuditUserColumn varchar(200)

	SELECT @PkColName =PKColumnName, @DbName = DatabaseName, @TableName = TableName, @ColumnName = ColumnName, @AuditUserColumn = AuditUserColumn  
	FROM [dbo].[CDCChangeLog] 
	WHERE ChangeLogID = @ChangeLogID;

	EXEC dbo.usp_Enable_CDC_Table @DbName, @TableName, @ColumnName;

	SELECT @ViewName = '[CTCFG].[vw' + ltrim(rtrim(@TableName))+ '_' + ltrim(rtrim(@ColumnName)) + ']'
	SELECT @objName = ltrim(rtrim(@DbName)) + '.[CTCFG].[vw' + ltrim(rtrim(@TableName))+ '_' + ltrim(rtrim(@ColumnName)) + ']'
	SELECT @CDCName = ltrim(rtrim(@DbName)) + '.[CDC].[dbo_' + ltrim(rtrim(@TableName))+ '_CT]' 
	SET @sql = N'DROP VIEW ' + @ViewName 
	
	IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(@ViewName))
		EXEC dbo.sp_executesql @statement = @sql;

		SET @SQl = N'CREATE VIEW ' +@ViewName + ' AS 
						SELECT DISTINCT N.' + @PkColName + ', O.' + @ColumnName + ' AS Old_' + @ColumnName+ ', N.' + @ColumnName + ' AS New_' + @ColumnName + ', T.tran_end_time AS CommitDateTime' +
						+ IIF(@AuditUserColumn IS NULL, ' ,NULL',', N.' + @AuditUserColumn ) +  ' AS LastModifiedBy ' +
						'FROM ' + @CDCName + ' O INNER JOIN ' + @CDCName + ' N ' +
						' ON O.' + @PkColName + ' = N.' + @PkColName + ' AND N.__$start_lsn = O.__$start_lsn AND O.__$operation = 3  AND N.__$operation= 4
						LEFT OUTER  JOIN [' + ltrim(rtrim(@DbName)) + '].cdc.lsn_time_mapping T ON N.__$start_lsn = Start_lsn
						WHERE ISNULL(O.' + @ColumnName + ',' + '''''' + ') <>  ISNULL(N.' + @ColumnName + ',' + '''''' + ');' 
	--SELECT @SQl
	IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(@ViewName))
			EXEC dbo.sp_executesql @statement = @sql;
					

END
