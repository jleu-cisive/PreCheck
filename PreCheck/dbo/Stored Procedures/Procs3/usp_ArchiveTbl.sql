CREATE PROCEDURE dbo.usp_ArchiveTbl
AS
BEGIN
SET NOCOUNT ON;

DECLARE @ProcessRows  INT = 10000
DECLARE @Table  varchar(255)
DECLARE @Duration int
DECLARE @Archive_Database varchar(255)
DECLARE @Archive_Table varchar(255)
DECLARE @Last_ArciveDate varchar(255)
DECLARE @ArchiveColumnFilter Varchar(255) 
DECLARE @TblSQL  varchar(max);
DECLARE @delSQL  varchar(max);
DECLARE @CNT Int

DECLARE TblCur CURSOR FOR SELECT 
	   [Table]
      ,[Duration]
      ,[Archive Database]
      ,[Archive_Table]
      ,[Last_ArciveDate]
	  ,[ArchiveColumnFilter]
  FROM [dbo].[DBA_ArchiveTbls] WHERE [Active] = 1;

  OPEN TblCur
  FETCH NEXT FROM TblCur INTO @Table, @Duration, @Archive_Database, @Archive_Table, @Last_ArciveDate,@ArchiveColumnFilter
  SELECT @Table,@@FETCH_STATUS
  WHILE @@FETCH_STATUS = 0
  BEGIN

	IF DATEADD(day,@Duration,@Last_ArciveDate) < CURRENT_TIMESTAMP
	BEGIN
		SET @Last_ArciveDate = DATEADD(day, (-1) * @Duration,CURRENT_TIMESTAMP)
		SET @TblSQL = 'INSERT INTO [' + @Archive_Database + '].dbo.[' +@Archive_Table + ']' 
		SET @TblSQL = @TblSQL + ' SELECT TOP ' + CONVERT(Varchar,@ProcessRows) + ' * FROM ' + @Table + ' WHERE ' + ISNULL(@ArchiveColumnFilter, '[DATE]') + ' <= ' + '''' +  CONVERT(Varchar(20),@Last_ArciveDate) + ''''
		SELECT @TblSQL;

		SET @delSQL = 'DELETE TOP  (' + CONVERT(Varchar,@ProcessRows) + ')  FROM ' + @Table + ' WHERE ' + ISNULL(@ArchiveColumnFilter, '[DATE]') + ' <= ' + '''' +  CONVERT(Varchar(20),@Last_ArciveDate) + ''''
		SELECT @delSQL;

		SET @CNT = 1
		WHILE @CNT <> 0
		BEGIN
			BEGIN TRAN
				EXEC (@TblSQL);
				SET @CNT = @@ROWCOUNT
				PRINT @Cnt;
				EXEC (@DelSQL);
			COMMIT TRAN
		END;
		SET @TblSQL = 'UPDATE [dbo].[DBA_ArchiveTbls] SET Last_ArciveDate = ' + ''''  + @Last_ArciveDate + '''' +  ' WHERE [TABLE] = ' + '''' +   @Table + '''' 
		EXEC(@TblSQL);
	END;
	FETCH NEXT FROM TblCur INTO @Table, @Duration, @Archive_Database, @Archive_Table, @Last_ArciveDate,@ArchiveColumnFilter
  END;
  CLOSE TblCur
  DEALLOCATE TblCur;
END;
