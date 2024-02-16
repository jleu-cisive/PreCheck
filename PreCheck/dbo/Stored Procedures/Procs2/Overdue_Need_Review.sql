
-- =============================================
-- Author:		Radhika Dereddy
-- Modified date: 07/25/2017
-- Reason to Modify: Please have this report adjusted to no longer include items in Needs Review that are in the Unused portion of the report. 
-- It should only show items in Needs Review status in the active portion of a background check.
-- Modified by Humera Ahmed  on  5/16/2019 - Add private notes column
-- =============================================

CREATE PROCEDURE [dbo].[Overdue_Need_Review] AS

-- Coded for online reporting  JS
SET NOCOUNT ON

SELECT A.Apno, A.ApStatus, A.UserID, A.Investigator,PC_Time_Stamp,
       A.ApDate, A.Last, A.First, A.Middle, a.reopendate, A.Priv_Notes [Private Notes],
       C.Name AS Client_Name,
       'Elapsed'  = CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(a.Reopendate,a.ApDate, getdate())),   
       (SELECT COUNT(*) FROM Crim  with (nolock) WHERE (Crim.Apno = A.Apno) AND (Crim.Clear IS NULL) AND (Crim.IsHidden = 0)) AS Crim_Count,
       (SELECT 0) AS Civil_Count,
       (SELECT COUNT(*) FROM Credit with (nolock) WHERE (Credit.Apno = A.Apno) AND ( credit.sectstat='0') AND (credit.IsHidden = 0)) AS Credit_Count,
       (SELECT COUNT(*) FROM DL with (nolock) WHERE (DL.Apno = A.Apno) AND ( DL.SectStat = '0') AND (DL.IsHidden = 0)) AS DL_Count,
       (SELECT COUNT(*) FROM Empl with (nolock) WHERE (Empl.Apno = A.Apno) AND ( empl.sectstat = '0') AND (Empl.IsOnReport = 1) AND (Empl.IsHidden = 0)) AS Empl_Count,
       (SELECT COUNT(*) FROM Educat with (nolock) WHERE (Educat.Apno = A.Apno) AND ( Educat.SectStat = '0') AND (Educat.IsOnReport = 1) AND (Educat.IsHidden = 0)) AS Educat_Count,
       (SELECT COUNT(*) FROM ProfLic with (nolock) WHERE (ProfLic.Apno = A.Apno) AND ( ProfLic.SectStat = '0') AND (ProfLic.IsOnReport = 1) AND (ProfLic.IsHidden = 0)) AS ProfLic_Count,
       (SELECT COUNT(*) FROM PersRef with (nolock) WHERE (PersRef.Apno = A.Apno) AND ( PersRef.SectStat = '0') AND (PersRef.IsOnReport = 1) AND (PersRef.IsHidden = 0)) AS PersRef_Count,
       (SELECT COUNT(*) FROM medinteg with (nolock) WHERE (medinteg.Apno = A.Apno) AND ( medinteg.SectStat = '0') AND (medinteg.IsHidden = 0)) AS Medinteg_Count
	   into #temp1
FROM Appl A with (nolock) 
INNER JOIN Client C  with (nolock) ON A.Clno = C.Clno
WHERE (A.ApStatus IN ('P','W') and A.clno <> 2135 and A.clno <> 3079) 
and not CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(a.Reopendate,a.ApDate, getdate())) < 0 
ORDER BY  elapsed Desc


select APNO  into #temp2 from #temp1
where Crim_Count = 0 
and Civil_Count = 0 
and Credit_Count = 0 
and DL_Count = 0 
and Empl_Count = 0 
and Educat_Count = 0 
and ProfLic_Count = 0 
and PersRef_Count = 0 
and Medinteg_Count = 0

select  * from #temp1 where APNO not in (Select APNO from #temp2)

drop table #temp1
drop table #temp2

