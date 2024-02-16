CREATE PROCEDURE CountApplBySSN
  @SSN varchar(11),
  @Count int OUTPUT
as
  set nocount on
  select @Count = count(*) from Appl where SSN = @SSN
