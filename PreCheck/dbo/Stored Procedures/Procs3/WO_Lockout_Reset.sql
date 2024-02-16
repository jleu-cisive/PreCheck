CREATE PROCEDURE WO_Lockout_Reset  @clientid int, @username varchar(14) AS
UPDATE Precheck..ClientContacts
SET WOLockout = 0
Where clno = @clientid
and username = @username