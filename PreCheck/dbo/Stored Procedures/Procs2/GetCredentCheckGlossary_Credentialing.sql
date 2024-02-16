
create PROCEDURE dbo.GetCredentCheckGlossary_Credentialing
AS
SET NOCOUNT ON


select CredentCheckGlossaryID,Item,Description,Grouping
from CredentCheckGlossary
where grouping='CredentialingStatusDefinition'
order by Item


SET NOCOUNT OFF

