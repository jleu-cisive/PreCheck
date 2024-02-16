﻿-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 12/11/2020
-- This report give the accurate details for Employment Department
-- Description:	This procedure is used instead of Verification_Team_Production_Details_WithWorkNumber(QReport)
-- for displaying the results based on investigator.
-- Summary is in Empl_AuditReport
-- EXEC [VerificationProductionDetails_WithWorkNumber_Employment] '12/09/2020', '12/09/2020', ''
-- =============================================
CREATE PROCEDURE [dbo].[VerificationProductionDetails_WithWorkNumber_Employment]
	-- Add the parameters for the stored procedure here
@StartDate datetime,
@EndDate datetime,
@UserId varchar(50)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
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
		ta.[UserId], ta.Id, case when s.[Description] is not null then s.[Description] else 'Current:'+ curr.[Description] end as [Status], isnull(S.Code,e.sectstat) as Code,
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

	SELECT  k.Apno, k.Employer, k.Web_Status, k.UserId, k.Id, k.Status,k.Code, k.ChangeDate, k.SubStatus,
			CASE WHEN k.ApnoPV IS NOT NULL THEN 1 ELSE '' END AS 'DuplicateRecords',
			CASE WHEN k.UserID LIKE '%(WKN)%' AND k.WorkNumberPVByID is null THEN 1 ELSE 0 END AS 'WorkNumber',
			CASE WHEN k.WorkNumberPVByID is not null AND k.UserID LIKE '%(WKN)%' THEN 1 ELSE 0 END AS 'DuplicateWorkNumber',
			CASE WHEN k.ApnoPV IS NULL THEN 1 ELSE '' END AS 'EmplEfforts'		
	INTO #tmpEmplAudit
	FROM 
	(
	SELECT T.Apno, T.Employer, T.Web_Status, T.UserId, T.Id, T.Status, T.Code, T.ChangeDate, T.SubStatus,
			LAG(T.Apno) over(partition by T.Id order by T.Id) as ApnoPV,
			LAG(T.UserID) over(partition by T.APNO, T.Id order by T.Id) as WorkNumberPVByID,
			LAG(T.UserID) over(partition by T.APNO order by T.Id) as WorkNumberPV
	FROM #tmpAudit T
	) AS k

	
	SELECT UserId, Sum(EmplEfforts) EmplEfforts, Sum(DuplicateRecords)DuplicateRecords, Sum(WorkNumber)WorkNumber, Sum(DuplicateWorkNumber) DuplicateWorkNumber,  
	(SELECT Count(Code) FROM #tmpEmplAudit F WHERE Code in ('C') AND F.USERID =T.UserID) AS ALERT,
	(SELECT Count(Code) FROM #tmpEmplAudit F WHERE Code in ('4') AND F.USERID =T.UserID) AS VERIFIED,
	(SELECT Count(Code) FROM #tmpEmplAudit F WHERE Code in ('U') AND F.USERID =T.UserID) AS UNVERIFIED,
	(SELECT Count(Code) FROM #tmpEmplAudit F WHERE Code in ('8') AND F.USERID =T.UserID) AS SEEATTACHED,
	(SELECT Count(Code) FROM #tmpEmplAudit F WHERE Code in ('9') AND F.USERID =T.UserID) AS PENDING,
	(SELECT Count(Code) FROM #tmpEmplAudit F WHERE Code in ('2') AND F.USERID =T.UserID) AS COMPLETE
	FROM #tmpEmplAudit T
	GROUP BY UserID

	
END
