

-- =============================================
-- Author:		Larry Ouch
-- Create date: 9/4/2019
-- Description:	Returns a node value as a varchar from XML from the provided nodePath parameter
-- =============================================
CREATE FUNCTION [dbo].[GetXMLNodeValue]
(
	@xml xml, 
	@NodeParent VARCHAR(MAX),
	@NodeChild VARCHAR(MAX)
)
RETURNS varchar(max)
AS
BEGIN

DECLARE @NodeValue VARCHAR(8000)

SET @NodeValue = @xml.value('(//*[local-name() = sql:variable("@NodeParent")]
	 /*[local-name() = sql:variable("@NodeChild")])[1]',  'varchar(max)')

RETURN @NodeValue


END
