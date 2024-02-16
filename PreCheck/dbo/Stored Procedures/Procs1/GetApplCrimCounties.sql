
--created 4/21/2003 by Steve Krenek
CREATE PROCEDURE GetApplCrimCounties
  @Apno int

as
  set nocount on
  select Distinct CNTY_NO from Crim where Apno = @Apno
