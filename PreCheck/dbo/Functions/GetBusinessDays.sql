CREATE FUNCTION [dbo].[GetBusinessDays]
(
@startdate datetime,
@enddate datetime
)
RETURNS integer
AS
BEGIN
DECLARE @days integer

SELECT @days = MainDB.[dbo].[fnGetBusinessDays](@startdate,@enddate)
RETURN (@days)

END
