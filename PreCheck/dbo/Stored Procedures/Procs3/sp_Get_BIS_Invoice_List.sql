








-- =============================================
-- Author:		<Swetha Rai>
-- Create date: <September,10,2008>
-- Description:	This generates the list of Invoices -  Monthly Billing MAS90 Import
-- Modified date: <February,14,2009>
-- Description:	Modified in accordance with the new data spec after the MAS90 upgrade to V4.3
--              InvoiceDueDate, Terms, SalesTax are all calculated within MAS90. 
-- Modified date: <November 23,2009>
-- Description:	sChapyala Added BillingCycle 5 to the table and filter below
-- Modified Date: 03/28/2018
-- Modified By: Radhika Dereddy - add billingcycle 'O' (Orianna)
-- Modified By: Radhika Dereddy on 02/01/2019 - add billingcycle 'U' (USPI), remove 'O'(bankrupt nolonger in business)
-- sp_Get_BIS_Invoice_List 4,2018
-- Modified By: Radhika Dereddy on 07/12/2019 - add billingcycle A1,A2 for AdventHealth
-- Modified by Radhika Dereddy on 09/20/2019 - add new billing cycle CS for Carespot/Medpost client
-- =============================================
CREATE PROCEDURE [dbo].[sp_Get_BIS_Invoice_List]
	@Month TINYINT =0,
	@Year SMALLINT =0 
AS
BEGIN
	
SET NOCOUNT ON;

Declare @InvDate char(8)
Declare @InvoiceDateFrom DateTime,@InvoiceDateTo DateTime

If @Month = 0 	Set @Month = month(getDate())
If @Year  = 0 	Set @Year  = Year(getDate())

DECLARE		@Cur_FOM Datetime,
			@Cur_EOM Datetime,			
			@Prev_EOM DateTime

			set @Cur_FOM = Cast((cast(@Month as varchar)+ '/01/' + cast(@Year as varchar)) as datetime)
			set @Cur_EOM = DateAdd(d,-1,dateadd(m,1,@Cur_FOM))  --Set the variable to the End of current month
			set @Prev_EOM = DateAdd(d,-1,@Cur_FOM)  --Set the variable to the End of last month

--Set @InvDate = '073107' --set this(last  day of last month)
  Set @InvDate = REPLACE(CONVERT(char(8), @Prev_EOM, 10), '-', '')
   	
---- Set @InvoiceDateTo = '08/15/2007' --Mid Month of the @INV_DUE_DATE
--Set @InvoiceDateTo = DateADD(d,14,@Cur_FOM)
	Set @InvoiceDateTo = CURRENT_TIMESTAMP -- changed by kiran on 5/2/2018
---- Set @InvoiceDateFrom = '07/15/2007' --Mid Month of the @InvDate
  -- Set @InvoiceDateFrom = DateAdd(m,-1,@InvoiceDateTo) --Mid Month of the @InvDate
  Set @InvoiceDateFrom = DateAdd(d,6,DateAdd(m,-1,@Cur_FOM)) -- changed by kiran on 5/2/2018
  --select @InvoiceDateTo,@InvoiceDateFrom,@Cur_FOM

SELECT InvoiceNumber AS InvoiceNo, 
	'IN' AS InvoiceType,    --IN for Invoice
	'00' AS ARDivisionNo,   --this needs to be made dynamic if PreCheck has accounting by division (not needed at this time)
	i.CLNO AS CustomerNo,
	@InvDate InvoiceDate,  
	0 As BatchNo,  
	999 AS ItemCode,         --In the future this will be made dynamic based on the cycle (per product etc.)
    5   As Itemtype,         -- is this impacted?? I think NO.
	Sale AS ExtensionAmount,  --PreTax Sale Amount
	Tax 
FROM InvMaster i
JOIN Client c ON c.CLNO=i.CLNO
LEFT JOIN Users u ON c.SalesPersonUserID = u.UserID
JOIN refBillingCycle bc ON bc.BillingCycleID=c.BillingCycleID
JOIN refTaxLocale t on t.TaxLocaleID=c.TaxLocaleID
WHERE InvDate > @InvoiceDateFrom and InvDate < @InvoiceDateTo 
and BillingCycle in ('A','C','P','B','D','1','2','3','R', 'U', 'A1','A2', 'CS', '99','H', 'F','SM','SP')
order by c.clno

  
END
