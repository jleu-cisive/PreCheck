-- ==================================================================================
CREATE PROCEDURE dbo.USP_DetailedTablesStorageReport
AS
BEGIN
   SET NOCOUNT OFF;
 
   DECLARE @SQLstring VARCHAR (300);
   --Create a Temporary Table to store report
   DECLARE @StorageRepTable TABLE (
      [Table_Name] VARCHAR (80)
      ,RowCnt INT
      ,TableSize VARCHAR(80)
      ,DataSpaceUsed VARCHAR(80)
      ,IndexSpaceUsed VARCHAR(80)
      ,Unused_Space VARCHAR(80)
      );
 
   --Create the Dynamic TSQL String
   SET @SQLstring = 'sp_msforeachtable ''sp_spaceused "?"''';
 
   --Populate Temporary Report Table
   INSERT INTO @StorageRepTable
   EXEC (@SQLstring);
 
   -- Sorting the report result 
   SELECT *
   FROM @StorageRepTable 
   ORDER BY Table_Name;
 
   SET NOCOUNT ON;
END
