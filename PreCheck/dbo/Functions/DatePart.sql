CREATE FUNCTION dbo.DatePart
  ( @fDate datetime )
RETURNS varchar(10)
AS
BEGIN
  RETURN ( CONVERT(varchar(10),@fDate,101) )
END
