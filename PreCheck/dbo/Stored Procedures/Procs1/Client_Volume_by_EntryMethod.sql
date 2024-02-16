﻿-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 04/13/2017
-- Description:	For Misty
-- =============================================
CREATE PROCEDURE [dbo].[Client_Volume_by_EntryMethod] --'8/23/2017','8/24/2017'
	-- Add the parameters for the stored procedure here
	 @StartDate DateTime,
     @EndDate DateTime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

CREATE TABLE #TEMPVOLUME ( CLNO INT, CLIENTNAME VARCHAR(100), AFFILIATE VARCHAR(100), DEMI INT, XML INT, STUWEB INT, SYSTEM INT, CIC INT, WEB INT, NUMBEROFREPORTS INT)

INSERT INTO #TEMPVOLUME
SELECT DISTINCT C.CLNO AS CLNO, C.NAME AS CLIENTNAME, R.AFFILIATE, 
(SELECT COUNT(APNO) FROM APPL WHERE ENTEREDVIA LIKE '%DEMI%' AND APDATE BETWEEN @STARTDATE AND DATEADD(D,1,@ENDDATE) AND CLNO = A.CLNO) AS 'DEMI',
(SELECT COUNT(APNO) FROM APPL WHERE ENTEREDVIA LIKE '%XML%' AND APDATE BETWEEN @STARTDATE AND DATEADD(D,1,@ENDDATE) AND CLNO = A.CLNO) AS 'XML',
(SELECT COUNT(APNO) FROM APPL WHERE ENTEREDVIA LIKE '%STUWEB%' AND APDATE BETWEEN @STARTDATE AND DATEADD(D,1,@ENDDATE) AND CLNO = A.CLNO) AS 'STUWEB',
(SELECT COUNT(APNO) FROM APPL WHERE ENTEREDVIA LIKE '%SYSTEM%' AND APDATE BETWEEN @STARTDATE AND DATEADD(D,1,@ENDDATE) AND CLNO = A.CLNO) AS 'SYSTEM',
(SELECT COUNT(APNO) FROM APPL WHERE ENTEREDVIA LIKE '%CIC%' AND APDATE BETWEEN @STARTDATE AND DATEADD(D,1,@ENDDATE) AND CLNO = A.CLNO) AS 'CIC',
(SELECT COUNT(APNO) FROM APPL WHERE ENTEREDVIA LIKE 'WEB%' AND APDATE BETWEEN @STARTDATE AND DATEADD(D,1,@ENDDATE) AND CLNO = A.CLNO) AS 'WEB',
((SELECT COUNT(APNO) FROM APPL WHERE ENTEREDVIA LIKE '%DEMI%' AND APDATE BETWEEN @STARTDATE AND DATEADD(D,1,@ENDDATE) AND CLNO = A.CLNO)+
(SELECT COUNT(APNO) FROM APPL WHERE ENTEREDVIA LIKE '%XML%' AND APDATE BETWEEN @STARTDATE AND DATEADD(D,1,@ENDDATE) AND CLNO = A.CLNO)+
(SELECT COUNT(APNO) FROM APPL WHERE ENTEREDVIA LIKE '%STUWEB%' AND APDATE BETWEEN @STARTDATE AND DATEADD(D,1,@ENDDATE) AND CLNO = A.CLNO)+
(SELECT COUNT(APNO) FROM APPL WHERE ENTEREDVIA LIKE '%SYSTEM%' AND APDATE BETWEEN @STARTDATE AND DATEADD(D,1,@ENDDATE) AND CLNO = A.CLNO) +
(SELECT COUNT(APNO) FROM APPL WHERE ENTEREDVIA LIKE '%CIC%' AND APDATE BETWEEN @STARTDATE AND DATEADD(D,1,@ENDDATE) AND CLNO = A.CLNO) +
(SELECT COUNT(APNO) FROM APPL WHERE ENTEREDVIA LIKE 'WEB%' AND APDATE BETWEEN @STARTDATE AND DATEADD(D,1,@ENDDATE) AND CLNO = A.CLNO)) AS 'NUMBEROFREPORTS'
FROM APPL A(NOLOCK)
INNER JOIN CLIENT C(NOLOCK) ON A.CLNO = C.CLNO
INNER JOIN REFCLIENTTYPE RC(NOLOCK) ON C.CLIENTTYPEID = RC.CLIENTTYPEID
INNER JOIN REFAFFILIATE AS R(NOLOCK) ON C.AFFILIATEID = R.AFFILIATEID
WHERE A.APDATE BETWEEN @STARTDATE AND DATEADD(D,1,@ENDDATE) ORDER BY CLNO


SELECT * FROM #TEMPVOLUME

UNION ALL

SELECT '' AS CLNO, 'TOTAL' AS CLIENTNAME, '' AS AFFILIATE, SUM(DEMI) AS DEMI, SUM(XML) AS XML, SUM(STUWEB) AS STUWEB , SUM(SYSTEM) AS SYSTEM, SUM(CIC) AS CIC, SUM(WEB) AS WEB, 
SUM(NUMBEROFREPORTS) AS NUMBEROFREPORTS
FROM #TEMPVOLUME



DROP TABLE #TEMPVOLUME


END