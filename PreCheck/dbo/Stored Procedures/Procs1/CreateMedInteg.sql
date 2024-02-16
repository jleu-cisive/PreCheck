
CREATE PROCEDURE dbo.[CreateMedInteg]
  @Apno int
as
  set nocount on
  insert into MedInteg (Apno) values (@Apno)

