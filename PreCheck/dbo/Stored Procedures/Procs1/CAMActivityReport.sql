

-- exec CAMActivityReport '','8/10/2019','8/10/2019'

-- =============================================
-- Date: July 4, 2001
-- Author: Pat Coffer
-- modified by Sahithi Gangaraju :08/28/2020, HDT :76673, Add new column Average Elapsed Time
-- modified by Doug DeGenaro :02/03/2020, HDT :83905, Add total iprd for pending reports column
-- Modified by:		Joshua Ates
-- Modified Date:	02/04/2020
-- Modification:	Rewrote final query to reduce server usage and speed up procedure.  
-- Moved subqueries in Select statement to left joins with groupings. Modification ID JA02042021
-- Modified by:		Jeff Simenc
-- Modified Date:	04/13/2023
-- Modification:	Added index hints to the ChangeLog table queries and removed the "order by userid"
--					Replace the call to "ApplToBeFinalized" with a slimmed down direct query.

-- =============================================
CREATE PROCEDURE [dbo].[CAMActivityReport]
@CAM  varchar(8),
@FromDate Datetime,
@Todate DateTime

AS
SET NOCOUNT ON

DROP TABLE IF EXISTS #tempChangeLog
DROP TABLE IF EXISTS #tempInProgressReviewd
DROP TABLE IF EXISTS #tmpCountIPRTotal
DROP TABLE IF EXISTS #tempUSER1
DROP TABLE IF EXISTS #tempUSER
DROP TABLE IF EXISTS #tmpAppl


set @Todate = dateAdd(d,1,@Todate)

Declare @pending int,@5daysold int, @closed int, @TBF int

SELECT   
	 UserID
	,id 
INTO #tempChangeLog
FROM         
	dbo.ChangeLog WITH (NOLOCK,INDEX(IX_ChangeLog_ChangeDate))
WHERE     
	TableName = 'Appl.ApStatus'
AND Newvalue = 'F'
AND OldValue = 'P'
AND ChangeDate BETWEEN @FromDate AND @Todate
--ORDER BY UserID
​
​
SELECT  
	 UserID
	,id 
INTO #tempInProgressReviewd
FROM 
	dbo.ChangeLog WITH (NOLOCK,INDEX(IX_ChangeLog_ChangeDate))
WHERE  
	(TableName = 'Appl.InProgressReviewed') 
AND Newvalue = 'True' 
AND OldValue = 'False'
AND ChangeDate BETWEEN @FromDate AND @Todate
AND UserID IS NOT NULL
--ORDER BY UserID
	
SELECT 
	 a.UserID
	,a.APNO
INTO #tmpCountIPRTotal
FROM 
	dbo.Appl a WITH (NOLOCK)
WHERE 
	a.InProgressReviewed	= 1 
AND a.ApStatus IN ('P','W')
	
​
SELECT  DISTINCT 
	userID 
INTO #tempUSER1
FROM        
	APPL WITH (NOLOCK) 
WHERE    
	appl.ApStatus IN ('F','W')
AND appl.CompDate between @FromDate AND @Todate
AND UserID IS NOT NULL
ORDER BY UserID
​
 
