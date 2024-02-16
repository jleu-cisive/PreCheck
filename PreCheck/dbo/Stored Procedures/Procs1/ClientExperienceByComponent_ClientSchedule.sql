-- =============================================
-- Author: Radhika Dereddy
-- Create date: 01/12/2021
-- Description: Mirrored this Qreport from Client Experience by Component QReport 
-- EXEC [dbo].[ClientExperienceByComponent_ClientSchedule] 
-- =============================================
CREATE PROCEDURE [dbo].[ClientExperienceByComponent_ClientSchedule] 

AS
BEGIN

DECLARE @StartDate DATETIME
SET @StartDate = dateadd(day,datediff(day,1,GETDATE()),0)
DECLARE @EndDate DATETIME
SET @EndDate =  dateadd(day,datediff(day,0,GETDATE()),0)
DECLARE @CLNO int =0
DECLARE @AffiliateID int =0

       -- SET NOCOUNT ON added to prevent extra result sets from
       -- interfering with SELECT statements.
       SET NOCOUNT ON;
 
       DROP TABLE IF EXISTS #TotalReports
       DROP TABLE IF EXISTS #crimsbydaterange
       DROP TABLE IF EXISTS #changelogfoundclosed

	   DROP TABLE IF EXISTS #AIReview
	   DROP TABLE IF EXISTS #TempAPNOLastUpdatedList
		
       SELECT a.APNO [Total Reports],a.UserID, a.ApDate, a.OrigCompDate,a.ReopenDate
       INTO #TotalReports
       FROM appl a(nolock)
       INNER JOIN dbo.Client c(nolock) ON a.CLNO = c.CLNO
       INNER JOIN dbo.refAffiliate ra(nolock) ON c.AffiliateID = ra.AffiliateID
       WHERE (convert(date,a.OrigCompDate) between @StartDate and @EndDate)
       AND a.CLNO not in (2135,3468)
       AND c.CLNO = IIF(@CLNO =0, c.CLNO, @CLNO)
       AND ra.AffiliateID = IIF(@AffiliateID =0, RA.AffiliateID, @AffiliateID)
	   AND a.UserID NOT IN ('CVendor','Cisive')
	     AND ISNULL(A.Investigator, '') <> ''
		AND A.userid IS NOT null
		AND ISNULL(A.CAM, '') = ''
		AND ISNULL(c.clienttypeid,-1) <> 15
       
	   --SELECT * FROM #TotalReports
	   SELECT c.CrimID,c.IrisOrdered 
	   into #crimsbydaterange 
	   FROM crim c(NOLOCK)
	   inner join appl a(NOLOCK)  on c.apno = a.apno 
	   inner join dbo.TblCounties d(NOLOCK) on c.CNTY_NO = d.CNTY_NO  
	   inner join client cc(NOLOCK) on a.clno = cc.clno 
	   inner join refAffiliate ra(NOLOCK) on cc.AffiliateId = ra.AffiliateID 
	   where (convert(date,a.OrigCompDate) between @StartDate and @EndDate)
	   and a.CLNO = IIF(@CLNO=0,a.CLNO, @CLNO)
	   and ra.AffiliateID = IIF(@affiliateId=0,ra.affiliateId, @affiliateId) 
	   AND a.UserID NOT IN ('CVendor','Cisive')

	  	SELECT  tr.[Total Reports]
		, Case when UPPER(cc.ClientCertReceived) = 'YES' then cc.CLientCertUpdated else tr.ApDate end as 'Report DateTime'
		, o.AIMICreatedDate as 'Review Completion DateTime'
		INTO #AIReview	
		FROM #TotalReports tr(nolock)
		LEFT JOIN ClientCertification cc(nolock) on tr.[Total Reports] = cc.APNO
		INNER JOIN Metastorm9_2.dbo.Oasis AS O(nolock) ON tr.[Total Reports] = O.apno
 
 
        -- Get the most recent closed component from the changelog
	   SELECT cdr.CrimID, c.ChangeDate, c.NewValue, cdr.IrisOrdered, ROW_NUMBER() over(PARTITION BY c.ID ORDER BY c.ChangeDate desc) as [Row]
	   into #changelogfoundclosed 
	   from #crimsbydaterange cdr (NOLOCK)
	   left JOIN ChangeLog c (NOLOCK) on c.ID = cdr.CrimID 

	   SELECT MAX(Last_Updated) AS Last_Updated, APNO INTO #TempAPNOLastUpdatedList
				FROM (
				(SELECT Last_Updated, APNO FROM dbo.Appl a WITH(NOLOCK) INNER JOIN #TotalReports tr ON a.APNO = tr.[Total Reports] )
						 UNION ALL
					  (SELECT Last_Updated, APNO FROM dbo.Empl e WITH(NOLOCK) INNER JOIN #TotalReports tr ON e.APNO = tr.[Total Reports] WHERE e.SectStat NOT IN ('0','9') AND e.IsOnReport = 1 AND e.Last_Updated IS NOT null )
						 UNION ALL
					  (SELECT Last_Updated, APNO FROM dbo.Educat edu WITH(NOLOCK) INNER JOIN #TotalReports tr ON edu.APNO = tr.[Total Reports] WHERE edu.SectStat NOT IN ('0','9') AND edu.IsOnReport = 1 AND edu.Last_Updated IS NOT null)
						 UNION ALL
					  (SELECT  Last_Updated, APNO FROM dbo.PersRef p WITH(NOLOCK) INNER JOIN #TotalReports tr ON p.APNO = tr.[Total Reports] WHERE p.SectStat NOT IN ('0','9') AND p.IsOnReport = 1 AND p.Last_Updated IS NOT null) 
						 UNION ALL
					  (SELECT  Last_Updated, APNO FROM dbo.ProfLic pl WITH(NOLOCK) INNER JOIN #TotalReports tr ON pl.APNO = tr.[Total Reports] WHERE pl.SectStat NOT IN ('0','9') AND pl.IsOnReport = 1 AND pl.Last_Updated IS NOT null)
						 UNION ALL
					  (SELECT Last_Updated, APNO FROM dbo.Credit c WITH(NOLOCK) INNER JOIN #TotalReports tr ON c.APNO = tr.[Total Reports] WHERE c.SectStat NOT IN ('0','9') and c.reptype ='S' AND c.Last_Updated IS NOT null) 
						 UNION ALL
					  (SELECT Last_Updated, APNO FROM dbo.Credit c2 WITH(NOLOCK) INNER JOIN #TotalReports tr ON c2.APNO = tr.[Total Reports] WHERE c2.SectStat NOT IN ('0','9') and c2.reptype ='C' AND c2.Last_Updated IS NOT null)
						 UNION ALL
					  (SELECT Last_Updated, APNO FROM dbo.MedInteg m WITH(NOLOCK) INNER JOIN #TotalReports tr ON m.APNO = tr.[Total Reports] WHERE m.SectStat NOT IN ('0','9') AND m.Last_Updated IS NOT null)
						 UNION ALL
					  (SELECT Last_Updated, APNO FROM dbo.DL d WITH(NOLOCK) INNER JOIN #TotalReports tr ON d.APNO = tr.[Total Reports] WHERE d.SectStat NOT IN ('0','9') AND d.Last_Updated IS NOT null)
						 UNION ALL
					  (SELECT Last_Updated, APNO FROM dbo.Crim cr  WITH(NOLOCK) INNER JOIN #TotalReports tr ON cr.APNO = tr.[Total Reports] WHERE ISNULL(cr.Clear, '') NOT IN ('','R','M','O', 'V','W','X','E','N','I','Q','Z') AND cr.ishidden = 0 AND cr.Last_Updated IS NOT null)
					) AS X GROUP BY X.APNO

					--select * from #TempAPNOLastUpdatedList taul
 
 
       SELECT tbl.Component, tbl.Volume, cast (tbl.TAT AS decimal(10,2)) [TAT] from
       (
            SELECT 'Crim' [Component],count(c.CrimID) [Volume],AVG(cast(DATEDIFF(d,c.IrisOrdered,clf.ChangeDate) AS decimal(5,1)))[TAT]
            FROM crim c (NOLOCK)
            inner join appl a(NOLOCK)  on c.apno = a.apno 
			inner join Client cl(NOLOCK) on a.CLNO = cl.CLNO
			inner join dbo.TblCounties d(NOLOCK)  on c.CNTY_NO = d.CNTY_NO 
			inner join refAffiliate ra(NOLOCK) on cl.AffiliateId = ra.AffiliateID 
			inner join #changelogfoundclosed clf(NOLOCK) on c.CrimID = clf.CrimID
			INNER JOIN Crimsectstat AS css(NOLOCK)  ON c.Clear = css.crimsect
			INNER JOIN IRIS_Researcher_Charges irc WITH (NOLOCK) ON C.vendorid = irc.Researcher_id AND C.CNTY_NO = irc.cnty_no AND irc.Researcher_Default = 'Yes'
			INNER JOIN dbo.Iris_Researchers ir WITH (nolock) ON irc.Researcher_id = ir.R_id
			--LEFT OUTER JOIN RefCrimDegree  AS K (NOLOCK) ON c.Degree = K.refCrimDegree
			where  (convert(date,a.OrigCompDate) between @StartDate and @EndDate)
			and a.CLNO = IIF(@CLNO=0,a.CLNO, @CLNO)
			and (clf.Row = 1 OR (clf.ChangeDate IS NULL and clf.NewValue IS NULL))
			and ra.AffiliateID = IIF(@affiliateId=0,ra.affiliateId, @affiliateId)
 
            UNION all
 
            --SELECT 'Edu' [Component],count(e.EducatID) [Volume], AVG(cast(dbo.elapsedbusinessdays_2( convert(datetime, e.CreatedDate), e.Last_Worked) AS decimal(5,1))) [TAT]
            --FROM #TotalReports tr
            --INNER JOIN dbo.Educat e ON tr.[Total Reports] = e.APNO 
            --WHERE e.IsHidden = 0 AND e.IsOnReport = 1

			SELECT 'Edu'[Component],count(e.EducatID) [Volume], AVG(cast (dbo.elapsedbusinessdays_2(convert(datetime, tr.ApDate), cl.ChangeDate ) AS decimal(5,1))) [TAT]
            FROM #TotalReports tr(NOLOCK)
            inner JOIN dbo.Educat e(NOLOCK) ON tr.[Total Reports] = e.APNO 
            left JOIN dbo.ChangeLog cl(NOLOCK) ON e.EducatID =cl.ID AND cl.TableName = 'Educat.SectStat' 
			--and cl.NewValue IN ('2','3','4','5')--('4','5','7','8','B','C') 
			and cl.NewValue IN ('4','C','U','8')
			AND cl.OldValue = '9'
            WHERE 
				--e.SectStat IN ('2','3','4','5')
				e.SectStat IN ('4','C','U','8')
				AND convert(date,tr.OrigCompDate) between @StartDate and @EndDate
				AND cl.ChangeDate IS NOT NULL
 
            UNION all
 
            --SELECT 'Emp'[Component],count(e.EmplID) [Volume], AVG(cast (dbo.elapsedbusinessdays_2( convert(datetime, e.CreatedDate), e.Last_Updated ) AS decimal(5,1))) [TAT]
            --FROM #TotalReports tr
            --INNER JOIN dbo.Empl e ON tr.[Total Reports] = e.APNO 
            --WHERE e.IsHidden = 0 AND e.IsOnReport = 1

			SELECT 'Emp'[Component],count(e.EmplID) [Volume], AVG(cast (dbo.elapsedbusinessdays_2(convert(datetime, tr.ApDate), cl.ChangeDate ) AS decimal(5,1))) [TAT]
            FROM #TotalReports tr(NOLOCK)
            inner JOIN dbo.Empl e(NOLOCK) ON tr.[Total Reports] = e.APNO 
            left JOIN dbo.ChangeLog cl(NOLOCK) ON e.EmplID =cl.ID AND cl.TableName = 'Empl.SectStat' 
			and cl.NewValue not IN ('0','9','R')
			AND cl.OldValue = '9'
            WHERE 
				e.SectStat not IN ('0','9','R')  --('2','3','4','5','7','8','C','U')
				AND e.IsHidden = 0
				AND convert(date,tr.OrigCompDate) between @StartDate and @EndDate
 
            UNION all
 
            SELECT 'Lic'[Component],count(pl.ProfLicID) [Volume], AVG(cast (dbo.elapsedbusinessdays_2(convert(datetime, tr.ApDate), cl.ChangeDate ) AS decimal(5,1))) [TAT]
            FROM #TotalReports tr(NOLOCK)
            inner JOIN dbo.ProfLic pl(NOLOCK) ON tr.[Total Reports] = pl.APNO 
            left JOIN dbo.ChangeLog cl(NOLOCK) ON pl.ProfLicID =cl.ID AND cl.TableName = 'ProfLic.SectStat' and cl.NewValue IN ('4','5','7','8','B','C') AND cl.OldValue = '9'
            WHERE 
				pl.SectStat IN ('4','5','7','8','B','C')
				AND convert(date,tr.OrigCompDate) between @StartDate and @EndDate
                           
            UNION all
 
            SELECT 'Total Reports'[Component],count(tr.[Total Reports]) [Volume], AVG(cast(dbo.elapsedbusinessdays_2( convert(datetime, tr.ApDate), tr.OrigCompDate) AS decimal(5,1))) [TAT]
            FROM #TotalReports tr(NOLOCK)

			UNION ALL
			  --select 'AI Review (Hours)'[Component],count(tr.[Total Reports]) [Volume], AVG(cast (datediff(hour,cc.ClientCertUpdated, agnl.CreatedDate) AS decimal(5,1))) [TAT] 
			  --select 'AI Review (Hours)'[Component],count(tr.[Total Reports]) [Volume], AVG(cast ([dbo].[ElapsedBusinessHours_2](cc.ClientCertUpdated, agnl.CreatedDate) AS decimal(5,1))) [TAT] 
			  -- from #TotalReports tr(NOLOCK)
			  -- left JOIN dbo.ClientCertification cc(NOLOCK) ON tr.[Total Reports] = cc.APNO
			  -- left JOIN dbo.ApplGetNextLog agnl(NOLOCK) ON tr.[Total Reports] = agnl.APNO
			   select 'AI Review (Hours)'[Component],count(tr.[Total Reports]) [Volume], AVG(cast ([dbo].[ElapsedBusinessHours_2](a.[Report DateTime], a.[Review Completion DateTime]) AS decimal(5,1))) [TAT] 
			   from #TotalReports tr(NOLOCK)
			   inner join #AIReview a(nolock) on tr.[Total Reports] = a.[Total Reports]

			UNION ALL
			--select 'TBF Review (Hours)'[Component],count(tr.[Total Reports]) [Volume], AVG(cast ([dbo].[ElapsedBusinessHours_2](tr.OrigCompDate, taul.Last_Updated) AS decimal(5,1))) [TAT] 
			select 'TBF Review (Hours)'[Component],count(tr.[Total Reports]) [Volume], AVG(cast ([dbo].[ElapsedBusinessHours_2](taul.Last_Updated,GetDate()) AS decimal(5,1))) [TAT]    
			   from #TotalReports tr(NOLOCK)
			   INNER JOIN #TempAPNOLastUpdatedList taul(NOLOCK) ON tr.[Total Reports] = taul.APNO
			   WHERE tr.ReopenDate IS NULL 
       )tbl
 
END
