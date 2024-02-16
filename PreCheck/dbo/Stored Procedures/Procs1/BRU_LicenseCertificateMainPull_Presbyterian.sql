
-- EXEC [dbo].[BRU_LicenseCertificateMainPull_Presbyterian] 7898,'12/01/2018', '12/10/2018'

Create PROCEDURE [dbo].[BRU_LicenseCertificateMainPull_Presbyterian]
	
	@CLNO int, @StartDate datetime,@EndDate datetime

AS
BEGIN
SET NOCOUNT ON 


begin
Exec CredentCheckDocuments.dbo.[PHS_LicenseCertificateMainPull]  @CLNO,@StartDate ,@EndDate
end


SET NOCOUNT OFF 
END


