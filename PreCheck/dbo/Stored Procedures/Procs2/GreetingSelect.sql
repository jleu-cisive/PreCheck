
CREATE PROCEDURE [dbo].GreetingSelect
AS
	SET NOCOUNT ON;
SELECT GreetingID, Greeting, Holiday FROM dbo.Greeting