INSERT INTO #tempUSER1
(userID)
(select  distinct userID
FROM      #tempChangeLog)
​
​
insert into #tempUSER1
(userID)
(select distinct userID 
FROM #tempInProgressReviewd)
​
SELECT  distinct userID into #tempUSER
FROM      #tempUSER1 
order by UserID
​
--SELECT   userID from #tempUSER
--DROP TABLE #tmpCHangeLog
​
create table #tmpAppl ( UserID varchar(8))
​
insert into #tmpAppl
SELECT A.UserID
	 FROM dbo.Appl A WITH (NOLOCK)    
	INNER JOIN dbo.Client C WITH(NOLOCK) ON A.Clno = C.Clno    
	left join dbo.Crim  WITH (NOLOCK) on crim.apno= a.apno And Crim.IsHidden =0 and ( crim.clear is null or crim.clear in ('R','M','O','V','I','W','Z','D'))    
	left join dbo.Civil WITH (NOLOCK) on civil.apno = a.apno AND ((Civil.Clear IS NULL) OR (Civil.Clear = 'O'))    
	left join dbo.Credit WITH (NOLOCK) on (Credit.Apno = A.Apno) AND (Credit.SectStat = '0' OR Credit.SectStat = '9')    
	left join  dbo.DL WITH (NOLOCK)  on (DL.Apno = A.Apno) AND (DL.SectStat = '0' OR DL.SectStat = '9')    
	left join dbo.Empl WITH (NOLOCK) on  (Empl.Apno = A.Apno) AND Empl.IsOnReport = 1 AND (Empl.SectStat = '0' OR Empl.SectStat = '9')    
	left join dbo.Educat WITH (NOLOCK) on  (Educat.Apno = A.Apno) AND Educat.IsOnReport = 1 AND (Educat.SectStat = '0' OR Educat.SectStat = '9')    
	left join dbo.ProfLic WITH (NOLOCK) on (ProfLic.Apno = A.Apno) AND ProfLic.IsOnReport = 1 AND (ProfLic.SectStat ='0' OR ProfLic.SectStat = '9')    
	left join dbo.PersRef WITH (NOLOCK) on  (PersRef.Apno = A.Apno) AND PersRef.IsOnReport = 1 AND (PersRef.SectStat = '0' OR PersRef.SectStat = '9')    
	left join dbo.Medinteg WITH (NOLOCK,INDEX(IX_MedInteg_ApNo))  on  (Medinteg.Apno = A.Apno) AND (Medinteg.SectStat = '0' OR Medinteg.SectStat = '9')    
	WHERE (A.ApStatus IN ('P','W'))    
	    AND A.Investigator <> ''	--AND ISNULL(A.Investigator, '') <> ''    -- chagned on 10/3
		AND A.userid IS NOT NULL	   
		
		AND c.clienttypeid <> 15	--AND ISNULL(c.clienttypeid,-1) <> 15    -- changed on 10/3
		AND crim.CrimID is null    
		AND civil.CivilID is null    
		AND credit.apno is null    
		AND DL.APNO is null    
		AND empl.EmplID is null    
		AND Educat.EducatID is null    
		AND ProfLic.ProfLicID is null    
		AND PersRef.PersRefID is null    
		AND Medinteg.apno is null
​
--select * from #tmpAppl
​
--Modification ID JA02042021 Start
​
SELECT 
	 'AUTO CLOSE' AS [UserID]
	,'AUTO CLOSE' AS [Name]
	,0 AS [Pending]
	,0 AS [3daysold]
	,0 AS [5daysold]
	,(SELECT COUNT(*) FROM ApplAutoCloseLog t WHERE ClosedOn  BETWEEN @FromDate AND @Todate) AS [Total Closed where Assigned]
	,0 AS [Closed by Own]
	,0 AS [Closed of Others] 
	,0 AS OriginalClosed
	,0 AS [Total In-Progress Review]
	,0 AS TBF
	,0 AS [Average Elapsed Time]
	,0 AS [Total IPR''d Reports]
UNION
SELECT 
	 U.UserID		
	,ISNULL(US.[Name],0)						AS	[Name]
	,ISNULL([Pending],0)						AS	[Pending]
	,ISNULL([3daysold],0)						AS	[3daysold]
	,ISNULL([5daysold],0)						AS	[5daysold]
	,ISNULL([Total Closed where Assigned],0)	AS	[Total Closed where Assigned]
	,ISNULL([Closed by Own],0)					AS	[Closed by Own]
	,ISNULL([Closed of Others],0)				AS	[Closed of Others]
	,ISNULL([OriginalClosed],0)					AS	[OriginalClosed]
	,ISNULL([Total In-Progress Review],0)		AS	[Total In-Progress Review]
	,ISNULL([TBF],0)							AS	[TBF]
	,ISNULL([Average Elapsed Time],0)			AS	[Average Elapsed Time]
	,ISNULL([Total IPR''d Reports],0)			AS	[Total IPR''d Reports]
FROM
	#tempUSER U
LEFT JOIN 
	Users US 
	ON US.UserID = U.UserID
LEFT JOIN
	(
		SELECT  
			 COUNT(*)	AS Pending
			,a1.UserID	AS UserID
		FROM 
			appl a1 WITH (NOLOCK)
		WHERE    
			a1.ApStatus IN ('P','W')
		GROUP BY
			a1.UserID
	) AS Pending
	ON Pending.UserID = U.UserID
LEFT JOIN
	(
		SELECT 
			 COUNT(*)	AS [3daysold]
			,a2.UserID	AS UserId
		FROM 
			appl a2 WITH (NOLOCK) 
		WHERE 
			(CONVERT(NUMERIC(7,2), dbo.ElapsedBusinessDays_3(a2.ApDate, GETDATE())))>= 3.0 
		AND a2.ApStatus IN ('P','W')
		AND a2.origcompdate IS NULL 
		GROUP BY
			a2.UserID
	 ) AS [3daysold]
	 ON [3daysold].UserId = U.UserID
LEFT JOIN
	(
		SELECT 
			 COUNT(*)	AS	[5daysold]
			,a2.UserID	AS	UserID
		FROM 
			appl a2 WITH (NOLOCK) 
		WHERE 
			(CONVERT(numeric(7,2), dbo.ElapsedBusinessDays_3(a2.ApDate, GETDATE())))>= 5.0 
		AND a2.ApStatus IN ('P','W')
		AND a2.origcompdate IS NULL 
		GROUP BY
			a2.UserID
	) AS [5daysold]
	ON [5daysold].UserID = U.UserID
LEFT JOIN
	(
		SELECT 
			 COUNT(*)  AS [Total Closed where Assigned]
			,a3.UserID
		FROM 
			appl a3 WITH (NOLOCK) 
		WHERE 
			a3.CompDate  BETWEEN @FromDate AND @Todate
		GROUP BY 
			a3.UserID
	) AS [Total Closed where Assigned]
	ON [Total Closed where Assigned].UserID = U.UserID
LEFT JOIN
	(
		SELECT 
			count(*) AS [Closed by Own]
			,UserID
		FROM 
			#tempChangeLog t 
		WHERE 
			id in (select a5.APNO from appl a5 with (nolock)where a5.UserID = t.UserID  and (a5.CompDate  between @FromDate and @Todate))  
		GROUP BY
			UserID
	) AS [Closed by Own]
	ON [Closed by Own].UserID = u.UserID
LEFT JOIN
	(
		SELECT 
			count(*) AS [Closed of Others]
			,UserID
		FROM 
			#tempChangeLog t 
		WHERE 
			id not in (select a5.APNO from appl a5 with (nolock)where a5.UserID = t.UserID  and (a5.CompDate  between @FromDate and @Todate))  
		GROUP BY
			UserID
	) AS [Closed of Others]
	ON	[Closed of Others].UserID = U.UserID
LEFT JOIN
	(
		SELECT 
			 count(*) AS [OriginalClosed]
			,t.UserID
		FROM 
			#tempChangeLog t 
		GROUP BY
			t.UserID
	) as [OriginalClosed]
	ON [OriginalClosed].UserID = U.UserID
LEFT JOIN
	(
		SELECT 
			 COUNT(*) AS [Total In-Progress Review]
			,t.UserID
		FROM 
			#tempInProgressReviewd t 
		GROUP BY
			t.UserID
	) AS [Total In-Progress Review]
	ON	[Total In-Progress Review].UserID = U.UserID
LEFT JOIN
	(
		SELECT 
			 COUNT(*) AS [TBF]
			,UserID
		FROM  
			#tmpAppl 
		GROUP BY
			UserID
	) AS [TBF]
	ON [TBF].UserID = U.UserID
LEFT JOIN
	(
		select 
			 DateDifference/CountOfApp AS [Average Elapsed Time]
			,T1.UserID
		from 
			appl T1
		LEFT JOIN
			(
				SELECT 
					 UserID
					,Count(*) AS CountOfApp
					,SUM(DATEDIFF(day, T11.ApDate, getdate())) AS DateDifference
				from 
					appl T11 
				where 
					T11.ApStatus IN ('P','W')
				GROUP BY
					UserID
			) AS Counts
			ON T1.UserID = Counts.UserID
		where 
			T1.ApStatus IN ('P','W')
	) AS [Average Elapsed Time]
	ON	[Average Elapsed Time].UserID = U.UserID
LEFT JOIN
	(
		SELECT 
			 count(*) AS [Total IPR''d Reports]
			,UserID
		FROM 
			#tmpCountIPRTotal tot 
		GROUP BY
			UserID
	) AS [Total IPR''d Reports] 
	ON	[Total IPR''d Reports].UserID = U.UserID
ORDER BY USERID ASC​
--Modification ID JA02042021 END
