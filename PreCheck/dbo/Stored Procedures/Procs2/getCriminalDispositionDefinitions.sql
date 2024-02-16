CREATE PROCEDURE dbo.getCriminalDispositionDefinitions
AS

SET NOCOUNT ON

SELECT CriminalDispositionDefinitionID, Term, Definition FROM CriminalDispositionDefinition
SET NOCOUNT OFF