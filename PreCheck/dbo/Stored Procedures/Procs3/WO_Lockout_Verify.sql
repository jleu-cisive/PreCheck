CREATE PROCEDURE WO_Lockout_Verify  @username varchar(14), @clientid int  AS
SELECT  * 
FROM Precheck..ClientContacts
Where clno = @clientid
and username = @username
and WOLockout < 3