CREATE PROCEDURE dbo.StateBoardUpdateLicenseAuthority 
@StateBoardSourceID int,
@Frequency varchar(100),
@NextRunDate Datetime,
@LastUpdated Datetime AS




 Update Rabbit.HEVN.dbo.LicenseAuthority
  set Frequency = @Frequency,NextRunDate = @NextRunDate,LastUpdated = @LastUpdated 
 where LicenseAuthorityid = @StateBoardSourceID
