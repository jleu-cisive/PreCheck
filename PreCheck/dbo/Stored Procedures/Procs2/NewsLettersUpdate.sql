
CREATE PROCEDURE [dbo].NewsLettersUpdate
(
	@NewsDate varchar(20),
	@Subject varchar(200),
	@FileName varchar(200),
	@URL varchar(200),
	@Original_NewsLettersID int,
	@Original_FileName varchar(200),
	@Original_NewsDate varchar(20),
	@Original_Subject varchar(200),
	@Original_URL varchar(200),
	@NewsLettersID int
)
AS
	SET NOCOUNT OFF;
UPDATE dbo.NewsLetters SET NewsDate = @NewsDate, Subject = @Subject, FileName = @FileName, URL = @URL WHERE (NewsLettersID = @Original_NewsLettersID) AND (FileName = @Original_FileName OR @Original_FileName IS NULL AND FileName IS NULL) AND (NewsDate = @Original_NewsDate OR @Original_NewsDate IS NULL AND NewsDate IS NULL) AND (Subject = @Original_Subject OR @Original_Subject IS NULL AND Subject IS NULL) AND (URL = @Original_URL OR @Original_URL IS NULL AND URL IS NULL);
	SELECT NewsLettersID, NewsDate, Subject, FileName, URL FROM dbo.NewsLetters WHERE (NewsLettersID = @NewsLettersID)
