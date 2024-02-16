


-- =============================================
-- Author:		Gaurav Bangia
-- Create date: 10/11/2019
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[GetIntegrationRequestNodeRawValue_Ns] 
(
	-- Add the parameters for the function here
	@RequestID int,@APNO Int,@NodeName varchar(500), @Clean BIT = 1
)
RETURNS nVarchar(500)   
AS
BEGIN
	DECLARE @NodeValue varchar(8000),@xml xml

	IF(ISNULL(@RequestID,0)>0)
		SELECT @xml = transformedrequest FROM Integration_OrderMgmt_Request 
		WHERE (RequestID = @RequestID) 
	ELSE IF(ISNULL(@APNO,0)>0)
		SELECT @xml = transformedrequest FROM Integration_OrderMgmt_Request 
		WHERE (apno = @APNO) 
	ELSE
		RETURN @NodeValue

	SELECT @NodeValue = cast(@xml.query('//*[local-name()=sql:variable("@NodeName")]') AS varchar(8000))

	SET @NodeValue = rtrim(ltrim(Replace(@NodeValue,'<' + @NodeName + '>','')))
	SET @NodeValue = rtrim(ltrim(Replace(@NodeValue,'</' + @NodeName + '>','')))
	SET @NodeValue = rtrim(ltrim(Replace(@NodeValue,'<' + @NodeName + '/>','')))

	IF(@Clean=1)
		SET @NodeValue = rtrim(ltrim(Replace(@NodeValue,'/','')))
	RETURN @NodeValue
	
	
END


