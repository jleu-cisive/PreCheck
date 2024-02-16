

CREATE PROCEDURE [dbo].[usp_Enable_CDC_Tables]
@Default_FileGroup		varchar(255) = N'FG_DATA'
,@Tablename				Varchar(255) = NULL
,@DisableifExists		bit = 0

AS

BEGIN

	SET NOCOUNT ON

	DECLARE @Sql	varchar(8000);

	DECLARE @RowCnt int;

	DECLARE @Schema sysname

	DECLARE @AuditTable sysname

	DECLARE @AColumns  varchar(4000)



	SELECT  row_number() OVER (ORDER BY A.Audittable DESC) AS Audit_ID,

	  AuditSchema,

	  AuditTable,

		STUFF((

			SELECT ',[' + u.AuditColumns + ']'

			FROM dbo.Audit_Tables u

			WHERE u.AuditTable = A.AuditTable AND u.ActiveFlag = 1

			ORDER BY u.AuditColumns

			FOR XML PATH('')

		),1,1,'') AS AColumns INTO #CDC

	FROM dbo.Audit_Tables A
	WHERE A.AuditTable = ISNULL(@Tablename,A.AuditTable)
	GROUP BY AuditSchema, AuditTable

	
	SET @RowCnt  = @@ROWCOUNT



	WHILE @RowCnt  > 0

	BEGIN

		SELECT @Schema =AuditSchema , @AuditTable = AuditTable, @AColumns = AColumns   FROM #CDC WHERE Audit_ID = @RowCnt



		IF EXISTS (	SELECT 1 FROM sys.tables WHERE name = @AuditTable AND is_tracked_by_cdc   = 1)

		BEGIN

			IF @DisableifExists = 1

			BEGIN



				SET @Sql  = N'EXEC sys.sp_cdc_disable_table

				@source_schema = N' + '''' + @Schema + '''

				, @source_name = N'+ '''' + @AuditTable + '''

				, @capture_instance = N'+ '''' + @Schema + '_' + @AuditTable + ''''

	

					SELECT @Sql
					EXEC(@Sql)  

			END

		END;



		IF NOT EXISTS (	SELECT 1 FROM sys.tables WHERE name = @AuditTable AND is_tracked_by_cdc   = 1)

		BEGIN

			SET @Sql  = N'EXEC sys.sp_cdc_enable_table

			@source_schema = N' + '''' + @Schema + '''

			, @source_name = N'+ '''' + @AuditTable + '''

			, @role_name = Null

			, @capture_instance = N'+ '''' + @Schema + '_' + @AuditTable + '''

			, @supports_net_changes = 1

			, @index_name = N''PK_'+  @AuditTable + '''

			, @captured_column_list = N' + '''' + @AColumns + '''

			, @allow_partition_switch =1

			, @filegroup_name = N'+ '''' + @Default_FileGroup + ''''



			SELECT @Sql  
			EXEC(@Sql)
		END



		SET @RowCnt = @RowCnt - 1;

	END

END;



