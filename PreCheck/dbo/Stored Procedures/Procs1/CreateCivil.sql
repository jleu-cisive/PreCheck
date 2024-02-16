-- Alter Procedure CreateCivil

CREATE PROCEDURE dbo.CreateCivil
  @Apno int,
  @CNTY_NO int,
  @CivilID int OUTPUT
as
  set nocount on

DECLARE @BigCounty varchar(75)
SELECT @BigCounty=county FROM dbo.TblCounties WHERE CNTY_NO=@CNTY_NO

  insert into Civil (Apno, CNTY_NO, County) values (@Apno, @CNTY_NO, @BigCounty)
  select @CivilID = @@Identity
