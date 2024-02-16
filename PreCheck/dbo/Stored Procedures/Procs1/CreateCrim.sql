CREATE PROCEDURE [dbo].[CreateCrim]
  @Apno int,
  @CNTY_NO int,
  @CrimID int OUTPUT
as
  set nocount on

DECLARE @BigCounty varchar(75)
SELECT @BigCounty=county FROM COUNTIES (NOLOCK) WHERE CNTY_NO=@CNTY_NO



  insert into Crim (Apno, CNTY_NO, County) values (@Apno, @CNTY_NO, @BigCounty)
  --select @CrimID = @@Identity --commented by schapyala on 02/05/2014 to prevent cross scope issues and potential dead locks
  Select @CrimID = SCOPE_IDENTITY()

 exec testfaxing @apno,@Bigcounty,@cnty_no,@CrimID


 --exec testfaxing @apno,@Bigcounty,@cnty_no,null

 ----get the latest crimid inserted for that app and county
 --Select @CrimID = max(crimid) From dbo.crim (nolock) where apno = @Apno and cnty_no = @CNTY_NO