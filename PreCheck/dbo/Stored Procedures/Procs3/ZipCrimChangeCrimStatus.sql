
CREATE PROCEDURE [dbo].[ZipCrimChangeCrimStatus] 
	@apno int, @status varchar(1)
AS
BEGIN
	UPDATE dbo.Crim SET crim.Clear = @status
	WHERE dbo.Crim.APNO = @apno AND dbo.Crim.Clear IS NULL
END
