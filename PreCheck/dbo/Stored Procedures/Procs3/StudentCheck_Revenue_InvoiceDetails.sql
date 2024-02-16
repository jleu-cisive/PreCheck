-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 07/15/2019
-- Description:	StudentCheck Revenue by component like Immunization and DrugTest.
-- EXEC [StudentCheck_Revenue_InvoiceDetails] '07/01/2019','07/31/2019',0,0
-- =============================================
CREATE PROCEDURE [dbo].[StudentCheck_Revenue_InvoiceDetails]
	-- Add the parameters for the stored procedure here
@StartDate datetime,
@EndDate Datetime,
@SchoolWillPay bit,
@CLNO int 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
(SELECT A.Apdate, A.CompDate, a.apno as APNO, a.state, c.TaxRate, c.clno as CLNO,c.name as ClientName,rc.ClientType, cp.name as ProgramName, id.Description, id.Amount,id.InvoiceNumber, id.CreateDate as InvoiceDate,
pm.packagedesc as PackageName, c.Billcycle, a.Billed, (Case when c.SchoolWillPay = 0 then 'No' else 'Yes' end) as SchoolWillPay
FROM appl a  
INNER JOIN client c on a.clno = c.clno
INNER JOIN clientprogram cp on cp.clientprogramid = a.clientprogramid
INNER JOIN clientpackages cps on cps.packageid = a.packageid and cps.clno = c.clno
INNER JOIN packagemain pm on pm.packageid = cps.packageid
inner join InvDetail id on a.apno = id.APNO
inner join refClientType rc on c.ClientTypeID = rc.ClientTypeID
WHERE a.CompDate >= @StartDate AND a.CompDate < DateAdd(d,1,@EndDate)
AND c.SchoolWillPay = @SchoolWillPay
AND c.CLNO = IIF(@CLNO=0, c.CLNO,@CLNO)
AND  id.Description like '%Immunization%'
AND a.Billed = 1
)

UNION 

(SELECT A.Apdate, A.CompDate, a.apno as APNO, a.state, c.TaxRate, c.clno as CLNO,c.name as ClientName, rc.ClientType, cp.name as ProgramName, id.Description, id.Amount,id.InvoiceNumber, id.CreateDate as InvoiceDate,
pm.packagedesc as PackageName, c.Billcycle, a.Billed, (Case when c.SchoolWillPay = 0 then 'No' else 'Yes' end) as SchoolWillPay
FROM appl a  
INNER JOIN client c on a.clno = c.clno
INNER JOIN clientprogram cp on cp.clientprogramid = a.clientprogramid
INNER JOIN clientpackages cps on cps.packageid = a.packageid and cps.clno = c.clno
INNER JOIN packagemain pm on pm.packageid = cps.packageid
inner join InvDetail id on a.apno = id.APNO
inner join refClientType rc on c.ClientTypeID = rc.ClientTypeID
WHERE a.CompDate >= @StartDate AND a.CompDate < DateAdd(d,1,@EndDate)
AND c.SchoolWillPay = @SchoolWillPay
AND c.CLNO = IIF(@CLNO=0, c.CLNO,@CLNO)
AND  id.Description like '%Drug%'
AND a.Billed = 1
)

UNION

(SELECT A.Apdate, A.CompDate, a.apno as APNO, a.state, c.TaxRate, c.clno as CLNO,c.name as ClietnName,rc.ClientType, cp.name as ProgramName, id.Description, id.Amount,id.InvoiceNumber, id.CreateDate as InvoiceDate,
pm.packagedesc as PackageName, c.Billcycle, a.Billed, (Case when c.SchoolWillPay = 0 then 'No' else 'Yes' end) as SchoolWillPay
FROM appl a  
INNER JOIN client c on a.clno = c.clno
INNER JOIN clientprogram cp on cp.clientprogramid = a.clientprogramid
INNER JOIN clientpackages cps on cps.packageid = a.packageid and cps.clno = c.clno
INNER JOIN packagemain pm on pm.packageid = cps.packageid
inner join InvDetail id on a.apno = id.APNO
inner join refClientType rc on c.ClientTypeID = rc.ClientTypeID
WHERE a.CompDate >= @StartDate AND a.CompDate < DateAdd(d,1,@EndDate)
AND c.SchoolWillPay = @SchoolWillPay
AND c.CLNO = IIF(@CLNO=0, c.CLNO,@CLNO)
AND  Type = 0
AND a.Billed = 1
)

END
