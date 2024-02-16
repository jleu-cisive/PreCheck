
-- =============================================
-- Author:		James Norton
-- Create date: 7/14/2022
-- Description:	To return the License Verification fee for a given LicenseTypeID, LicenseState 
-- =============================================
CREATE FUNCTION [dbo].[LicenseVerificationFee] 
(	
    @LicenseTypeID INT,	
	@LicenseState  varchar(2) 
)
RETURNS TABLE 
AS
RETURN 
(
 SELECT ISNULL(max([LicenseVerificationFee]),0) as PassthroughFee
   FROM [HEVN].[dbo].[LicenseTypeByState]
  where LicenseTypeID = @LicenseTypeID and LicenseState = @LicenseState and IsActive = 1
)
