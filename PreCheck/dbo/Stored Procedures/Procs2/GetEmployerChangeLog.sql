

-- =============================================
-- Author:           <Liel Alimole>
-- Create date: <05/20/2013>
-- Description:      <Gets change log of employer>
-- Updated By : Doug DeGenaro
-- Added thre new SJV 
-- Modified By: Deepak Vodethela
-- Modified Date : 07/25/2019
-- Description: Req#55694 - Please add "Applicant Contact" column for a T/F output, output should be specific to Applicant Contact that specific verification, "Total Applicant Contact Attempts" column, and "First Applicant Contact date/time" column.  
-- Execution: EXEC [dbo].[GetEmployerChangeLog] '07/01/2019','07/03/2019'
-- =============================================
CREATE PROCEDURE [dbo].[GetEmployerChangeLog]
       -- Add the parameters for the stored procedure here
--declare
       @StartDate DateTime = getdate,
       @EndDate DateTime = getdate
AS
BEGIN
	Set NoCount On 
	-- Set startdate as the very beginning of the filtered date and end date as the very beginning of the 
	-- DAY AFTER the filter so it could be used in less than filter ..
	select @StartDate=convert(date,@StartDate), @EndDate=dateadd(day,1,convert(date,@EndDate))

	Drop table if exists #logs
	SELECT	l.[ID],
			e.[OrderId],
			a.[APNO], 
			e.EmplID,
			a.[ApDate], 
			cl.[Name] [ClientName], 
			a.[CLNO] [ClientID], 
			e.[Employer], 
			e.web_status, 
			ss.[Description] as [FinalStatus],
			e.[Investigator] AS [UserModuleIn], 
			l.[UserID] AS [ClosedBy], 
			l.[ChangeDate] AS [ChangedDate],
			'' as [Applicant Contact]
		into #logs
	FROM [ChangeLog] l(NOLOCK)
	join [dbo].[Empl] e(NOLOCK) on e.[EmplID] = l.[ID]
	join [dbo].[Appl]  a(NOLOCK) on a.[APNO] = e.[Apno]
	join [dbo].[Client] cl(NOLOCK) on cl.[CLNO] = a.[CLNO]
	join [dbo].[SectStat] ss(NOLOCK) on ss.[Code] = l.[NewValue]
	WHERE l.[TableName] = 'Empl.SectStat' 
	  AND l.[OldValue] in ('0', '9')
	  AND l.[NewValue] not in ('0', '9')
	  AND l.[ChangeDate] >= @StartDate 
	  AND l.[ChangeDate] < @EndDate 

	Drop table if exists #IDs
	Select distinct [ID] into #IDs From #logs

	-- VD: 07/25/2019 - Added logic to get the Applicant Contact values
	;WITH cte_W1 AS
	(
	SELECT A.APNO, A.SectionUniqueID, A.CreateDate
	FROM ApplicantContact A (NOLOCK) 
	INNER JOIN #logs AS L ON A.SectionUniqueID = L.EmplID AND A.ApplSectionID = 1
	),
	cte_W2 AS 
	(
	SELECT	DISTINCT a.APNO, 
		a.SectionUniqueID,
		COUNT(a.SectionUniqueID) OVER (PARTITION BY a.SectionUniqueID ORDER BY a.APNO DESC) AS [Total Applicant Contact Attempts], 
		MAX(A.CreateDate) OVER (PARTITION BY a.SectionUniqueID ORDER BY A.CreateDate DESC) AS [Last Applicant Contact Date], 
		MIN(A.CreateDate) OVER (PARTITION BY a.SectionUniqueID ORDER BY A.CreateDate ASC) AS [First Applicant Contact Date]
	FROM cte_W1 AS a WITH (NOLOCK)
	GROUP BY a.APNO, a.SectionUniqueID, A.CreateDate
	),
	cte_W3 AS
	(
	SELECT	DISTINCT K.APNO,
		K.SectionUniqueID,
		MAX(K.[Total Applicant Contact Attempts]) AS [Total Applicant Contact Attempts],
		MAX(K.[Last Applicant Contact Date]) OVER (PARTITION BY K.SectionUniqueID ORDER BY K.[Last Applicant Contact Date] DESC) AS [Last Applicant Contact Date],
		MIN(K.[First Applicant Contact Date]) OVER (PARTITION BY K.SectionUniqueID ORDER BY K.[First Applicant Contact Date] ASC) AS [First Applicant Contact Date]
	FROM cte_W2 AS K WITH (NOLOCK)
	GROUP BY K.APNO, K.SectionUniqueID, K.[Last Applicant Contact Date], K.[First Applicant Contact Date]
	)
	SELECT * 
		INTO #tmpApplicantContact
	FROM cte_W3 WITH (NOLOCK)	

	--SELECT * FROM #tmpApplicantContact

	Select	l.[APNO], 
			l.[ApDate], 
			l.[ClientName], 
			l.[ClientID], 
			l.[Employer], 
			l.web_status, 
			l.[FinalStatus],
			l.[UserModuleIn], 
			l.[ClosedBy], 
			l.[ChangedDate],
			SjvOrderedDate.[SJV Ordered Date],
			ResFoundDate.[SJV Result Found Date],
			Upper(ResultFound.[Request].value('(//Search/@ResultFound)[1]','varchar(max)')) [SJV Result Found],
			(CASE WHEN Y.[Total Applicant Contact Attempts] >= 1 THEN 'True' ELSE 'False' END) AS [Applicant Contact],
			Y.[Total Applicant Contact Attempts],
			Y.[First Applicant Contact Date] as [First Applicant Contact Date/Time]
	From #logs l
	LEFT OUTER JOIN 
	(
			select 
				filt.[ID],
				filt.[NewValue] [SJV Ordered Date],
				row_number() over(partition by filt.[ID] order by filt.[HEVNMgmtChangeLogID] desc) rn
			from 
				[dbo].[ChangeLog] filt(NOLOCK)
				join #IDs i on i.[ID] = filt.[ID] and filt.[TableName] = 'Empl.DateOrdered' 
	) SjvOrderedDate on SjvOrderedDate.[ID] = l.[ID] and SjvOrderedDate.[rn] = 1
	LEFT OUTER JOIN
	(
			select 
				filt.[ID],
				filt.[ChangeDate] [SJV Result Found Date],
				row_number() over(partition by filt.[ID] order by filt.[HEVNMgmtChangeLogID] desc) rn
			from 
				[dbo].[ChangeLog] filt(NOLOCK)
				join #IDs i on i.[ID] = filt.[ID] and filt.[TableName] = 'Empl.Web_Status' and filt.[UserID] = 'SJV'
	) ResFoundDate on ResFoundDate.[ID] = l.[ID] and ResFoundDate.[rn] = 1
	LEFT OUTER JOIN
	(
			Select 
				ivol.[OrderId],
				ivo.[Request],
				Row_number() over (partition by ivol.[OrderId] order by ivol.[CreatedDate] desc) rn
			From
				[dbo].[Integration_VendorOrder] ivo (NOLOCK)
				join [dbo].[Integration_VendorOrder_Log] ivol(NOLOCK) on 
						ivol.[Integration_VendorOrderId] = ivo.[Integration_VendorOrderId] 
						and ivo.VendorName = 'SJV' 
						and ivo.[VendorOperation] = 'Listener'
						and ivol.[OrderId] in (select distinct [OrderId] from #logs)
			where 
				ivo.[CreatedDate] >= @StartDate and ivo.[CreatedDate] < @EndDate
	) ResultFound on ResultFound.[OrderId] = l.[OrderId] and ResultFound.[rn] = 1
	LEFT OUTER JOIN 
	(
		SELECT * FROM #tmpApplicantContact
	) AS Y ON L.EmplID = Y.SectionUniqueID


	Drop table if exists #IDs
	Drop table if exists #logs

END




