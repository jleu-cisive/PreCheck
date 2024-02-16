-- Create Procedure CreateCrimSexOffenderTCH


CREATE PROCEDURE [dbo].[CreateCrimSexOffenderTCH]
  @state varchar(2),
  @Apno int,
  @CNTY_NO int,
   @CrimID int OUTPUT
as
  set nocount on

DECLARE @BigCounty varchar(75)

--SELECT @BigCounty=county FROM COUNTIES WHERE CNTY_NO=@CNTY_NO
SELECT @BigCounty=county+', '+ State FROM dbo.TblCounties WHERE CNTY_NO=@CNTY_NO

  insert into Crim (Apno, CNTY_NO, County) values (@Apno, @CNTY_NO, @BigCounty)
  select @CrimID = @@Identity
  exec testfaxingsexoffenderTCH @apno,@Bigcounty,@cnty_no, @CrimID, @state
