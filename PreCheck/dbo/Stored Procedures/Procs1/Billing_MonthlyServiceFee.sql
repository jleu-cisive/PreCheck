-- =============================================
-- Author:		<Lalit Kumar>
-- Create date: <29-Feb-2023>
-- Description:	<to create dummy apps for monthly service fees.>
-- Modified by Lalit on 29 March to make sure billed and packageid's are correct.
-- =============================================
CREATE procedure [dbo].[Billing_MonthlyServiceFee]
as
begin
SET NOCOUNT ON;
declare @eomdate datetime=CAST(eomonth(DATEADD(m,-1,getdate())) AS datetime)  -- define date as last date of previous month
------------------------------------ read ClientConfiguration to find clno for which fee needs to be added -------------
DROP TABLE IF EXISTS #tempbill
SELECT cca.Clno, ccd.Value AS [Description], ccc.Value AS Amount
INTO #tempbill
FROM ClientConfiguration cca
	 INNER JOIN ClientConfiguration ccd ON cca.Clno=ccd.Clno AND ccd.ConfigurationKey = 'Billing_Monthly_SF_desc'
	 INNER JOIN ClientConfiguration ccc ON cca.Clno=ccc.Clno AND ccc.ConfigurationKey='Billing_Monthly_SFCharges'
WHERE cca.ConfigurationKey = 'Billing_Monthly_SFActive' AND cca.Value='True' AND cca.Clno NOT IN (2135, 3079, 3468, 3668) --- change here from in to not in
AND ccc.Value>0
--------------------------------------check appl table if dummy apno already added or not-------------------------------
DROP TABLE IF EXISTS #tempclapno
SELECT tmp.* 
INTO #tempclapno
FROM #tempbill tmp
	 LEFT JOIN Appl a ON a.Clno=tmp.Clno AND a.First='Monthly' AND a.Last='Service Fee' AND a.SSN='000-00-0000' AND a.ApDate=@eomdate
WHERE a.APNO IS NULL
---------------------------------------- create new apno's and make corresponding entries into invdetail table------
IF (SELECT COUNT(*) FROM #tempclapno) >0 BEGIN
INSERT INTO Appl(ApStatus, Billed, EnteredBy, ApDate, CompDate, Clno, Last, First, SSN, DOB, Addr_Street, City, State, Zip,IsAutoPrinted,IsAutoSent,AutoPrintedDate,AutoSentDate,PackageID)
SELECT 'F', 1, 'Billing', @eomdate, @eomdate, tmpc.Clno, 'Service Fee', 'Monthly', '000-00-0000', '1900-01-01', '111 Service Fee', 'Service Fee', 'TX', '11111',1,1,@eomdate, @eomdate,2399
FROM #tempclapno tmpc

INSERT INTO InvDetail(APNO, Type, Subkey, SubKeyChar, Billed, InvoiceNumber, CreateDate, Description, Amount)
SELECT a.APNO, 1, NULL, NULL, 0, NULL, GETDATE(), tmp.Description, tmp.Amount
FROM Appl a
	 INNER JOIN #tempclapno tmp ON a.Clno=tmp.Clno AND a.First='Monthly' AND a.Last='Service Fee' AND a.SSN='000-00-0000' AND a.ApDate=@eomdate

END
------------------------------------------- make sure dummy apno's are marked as billed and packageid's are filled -------
update a
set a.billed=1,
a.packageid=2399
----select * 
from Appl a where a.First='Monthly' AND a.Last='Service Fee' AND a.SSN='000-00-0000' AND a.ApDate>'2023-01-01' and a.CLNO NOT in (3468, 3668, 2135)
and (a.Billed<>1 or ISNULL(a.packageid,0) <>2399)
-------------------------------------------drop temp tables-----------------------
DROP TABLE IF EXISTS #tempbill
DROP TABLE IF EXISTS #tempclapno
END
-------------------
SET NOCOUNT OFF
