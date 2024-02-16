CREATE PROCEDURE GetClientUnbilledAppls 
	@Clno smallint
AS
SET NOCOUNT ON
SELECT Apno FROM Appl 
WHERE (CLNO = @CLNO)
  AND (Billed = 0)
