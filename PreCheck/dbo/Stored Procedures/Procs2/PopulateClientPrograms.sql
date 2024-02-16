
CREATE  PROCEDURE PopulateClientPrograms 
	@ClientID varchar(10)
AS

SELECT '-Select Program to Show-' DescriptiveName, 0 CLNO
UNION ALL
SELECT (case when dbo.Client.DescriptiveName is null then dbo.Client.name else dbo.Client.DescriptiveName end) DescriptiveName, dbo.Client.CLNO
FROM dbo.Client
WHERE dbo.Client.CLNO=@clientID OR dbo.Client.WebOrderParentCLNO=@clientID
