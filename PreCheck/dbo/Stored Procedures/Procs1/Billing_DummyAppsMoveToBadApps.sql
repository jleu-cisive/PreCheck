-- =============================================
-- Author:		<Lalit Kumar>
-- Create date: <29-March-2023>
-- Description:	<to move dummy apps created for monthly service fees to bad apps in order to hide these from appearing in client access.>
-- =============================================
CREATE PROCEDURE [dbo].[Billing_DummyAppsMoveToBadApps]

AS
BEGIN
	
	SET NOCOUNT ON;

	update a
	SET a.Priv_Notes= CONCAT('CLNO: ',a.CLNO,' :this app was created for monthly service fee: ',a.Priv_Notes),
	a.DeptCode=a.clno,
	a.CLNO=2135,
	a.Billed=1
	----SELECT * 
	FROM Appl a
		 INNER JOIN InvDetail id ON a.APNO=id.APNO AND a.First='Monthly' AND a.Last='Service Fee' AND a.SSN='000-00-0000' AND a.ApDate>'2023-01-01' AND a.Clno NOT IN (3468, 3668, 2135)
		 AND id.Billed=1 AND id.[Type]=1
	WHERE ISNULL(id.InvoiceNumber, '')<>''

END
