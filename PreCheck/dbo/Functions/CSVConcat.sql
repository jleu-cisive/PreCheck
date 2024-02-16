-- =============================================
-- Author:		Gaurav Bangia
-- Create date: 4/19/2018
-- =============================================
CREATE FUNCTION [dbo].[CSVConcat] 
(
	-- Add the parameters for the function here
	@List1 VARCHAR(4000) = null,
	@List2 VARCHAR(3999) = null
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result VARCHAR(MAX)
	SET @List1 = ISNULL(@List1,'')
	SET @List2 = ISNULL(@List2,'')
	
	SELECT  @Result=
    STUFF(
        CASE WHEN @List1 ='' THEN '' ELSE COALESCE(','+@List1 , '') END +
        CASE WHEN @List2 ='' THEN '' ELSE COALESCE(','+@List2 , '') end 
      , 1,1,'')

	
	RETURN @Result

END