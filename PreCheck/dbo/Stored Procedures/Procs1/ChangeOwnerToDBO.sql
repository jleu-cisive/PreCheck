CREATE PROCEDURE [DBO].[ChangeOwnerToDBO] 
 AS
declare @sql varchar(8000)

SELECT  @sql = coalesce(@sql,'select 1') + ';Exec sp_changeobjectowner  '''+    ltrim(u.name) + '.' + ltrim(s.name) + ''''   + ',  dbo'
FROM  [dbo].[sysobjects] s inner join  [dbo].[sysUsers] u on s.uid = u.uid    
where u.name <> 'dbo'AND   xtype in ('V', 'P', 'U') AND   u.name not like 'INFORMATION%'order by s.name

--select @sql

EXEC(@sql)