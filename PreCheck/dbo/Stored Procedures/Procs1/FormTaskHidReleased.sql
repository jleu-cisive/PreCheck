

CREATE  PROCEDURE [dbo].[FormTaskHidReleased] AS
UPDATE    dbo.Task
SET              IsHidden = 1
WHERE     (StatusID = 14)

UPDATE    dbo.Task
SET              IsHidden = 0
WHERE     (StatusID != 14)
