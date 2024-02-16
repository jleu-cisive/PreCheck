CREATE PROCEDURE CreateEmpl
  @Apno int,
  @Employer varchar(30),
  @EmplID int OUTPUT
as
  set nocount on
  insert into Empl (Apno, Employer)
  values (@Apno, @Employer)
  select @EmplID = @@Identity
