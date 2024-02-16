
CREATE PROCEDURE [dbo].[ZipCrimIntegrationDataReport]
	@orderNumber int
AS
BEGIN
	SELECT 
		cil.RecordId, 
		cil.RequestDirection,
		cil.RequestMessage, 
		cil.ResponseMessage, 
		cil.Message, 
		cil.Result,
		cil.HasError,
		cil.IsComplete,
		cil.CreateDate
	FROM dbo.CisiveIntegrationLog cil
	WHERE cil.RecordId = @orderNumber
END
