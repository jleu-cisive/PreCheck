
-- =============================================
-- Author:		<Swetha Rai>
-- Create date: <September,10,2008>
-- Description:	This generates the list of customers -  Monthly Billing MAS90 Import
-- Modified date: <February,14,2009>
-- Description:	Modified in accordance with the new data spec after the MAS90 upgrade to V4.3
--              InvoiceDueDate, Terms, SalesTax are all calculated within MAS90.
-- Updated on 02/03/2010 - replaced Address with Billing Address as per CMwanzia
-- Modified by schapyala 09262017 - Added physical address
-- Modified by radhika dereddy on 11/25/2019 for HDT 62655 to generate a list with Active Clients and who has activity in the last 2 years.
-- Modified by Radhika Dereddy on 06/01/2020 to include BillCycle and Accounting System Grouping to the select list
-- =============================================
CREATE PROCEDURE [dbo].[sp_Get_BIS_Cust_List]

AS
BEGIN
	
	SET NOCOUNT ON;

  SELECT 
		'00' AS ARDivisionNo,
		CAST(RIGHT('0000000' + CONVERT(VARCHAR(7),CLNO), 7) AS VARCHAR) AS CustomerNo,
		LEFT(REPLACE(c.NAME,',',' '), 30) as CustomerName,
	   --Modified by Schapyala on 02/05/2018 to send main address only when billing address is null - requested by Rick
		isNULL(LEFT(REPLACE(REPLACE(AttnTo,char(13) +char(10),' '),',',' '),30),'') as ContactName,--Addressline1,	
		isNULL(LEFT(REPLACE(REPLACE(BillingAddress1,char(13) +char(10),' '),',',' '),30),LEFT(REPLACE(REPLACE(Addr1,char(13) +char(10),' '),',',' '),30)) as BillingAddressline1,
		isNULL(LEFT(REPLACE(REPLACE(BillingAddress2,char(13) +char(10),' '),',',' '),30),'') as BillingAddressline2,				
		isNULL(LEFT(REPLACE(BillingCity,',',' '),20),LEFT(REPLACE(City,',',' '),20)) as BillingCity,
		isNULL(LEFT(REPLACE(BillingState,',',' '),2),LEFT(REPLACE([State],',',' '),2)) as BillingState,
		isNULL(REPLACE(BillingZip,',',' '),REPLACE(Zip,',',' ')) as BillingZipCode,
		isNULL(REPLACE([BillCycle],',',' '),REPLACE(Zip,',',' ')) as 'BillingGroup',
		isNULL(REPLACE([Accounting System Grouping],',',' '),REPLACE(Zip,',',' ')) as 'AccountingSystemGrouping',
		--End Modified by Schapyala on 02/05/2018 to send main address only when billing address is null - requested by Rick
		isNULL(REPLACE(Phone,',',' '),'') as TelephoneNo,
		'' AS TelephoneExt,
        --When the client is exempt, no tax is charged irrespective of the taxlocale
		--(Case when IsTaxExempt = 1 then 'NONTAX' else MAS90Schedule End)  AS TaxSchedule, --commneted by Radhika on 07/06/2020 to show the correct Tax Schedule
		(Case when IsTaxExempt = 1 then 'EX' else TaxLocale End)  AS TaxSchedule,--C.TaxRate,
		isNULL(TaxExemptionNumber,'') as TaxExemptNo,
		30 AS TermsCode
FROM Client C
INNER JOIN refTaxLocale T on t.TaxLocaleID=c.TaxLocaleID
WHERE C.IsInActive = 0 and C.LastInvDate > '01/01/2017'
--and c.clno = 13418
END












