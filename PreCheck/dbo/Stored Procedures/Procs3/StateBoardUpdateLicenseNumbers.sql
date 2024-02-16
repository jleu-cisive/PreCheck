
CREATE PROCEDURE StateBoardUpdateLicenseNumbers 

   @StateBoardLicenseNumberA_ID int = 0 ,
   @UserA_ID varchar(10) = null,
   @LicenseNumberA varchar(50),
   @StateBoardDisciplinaryRunID int,
   @StateBoardLicenseNumberB_ID int = 0,
   @LicenseNumberB varchar(50),
   @UserB_ID varchar(10) = null
AS

    /* If Row ID does not exists Insert else Update  */
   
   IF (@StateBoardLicenseNumberA_ID=0)
      Begin
        INSERT INTO StateBoardLicenseNumber
         (StateBoardDisciplinaryRunID,LicenseNumber,UserID)
        VALUES   (@StateBoardDisciplinaryRunID,@LicenseNumberA,@UserA_ID)
      End
   Else
      Begin
           IF(Select count(*) from StateBoardLicenseNumber where StateBoardLicenseNumberID = @StateBoardLicenseNumberA_ID) > 0
           Begin
              Update StateBoardLicenseNumber
              Set LicenseNumber  =   @LicenseNumberA 
              where StateBoardLicenseNumberID =   @StateBoardLicenseNumberA_ID
           End
     End
  
     /* If Row ID does not exists Insert else Update  */

   IF (@StateBoardLicenseNumberB_ID=0)
      Begin
        INSERT INTO StateBoardLicenseNumber
         (StateBoardDisciplinaryRunID,LicenseNumber,UserID)
        VALUES   (@StateBoardDisciplinaryRunID,@LicenseNumberB,@UserB_ID)
      End
   Else
      Begin
           IF(Select count(*) from StateBoardLicenseNumber where StateBoardLicenseNumberID = @StateBoardLicenseNumberB_ID) > 0
           Begin
              Update StateBoardLicenseNumber
              Set LicenseNumber  =   @LicenseNumberB 
              where StateBoardLicenseNumberID =   @StateBoardLicenseNumberB_ID
           End
     End
