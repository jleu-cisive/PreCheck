
CREATE FUNCTION [dbo].[IsClientZipCrim] 
	(@apno int)
RETURNS bit
WITH EXECUTE AS CALLER
AS
BEGIN
	DECLARE @isZipCrim bit; 

	SELECT @isZipCrim = iif(cc.CLNO Is NULL OR cc2.CLNO IS NOT NULL, 0, 1) 
	FROM dbo.Appl a
	LEFT JOIN dbo.ClientConfiguration cc ON cc.CLNO = a.CLNO AND cc.ConfigurationKey = 'ZIPCRIM' AND UPPER(cc.[Value]) = 'TRUE'
	LEFT JOIN dbo.ClientConfiguration cc2 ON cc2.CLNO = a.CLNO AND cc2.ConfigurationKey = 'AUTOORDER' AND upper(cc2.[Value]) = 'TRUE'
	WHERE a.APNO = @apno
	return @isZipCrim
END
