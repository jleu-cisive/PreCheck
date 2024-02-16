-- =============================================
-- Date: July 3, 2001
-- Author: Pat Coffer
-- =============================================
CREATE PROCEDURE UpdateApplBilled
	@Apno int
AS
SET NOCOUNT ON
 
UPDATE Appl
SET Billed = 1
WHERE Apno = @Apno
