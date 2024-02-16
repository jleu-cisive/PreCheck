CREATE PROCEDURE  [dbo].[GetNCHIntegrationRecordAliases] 
(
	@APNO varchar(15)
)

AS
BEGIN

	SET NOCOUNT ON

	SELECT aa.[First] as FirstName, aa.Middle as MiddleName, aa.[Last] as LastName
	From  dbo.ApplAlias aa
	WHERE aa.IsActive = 1
	AND aa.APNO = @APNO

	--UNION ALL

	--SELECT aa.[First] as FirstName, aa.Middle as MiddleName, aa.[Last] as LastName
	--From  dbo.ApplAlias aa
	--WHERE aa.IsActive = 1
	--AND aa.APNO = @APNO


END
