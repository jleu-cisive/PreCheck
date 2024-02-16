
CREATE PROCEDURE [dbo].[FormTaskSetFilter] AS

UPDATE    dbo.Task
SET              IsHidden = 1
WHERE     (StatusID = 14)

Update dbo.Task
SET      IsHidden = 0
Where   StatusID <>14

UPDATE    dbo.Task
SET              ExpandCollapse = '-'
WHERE     (ExpandCollapse = '+' and ishidden = 0)
