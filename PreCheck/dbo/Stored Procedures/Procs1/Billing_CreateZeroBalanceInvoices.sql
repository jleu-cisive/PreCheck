-- =============================================
-- Author:		Yves Fernandes
-- Create date: 05/05/2019
-- Description:	Create a Zero Balance iNvoice for clients who need an Invoice without orders.
-- =============================================

CREATE PROCEDURE [dbo].[Billing_CreateZeroBalanceInvoices]
	@InvoiceServiceDate datetime2(3)
AS
	SET NOCOUNT on
	; WITH CTE AS
	(
		SELECT 
			value AS CLNO
		FROM fn_split(
			(SELECT cc.[Value] FROM dbo.ClientConfiguration cc WHERE cc.ConfigurationKey = 'Billing_ClientsForZeroBalance'), 
			',')
	)
	SELECT * INTO #ParentAcounts FROM CTE;

	select CLNO INTO #ClientsForZerobalance from Client where weborderparentclno in (SELECT pa.CLNO FROM #ParentAcounts pa)

	INSERT INTO dbo.InvMaster
	(
	    CLNO,
	    Printed,
	    InvDate,
	    Sale,
	    Tax
	)
	SELECT cfz.CLNO, 0, convert(date, @InvoiceServiceDate), 0, 0  
	FROM #ClientsForZerobalance cfz
	LEFT JOIN dbo.InvMaster im ON im.CLNO = cfz.CLNO AND Convert(date, im.InvDate) = convert(date, @InvoiceServiceDate)
	WHERE IM.CLNO  IS NULL

	DROP TABLE #ParentAcounts
	DROP TABLE #ClientsForZerobalance
