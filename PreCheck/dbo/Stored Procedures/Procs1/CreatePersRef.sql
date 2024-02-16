CREATE PROCEDURE CreatePersRef
  @Apno int,
  @Name varchar(25),
  @PersRefID int OUTPUT
as
  set nocount on
  
  insert into PersRef(Apno, Name)
  values (@Apno, @Name)
  select @PersRefID = @@Identity
