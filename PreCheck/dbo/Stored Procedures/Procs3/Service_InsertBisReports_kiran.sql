




create PROCEDURE [dbo].[Service_InsertBisReports_kiran] AS

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;



/*Update Appl
set inuse = 'Print'
where (Apstatus = 'f' or Apstatus = 'W') and (isautoprinted = 0) 
and compdate > '1/20/2006 6:34:00 AM'
and (inuse is null)  */

-- Print future applications but only print past history application if it is resend

Update Appl
set inuse = 'Print'
where APNO in (select Top 100 APNO
from Appl A inner join
Client C ON A.CLNO = C.CLNO
where a.clno not in (3468) and (
 --(A.Apstatus = 'f' or A.Apstatus = 'W')3/15/07 Removed W status
 (A.Apstatus = 'w' and (A.isautoprinted = 0) and (A.inuse is null)) 
or
(A.Apstatus = 'f' and (A.isautoprinted = 0) and (A.compdate > '1/14/2006 5:34:00 PM')
and (A.inuse is null)) 
or
--((A.Apstatus = 'f' or A.Apstatus = 'W')
( A.Apstatus = 'f' and (A.isautoprinted = 0) and (A.compdate < '1/14/2006 5:34:00 PM')
and (A.inuse is null) and (A.autosentdate is not null) and(C.AutoReportDelivery = 1)
) 
or
(
a.last_updated > '1/1/08'
and
a.apstatus = 'F' and a.clno = 2167 and
(select count(*) from backgroundreports.dbo.backgroundreport with (nolock) where apno = a.apno) = 0
)) order by a.apno desc
)




--sELECT distinct clno,apno,isautoprinted,AutoPrintedDate,apdate
Update appl
set inuse = 'Print'
where APNO in (select Top 100 APNO
from appl a left join hevn..employeerecord er on a.clno = er.Employerid and a.ssn = er.ssn and er.enddate is null where 
--a.clno in (2179,9770, 7354,10365,   9919,10102,11115, 2179 , 5593,      11756,11867,    9098 ,    9006 ) 
a.clno IN (1517,1514,1522,1512,1532,2465,7397,1081,1519,1518,1537,1515,1529) --etmc
and apno not in (select apno from backgroundreports..BackgroundReport) and apstatus='F' )


SELECT     dbo.Appl.APNO, dbo.Appl.ApStatus, dbo.Appl.[Last], dbo.Appl.[First], dbo.Appl.Middle, dbo.Appl.CLNO, SUBSTRING (dbo.Appl.Attn, 1, 25) as Attn, dbo.Client.Fax, 
                      dbo.Client.AutoReportDelivery, dbo.Appl.IsAutoPrinted, dbo.Appl.AutoPrintedDate, dbo.Appl.IsAutoSent, dbo.Appl.AutoSentDate
INTO #ReportsToInsert
FROM         dbo.Appl WITH (NOLOCK) INNER JOIN
                      dbo.Client WITH (NOLOCK) ON dbo.Appl.CLNO = dbo.Client.CLNO
WHERE     (dbo.Appl.InUse = 'Print')

--the purpose of the following statement is to :lock" these rows from being picked up by the other instances of exection.
--the GEN-PDF identify a batch, this batch should be reset InUse to null
--UPDATE dbo.Appl
--SET InUse='GEN-PDF'
--WHERE dbo.Appl.Apno IN
--(
--	SELECT APNO FROM #ReportsToInsert
--)


SELECT * FROM #ReportsToInsert order by apno desc
DROP Table #ReportsToInsert

SET NOCOUNT OFF;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;


