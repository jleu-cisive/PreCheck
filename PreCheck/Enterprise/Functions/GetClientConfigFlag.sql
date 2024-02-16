-- =============================================
-- Author:		Larry Ouch
-- Create date: 11/14/2018
-- Description:	Returns a boolean flag if the KeyName and KeyValue pair exists in the enterprise client configuration table
	-- PRINT [Enterprise].[GetClientConfigFlag](12725,'VerifyPresentEmployer', 'true')
-- =============================================
CREATE FUNCTION [Enterprise].[GetClientConfigFlag]
(
	@ClientId INT,
	@KeyName VARCHAR(50),
	@KeyValue VARCHAR(MAX)
)
RETURNS BIT
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Flag BIT

	-- Add the SQL statements to compute the return value here
	SELECT @Flag =  CASE(SELECT [Enterprise].[Config].[GetClientConfigValueByHierarchy] (@ClientId,@KeyName)) WHEN @KeyValue THEN  1 ELSE 0 END
	-- Return the result of the function
	RETURN @Flag
END
