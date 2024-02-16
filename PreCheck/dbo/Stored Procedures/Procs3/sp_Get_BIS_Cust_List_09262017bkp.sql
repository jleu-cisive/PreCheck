






-- =============================================
-- Author:		<Swetha Rai>
-- Create date: <September,10,2008>
-- Description:	This generates the list of customers -  Monthly Billing MAS90 Import
-- Modified date: <February,14,2009>
-- Description:	Modified in accordance with the new data spec after the MAS90 upgrade to V4.3
--              InvoiceDueDate, Terms, SalesTax are all calculated within MAS90.
-- Updated on 02/03/2010 - replaced Address with Billing Address as per CMwanzia
-- =============================================
Create PROCEDURE [dbo].[sp_Get_BIS_Cust_List_09262017bkp]

AS
BEGIN
	
	SET NOCOUNT ON;

  SELECT 
		'00' AS ARDivisionNo,
		CAST(RIGHT('0000000' + CONVERT(VARCHAR(7),CLNO), 7) AS VARCHAR) AS CustomerNo,
		LEFT(REPLACE(c.NAME,',',' '), 30) as CustomerName,
--		isNULL(LEFT(REPLACE(REPLACE(ADDR1,char(13) +char(10),' '),',',' '),30),'') as Addressline1,
--		isNULL(LEFT(REPLACE(REPLACE(ADDR2,char(13) +char(10),' '),',',' '),30),'') as Addressline2,
--		isNULL(LEFT(REPLACE(CITY,',',' '),20),'') as City,
--		isNULL(LEFT(REPLACE(STATE,',',' '),2),'') as State,
--		isNULL(REPLACE(ZIP,',',' '),'') as ZipCode,	
		isNULL(LEFT(REPLACE(REPLACE(AttnTo,char(13) +char(10),' '),',',' '),30),'') as Addressline1,	
		isNULL(LEFT(REPLACE(REPLACE(BillingAddress1,char(13) +char(10),' '),',',' '),30),'') as Addressline2,		
		isNULL(LEFT(REPLACE(BillingCity,',',' '),20),'') as City,
		isNULL(LEFT(REPLACE(BillingState,',',' '),2),'') as State,
		isNULL(REPLACE(BillingZip,',',' '),'') as ZipCode,
		isNULL(REPLACE(Phone,',',' '),'') as TelephoneNo,
		'' AS TelephoneExt,
        --When the client is exempt, no tax is charged irrespective of the taxlocale
		(Case when IsTaxExempt = 1 then 'NONTAX' else MAS90Schedule End)  AS TaxSchedule, 
		isNULL(TaxExemptionNumber,'') as TaxExemptNo,
		30 AS TermsCode,
		isNULL(LEFT(REPLACE(REPLACE(BillingAddress2,char(13) +char(10),' '),',',' '),30),'') as Addressline3
FROM Client C
INNER JOIN refTaxLocale T on t.TaxLocaleID=c.TaxLocaleID
END












