CREATE PROCEDURE DeleteClientRate
  @CLNO smallint,
  @RateType varchar(4)
as
  delete from ClientRates
    where CLNO = @CLNO
      and RateType = @RateType
