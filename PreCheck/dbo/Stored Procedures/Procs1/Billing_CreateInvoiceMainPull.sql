


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	changed by Radhika Dereddy on 10/11/2013
-- =============================================

-- EXEC [Billing_CreateInvoiceMainPull] '12/01/2019', 'A,'
CREATE PROCEDURE [dbo].[Billing_CreateInvoiceMainPull] 
	-- Add the parameters for the stored procedure here
	@CutOffDate datetime,
	--@BillingCycle char(2) 
	@BillingCycle nvarchar(50) --Radhika Dereddy 10/11/2013
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

----Radhika Dereddy 10/11/2013 create a temporary table for storing the BillingCycle values.
CREATE Table #tempBillingCycle
(
	Cycle varchar(10)
)
Declare @cycle nvarchar(100)
Declare @pos int
SET @pos = charindex(',', @BillingCycle)

WHILE (@pos <> 0)
BEGIN
	SET @cycle = Substring(@BillingCycle, 1, @pos-1)
	INSERT INTO #tempBillingCycle (Cycle) Values (@cycle)

	SET @Billingcycle = Substring(@BillingCycle, @pos+1, LEN(@BillingCycle))
	SET @pos = charindex(',', @BillingCycle)
END

--Select Cycle from #tempBillingCycle

SELECT D.APNO,
 D.AMOUNT, 
 D.DESCRIPTION,
 D.Type, 
 D.InvDetID,
 APPL.APSTATUS,  
 APPL.LAST, 
 APPL.FIRST, 
 APPL.MIDDLE,
 APPL.COMPDATE,
 APPL.CLNO, 
 Appl.update_billing, 
 APPL.DeptCode,
 C.NAME,  
 C.ADDR1, 
 C.ADDR2,
 C.CITY,
 C.STATE, 
 C.ZIP, 
 C.TAXRATE,
 C.IsTaxExempt,
 refBC.BillingCycle as BillingCycle
 FROM InvDetail D  WITH (NOLOCK)
	inner join APPL APPL WITH (NOLOCK) on d.apno = appl.apno
	inner join CLIENT C WITH (NOLOCK) on appl.clno = c.clno
	inner join refBillingCycle refBC WITH (NOLOCK) on refBC.billingCycleID = C.billingCycleID
	left join clientconfig_billing cb WITH (NOLOCK) on c.clno = cb.clno
	left join clienthierarchybyservice cs WITH (NOLOCK) on c.clno = cs.clno and cs.refhierarchyserviceid = 3
	left join clientconfig_billing cbp WITH (NOLOCK) on cs.parentclno = cbp.clno
	inner join #tempBillingCycle Tc on Ltrim(RTrim(replace(replace(c.BillCycle,char(10),''),char(13),''))) = tc.Cycle --Radhika Dereddy on 10/11/2013
 WHERE 
( ( D.Billed = 0 ) AND  ( ( ( APPL.APSTATUS = 'F' ) AND ( APPL.COMPDATE < @CutOffDate ) )  OR ( APPL.APSTATUS = 'W' ) )
) 
AND (ISNULL(APPL.packageid,'') <> '' OR (isnull(cb.nopackagenobill,0) <> 1 and isnull(cbp.nopackagenobill,0) <> 1))


ORDER BY C.billingCycleID,APPL.CLNO , appl.last, appl.first, appl.middle, appl.apno , D.TYPE

SET NOCOUNT OFF
SET TRANSACTION ISOLATION LEVEL READ COMMITTED

Drop table #tempBillingCycle 
END







