
CREATE PROCEDURE [dbo].[ZipCrim_IsCLientConfiguredForZipCrim]
	@apno int
AS
	SELECT dbo.IsClientZipCrim(@apno)
