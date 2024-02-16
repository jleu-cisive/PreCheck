
CREATE PROCEDURE [dbo].FormCredentCheckGlossary_Insert
(
	@Item varchar(100),
	@Description varchar(800),
	@Grouping varchar(100)
)
AS
	SET NOCOUNT OFF;
INSERT INTO dbo.CredentCheckGlossary(Item, Description, Grouping) VALUES (@Item, @Description, @Grouping);
	SELECT CredentCheckGlossaryID, Item, Description, Grouping FROM dbo.CredentCheckGlossary WHERE (CredentCheckGlossaryID = @@IDENTITY) ORDER BY Item
