
CREATE PROCEDURE [dbo].[Win_Service_HandlePackageAndClientInstructionsforZipCrimClients]
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @missingPackageText varchar(max) = 'Please select a package to be pursued for this report\n'
	DECLARE @additionalIntructionsText varchar(max) = 'ZipCrim Processed: Client has potentially ordered additional services.  Please ensure proper items ordered. \n'

	UPDATE dbo.Appl 
		SET dbo.Appl.InUse = NULL,
		dbo.Appl.Investigator = NULL,
		dbo.Appl.NeedsReview = substring(NeedsReview,1,1) + '2',
		dbo.Appl.Priv_Notes = Convert(varchar, GETDATE(), 22) + ' - '
								+ iif(dbo.Appl.PackageID IS NULL, @missingPackageText, '')  
								+ dbo.Appl.Priv_Notes
	WHERE dbo.Appl.InUse = 'Social_E' 
		AND dbo.IsClientZipCrim(dbo.Appl.APNO) = 1 
		AND dbo.Appl.PackageID IS NULL
END
