



CREATE PROCEDURE [dbo].[FormPrecheckNetForms_Del]
(
	@Original_FormID int,
	@Original_NameOfFile varchar(200),
	@Original_NameOnWeb varchar(200),
	@Original_UsedFor varchar(50)
)
AS
	SET NOCOUNT OFF;
DELETE FROM dbo.PreCheckNetForms 
WHERE (FormID = @Original_FormID) 
AND (NameOfFile = @Original_NameOfFile OR @Original_NameOfFile IS NULL AND NameOfFile IS NULL) 
AND (NameOnWeb = @Original_NameOnWeb OR @Original_NameOnWeb IS NULL AND NameOnWeb IS NULL) 
AND (UsedFor = @Original_UsedFor OR @Original_UsedFor IS NULL AND UsedFor IS NULL);
