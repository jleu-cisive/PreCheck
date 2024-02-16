/*
Procedure Name : - SJV_Verifications_Assigned_Summary
Requested By: Dana Sangerhausen
Developer: Deepak Vodethela
Execution : EXEC [SJV_Verifications_Assigned_Summary] '05/13/2019','05/13/2019'
*/

CREATE PROCEDURE [dbo].[SJV_Verifications_Assigned_Summary]
	@StartDate DATETIME,
	@EndDate DATETIME
AS


--Added the count of records successfully received by SJV - Suchitra Yellapantula 12/13/2016
select CAST(CreatedDate AS DATE) AS CreatedDate, COUNT(1) [RecordsSentCount]
into #tempCountSent
from Integration_VendorOrder
where VendorName = 'SJV' and VendorOperation = 'SubmitOrder' 
			AND CAST(CreatedDate AS DATE) >= CAST(@StartDate AS DATE)
			AND CAST(CreatedDate AS DATE) <= CAST(@EndDate AS DATE)
			AND Response.value('(//Success)[1]','varchar(max)')='true'
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

select TS.CreatedDate, TA.[Records Assigned], TS.RecordsSentCount as 'Records Sent'
from #tempCountAssigned TA left outer join #tempCountSent TS on TA.CreatedDate = TS.CreatedDate
order by TS.CreatedDate

drop table #tempCountSent
drop table #tempCountAssigned


