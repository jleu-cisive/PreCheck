
--[Overdue_status_report_HCA] 1,1,1

CREATE PROCEDURE [dbo].[Overdue_status_report_HCA_02122021]  
(
	@HCA_InModel bit = 1,
	@includeCompletedReports Bit  = 0,
	@MergeCompletedReports Bit = 0 
) 
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Create Table #tmpHCAOverDue (
							[Report Number] int ,
							[Report Created Date] DateTime,
							[Report Status] varchar(10),
							[Applicant Last Name] varchar(100),
							[Applicant First Name] varchar(100),
							[Applicant Middle Name] varchar(50),
							SSN varchar(11),
							[Report Reopened Date] Datetime,
							[Report Completion Date] DateTime,
							 ProcessLevel varchar(50),
							 Requisition varchar(50),
							 [Account Name] varchar(250),
							 [Elapsed Days] int,
							 [Criminal Searches Ordered] int,
							 [Criminal Searches Pending] int,
							 [MVR Ordered] int,
							 [MVR Pending] int,
							 [Employment Verifications Ordered] int,
							 [Employment Verifications Pending] int,
							 [Education Verifications Ordered] int, 
							 [Education Verifications Pending] int,
							 [License Verifications Ordered] int,
							 [License Verifications Pending] int,
							 [Personal References Ordered] int,
							 [Personal References Pending] int,
							 [SanctionCheck Ordered] int,
							 [SanctionCheck Pending] int,
							 [Percentage Completed] int
							 )
CREATE TABLE #tempPendingPercentages
							(
							[CAM] varchar(8),
							[Report Number] int, 
							[Client ID] int,							
							[Client Name] varchar(100), 
							[Recruiter Name] varchar(100),
							[Reopened] varchar(20), 
							[Admitted] varchar(10),
							[InProgressReviewed] varchar(20), 
							[Percentage Completed] int,
							[BusinessDaysInThisPercentage] varchar(10), 
							[Report TAT] int
							)

INSERT INTO #tempPendingPercentages
EXEC [PendingReportsWithPercentages_ByCAM] null


