



-- Modified by Michael Tabarovsky on 05-09-2006.
CREATE PROCEDURE [dbo].[ReportApplWithUnworkedSections] AS
SET NOCOUNT ON
DECLARE @TABLE TABLE ( APNO INT, APDATE DATETIME, COUNT1 INT, COUNT2 INT, COUNT3 INT, COUNT4 INT )
INSERT INTO @TABLE
SELECT A.APNO, A.APDATE,
( SELECT COUNT( 1 )
FROM EMPL (NOLOCK, index=IX_Empl_Apno)
WHERE APNO = A.APNO AND (PRIV_NOTES IS NULL OR DATALENGTH(PRIV_NOTES)= 0)AND (PUB_NOTES IS NULL OR DATALENGTH(PUB_NOTES) = 0) AND IsOnReport = 1),
( SELECT COUNT( 1 )
FROM EDUCAT (NOLOCK)
WHERE APNO = A.APNO AND (PRIV_NOTES IS NULL OR DATALENGTH(PRIV_NOTES)= 0)AND (PUB_NOTES IS NULL OR DATALENGTH(PUB_NOTES) = 0) AND IsOnReport = 1),
( SELECT COUNT( 1 )
FROM PERSREF (NOLOCK, index=IX_PersRef_Apno)
WHERE APNO = A.APNO AND (PRIV_NOTES IS NULL OR DATALENGTH(PRIV_NOTES)= 0)AND (PUB_NOTES IS NULL OR DATALENGTH(PUB_NOTES) = 0) AND IsOnReport = 1),
( SELECT COUNT( 1 )
FROM PROFLIC (NOLOCK, index=IX_ProfLic_Apno)
WHERE APNO = A.APNO AND (PRIV_NOTES IS NULL OR DATALENGTH(PRIV_NOTES)= 0)AND (PUB_NOTES IS NULL OR DATALENGTH(PUB_NOTES) = 0) AND IsOnReport = 1)
FROM APPL A (NOLOCK)
WHERE A.APDATE >= '01-01-2008' AND A.APDATE < getdate() AND A.CLNO <> 2135 AND A.APSTATUS <> 'F'
ORDER BY A.APNO
SELECT APNO, APDATE, COUNT1 AS EMPL, COUNT2 AS EDUCAT, COUNT3 AS PERSREF, COUNT4 AS PROFLIC
FROM @TABLE
WHERE COUNT1 > 0 OR COUNT2 > 0 OR COUNT3 > 0 OR COUNT4 > 0 order by apdate
/*
SELECT a.APNO, apdate, 
		(SELECT count(*) FROM APPL
			JOIN Empl ON empl.apno=appl.apno 
			WHERE appl.apno=a.apno and empl.PUB_NOTES is null and empl.PRiv_NOTES is null) as Empl,
		(SELECT count(*) FROM APPL
			JOIN Educat ON Educat.apno=appl.apno 
			WHERE appl.apno=a.apno and Educat.PUB_NOTES is null and Educat.PRiv_NOTES is null) as Educat,
		(SELECT count(*) FROM APPL
			JOIN PersRef ON PersRef.apno=appl.apno 
			WHERE appl.apno=a.apno and PersRef.PUB_NOTES is null and PersRef.Priv_NOTES is null) as PersRef,
		(SELECT count(*) FROM APPL
			JOIN ProfLic ON ProfLic.apno=appl.apno 
			WHERE appl.apno=a.apno and ProfLic.PUB_NOTES is null and ProfLic.Priv_NOTES is null) as ProfLic
	FROM Appl a
	JOIN Client c on c.clno=a.clno
	WHERE apdate > '1/1/2005' and apdate < CONVERT(DATETIME, (CONVERT(varchar(11), getdate(), 106)))
		and a.clno <> 2135 -- test client
		and ((SELECT count(*) FROM APPL
			JOIN Empl ON empl.apno=appl.apno 
			WHERE appl.apno=a.apno and empl.PUB_NOTES is null and empl.Priv_NOTES is null) > 0
		or (SELECT count(*) FROM APPL
			JOIN Educat ON Educat.apno=appl.apno 
			WHERE appl.apno=a.apno and Educat.PUB_NOTES is null and Educat.Priv_NOTES is null) > 0
		or (SELECT count(*) FROM APPL
			JOIN PersRef ON PersRef.apno=appl.apno 
			WHERE appl.apno=a.apno and PersRef.PUB_NOTES is null and PersRef.Priv_NOTES is null) > 0
		or (SELECT count(*) FROM APPL
			JOIN ProfLic ON ProfLic.apno=appl.apno 
			WHERE appl.apno=a.apno and ProfLic.PUB_NOTES is null and ProfLic.Priv_NOTES is null) > 0
		)
	order by a.apno
*/






