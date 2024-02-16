
-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

CREATE PROCEDURE [dbo].[MethodistUploader_ReportLogUpdate]

	@ReportID int,@ReportUploadVolumeID INT,@FORCLIENT INT,@ClientFacilityGroup varchar(50) = 'NonGrouped', @ReportType int,@VolumeLabel varchar(100)



AS

BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from

	-- interfering with SELECT statements.

	

	if (select count(*) from reportuploadlog r inner join reportuploadvolume rv
	 on r.reportuploadvolumeid = rv.reportuploadvolumeid 
	 where r.ReportID = @ReportID and rv.ForClient = @FORCLIENT AND rv.ClientFacilityGroup = @ClientFacilityGroup 
	 AND rv.ReportType  = @ReportType) = 0

	Insert into reportuploadlog (ReportID,ReportUploadVolumeID,CreatedDate,reporttype) VALUES (@ReportID,@ReportUploadVolumeID,getdate(),@ReportType)

	else
	  update reportuploadlog set ReportUploadVolumeID = @ReportUploadVolumeID,resend = 0 where reportuploadlogid =  
		( SELECT r.reportuploadlogid from reportuploadlog r inner join reportuploadvolume rv on r.reportuploadvolumeid = rv.reportuploadvolumeid
				WHERE r.ReportID = @ReportID and  rv.ForClient = @FORCLIENT AND rv.ClientFacilityGroup = @ClientFacilityGroup
			AND rv.ReportType = @ReportType AND r.resend = 1)
END




























