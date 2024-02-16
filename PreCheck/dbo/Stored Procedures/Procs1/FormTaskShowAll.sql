


CREATE   PROCEDURE [dbo].[FormTaskShowAll] AS
UPDATE    dbo.Task
SET              IsHidden = 0
WHERE     (IsHidden = 1)

UPDATE    dbo.Task
SET              ExpandCollapse = '-'
WHERE     (ExpandCollapse = '+')
