-- =============================================
-- Author:		DEEPAK VODETHELA
-- Create Date: 02/09/2016
-- DescriptiON: To provide Empployment Audit Trail of the Investigator for a given date range
-- Execution : EXEC [dbo].[Empl_AuditReport]   'AYanez','11/04/2019','11/04/2019'
-- Modified on: 03/29/2019
-- Decription: Modified the logic to match the counts on two QReporte (Employment Audit Report & Verification Production Details with Work Number - Irrespec)
-- Modified By:		DEEPAK VODETHELA
-- Modified Date: 02/09/2016
-- Description: Req#55786 - The report was not showing all the data points. Therefore I changed the logic to display all the audits per user.
-- Modified By - Doug Degenaro on 12/01/2019 and fixed the report which is correct
-- EXEC [Empl_AuditReport] 'MBartolo', '02/20/2020', '02/20/2020'
-- Modified by Radhika Dereddy on 02/25/2020 and added DuplicateRecords, WOrkNumber, DuplicateWorkNumber and EmplEfforts in addition to the totals at the bottom
-- Modified by Amy Liu on 09/02/2020 to add sectSubStatus into the report for Phase3 of project:IntranetModule- status-Substatus
-- exec  [dbo].[Empl_AuditReport] 'Agaribay', '12/09/2020','12/09/2020'
-- =============================================
CREATE PROCEDURE [dbo].[Empl_AuditReport] 
	@Userid varchar(50),
	@StartDate DateTime , 
	@EndDate DateTime 
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets FROM
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--declare 	@Userid varchar(50) ='pluker',
	--@StartDate DateTime = '08/25/2020', 
	--@EndDate DateTime ='08/25/2020'
	SET @EndDate = dateadd(s,-1,dateadd(d,1,@EndDate)) 
   
	
	DROP TABLE IF EXISTS #temp1
	DROP TABLE IF EXISTS #temp2
	DROP TABLE IF EXISTS #temp3
	DROP TABLE IF EXISTS #tempIdList
	DROP TABLE IF EXISTS #tmpAll 
	Drop TABle IF Exists #tmpEmplAudit
	Drop TABle IF Exists #tmpAudit

SELECT *, 't1' src INTO #temp1
  FROM ( 
		SELECT ROW_NUMBER() OVER (PARTITION BY c.[ID], CONVERT(DATE, c.[ChangeDate]) order by c.[ChangeDate] desc) rn, c.[ID],
			 CASE WHEN wkids.[sectionkeyid] is null then 
			 CASE WHEN len(ltrim(rtrim(c.[UserID]))) <=8 then ltrim(rtrim(c.[UserID])) else  SUBSTRING ( ltrim(rtrim(c.[UserID])) ,1 , len(ltrim(rtrim(c.[UserID]))) -5) END    -- no work number ..
				  ELSE (CASE WHEN len(ltrim(rtrim(c.[UserID]))) <=8 then ltrim(rtrim(c.[UserID])) else  SUBSTRING ( ltrim(rtrim(c.[UserID])) ,1 , len(ltrim(rtrim(c.[UserID]))) -5) end) + '(WKN)'      -- work number from Integration_Verification_SourceCode
			 END [UserID],
			 c.[ChangeDate],
			 c.[NewValue] [Value]
       FROM dbo.ChangeLog c 
	   LEFT OUTER JOIN ( SELECT sectionkeyid FROM  dbo.Integration_Verification_SourceCode with (nolock) 
							WHERE refVerificationSource = 'WorkNumber' 
						  and DateTimStamp between @StartDate and @EndDate
                       ) wkids ON c.[ID] = wkids.[sectionkeyid]
		WHERE c.[TableName] = 'Empl.sectstat' and c.[UserID] like @UserId + '%' and c.ChangeDate between @StartDate and @EndDate
     ) a
WHERE a.[rn] = 1

