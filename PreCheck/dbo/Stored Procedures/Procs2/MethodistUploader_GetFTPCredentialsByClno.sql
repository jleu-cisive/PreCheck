/* ==================================================================
Author:		 Deepak Vodethela
Create date: 11/01/2017
Description: Get FTP Credentiala by Client Number
Execution: EXEC MethodistUploader_GetFTPCredentialsByClno 2569 
		   EXEC MethodistUploader_GetFTPCredentialsByClno 7898
 ================================================================== */
CREATE PROCEDURE [dbo].[MethodistUploader_GetFTPCredentialsByClno]
	@Clno int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT UserID, [Password],FtpFile, FtpSite, FtpSitePickupSubFolder
	FROM [HEVN].[dbo].[FtpSiteSetting](NOLOCK)
	WHERE ClientID = @Clno
END
