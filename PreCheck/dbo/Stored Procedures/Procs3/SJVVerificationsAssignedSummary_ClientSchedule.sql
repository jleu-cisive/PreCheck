-- =============================================
-- Author: Radhika Dereddy
-- Create date: 02/28/2021
-- Description: SJV Verifications Assigned Summary Details
-- Mirrored the procedure from [dbo].[SJV_Verifications_Assigned_Summary]Qreport to schedule it
-- EXEC [dbo].[SJVVerificationsAssignedSummary_ClientSchedule]
-- =============================================

CREATE PROCEDURE [dbo].[SJVVerificationsAssignedSummary_ClientSchedule]

AS

BEGIN

DECLARE @StartDate DATE = CONVERT(Date, getdate()) --Today's date
DECLARE @EndDate DATE = CONVERT(Date, getdate()) --Today's date


SELECT CAST(CreatedDate AS DATE) AS CreatedDate, COUNT(1) [RecordsSentCount]
INTO #tempCountSent
FROM Integration_VendorOrder (NOLOCK)
WHERE VendorName = 'SJV' and VendorOperation = 'SubmitOrder' 
			AND CAST(CreatedDate AS DATE) >= CAST(@StartDate AS DATE)
			AND CAST(CreatedDate AS DATE) <= CAST(@EndDate AS DATE)
			AND Response.value('(//Success)[1]','varchar(max)')='true'
GROUP BY CAST(CreatedDate AS DATE)
ORDER BY CAST(CreatedDate AS DATE)

SELECT CAST(GA.CreatedDate AS DATE) AS CreatedDate, COUNT(1) [Records Assigned] 
INTO #tempCountAssigned
FROM PreCheck.dbo.GetNextAudit (NOLOCK) GA
WHERE NewValue = 'SJV'
  AND CAST(GA.CreatedDate AS DATE) >= CAST(@StartDate AS DATE)
  AND CAST(GA.CreatedDate AS DATE) <= CAST(@EndDate AS DATE)
GROUP BY (CAST(GA.CreatedDate AS DATE))
ORDER BY CAST(GA.CreatedDate AS DATE)

SELECT TS.CreatedDate, TA.[Records Assigned], TS.RecordsSentCount as 'Records Sent'
FROM #tempCountAssigned TA 
LEFT OUTER JOIN #tempCountSent TS on TA.CreatedDate = TS.CreatedDate
ORDER BY TS.CreatedDate

DROP TABLE IF EXISTS #tempCountSent
DROP TABLE IF EXISTS #tempCountAssigned

END
