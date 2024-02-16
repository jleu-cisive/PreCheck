
CREATE PROCEDURE [dbo].FormCredentCheckGlossary_Update
(
	@Item varchar(100),
	@Description varchar(800),
	@Grouping varchar(100),
	@Original_CredentCheckGlossaryID int,
	@Original_Description varchar(800),
	@Original_Grouping varchar(100),
	@Original_Item varchar(100),
	@CredentCheckGlossaryID int
)
AS
	SET NOCOUNT OFF;
UPDATE dbo.CredentCheckGlossary SET Item = @Item, Description = @Description, Grouping = @Grouping WHERE (CredentCheckGlossaryID = @Original_CredentCheckGlossaryID) AND (Description = @Original_Description OR @Original_Description IS NULL AND Description IS NULL) AND (Grouping = @Original_Grouping OR @Original_Grouping IS NULL AND Grouping IS NULL) AND (Item = @Original_Item OR @Original_Item IS NULL AND Item IS NULL);
	SELECT CredentCheckGlossaryID, Item, Description, Grouping FROM dbo.CredentCheckGlossary WHERE (CredentCheckGlossaryID = @CredentCheckGlossaryID) ORDER BY Item
