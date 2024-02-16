CREATE PROCEDURE [dbo].[Overdue_Need_Review_Per_Csr_Sub] @csrt varchar(20) AS

SELECT A.Apno, A.ApStatus, A.UserID, A.Investigator,a.userid,a.reopendate,
       A.ApDate, A.Last, A.First, A.Middle,  'Elapsed'  = CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(a.Reopendate,a.ApDate, getdate())),
       C.Name AS Client_Name
	FROM Appl A
JOIN Client C ON A.Clno = C.Clno
WHERE (A.ApStatus IN ('P','W')) and (a.userid = @csrt) 
	and (SELECT COUNT(*) FROM Crim WHERE (Crim.Apno = A.Apno)  AND (Crim.IsHidden = 0) AND (Crim.Clear IS NULL))=0
       	and (SELECT COUNT(*) FROM Civil WHERE (Civil.Apno = A.Apno))=0
	and (SELECT COUNT(*) FROM Credit WHERE (Credit.Apno = A.Apno) )=0
	and (SELECT COUNT(*) FROM DL WHERE (DL.Apno = A.Apno))=0
	and (SELECT COUNT(*) FROM Empl WHERE (Empl.Apno = A.Apno) AND Empl.IsOnReport = 1)=0
	and (SELECT COUNT(*) FROM Educat WHERE (Educat.Apno = A.Apno) AND Educat.IsOnReport = 1)=0
	and (SELECT COUNT(*) FROM ProfLic WHERE (ProfLic.Apno = A.Apno) AND ProfLic.IsOnReport = 1)=0
	and (SELECT COUNT(*) FROM PersRef WHERE (PersRef.Apno = A.Apno) AND PersRef.IsOnReport = 1)=0
ORDER BY A.ApDate






