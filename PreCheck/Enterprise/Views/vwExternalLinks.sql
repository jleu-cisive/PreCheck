





CREATE VIEW [Enterprise].[vwExternalLinks]
AS

SELECT * FROM Enterprise.[dbo].[vwApplicantExternalForm]  WHERE IsActive = 1 or IsActive is null 