SELECT  * , 't2' src into #temp2
	FROM ( SELECT ROW_NUMBER() over (partition by c.[ID], Convert(date, c.[ChangeDate]) order by c.[ChangeDate] desc) rn,c.[ID],
				CASE WHEN wkids.[sectionkeyid] is null then                            
				CASE WHEN len(ltrim(rtrim(c.[UserID]))) <=8 then ltrim(rtrim(c.[UserID])) else  SUBSTRING ( ltrim(rtrim(c.[UserID])) ,1 , len(ltrim(rtrim(c.[UserID]))) -5) end -- no work number ..
					 ELSE (case when len(ltrim(rtrim(c.[UserID]))) <=8 then ltrim(rtrim(c.[UserID])) else  SUBSTRING ( ltrim(rtrim(c.[UserID])) ,1 , len(ltrim(rtrim(c.[UserID]))) -5) end) + '(WKN)'      -- work number from Integration_Verification_SourceCode
					  END [UserID],
				c.[ChangeDate],c.[NewValue] [Value]
		  FROM dbo.ChangeLog c 
		  LEFT OUTER JOIN (SELECT  sectionkeyid FROM  dbo.Integration_Verification_SourceCode with (nolock)
							WHERE refVerificationSource = 'WorkNumber' 
								and DateTimStamp between @StartDate and @EndDate
						  ) wkids ON c.[ID] = wkids.[sectionkeyid]
		  WHERE c.[TableName] = 'Empl.web_status' and c.[UserID] like  @UserId + '%' and c.ChangeDate between @StartDate and @EndDate
     ) a
WHERE a.[rn] = 1

SELECT * , 't3' src into #temp3
  FROM (SELECT ROW_NUMBER() over (partition by c.[ID], Convert(date, c.[ChangeDate]) order by c.[ChangeDate] desc) rn,c.[ID],
                     CASE WHEN wkids.[sectionkeyid] is null then
					 CASE WHEN len(ltrim(rtrim(c.[UserID]))) <=8 then ltrim(rtrim(c.[UserID])) else  SUBSTRING ( ltrim(rtrim(c.[UserID])) ,1 , len(ltrim(rtrim(c.[UserID]))) -5) end     -- no work number ..
                          ELSE (case when len(ltrim(rtrim(c.[UserID]))) <=8 then ltrim(rtrim(c.[UserID])) else  SUBSTRING ( ltrim(rtrim(c.[UserID])) ,1 , len(ltrim(rtrim(c.[UserID]))) -5) end) + '(WKN)'   -- work number from Integration_Verification_SourceCode
                     END [UserID],
                      c.[ChangeDate], c.[NewValue] [Value]
         FROM dbo.ChangeLog c 
         LEFT OUTER JOIN ( SELECT sectionkeyid FROM  dbo.Integration_Verification_SourceCode with (nolock)
							WHERE  refVerificationSource = 'WorkNumber' 
							and DateTimStamp between @StartDate and @EndDate							 
						  ) wkids ON c.[ID] = wkids.[sectionkeyid]
         WHERE ( c.[TableName] = 'Empl.priv_notes' or c.TableName = 'Empl.pub_notes') and c.[UserID] like  @UserId + '%' and c.ChangeDate between @StartDate and @EndDate
       ) a
WHERE a.[rn] = 1


--select * from #temp1
--select * from #temp2
--select * from #temp3

select id, ChangeDate into #tempIdList
from 
(
	select  id, ChangeDate from #temp1
		union all
	select id, ChangeDate from #temp2
		union all
	select id,changeDate from #temp3
) a


select distinct * into #tmpAll
from
(
	select idl.id,	t1.[Value] as sectstat, t2.[Value] as Web_Status,
	case 
		-- If t1 is the greatest date
		when 
			(t1.Changedate is not null) 
				and (t1.Changedate >= t2.ChangeDate or t2.ChangeDate is null) 
				and (t1.Changedate >= t3.ChangeDate or t3.ChangeDate is null) 
		then 
			t1.ChangeDate 
		-- IF t2 is the greatest date
		when 
			(t2.Changedate is not null) 
				and (t2.Changedate >= t1.ChangeDate or t1.ChangeDate is null) 
				and (t2.Changedate >= t3.ChangeDate or t3.ChangeDate is null) 
		then 
			t2.ChangeDate 				
		else 
			t3.ChangeDate end as [ChangeDate],
	case 
		-- If t1 is the greatest date
		when 
			(t1.Changedate is not null) 
				and (t1.Changedate >= t2.ChangeDate or t2.ChangeDate is null) 
				and (t1.Changedate >= t3.ChangeDate or t3.ChangeDate is null) 
		then 
			t1.[UserID] 
		-- IF t2 is the greatest date
		when 
			(t2.Changedate is not null) 
				and (t2.Changedate >= t1.ChangeDate or t1.ChangeDate is null) 
				and (t2.Changedate >= t3.ChangeDate or t3.ChangeDate is null) 
		then 
			t2.[UserID] 
		else
			t3.[UserID] end as [UserID]	
from #tempIdList idl 
left outer join #temp1 t1 on idl.id  = t1.ID and idl.ChangeDate = t1.ChangeDate
left outer join #temp2 t2 on idl.ID = t2.ID and idl.ChangeDate = t2.ChangeDate
left outer join #temp3 t3 on idl.ID = t3.ID and idl.ChangeDate = t3.ChangeDate
) a

