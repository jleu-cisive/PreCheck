/*
Procedure Name : Zc_Verifications_Assigned_Summary
Requested By   : Michelle Paz
Developer      : Vairavan A
Created on     : 15-12-2023
Ticket no & Description : 119545 New Qreport SJV Qreports
Execution      : EXEC [Zc_Verifications_Assigned_Summary] '12/14/2023', '12/15/2023'
*/

CREATE PROCEDURE [dbo].[Zc_Verifications_Assigned_Summary]
	@StartDate DATETIME,
	@EndDate DATETIME
AS
Begin
set nocount on

	Declare @VendorName varchar(50) = 'EnterpriseSJV'  

Select CAST(CreatedDate AS DATE) AS CreatedDate, COUNT(1) [RecordsSentCount]
into #tempCountSent
from Integration_VendorOrder_Submitted with(nolock)
where SubmittedTo=@VendorName
	AND CAST(CreatedDate AS DATE) >= @StartDate
	AND CAST(CreatedDate AS DATE) <= @EndDate
GROUP BY CAST(CreatedDate AS DATE)
ORDER BY CAST(CreatedDate AS DATE)


SELECT CAST(GA.CreatedDate AS DATE) AS CreatedDate, COUNT(1) [Records Assigned] 
into #tempCountAssigned
FROM PreCheck.dbo.GetNextAudit (NOLOCK) GA
WHERE NewValue = 'SJV'
  AND CAST(GA.CreatedDate AS DATE) >= CAST(@StartDate AS DATE)
  AND CAST(GA.CreatedDate AS DATE) <= CAST(@EndDate AS DATE)
GROUP BY (CAST(GA.CreatedDate AS DATE))
ORDER BY CAST(GA.CreatedDate AS DATE)

select TS.CreatedDate, TA.[Records Assigned], Isnull(TS.RecordsSentCount,0) as 'Records Sent'
from #tempCountAssigned TA left outer join #tempCountSent TS on TA.CreatedDate = TS.CreatedDate
order by TS.CreatedDate

drop table #tempCountSent
drop table #tempCountAssigned

set nocount off
End


