

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[MethodistUploader_CreateVolume] 
	-- Add the parameters for the stored procedure here
	@FORCLIENT INT,@ClientFacilityGroup varchar(50) = 'NonGrouped',
 @ReportType int,@VolumeLabel varchar(100),@StartDate datetime,@EndDate datetime

AS
BEGIN

--SET @StartDate = '05/02/2014'--DATEADD(m,-4,getdate());
--Set @EndDate = '07/02/2014';
	
INSERT INTO reportuploadvolume
(VolumeLabel,ClientFacilityGroup,ForClient,StartDate,EndDate,ReportType,CreatedDate)
VALUES
(@VolumeLabel,@ClientFacilityGroup,@FORCLIENT,@StartDate,@EndDate,@ReportType,current_timestamp)

SELECT @@IDENTITY;
END


