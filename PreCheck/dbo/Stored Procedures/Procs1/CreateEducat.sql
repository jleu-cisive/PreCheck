
CREATE PROCEDURE [dbo].[CreateEducat]
  @Apno int,
  @School varchar(50),
  @EducatID int OUTPUT
as
  set nocount on
  insert into Educat (Apno, School)
  values (@Apno, @School)
  select @EducatID = @@Identity

