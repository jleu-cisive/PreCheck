
CREATE FUNCTION dbo.SecondsToTime 
( @seconds int )
RETURNS datetime AS  
BEGIN 
	RETURN  DateAdd(s,@seconds, 0)
END

