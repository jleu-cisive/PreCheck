

-- =============================================
-- Author:		Santosh Chapyala
-- Create date: Deployed from staging to Prod: 8/1/2019 - by Gaurav
-- Description:	Functions return specific node value for the requestId and APNO passed as the parameter
-- =============================================
CREATE FUNCTION [dbo].[GetIntegrationRequestNodeValue_Ns] 
(
	-- Add the parameters for the function here
	@RequestID int,@APNO Int,@NodeName varchar(500)
)
RETURNS NVarchar(500)   
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

	SET @NodeValue = rtrim(ltrim(Replace(Replace(@NodeValue,'/',''),'<' + @NodeName + '>','')))

	RETURN @NodeValue
	
	
END

