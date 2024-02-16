CREATE PROCEDURE InsertClientRate
  @Clno smallint,
  @RateType varchar(4),
  @Rate smallmoney
as
  set nocount on
  insert into ClientRates
    (Clno, RateType, Rate)
  values
    (@Clno, @RateType, @Rate)
