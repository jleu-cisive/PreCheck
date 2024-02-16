
-- =============================================
-- Author:		Gaurav Bangia
-- Create date: 5/1/2017
-- Description:	
-- =============================================


CREATE FUNCTION [dbo].[IsDefaultIntOrNull]
(
	-- Add the parameters for the function here
	@value INT null, @defaultValue int NULL
)
RETURNS INT
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result int
	
	-- Add the T-SQL statements to compute the return value here
	IF(@value IS NULL OR @value=0)
		SET @Result=@defaultValue
	ELSE
		SET @Result=@value
	-- Return the result of the function
	RETURN @Result

END
