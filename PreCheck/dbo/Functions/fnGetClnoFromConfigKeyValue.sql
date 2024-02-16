CREATE FUNCTION [dbo].[fnGetClnoFromConfigKeyValue](@ConfigKey varchar(100),@value varchar(50))  
RETURNS Varchar(8000) AS  
BEGIN 
DECLARE @FunctionIdList varchar(8000)
	
	SELECT @FunctionIdList = COALESCE(@FunctionIdList + ', ', '') + cast(CC.Clno as varchar)
	FROM Client C
		inner join ClientConfiguration CC
		ON C.CLNO = CC.CLNO
	WHERE CC.configurationKey = @ConfigKey and CC.[Value] = @value

	RETURN @FunctionIdList

END
