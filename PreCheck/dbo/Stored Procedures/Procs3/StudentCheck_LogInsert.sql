

 

 

 

 

 

CREATE PROCEDURE [dbo].[StudentCheck_LogInsert]

  @APNO int,

  @CLNO int,

  @PackageID int,

  @ClientSetup VarChar(10),

  @Drug VarChar(10),

  @NonElectronic VarChar(10),

  @RedirectEDrugUrl VarChar(8000),

  @RedirectConfirmUrl VarChar(8000),

  @BeforeAndAfter VarChar(10)

      

as

INSERT INTO StudentCheckLog

(Apno,Clno,PackageID,ClientSetup,DrugTest,NonElectronic,RedirectEDrugUrl,RedirectConfirmUrl, BeforeAndAfter,CreatedDate)

 Values(@APNO, @CLNO, @PackageID, @ClientSetup,@Drug,@NonElectronic, @RedirectEDrugUrl,@RedirectConfirmUrl, @BeforeAndAfter,getdate())

 

