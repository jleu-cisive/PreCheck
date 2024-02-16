
CREATE PROCEDURE [dbo].PreCheckNetForm_Select
AS
	SET NOCOUNT ON;
SELECT FormID, NameOnWeb, UsedFor, NameOfFile FROM dbo.PreCheckNetForms ORDER BY NameOnWeb