--select * from #tmpAll

select distinct e.Apno, e.Employer, case when IsNull(ws.Description,'') <> '' then ws.description else 'Current:' + curr2.[Description] end as Web_Status,
		ta.[UserId], ta.Id, case when s.[Description] is not null then s.[Description] else 'Current:'+ curr.[Description] end as [Status], 
		 isnull(sss.SectSubStatus, '') as SubStatus,ChangeDate
	INTO #tmpAudit
from 
	#tmpAll ta 
	inner join dbo.Empl e on ta.ID = e.EmplID
	left join dbo.SectSubStatus sss on e.SectStat = sss.SectStatusCode and e.SectSubStatusID = sss.SectSubStatusID and sss.ApplSectionID = 1
	left join dbo.Websectstat ws on ws.code = ta.Web_Status
	left join dbo.SectStat s on s.Code = ta.sectstat
	left outer join dbo.SectStat curr on curr.Code = e.[SectStat]
	left outer join dbo.Websectstat curr2 on curr2.Code = IsNull(e.web_status,0)
	order by e.Apno desc

	SELECT  k.Apno, k.Employer, k.Web_Status, k.UserId, k.Id, k.Status, k.ChangeDate, k.SubStatus,
			CASE WHEN k.ApnoPV IS NOT NULL THEN 1 ELSE '' END AS 'DuplicateRecords',
			CASE WHEN k.UserID LIKE '%(WKN)%' AND k.WorkNumberPVByID is null THEN 1 ELSE 0 END AS 'WorkNumber',
			CASE WHEN k.WorkNumberPVByID is not null AND k.UserID LIKE '%(WKN)%' THEN 1 ELSE 0 END AS 'DuplicateWorkNumber',
			CASE WHEN k.ApnoPV IS NULL THEN 1 ELSE '' END AS 'EmplEfforts'		
	INTO #tmpEmplAudit
	FROM 
	(
	SELECT T.Apno, T.Employer, T.Web_Status, T.UserId, T.Id, T.Status, T.ChangeDate, T.SubStatus,
			LAG(T.Apno) over(partition by T.Id order by T.Id) as ApnoPV,
			LAG(T.UserID) over(partition by T.APNO, T.Id order by T.Id) as WorkNumberPVByID,
			LAG(T.UserID) over(partition by T.APNO order by T.Id) as WorkNumberPV
	FROM #tmpAudit T
	) AS k



	SELECT Apno, Employer, Web_Status, UserId, Id, Status, SubStatus, ChangeDate, DuplicateRecords, WorkNumber,  DuplicateWorkNumber, EmplEfforts
	FROM
	(
		SELECT Apno, Employer, Web_Status, UserId, Id, Status, SubStatus, ChangeDate, DuplicateRecords, WorkNumber,  DuplicateWorkNumber, EmplEfforts, 1 as 'Sequence' from #tmpEmplAudit
		   UNION
		SELECT '', '' ,'', '', '', 'Total Duplicates','', getdate(), Sum(DuplicateRecords), '' as WorkNumber, '' DuplicateWorkNumber, '' EmplEfforts,  2 as 'Sequence' from #tmpEmplAudit
		   UNION
		SELECT '', '' ,'', '', '','Total WorkNumbers', '', getdate(),'', Sum(WorkNumber) as WorkNumber, '' DuplicateWorkNumber, '' EmplEfforts, 3 as 'Sequence' from #tmpEmplAudit
			UNION
		SELECT '', '' ,'', '', '', 'Total DuplicateWorkNumber','', getdate(),'', '' as WorkNumber,Sum(DuplicateWorkNumber) as DuplicateWorkNumber , '' EmplEfforts, 4 as 'Sequence' from #tmpEmplAudit
			UNION
		SELECT '', '' ,'', '', '', 'Total EmplEfforts', '', getdate(),'', '' as WorkNumber,''  DuplicateWorkNumber, Sum(EmplEfforts) EmplEfforts, 5 as 'Sequence' from #tmpEmplAudit
	) As A 
	Order by Sequence

	DROP TABLE #tmpAudit

END