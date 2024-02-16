
/*
Q-Report Name: Education Team Production Details With NCH - Irrespective of ReportDate
Procedure Name : Education_Team_Production_Details_With_NCH_Irrespective_of_ReportDate
Requested By: Milton Robins
Developer: Deepak Vodethela
Execution : EXEC [Education_Team_Production_Details_With_NCH_Irrespective_of_ReportDate] '10/11/2016','10/11/2016'
*/
CREATE PROCEDURE Education_Team_Production_Details_With_NCH_Irrespective_of_ReportDate
@StartDate DateTime,
@EndDate DateTime
AS

BEGIN
SELECT  c.Newvalue,(CASE WHEN LEN(LTRIM(RTRIM(c.UserID))) <=8 THEN LTRIM(RTRIM(c.UserID)) ELSE  SUBSTRING (LTRIM(RTRIM(c.UserID)) ,1 , LEN(LTRIM(RTRIM(c.UserID))) -7) END) AS UserID,c.id 
		INTO #tempChangeLog
FROM dbo.ChangeLog c WITH (NOLOCK)
JOIN (SELECT  UserID, id, Max(changedate) as changedate
	  FROM  dbo.Changelog (nolock)
	  GROUP BY userid, id, TableName
	  HAVING (MAX(changedate) BETWEEN @StartDate AND DATEADD(S,-1,DATEADD(D,1,@EndDate)))
		 AND (TableName = 'Educat.sectstat')
	)c1
ON c.UserID = c1.UserId AND c.id = c1.id AND c.changedate = c1.changedate
WHERE (c.TableName = 'Educat.SectStat') AND c.UserID <> ''
  AND c.ChangeDate BETWEEN @StartDate AND DATEADD(S,-1,DATEADD(D,1,@EndDate))
ORDER BY c.UserID

--SELECT * from #tempChangeLog
--SELECT id, count(*) from #tempChangeLog
--Group by id
--having count(*) >1

SELECT Newvalue, (CASE WHEN LEN(LTRIM(RTRIM(UserID))) <=8 THEN LTRIM(RTRIM(UserID)) ELSE  SUBSTRING (LTRIM(RTRIM(UserID)) ,1 , LEN(LTRIM(RTRIM(UserID))) -7) END) AS UserID, id 
		INTO #tempChangeLog2
FROM dbo.ChangeLog(NOLOCK)
where TableName =  'Educat.web_status'
  AND ChangeDate BETWEEN @StartDate AND DATEADD(S,-1,DATEADD(D,1,@EndDate))
  AND Newvalue <> 0 
order by UserID

--SELECT * from #tempChangeLog2

SELECT (CASE WHEN LEN(LTRIM(RTRIM(UserID))) <=8 THEN LTRIM(RTRIM(UserID)) ELSE  SUBSTRING (LTRIM(RTRIM(UserID)) ,1 , LEN(LTRIM(RTRIM(UserID))) -7) END) AS UserID, id 
		INTO #tempChangeLog3
FROM dbo.ChangeLog(nolock)
where TableName like 'Educat.%'
  AND ChangeDate BETWEEN @StartDate AND DATEADD(S,-1,DATEADD(D,1,@EndDate))
order by UserID

--SELECT * from #tempChangeLog3

SELECT DISTINCT id, UserID 
		INTO #tempChangeLog4
From #tempChangeLog3

--SELECT * FROM #tempChangeLog4

SELECT distinct UserID 
		INTO #tempUsers 
from Users 
Where Educat = 1 
  AND Disabled = 0
order by UserID

--SELECT * from #tempUsers

SELECT  T.UserID  Investigator, 
	(SELECT count(1) From #tempChangeLog4 where  #tempChangeLog4.UserID = T.UserID) [EduEfforts],
	(SELECT count(1) From #tempChangeLog B (NoLock) where Newvalue = '4' AND ISNULL(B.UserID,'') = ISNULL(T.UserID,'')) [VERIFIED],
	(SELECT count(1) From #tempChangeLog C (NoLock) where Newvalue = '5'  AND ISNULL(C.UserID,'') = ISNULL(T.UserID,'')) [VERIFIED/SEE ATTACHED],
	(SELECT count(1) From #tempChangeLog D (NoLock) where Newvalue = '6'  AND ISNULL(D.UserID,'') = ISNULL(T.UserID,'')) [UNVERIFIED/SEE ATTACHED],
	(SELECT count(1) From #tempChangeLog E (NoLock) where Newvalue = '8'   AND ISNULL(E.UserID,'') = ISNULL(T.UserID,'')) [SEE ATTACHED],  
	(SELECT count(1) From #tempChangeLog F (NoLock) where Newvalue = '7'  AND ISNULL(F.UserID,'') = ISNULL(T.UserID,'')) [ALERT/SEE ATTACHED]
FROM #tempUsers T
Group By T.UserID

UNION ALL

SELECT 'Totals' Investigator, 
	0 [EduEfforts],
	(SELECT count(1) From #tempChangeLog B (NoLock) where Newvalue = '4' AND UserID in (SELECT UserID from #tempUsers)) [VERIFIED],
	(SELECT count(1) From #tempChangeLog C (NoLock) where Newvalue = '5' AND UserID in (SELECT UserID from #tempUsers)) [VERIFIED/SEE ATTACHED],
	(SELECT count(1) From #tempChangeLog D (NoLock) where Newvalue = '6' AND UserID in (SELECT UserID from #tempUsers)) [UNVERIFIED/SEE ATTACHED],
	(SELECT count(1) From #tempChangeLog E (NoLock) where Newvalue = '8' AND UserID in (SELECT UserID from #tempUsers)) [SEE ATTACHED], 
	(SELECT count(1) From #tempChangeLog F (NoLock) where Newvalue = '7' AND UserID in (SELECT UserID from #tempUsers)) [ALERT/SEE ATTACHED]

Drop Table #tempChangeLog
Drop Table #tempChangeLog2
Drop Table #tempChangeLog3
Drop Table #tempChangeLog4
Drop Table #tempUsers

END
