CREATE PROCEDURE InsertDefaultRate
  @RateType varchar(4),
  @DefaultRate smallmoney
as
  set nocount on
  insert into DefaultRates (RateType, DefaultRate)
  values (@RateType, @DefaultRate)
