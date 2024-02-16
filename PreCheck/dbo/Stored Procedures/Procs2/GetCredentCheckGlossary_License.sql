
create PROCEDURE dbo.GetCredentCheckGlossary_License
AS
SET NOCOUNT ON


select CredentCheckGlossaryID,Item,Description,Grouping
from CredentCheckGlossary
where grouping='LicenseStatusDefinition'
order by Item


SET NOCOUNT OFF

