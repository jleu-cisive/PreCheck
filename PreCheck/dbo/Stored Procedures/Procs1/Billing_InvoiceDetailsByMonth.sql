

--[Billing_InvoiceDetailsByMonth]  4,2020

-- =============================================
-- Author:		Kiran Miryala
-- Create date: 5/27/2020
-- Description:	Billing details by month so accounting can run required reports
-- EXEC [dbo].[Billing_InvoiceDetailsByMonth] 05,2021,'0',0
-- Modified by Humera Ahmed on 6/9/2021 for HDT#7543 - Add Affiliate and Client Name columns to the report. Add CLNO and Affiliate parameters
-- =============================================
/*
-- Modified by Sunil Mandal #62277
Ticket - #62277 Add Accounting System Group value to "Billing Invoice Details By Month" QReport
EXEC [dbo].[Billing_InvoiceDetailsByMonth] 05,2021,'0',0
*/

CREATE PROCEDURE [dbo].[Billing_InvoiceDetailsByMonth] 
	-- Add the parameters for the stored procedure here
	@Month int,
	@Year int,
	@CLNO varchar(max) = '0',
	@AffiliateID int = 0
AS
BEGIN

SET ANSI_WARNINGS ON
SET ARITHABORT ON

IF(@CLNO = 0 OR @CLNO IS NULL OR LOWER(@CLNO) = 'null' OR @CLNO='')
	BEGIN
		SET @CLNO = 0
	END

 
select 
	c.CLNO [Client Number]
	,c.Name [Client Name]
	, ra.Affiliate
	,c.[Accounting System Grouping] -- Added By Sunil Mandal # Ticket - 62277
	, Apno,Type
	,I.invoicenumber
	,Description
	,Amount
	,InvDate
from dbo.invdetail i with (nolock) 
inner join dbo.invmaster ii with (nolock) on i.invoicenumber = ii.invoicenumber
INNER JOIN dbo.Client c WITH(nolock) ON ii.CLNO=c.CLNO 
INNER JOIN dbo.refAffiliate ra WITH(nolock)  ON c.AffiliateID = ra.AffiliateID
where 
month(InvDate) = @month 
and year(InvDate) = @year
and c.CLNO = IIF(@CLNO =0, c.CLNO, @CLNO)
AND ra.AffiliateID = IIF(@AffiliateID=0, ra.AffiliateID, @AffiliateID)
order by 
	c.Clno,Apno,i.InvoiceNumber,type

End












