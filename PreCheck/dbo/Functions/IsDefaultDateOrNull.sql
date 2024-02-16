-- =============================================
-- Author:		Gaurav Bangia
-- Create date: 5/1/2017
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[IsDefaultDateOrNull]
(
	-- Add the parameters for the function here
	@value datetime null, @defaultValue datetime NULL, @nullEqual VARCHAR(20)
)
RETURNS datetime
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result datetime
	
	-- Add the T-SQL statements to compute the return value here
	IF(@value IS NULL OR @value=@nullEqual)
		SET @Result=@defaultValue
	ELSE
		SET @Result=@value
	-- Return the result of the function
	RETURN @Result

END


