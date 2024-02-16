
-- EXEC [dbo].[BRU_LicenseCertificateMainPull_LakeCharles] 16071,'12/01/2018', '12/10/2018'

CREATE PROCEDURE [dbo].[BRU_LicenseCertificateMainPull_LakeCharles]
	@CLNO int, @StartDate datetime,@EndDate datetime
AS
BEGIN
SET NOCOUNT ON 

	BEGIN
		Exec CredentCheckDocuments.dbo.[LakeCharles_LicenseCertificateMainPull]  @CLNO,@StartDate ,@EndDate
	END

SET NOCOUNT OFF 
END


