




-- =============================================
-- Author: Larry Ouch			
-- Create date: 03/18/2023
-- Description:	Gets pending employment and education orders that have been submitted to Enterprise ZipCrim
-- which have not had any activity for 24hrs
-- SELECT * FROM [dbo].[vwPendingEnterpriseZipCrimOrders]
-- =============================================
CREATE VIEW [dbo].[vwPendingEnterpriseZipCrimOrders]
AS

	--PENDING SJV ORDERS IN HEALTHCARE
SELECT DISTINCT emp.OrderId, NULL AS StatusReceived, ivs.SubmittedTo AS VerificationType FROM dbo.Empl (NOLOCK) emp  
CROSS APPLY (
			SELECT TOP 1 ivl.OrderId, ivl.ProcessedDate, ivs.SubmittedTo
			FROM dbo.Integration_VendorOrder_Log (NOLOCK) ivl
			INNER JOIN dbo.Integration_VendorOrder_Submitted (NOLOCK) ivs on ivs.OrderId = ivl.OrderId
			WHERE ivl.OrderId = emp.OrderId
			AND ivl.ProcessedDate < DateAdd(hour, -1, GETDATE()) --No activity for that past 1 day
			AND ivs.SubmittedTo = 'EnterpriseSJV'
			ORDER BY ivl.ProcessedDate DESC
			) i
INNER JOIN dbo.Integration_VendorOrder_Submitted ivs (NOLOCK) ON IVS.OrderId = emp.OrderId
WHERE emp.Investigator = 'SJV' 
AND emp.SectStat = '9'
--AND IsNull(emp.web_status,0) = 0
AND IsNull(emp.OrderId,0) != 0
AND IsNull(emp.IsOnReport,0) = 1
AND emp.CreatedDate < DateAdd(day, -1, GETDATE()) --1 day buffer for newly created orders

UNION 

--PENDING NSCH ORDERS IN HEALTHCARE
SELECT DISTINCT edu.OrderId, NULL AS StatusReceived, ivs.SubmittedTo AS VerificationType FROM dbo.Educat (NOLOCK) edu  
CROSS APPLY (
			SELECT TOP 1 ivl.OrderId, ivl.ProcessedDate, ivs.SubmittedTo
			FROM dbo.Integration_VendorOrder_Log (NOLOCK) ivl
			INNER JOIN dbo.Integration_VendorOrder_Submitted (NOLOCK) ivs on ivs.OrderId = ivl.OrderId
			WHERE ivl.OrderId = edu.OrderId
			AND ivl.ProcessedDate < DateAdd(hour, -1, GETDATE()) --No activity for that past 1 day
			AND ivs.SubmittedTo = 'EnterpriseNSCH'
			ORDER BY ivl.ProcessedDate DESC
			) i
INNER JOIN dbo.Integration_VendorOrder_Submitted ivs (NOLOCK) ON IVS.OrderId = edu.OrderId
WHERE edu.Investigator = 'NCH' 
AND edu.SectStat = '9'
--AND IsNull(edu.web_status,0) = 0
AND IsNull(edu.OrderId,0) != 0
AND IsNull(edu.IsOnReport,0) = 1
AND edu.CreatedDate < DateAdd(day, -1, GETDATE()) --1 day buffer for newly created orders
