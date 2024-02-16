-- =============================================
-- Author:		Gaurav Bangia
-- Create date: 06/13/2017
-- Description:	Function Returns cooma separated list of user email addresses
-- =============================================
CREATE FUNCTION [dbo].[ListCSVQReportUserEmail] 
(
	-- Add the parameters for the function here
	@QReportId int
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result VARCHAR(MAX)
	SELECT @Result = COALESCE(@Result + ',', '') + CAST(EmailAddress AS VARCHAR)
	FROM   dbo.vwQReportUserMap
	WHERE  QReportId = @QReportId

	RETURN @Result

END
