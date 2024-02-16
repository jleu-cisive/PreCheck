CREATE PROCEDURE InsertText
  @TextID smallint,
  @TextValue text
AS
  set nocount on
  insert into Texts (TextID, TextValue)
  values (@TextID, @TextValue)
