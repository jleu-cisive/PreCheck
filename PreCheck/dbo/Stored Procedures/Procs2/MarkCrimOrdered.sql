-- =================================================
-- Date: July 2, 2001
-- Author: Pat Coffer
--
-- Updates a Crim record to "Ordered" status
-- =================================================
CREATE  PROCEDURE MarkCrimOrdered
	@CrimID int
AS
SET NOCOUNT ON
UPDATE Crim
SET Clear = 'O',
    Ordered = CONVERT(varchar(8), GetDate(), 1) + ' ' + 
		CONVERT(varchar(5), GetDate(), 8)
WHERE (CrimID = @CrimID)
