
CREATE PROCEDURE [dbo].[Win_Service_ApplAddPrivateNotes]
	@apno int, @note varchar(max)
AS
BEGIN
	UPDATE dbo.Appl	
	SET 
		dbo.Appl.Priv_Notes = convert(varchar, getdate(), 22) + ': ' + @note + '\n' + dbo.Appl.Priv_Notes
	WHERE dbo.Appl.APNO = @apno
END
