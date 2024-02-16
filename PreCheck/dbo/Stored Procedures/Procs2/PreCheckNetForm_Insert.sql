
CREATE PROCEDURE [dbo].PreCheckNetForm_Insert
(
	@NameOnWeb varchar(200),
	@UsedFor varchar(50),
	@NameOfFile varchar(200)
)
AS
	SET NOCOUNT OFF;
INSERT INTO dbo.PreCheckNetForms(NameOnWeb, UsedFor, NameOfFile) VALUES (@NameOnWeb, @UsedFor, @NameOfFile);
	SELECT FormID, NameOnWeb, UsedFor, NameOfFile FROM dbo.PreCheckNetForms WHERE (FormID = @@IDENTITY) ORDER BY NameOnWeb
