
CREATE PROCEDURE [dbo].[NewsLettersWeb] AS

SELECT     NewsLettersID, NewsDate, Subject, URL
FROM         dbo.NewsLetters
