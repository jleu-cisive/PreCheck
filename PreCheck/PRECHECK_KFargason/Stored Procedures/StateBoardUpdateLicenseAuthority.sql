
CREATE PROCEDURE [PRECHECK\KFargason].StateBoardUpdateLicenseAuthority 
@StateBoardSourceID int,
@Frequency varchar(100),
@NextRunDate Datetime,
@LastUpdated Datetime AS




 Update HEVN.dbo.LicenseAuthority
  set Frequency = @Frequency,NextRunDate = @NextRunDate,LastUpdated = @LastUpdated 
 where LicenseAuthorityid = @StateBoardSourceID
