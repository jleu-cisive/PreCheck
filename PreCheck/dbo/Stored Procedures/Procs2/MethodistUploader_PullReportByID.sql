
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Execution: EXEC MethodistUploader_PullReportByID 2, 1084444
-- =============================================
CREATE PROCEDURE [dbo].[MethodistUploader_PullReportByID]
	-- Add the parameters for the stored procedure here
	@ReportType int, @ReportID int
AS
BEGIN
	
	IF (@ReportType = 1)
	BEGIN
		SELECT backgroundreport,createdate AS ReportDate FROM BackgroundReports.dbo.BackgroundReport WHERE backgroundreportid = @ReportID;
	END
	ELSE IF (@ReportType = 2)
	BEGIN

		SELECT pdf, ReportDate FROM 
							( 
								SELECT pdf,date AS ReportDate,releaseformid FROM releaseform WITH (NOLOCK)
								UNION ALL
								SELECT pdf,date AS ReportDate,releaseformid FROM PreCheck_MainArchive.dbo.ReleaseForm_Archive WITH (NOLOCK) 
							) AS r
							WHERE releaseformid  = @ReportID;

		/* 
		-- Uncomment the below statements when ApplicantInfo_pdf is needed and comment the above statements
		SELECT pdf, ReportDate FROM 
							( 
								SELECT ApplicantInfo_pdf AS pdf,date AS ReportDate,releaseformid FROM releaseform WITH (NOLOCK) WHERE ApplicantInfo_pdf IS NOT NULL
								UNION ALL
								SELECT ApplicantInfo_pdf AS pdf,date AS ReportDate,releaseformid FROM PreCheck_MainArchive.dbo.ReleaseForm_Archive WITH (NOLOCK) WHERE ApplicantInfo_pdf IS NOT NULL
							) AS r
							WHERE releaseformid  = @ReportID;
		*/
	END
	ELSE IF (@ReportType = 3)
	BEGIN
        SELECT LicenseCertificate,CreatedDate AS ReportDate FROM CredentCheckDocuments.dbo.LicenseCertificate
        WHERE LicenseCertificateID = @ReportID;
	END
    ELSE IF (@ReportType = 4)
	BEGIN
        SELECT isnull(FileContent,'') LicenseImage,CreatedDate AS ReportDate FROM CredentCheckDocuments.dbo.LicenseImage 
        WHERE LicenseImageID = @ReportID;
	END
END

