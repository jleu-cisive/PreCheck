-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 04/13/2018
-- Description:	Creating a stored procedure instead of a inline query in the Qreport
-- Modified by Radhika Dereddy on 04/24/2020 - TO run the query by Invoice Number and not by CreateDate of the invoicedetail
-- EXEC [Client_Invoice_LineItems] 1616, 9281657
-- =============================================
CREATE PROCEDURE [dbo].[Client_Invoice_LineItems]
	-- Add the parameters for the stored procedure here
	@CLNO int,
	@InvoiceNumber int
	--@STARTDATE datetime,
	--@ENDDATE datetime
	
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
 
SELECT I.* FROM INVDETAIL I WITH (NOLOCK)
INNER JOIN APPL A WITH (NOLOCK)  ON I.APNO = A.APNO
WHERE A.CLNO = IIF(@CLNO=0,A.CLNO,@CLNO) 
AND i.InvoiceNumber = @InvoiceNumber
--AND  CREATEDATE>= @STARTDATE 
--AND  CREATEDATE< @ENDDATE  

END
