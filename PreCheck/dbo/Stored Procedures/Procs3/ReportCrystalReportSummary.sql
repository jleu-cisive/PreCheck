
CREATE PROCEDURE ReportCrystalReportSummary AS
SET NOCOUNT ON
;with cte as
(
	SELECT A.Apno, A.ApStatus, A.UserID, A.Investigator,A.ApDate, A.Last, A.First, A.Middle, a.reopendate,C.Name AS Client_Name, C.CLNO, RA.Affiliate,
	'Elapsed'  = CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(a.Reopendate,a.ApDate,getdate())), 
	(case when A.InProgressReviewed = 0 then 'False' else 'True' end) as InProgressReviewed,
	( SELECT COUNT(1) FROM Crim with (nolock) WHERE (Crim.Apno = A.Apno And IsHidden=0) 
		AND 
		  (
			(Crim.Clear IS NULL) OR (Crim.Clear = 'O') OR (Crim.Clear = 'R') OR (Crim.Clear = 'V') OR (Crim.Clear = 'Z') OR (Crim.Clear = 'W')
			 OR (Crim.Clear = 'X') OR (Crim.Clear = 'E') OR (Crim.Clear = 'M') OR (Crim.Clear = 'N') OR (Crim.Clear = 'Q') OR (Crim.Clear = 'D') OR (Crim.Clear = 'G')
		  )
	) AS Crim_Count,
	(SELECT 0) AS Civil_Count,
	(SELECT COUNT(1) FROM Credit with (nolock) WHERE (Credit.Apno = A.Apno And IsHidden=0) AND (Credit.SectStat = '9' or credit.sectstat='0') ) AS Credit_Count,
	(SELECT COUNT(1) FROM DL with (nolock) WHERE (DL.Apno = A.Apno And IsHidden=0) AND (DL.SectStat = '9' or DL.SectStat = '0')) AS DL_Count,
	(SELECT COUNT(1) FROM Empl with (nolock) WHERE (Empl.Apno = A.Apno) AND Empl.IsOnReport = 1  AND (Empl.SectStat = '9' or empl.sectstat = '0')) AS Empl_Count,
	(SELECT COUNT(1) FROM Educat with (nolock) WHERE (Educat.Apno = A.Apno) AND Educat.IsOnReport = 1 AND (Educat.SectStat = '9' or Educat.SectStat = '0')) AS Educat_Count,
	(SELECT COUNT(1) FROM ProfLic with (nolock) WHERE (ProfLic.Apno = A.Apno) AND ProfLic.IsOnReport = 1 AND (ProfLic.SectStat = '9' or ProfLic.SectStat = '0')) AS ProfLic_Count,
	(SELECT COUNT(1) FROM PersRef with (nolock) WHERE (PersRef.Apno = A.Apno) AND PersRef.IsOnReport = 1 AND (PersRef.SectStat = '9' or PersRef.SectStat = '0')) AS PersRef_Count,
	(SELECT COUNT(1) FROM medinteg with (nolock) WHERE (medinteg.Apno = A.Apno and IsHidden = 0) AND (medinteg.SectStat = '9' or medinteg.SectStat = '0')) AS Medinteg_Count
	FROM Appl A with (nolock)
	JOIN Client C  with (nolock) ON A.Clno = C.Clno
	inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID
	WHERE (A.ApStatus IN ('P','W')) and a.CLNO not in (2135,3468)
)
select * into #TempAPNOs from cte;

with cte as (
	select APNO
	from #TempAPNOs
	where Crim_Count = 0 
	and Civil_Count = 0 
	and Credit_Count = 0 
	and DL_Count = 0 
	and Empl_Count = 0 
	and Educat_Count = 0 
	and ProfLic_Count = 0 
	and PersRef_Count = 0 
	and Medinteg_Count = 0
),
cte1 as (
	select  * from #TempAPNOs where APNO not in (Select APNO from cte)
)
select * into #APNOs from cte1 with (nolock);

