-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 04/13/2018
-- Description:	Creating a stored procedure instead of a inline query in the Qreport
-- =============================================
CREATE PROCEDURE Client_Contacts_by_Invoice
	-- Add the parameters for the stored procedure here
	@InvoiceDate Datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
SELECT I.INVOICENUMBER,I.INVDATE,I.SALE,C.CLNO,C.NAME,C.ATTNTO AS BILLINGATTNTO,
 C.BILLINGADDRESS1,C.BILLINGADDRESS2,C.BILLINGCITY,C.BILLINGSTATE,C.BILLINGZIP,
 CC.FIRSTNAME AS CONTACTFIRST,CC.LASTNAME AS CONTACTLAST,CC.EMAIL AS CONTACTEMAIL
FROM INVMASTER I WITH (NOLOCK)
INNER JOIN CLIENT C WITH (NOLOCK) ON I.CLNO = C.CLNO
LEFT JOIN CLIENTCONTACTS CC WITH (NOLOCK) ON CC.CLNO = C.CLNO
WHERE INVDATE = @InvoiceDate


END
