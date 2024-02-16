CREATE PROCEDURE dbo.usp_CompressUserTables (
 @pTableName		Varchar(255) = NULL,
  @compression_mode VARCHAR(30),
  @schema VARCHAR(30),
  @Thresold INT )

AS

BEGIN
 SET NOCOUNT ON
 
 DECLARE @tsql VARCHAR(200)
 , @tablename VARCHAR(60)
 ,@EstimatedSize BIGINT
 
 DECLARE cur CURSOR
 FOR
 (SELECT DISTINCT t.NAME AS table_name
 FROM sys.partitions p ,sys.tables t ,sys.schemas s
 WHERE p.object_id = t.object_id AND p.partition_number = 1 AND t.schema_id = s.schema_id
  AND s.NAME = @schema AND p.data_compression = 0 and t.name = isNULL(@pTableName,t.name));

 -- Capture results
 CREATE TABLE #CompressTbl (
  [object_name] SYSNAME
  ,[schema_name] SYSNAME
  ,[index_id] INT
  ,[partition_number] INT
  ,[size_with_current_compression_settingKB] BIGINT
  ,[size_with_requested_compression_settingKB] BIGINT
  ,[sample_size_with_current_compression_settingKB] BIGINT
  ,[sample_size_with_requested_compression_settingKB] BIGINT );

 OPEN cur 
 FETCH NEXT FROM cur INTO @tablename
 WHILE @@FETCH_STATUS = 0
 BEGIN
  INSERT INTO #CompressTbl
  EXECUTE sp_estimate_data_compression_savings @schema_name = @schema
  ,@object_name = @tablename
  ,@index_id = NULL
  ,@partition_number = NULL
  ,@data_compression = @compression_mode;

  SELECT @EstimatedSize =  ([size_with_current_compression_settingKB] - 
                               [size_with_requested_compression_settingKB])
  FROM #CompressTbl

  IF (@EstimatedSize > @Thresold)
  BEGIN
   SET @tsql = 'ALTER TABLE ' + @schema + '.[' + @tableName + ']' +
    ' rebuild WITH( DATA_COMPRESSION = ' + @compression_mode + ' )'
   EXEC (@tsql)
  END
  TRUNCATE TABLE #CompressTbl
  FETCH NEXT FROM cur INTO @tablename
 END
 CLOSE cur
 DEALLOCATE cur
 DROP TABLE #CompressTbl
 set nocount off
END
