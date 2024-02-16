
--created 4/24/2003 by Steve Krenek
CREATE PROCEDURE GetApplCivilCounties
  @Apno int

as
  set nocount on
  select Distinct CNTY_NO from Civil where Apno = @Apno
