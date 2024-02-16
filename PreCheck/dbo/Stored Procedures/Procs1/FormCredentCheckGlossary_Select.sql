

CREATE PROCEDURE [dbo].FormCredentCheckGlossary_Select
(
 --@grouping varchar(100)='GeneralDefinition'
 @grouping int=1
)
AS

SET NOCOUNT ON;

if (@grouping=1)
  begin
	select CredentCheckGlossaryID, Item, Description, Grouping 
	from dbo.CredentCheckGlossary 
	where (Grouping = 'GeneralDefinition') 
	order by Item
  end
else if (@grouping=0)
  begin
	select CredentCheckGlossaryID, Item, Description, Grouping 
	from dbo.CredentCheckGlossary 
	where (Grouping = 'CredentialingStatusDefinition') 
	order by Item
  end
else if (@grouping=2)
  begin
	select CredentCheckGlossaryID, Item, Description, Grouping 
	from dbo.CredentCheckGlossary 
	where (Grouping = 'LicenseStatusDefinition') 
	order by Item
  end
  
--SELECT CredentCheckGlossaryID, Item, Description, Grouping FROM dbo.CredentCheckGlossary WHERE (Grouping = @grouping) ORDER BY Item


