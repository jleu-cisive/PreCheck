-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE dbo.MethodistUploader_UpdateImageCount
	-- Add the parameters for the stored procedure here
	@ReportUploadVolumeID int,@ImageCount int
AS
BEGIN
	
	update reportuploadvolume set imagecount = @ImageCount where reportuploadvolumeid = @ReportUploadVolumeID
END
