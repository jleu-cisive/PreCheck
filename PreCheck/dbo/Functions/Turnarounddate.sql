CREATE FUNCTION [dbo].[Turnarounddate] (@Date smalldatetime) 
RETURNS char(8)
AS 
    BEGIN 
    	
    	DECLARE @ME CHAR(8)
    	SET @ME = Left(DateName(mm, @Date), 3) + ' ' + Cast(DatePart(yy, @Date) AS VARCHAR(4))
    	Return(@ME)
END
