CREATE PROCEDURE CreateProfLic
  @Apno int,
  @Lic_Type varchar(30),
  @ProfLicID int OUTPUT
as
  set nocount on
  
  insert into ProfLic (Apno, Lic_Type)
  values (@Apno, @Lic_Type)
  select @ProfLicID = @@Identity
