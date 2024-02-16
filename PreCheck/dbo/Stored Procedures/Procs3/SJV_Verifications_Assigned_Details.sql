/*
Procedure Name : - SJV_Verifications_Assigned_Details
Requested By: Dana Sangerhausen
Developer: Deepak Vodethela
Execution : EXEC [SJV_Verifications_Assigned_Details] '07/10/2019', '11/10/2019'
*/


--Updated by Suchitra Yellapantula on 12/13/2016 to show the Empls sent to SJV (instead of those assigned to SJV)
CREATE PROCEDURE [dbo].[SJV_Verifications_Assigned_Details]
	@StartDate DATETIME,
	@EndDate DATETIME
AS

select Response.value('(//ID)[1]','int') as 'EmplID'
into #TempEmplIDs
from Integration_VendorOrder 
where VendorName = 'SJV' and VendorOperation = 'SubmitOrder' 
			AND CAST(CreatedDate AS DATE) >= CAST(@StartDate AS DATE)
			AND CAST(CreatedDate AS DATE) <= CAST(@EndDate AS DATE)
			AND Response.value('(//Success)[1]','varchar(max)')='true'

select E.DateOrdered as 'DateSent', E.APNO, E.Employer as 'Employer Name', S.Description [Status]
from Empl E inner join #TempEmplIDs T on E.EmplID = T.EmplID
inner join SectStat S on S.Code = E.SectStat


drop table #TempEmplIDs

/*
SELECT	CAST(CreatedDate AS date) AS CreatedDate, Apno, COUNT(1) [Records Assigned]
FROM PreCheck.dbo.GetNextAudit(NOLOCK)
WHERE NewValue = 'SJV'
  AND CAST(CreatedDate AS DATE) >= CAST(@StartDate AS DATE)
  AND CAST(CreatedDate AS DATE) <= CAST(@EndDate AS DATE)
GROUP BY GROUPING SETS((CAST(CreatedDate AS DATE),Apno),())
*/