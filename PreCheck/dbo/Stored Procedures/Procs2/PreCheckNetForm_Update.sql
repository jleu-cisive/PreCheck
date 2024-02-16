
CREATE PROCEDURE [dbo].PreCheckNetForm_Update
(
	@NameOnWeb varchar(200),
	@UsedFor varchar(50),
	@NameOfFile varchar(200),
	@Original_FormID int,
	@Original_NameOfFile varchar(200),
	@Original_NameOnWeb varchar(200),
	@Original_UsedFor varchar(50),
	@FormID int
)
AS
	SET NOCOUNT OFF;
UPDATE dbo.PreCheckNetForms SET NameOnWeb = @NameOnWeb, UsedFor = @UsedFor, NameOfFile = @NameOfFile WHERE (FormID = @Original_FormID) AND (NameOfFile = @Original_NameOfFile OR @Original_NameOfFile IS NULL AND NameOfFile IS NULL) AND (NameOnWeb = @Original_NameOnWeb OR @Original_NameOnWeb IS NULL AND NameOnWeb IS NULL) AND (UsedFor = @Original_UsedFor OR @Original_UsedFor IS NULL AND UsedFor IS NULL);
	SELECT FormID, NameOnWeb, UsedFor, NameOfFile FROM dbo.PreCheckNetForms WHERE (FormID = @FormID) ORDER BY NameOnWeb
