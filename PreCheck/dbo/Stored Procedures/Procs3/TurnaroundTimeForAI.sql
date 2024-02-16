
/***********************************************************************
Created by: Amy Liu on 074/18/2018
Requested by: Dana Sangerhausen
Description:HDT36244:
Create report with parameters of dates, and that indicates hours elapsed between Report Created Date (certified) and when it is reviewed by an AI user (excludes Auto Ordered reports)
Please exclude non-business days from calculation.
Also, can stop at 24+ hours, grouping everythign at 24 hours and more together in display
--EXEC TurnaroundTimeForAI '07/01/2018','07/15/2018'

***********************************************************************/
CREATE PROCEDURE [dbo].[TurnaroundTimeForAI]
(
  @StartDate datetime,
  @EndDate datetime
  
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	IF OBJECT_ID('tempdb..#TempAPNOReviewedList') IS NOT NULL
		DROP TABLE #TempAPNOReviewedList
	IF OBJECT_ID('tempdb..#TempDistinctAPNOList') IS NOT NULL
		DROP TABLE 	#TempDistinctAPNOList
	IF OBJECT_ID('tempdb..#AITableSum') IS NOT NULL
		DROP TABLE #AITableSum
	

	--declare  @StartDate datetime='07/01/2018',
	--		@EndDate datetime ='07/15/2018'

select distinct a.apno,a.apstatus,--cc.clientCertUpdated, 
a.apdate CertifiedDate,  o.AIMICreatedDate,
 [dbo].[ElapsedBusinessHours_2](a.apdate,  o.AIMICreatedDate) AS Turnaround
into #TempAPNOReviewedList
from appl a with(nolock)
INNER JOIN [Metastorm9_2].[dbo].[Oasis] o with(nolock) on a.apno= cast(o.apno as int) and o.apno is not null
--left join dbo.ClientCertification cc with(nolock) on a.apno= cc.apno and cc.clientCertReceived ='Yes'  -- I have found the many certified dates are later than AIMICreatedDate so I can't use it.--Amy on 07/24/2018
where a.Apdate >= @StartDate 
   and a.Apdate <  DATEADD(d,1,@EndDate)
    and (a.investigator<>'AUTO' ) --or a.investigator is null)
   --and isnull(a.Investigator,'')<>''  --don't know if we need to report this -- I think 
   --and apstatus in ('W','F')
   AND a.CLNO <> 3468 AND a.Investigator not in ('DSOnly', 'Immuniz')

   --select * 
   --from #TempAPNOReviewedList o order by apno,AIMICreatedDate desc 

   -----remove duplicate record and choose lastest one with date
   select * 
   into #TempDistinctAPNOList
   from
   (
   select t.*, row_number() over (partition BY t.apno order by t.AIMICreatedDate desc) [row]
   from #TempAPNOReviewedList t 
   ) t1 where t1.row=1
   order by apno
	
	create table #AITableSum 
	( 
		ID int NOT NULL IDENTITY (1,1),
		Turnaround varchar(10), 
		Total int,
		Percentage decimal(16,4),
		GrandTotal int
	) 
	INSERT INTO #AITableSum (Turnaround, Total)
			SELECT cast(TAL.Turnaround AS varchar) AS Trunaround, sum(count(*)) OVER (PARTITION BY TAL.Turnaround ) AS Total
			 FROM #TempDistinctAPNOList TAL WHERE TAL.Turnaround	<24 AND TAL.Turnaround>=0
			 GROUP BY TAL.Turnaround ORDER BY TurnAround

	INSERT INTO #AITableSum (Turnaround, Total)
			 SELECT '24+' AS Trunaround,  count(row) AS Total 
			 FROM #TempDistinctAPNOList TAL WHERE TAL.Turnaround	>=24
	INSERT INTO #AITableSum (Turnaround, Total)	
			 SELECT  'N/A' AS Trunaround,  count(row) AS Total
			FROM #TempDistinctAPNOList TAL WHERE TAL.Turnaround	IS NULL
	INSERT INTO #AITableSum (Turnaround, Total)
			SELECT 'Weekend'AS Trunaround,  count(row) AS Total 
			 FROM #TempDistinctAPNOList TAL WHERE TAL.Turnaround	<0
	 
	 UPDATE #AITableSum SET GrandTotal=	
	 (SELECT sum(total) FROM #AITableSum)

	-- SELECT * FROM #AITableSum ats 

 SELECT Hours= CASE WHEN  cast(ats.Total AS decimal)/CAST(ats.GrandTotal AS DECIMAL) = 1 THEN 'Total' else ats.Turnaround end,
 ats.total AS Count, ats.GrandTotal,
 cast(total AS DECIMAL) *100/cast(sum(total) OVER () AS DECIMAL(16,4))  AS Percentage,
 cast((cast(total AS DECIMAL)/cast(sum(total) OVER () AS DECIMAL)+
 COALESCE((SELECT sum(B.Total/cast(B.GrandTotal AS decimal)) r FROM #AITableSum AS B WHERE B.ID <ats.ID 
					--AND ats.Turnaround NOT IN ('24+','N/A','Weekend')
					), 0)
 )*100 AS decimal(16,4) ) AS  [Cumulative Percentage] 
	 FROM #AITableSum ats 
	 GROUP BY ats.ID,ats.Turnaround, ats.Total, ats.GrandTotal

	IF OBJECT_ID('tempdb..#TempAPNOReviewedList') IS NOT NULL
		DROP TABLE #TempAPNOReviewedList
	IF OBJECT_ID('tempdb..#TempDistinctAPNOList') IS NOT NULL
		DROP TABLE 	#TempDistinctAPNOList
	IF OBJECT_ID('tempdb..#AITableSum') IS NOT NULL
		DROP TABLE #AITableSum
	

  SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	SET NOCOUNT OFF

END