Insert into #tmpHCAOverDue
SELECT A.Apno , A.ApDate ,case when A.ApStatus = 'P' then 'InProgress' else 'Available' end,
	   replace(A.Last,',','') , A.First , A.Middle ,SSN, A.reopendate ,A.compDate, replace(isnull(deptcode,0),',', ' ') , 
	   replace(IsNull(Request.value('(/Application/NewApplicant/RequisitionNumber)[1]', 'varchar(50)'),''),',',''),  
       replace(C.Name,',','')  , CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(a.Reopendate,a.ApDate,getdate())),--'2017-03-26 06:55:00.880')),
       (SELECT COUNT(1) FROM Crim with (nolock) WHERE (Crim.Apno = A.Apno And IsHidden=0) ),   --[Criminal Searches Ordered]
       (SELECT COUNT(1) FROM Crim with (nolock) WHERE (Crim.Apno = A.Apno And IsHidden=0) AND 
		(ISNULL(Crim.Clear,'') NOT IN ('T','F'))
	   --((Crim.Clear IS NULL) OR (Crim.Clear = 'O') OR (Crim.Clear = 'R'))
	   ), --[Criminal Searches Pending]    
	   (SELECT COUNT(1) FROM DL with (nolock) WHERE (DL.Apno = A.Apno And IsHidden=0) ), --[MVR Ordered]
       (SELECT COUNT(1) FROM DL with (nolock) WHERE (DL.Apno = A.Apno And IsHidden=0)   AND (DL.SectStat = '9' or DL.SectStat = '0')) , --[MVR Pending]
       (SELECT COUNT(1) FROM Empl with (nolock) WHERE (Empl.Apno = A.Apno) AND Empl.IsOnReport = 1) , --[Employment Verifications Ordered]
       (SELECT COUNT(1) FROM Empl with (nolock)	WHERE (Empl.Apno = A.Apno) AND Empl.IsOnReport = 1  AND (Empl.SectStat = '9' or empl.sectstat = '0')) , --[Employment Verifications Pending]
       (SELECT COUNT(1) FROM Educat with (nolock) WHERE (Educat.Apno = A.Apno) AND Educat.IsOnReport = 1) , --AS [Education Verifications Ordered]
       (SELECT COUNT(1) FROM Educat with (nolock) WHERE (Educat.Apno = A.Apno) AND Educat.IsOnReport = 1 AND (Educat.SectStat = '9' or Educat.SectStat = '0')) , --AS [Education Verifications Pending]
       (SELECT COUNT(1) FROM ProfLic with (nolock) 	WHERE (ProfLic.Apno = A.Apno) AND ProfLic.IsOnReport = 1), -- AS [License Verifications Ordered],
       (SELECT COUNT(1) FROM ProfLic with (nolock) WHERE (ProfLic.Apno = A.Apno) AND ProfLic.IsOnReport = 1 AND (ProfLic.SectStat = '9' or ProfLic.SectStat = '0')), -- AS [License Verifications Pending],
       (SELECT COUNT(1) FROM PersRef with (nolock) WHERE (PersRef.Apno = A.Apno) AND PersRef.IsOnReport = 1), -- AS [Personal References Ordered],
       (SELECT COUNT(1) FROM PersRef with (nolock) 	WHERE (PersRef.Apno = A.Apno) AND PersRef.IsOnReport = 1 AND (PersRef.SectStat = '9' or PersRef.SectStat = '0')) , --AS  [Personal References Pending],
       (SELECT COUNT(1) FROM medinteg with (nolock) WHERE (medinteg.Apno = A.Apno and IsHidden = 0) ), -- AS [SanctionCheck Ordered],
       (SELECT COUNT(1) FROM medinteg with (nolock) WHERE (medinteg.Apno = A.Apno and IsHidden = 0) AND (medinteg.SectStat = '9' or medinteg.SectStat = '0')), --AS [SanctionCheck Pending]
	   (CASE WHEN tp.[Percentage Completed] = 100 THEN 99 ELSE tp.[Percentage Completed] END) as [Percentage Completed]
FROM Appl A with (nolock)
Inner JOIN Client C  with (nolock) ON A.Clno = C.Clno
left join dbo.PrecheckServiceLog R (Nolock) on a.apno = R.apno and ServiceName = 'PrecheckWebService'
LEFT JOIN HEVN.dbo.Facility F (nolock) ON IsNull(Request.value('(/Application/NewApplicant/DeptCode)[1]', 'varchar(50)'),'') = facilitynum and parentemployerid = 7519 and Isnull(IsOneHR,0) =  @HCA_InModel
INNER JOIN #tempPendingPercentages tp ON A.APNO = tp.[Report Number]
WHERE (C.affiliateid in (4)) 
and (A.ApStatus IN ('P','W')) 
--and A.apno = 4594793


--Client did not want the below records to be eliminated - 03/22/2016
--Eliminate records with no pending items
--select distinct [Report Number]  into #temp2 from #tmpHCAOverDue where [Criminal Searches Pending] = 0 and [MVR Pending] = 0 and [Employment Verifications Pending] = 0 and [Education Verifications Pending] = 0 and [License Verifications Pending] = 0 and 
--[Personal References Pending] = 0 and [SanctionCheck Pending] = 0


