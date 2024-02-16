
CREATE PROCEDURE [dbo].NewsLettersSelect
AS
	SET NOCOUNT ON;
SELECT NewsLettersID, NewsDate, Subject, FileName, URL FROM dbo.NewsLetters
