CREATE PROCEDURE DeleteClient
  @CLNO smallint
as
  set nocount on
  delete from Client where CLNO = @CLNO