;with cte as 
(
	select '7+' as 'Days',
	sum(case when a.ApStatus = 'P' then 1 else 0 end) as InProgress,
	sum(case when a.ApStatus = 'W' then 1 else 0 end) as SentPending,
	sum(a.Crim_Count) as Crim,
	sum(a.Civil_Count) as Civil, sum(a.Credit_Count) as Credit,
	sum(a.DL_Count) as DL, sum(a.Empl_Count) as Empl,
	sum(a.Educat_Count) as Educat, sum(a.ProfLic_Count) as Lic,
	sum(a.PersRef_Count) as Ref, sum(a.Medinteg_Count) as Med
	 from #APNOs a with (nolock) where a.Elapsed >= 7
	UNION ALL
	select '6' as 'Days',
	sum(case when a.ApStatus = 'P' then 1 else 0 end) as InProgress,
sum(case when a.ApStatus = 'W' then 1 else 0 end) as SentPending,
	sum(a.Crim_Count) as Crim,
	sum(a.Civil_Count) as Civil, sum(a.Credit_Count) as Credit,
	sum(a.DL_Count) as DL, sum(a.Empl_Count) as Empl,
	sum(a.Educat_Count) as Educat, sum(a.ProfLic_Count) as Lic,
	sum(a.PersRef_Count) as Ref,  sum(a.Medinteg_Count) as Med
	 from #APNOs a with (nolock) where a.Elapsed = 6
	UNION ALL 
	select '5' as 'Days',
	sum(case when a.ApStatus = 'P' then 1 else 0 end) as InProgress,
sum(case when a.ApStatus = 'W' then 1 else 0 end) as SentPending,
	 sum(a.Crim_Count) as Crim,
	sum(a.Civil_Count) as Civil, sum(a.Credit_Count) as Credit,
	sum(a.DL_Count) as DL, sum(a.Empl_Count) as Empl,
	sum(a.Educat_Count) as Educat, sum(a.ProfLic_Count) as Lic,
	sum(a.PersRef_Count) as Ref,  sum(a.Medinteg_Count) as Med
	 from #APNOs a with (nolock) where a.Elapsed = 5
	UNION ALL 
	select '4' as 'Days',
	sum(case when a.ApStatus = 'P' then 1 else 0 end) as InProgress,
sum(case when a.ApStatus = 'W' then 1 else 0 end) as SentPending,
	 sum(a.Crim_Count) as Crim,
	sum(a.Civil_Count) as Civil, sum(a.Credit_Count) as Credit,
	sum(a.DL_Count) as DL, sum(a.Empl_Count) as Empl,
	sum(a.Educat_Count) as Educat, sum(a.ProfLic_Count) as Lic,
	sum(a.PersRef_Count) as Ref,  sum(a.Medinteg_Count) as Med
	 from #APNOs a with (nolock) where a.Elapsed = 4
	UNION ALL 
	select '3' as 'Days', 
	sum(case when a.ApStatus = 'P' then 1 else 0 end) as InProgress,
sum(case when a.ApStatus = 'W' then 1 else 0 end) as SentPending,
	sum(a.Crim_Count) as Crim,
	sum(a.Civil_Count) as Civil, sum(a.Credit_Count) as Credit,
	sum(a.DL_Count) as DL, sum(a.Empl_Count) as Empl,
	sum(a.Educat_Count) as Educat, sum(a.ProfLic_Count) as Lic,
	sum(a.PersRef_Count) as Ref,  sum(a.Medinteg_Count) as Med
	 from #APNOs a with (nolock) where a.Elapsed = 3
	UNION ALL 
	select '2' as 'Days', 
	sum(case when a.ApStatus = 'P' then 1 else 0 end) as InProgress,
sum(case when a.ApStatus = 'W' then 1 else 0 end) as SentPending,
	sum(a.Crim_Count) as Crim,
	sum(a.Civil_Count) as Civil, sum(a.Credit_Count) as Credit,
	sum(a.DL_Count) as DL, sum(a.Empl_Count) as Empl,
	sum(a.Educat_Count) as Educat, sum(a.ProfLic_Count) as Lic,
	sum(a.PersRef_Count) as Ref,  sum(a.Medinteg_Count) as Med
	 from #APNOs a with (nolock) where a.Elapsed = 2
	UNION ALL 
	select '1' as 'Days', 
	sum(case when a.ApStatus = 'P' then 1 else 0 end) as InProgress,
sum(case when a.ApStatus = 'W' then 1 else 0 end) as SentPending,
	sum(a.Crim_Count) as Crim,
	sum(a.Civil_Count) as Civil, sum(a.Credit_Count) as Credit,
	sum(a.DL_Count) as DL, sum(a.Empl_Count) as Empl,
	sum(a.Educat_Count) as Educat, sum(a.ProfLic_Count) as Lic,
	sum(a.PersRef_Count) as Ref,  sum(a.Medinteg_Count) as Med
	 from #APNOs a with (nolock) where a.Elapsed = 1
),
cte1 as (
select c.Days, c.InProgress, c.SentPending,  
c.InProgress + c.SentPending as 'Apps Total',
c.Crim,c.Civil,c.Credit,c.DL,c.Empl,c.Educat,c.Lic,c.Ref,c.Med,
c.Crim + c.Civil + c.Credit + c.DL + c.Empl + c.Educat + c.Lic + c.Ref + c.Med as 'Tasks Total'
from cte as c with (nolock)
),
cte2 as (
select c.Days,c.InProgress,c.SentPending,c.[Apps Total],c.Crim, c.Civil,c.Credit,c.DL,c.Empl,c.Educat,c.Lic,c.Ref,c.Med, c.[Tasks Total]
from cte1 c with (nolock)
union all
select 'Total' as Days, sum(c.InProgress) as InProgress, sum(c.SentPending) as SentPending, sum(c.[Apps Total]) as 'Apps Total',
SUM(c.Crim) as Crim, sum(c.Civil) as Civil, sum(c.Credit) as Credit, sum(c.DL) as DL, sum(c.Empl) as Empl, sum (c.Educat) as Educat,
sum(c.Lic) as Lic, sum(c.Ref) as Ref, sum(c.Med) as Med, sum(c.[Tasks Total]) as 'Tasks Total' 
from cte1 as c with (nolock)
)
select *from cte2 with (nolock)

drop table #TempAPNOs
drop table #APNOs