If @includeCompletedReports = 1	

	Insert into #tmpHCAOverDue
	SELECT A.Apno , A.ApDate , Case when A.ApStatus = 'F' then 'Completed' else 'ReOpened' end,
		replace(A.Last,',','') , A.First , A.Middle ,SSN, a.reopendate , a.compdate, replace(isnull(deptcode,0),',', ' ') , 
	   replace(IsNull(Request.value('(/Application/NewApplicant/RequisitionNumber)[1]', 'varchar(50)'),''),',',''),  
      replace(C.Name,',','') , CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(a.Reopendate,a.ApDate,getdate())),--'2017-03-26 06:55:00.880')),
       (SELECT COUNT(1) FROM Crim with (nolock) WHERE (Crim.Apno = A.Apno And IsHidden=0) ),   --[Criminal Searches Ordered]
       0, --[Criminal Searches Pending]
	   (SELECT COUNT(1) FROM DL with (nolock) WHERE (DL.Apno = A.Apno And IsHidden=0) ), --[MVR Ordered]
       0 , --[MVR Pending]
       (SELECT COUNT(1) FROM Empl with (nolock) WHERE (Empl.Apno = A.Apno) AND Empl.IsOnReport = 1) , --[Employment Verifications Ordered]
       0 , --[Employment Verifications Pending]
       (SELECT COUNT(1) FROM Educat with (nolock) WHERE (Educat.Apno = A.Apno) AND Educat.IsOnReport = 1) , --AS [Education Verifications Ordered]
       0, --AS [Education Verifications Pending]
	   (SELECT COUNT(1) FROM ProfLic with (nolock) 	WHERE (ProfLic.Apno = A.Apno) AND ProfLic.IsOnReport = 1), -- AS [License Verifications Ordered],
       0, -- AS [License Verifications Pending],
       (SELECT COUNT(1) FROM PersRef with (nolock) WHERE (PersRef.Apno = A.Apno) AND PersRef.IsOnReport = 1), -- AS [Personal References Ordered],
       0 , --AS  [Personal References Pending],
        (SELECT COUNT(1) FROM medinteg with (nolock) WHERE (medinteg.Apno = A.Apno and IsHidden = 0) ), -- AS [SanctionCheck Ordered],
        0, --AS [SanctionCheck Pending]
	   (CASE WHEN tp.[Percentage Completed] = 100 and A.Apstatus <> 'F' THEN 99 ELSE tp.[Percentage Completed] END) as [Percentage Completed]
FROM Appl A with (nolock)
Inner JOIN Client C  with (nolock) ON A.Clno = C.Clno
left join dbo.PrecheckServiceLog R (Nolock) on a.apno = R.apno and ServiceName = 'PrecheckWebService'
LEFT JOIN HEVN.dbo.Facility F (nolock) ON IsNull(Request.value('(/Application/NewApplicant/DeptCode)[1]', 'varchar(50)'),'') = facilitynum and parentemployerid = 7519 and Isnull(IsOneHR,0) =  @HCA_InModel
INNER JOIN #tempPendingPercentages tp ON A.APNO = tp.[Report Number]
WHERE (C.affiliateid in (4)) 
and ((A.ApStatus = 'F') or (A.ApStatus = 'P' and OrigCompDate is not null)) and A.ApDate >= DateAdd(d,-180,current_TimeStamp)
--and A.apno = 4594793

if @MergeCompletedReports = 1
    Select distinct *,ResultsURL = 'https://weborder.precheck.net/ClientAccess/webclient.aspx?Apno=' + CAST([Report Number] AS VARCHAR) + '&Clno=7519' 
	From
	(
		select * from #tmpHCAOverDue where [Report Status] in ('InProgress','Available')  
			UNION ALL
		select  * from #tmpHCAOverDue where [Report Status] in ('Completed','ReOpened') 
			and DateDiff(dd,cast([Report Completion Date]  as Date),cast(Current_timeStamp as Date))<=7
    ) QRY  ORDER BY  [Elapsed Days] Desc
else
    Begin
	   --Client wants to include all in progress regardless of the non pending components

	   select  distinct 'OverDue' FileType, * from #tmpHCAOverDue where --[Report Number] not in (Select [Report Number] from #temp2) and 
	   [Report Status] in ('InProgress','Available')  ORDER BY  [Elapsed Days] Desc

	   If @includeCompletedReports = 1
		  select  distinct 'Completed' FileType, * from #tmpHCAOverDue Where [Report Status] in ('Completed','ReOpened')
		    ORDER BY  [Report Created Date] Desc

    end

DROP TABLE #tmpHCAOverDue
DROP TABLE #tempPendingPercentages
--drop table #temp2

SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SET NOCOUNT OFF

set ANSI_NULLS OFF

set QUOTED_IDENTIFIER OFF