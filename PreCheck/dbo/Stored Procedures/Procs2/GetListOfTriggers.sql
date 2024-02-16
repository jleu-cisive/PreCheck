CREATE PROCEDURE GetListOfTriggers AS


SELECT     sysobjects_1.name AS TableName,dbo.sysobjects.name AS TriggerName
FROM         dbo.sysobjects INNER JOIN
                      dbo.sysobjects sysobjects_1 ON dbo.sysobjects.parent_obj = sysobjects_1.id
WHERE     (dbo.sysobjects.xtype = 'tr')
order by tablename