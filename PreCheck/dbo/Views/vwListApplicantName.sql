
CREATE VIEW	[dbo].[vwListApplicantName]
AS
SELECT
 FirstName=[First],
LastName=[Last],
ClientId=[CLNO]
FROM dbo.Appl a
WHERE a.CreatedDate >='1/1/2013'



