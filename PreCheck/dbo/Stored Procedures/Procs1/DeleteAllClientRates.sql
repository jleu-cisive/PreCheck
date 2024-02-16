CREATE PROCEDURE DeleteAllClientRates
  @CLNO smallint
as
  set nocount on
  delete from ClientRates where CLNO = @CLNO
