-- =============================================
-- Date: July 3, 2001
-- Author: Pat Coffer
-- =============================================
CREATE PROCEDURE UpdateClientLastInvoice
	@Clno smallint,
	@LastInvDate datetime,
	@LastInvAmount smallmoney
AS
SET NOCOUNT ON
UPDATE Client
SET LastInvDate = @LastInvDate,
    LastInvAmount = @LastInvAmount
WHERE Clno = @Clno
