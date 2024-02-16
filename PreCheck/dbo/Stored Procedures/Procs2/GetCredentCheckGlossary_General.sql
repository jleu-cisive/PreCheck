
create PROCEDURE dbo.GetCredentCheckGlossary_General
AS
SET NOCOUNT ON


select CredentCheckGlossaryID,Item,Description,Grouping
from CredentCheckGlossary
where grouping='GeneralDefinition'
order by grouping,Item


SET NOCOUNT OFF

