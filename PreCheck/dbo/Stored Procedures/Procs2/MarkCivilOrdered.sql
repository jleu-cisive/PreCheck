-- =================================================
-- Date: July 2, 2001
-- Author: Pat Coffer
--
-- Updates a Civil record to "Ordered" status
-- =================================================
CREATE  PROCEDURE MarkCivilOrdered
	@CivilID int
AS
SET NOCOUNT ON
UPDATE Civil
SET Clear = 'O',
    Ordered = CONVERT(varchar(8), GetDate(), 1) + ' ' + 
		CONVERT(varchar(5), GetDate(), 8)
WHERE (CivilID = @CivilID)
