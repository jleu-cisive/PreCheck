-- =============================================
-- Author:		Gaurav Bangia
-- Create date: 5/1/2017
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[IsDefaultStringOrNull]
(
	-- Add the parameters for the function here
	@value VARCHAR(MAX) null, @defaultValue VARCHAR(MAX) NULL
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result VARCHAR(MAX)
	
	-- Add the T-SQL statements to compute the return value here
	IF(@value IS NULL OR @value='')
		SET @Result=@defaultValue
	ELSE
		SET @Result=@value
	-- Return the result of the function
	RETURN @Result

END