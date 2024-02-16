create procedure usp_UnusedTables

as

declare @databasename varchar(50)
set @databasename = 'precheck'

declare @TableDetails_Query nvarchar(max)

if exists (select name from tempdb.sys.tables where name like '%#TableDetails%')
drop table #TableDetails
create table #TableDetails
(
        [Database_Name] varchar(50)
    ,[Schema_Name] varchar(50)
    ,[Object_Id] bigint
    ,[Table_Name] varchar(500)
    ,[Modified_Date] datetime
)
set @TableDetails_Query =
'INSERT INTO #TableDetails (
    [Database_Name]
    ,[Schema_Name]
    ,[Object_Id]
    ,[Table_Name]
    ,[Modified_Date]
    )
SELECT DatabaseName
    ,SchemaName
    ,ObjectId
    ,TableName
    ,ModifiedDate
FROM (
SELECT DISTINCT ' + '''' + @DatabaseName + '''' + ' AS DatabaseName
    ,sch.NAME AS SchemaName
    ,tbl.object_id AS ObjectId
    ,tbl.NAME AS TableName
    ,tbl.modify_date AS ModifiedDate
FROM ' + @DatabaseName + '.sys.tables AS tbl
INNER JOIN ' + @DatabaseName + '.sys.schemas AS sch ON tbl.schema_id = sch.schema_id
LEFT JOIN ' + @DatabaseName + '.sys.extended_properties AS ep ON ep.major_id = tbl.[object_id] /*Exclude System Tables*/
WHERE tbl.NAME IS NOT NULL
    AND sch.NAME IS NOT NULL
    AND (ep.[name] IS NULL OR ep.[name] <> ''microsoft_database_tools_support'')
    ) AS rd
WHERE rd.SchemaName IS NOT NULL
ORDER BY DatabaseName ASC
    ,TableName ASC'
exec sp_Executesql @TableDetails_Query

