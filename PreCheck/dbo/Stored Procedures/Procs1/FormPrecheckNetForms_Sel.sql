
CREATE PROCEDURE [dbo].[FormPrecheckNetForms_Sel]
(
	@NameOnWeb varchar(200)
)
AS

SET NOCOUNT ON;

SELECT FormID, NameOnWeb, UsedFor, NameOfFile 
FROM dbo.PreCheckNetForms 
WHERE (NameOnWeb = @NameOnWeb) 
ORDER BY NameOnWeb;

