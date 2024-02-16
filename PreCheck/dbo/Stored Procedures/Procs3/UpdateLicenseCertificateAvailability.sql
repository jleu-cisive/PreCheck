
CREATE PROCEDURE [dbo].[UpdateLicenseCertificateAvailability] 

 

(

@LicenseID int,

@NoticeTypeID int

)

 AS


	BEGIN
		UPDATE dbo.ProfLic Set GenerateCertificate = 0, CertificateAvailabilityStatus = 1
		WHERE  ProfLicID = @LicenseID
	END