
CREATE PROCEDURE [dbo].NewsLettersInsert
(
	@NewsDate varchar(20),
	@Subject varchar(200),
	@FileName varchar(200),
	@URL varchar(200)
)
AS
	SET NOCOUNT OFF;
INSERT INTO dbo.NewsLetters(NewsDate, Subject, FileName, URL) VALUES (@NewsDate, @Subject, @FileName, @URL);
	SELECT NewsLettersID, NewsDate, Subject, FileName, URL FROM dbo.NewsLetters WHERE (NewsLettersID = @@IDENTITY)
