
CREATE PROCEDURE [dbo].[ZipCrim_GetMaxCrimCount]
AS
BEGIN
	SELECT cast(cc.[Value] AS int) AS MaxCount 
	FROM dbo.ClientConfiguration cc 
	WHERE cc.CLNO = 0 
	  AND cc.ConfigurationKey = 'ZIPCRIM_MAXCRIMCOUNT'
END
