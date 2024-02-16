CREATE PROCEDURE WO_Lockout_Increment  @username varchar(14), @clientid int  AS
UPDATE Precheck..ClientContacts
SET WOLockout = WOLockout + 1
Where clno = @clientid
and username = @username