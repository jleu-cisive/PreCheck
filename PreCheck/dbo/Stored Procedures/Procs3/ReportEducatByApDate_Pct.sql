﻿
CREATE PROCEDURE [dbo].[ReportEducatByApDate_Pct] @APDATE DATETIME, @FROMPENDING DATETIME AS
DECLARE @STARTDATE DATETIME, @ENDDATE DATETIME
SET @STARTDATE = @APDATE
SET @ENDDATE = @FROMPENDING
SELECT E1.INVESTIGATOR,
( SELECT COUNT( * )
FROM APPL A (NOLOCK) INNER JOIN EDUCAT E2 (NOLOCK) ON A.APNO = E2.APNO
WHERE E2.IsOnReport = 1 AND E2.FROMPENDING >= @STARTDATE AND E2.FROMPENDING < @ENDDATE AND E2.INVESTIGATOR = E1.INVESTIGATOR AND A.APDATE IS NOT NULL AND E2.FROMPENDING IS NOT NULL ) AS TOTAL,

CAST( 100 * ( SELECT COUNT( * )
FROM APPL A (NOLOCK) INNER JOIN EDUCAT E2 (NOLOCK) ON A.APNO = E2.APNO
WHERE E2.IsOnReport = 1 AND E2.FROMPENDING >= @STARTDATE AND E2.FROMPENDING < @ENDDATE AND E2.INVESTIGATOR = E1.INVESTIGATOR AND A.APDATE IS NOT NULL AND E2.FROMPENDING IS NOT NULL AND DBO.ELAPSEDBUSINESSDAYS_2(A.APDATE,E2.FROMPENDING ) <= 0 ) /
( SELECT COUNT( * )
FROM APPL A (NOLOCK) INNER JOIN EDUCAT E2 (NOLOCK) ON A.APNO = E2.APNO
WHERE  E2.IsOnReport = 1 AND E2.FROMPENDING >= @STARTDATE AND E2.FROMPENDING < @ENDDATE AND E2.INVESTIGATOR = E1.INVESTIGATOR AND A.APDATE IS NOT NULL AND E2.FROMPENDING IS NOT NULL  ) AS NUMERIC( 5, 2 ) ) AS 'SameDay',

CAST( 100 * ( SELECT COUNT( * )
FROM APPL A (NOLOCK) INNER JOIN EDUCAT E2 (NOLOCK) ON A.APNO = E2.APNO
WHERE E2.IsOnReport = 1 AND E2.FROMPENDING >= @STARTDATE AND E2.FROMPENDING < @ENDDATE AND E2.INVESTIGATOR = E1.INVESTIGATOR AND A.APDATE IS NOT NULL AND E2.FROMPENDING IS NOT NULL AND DBO.ELAPSEDBUSINESSDAYS_2(A.APDATE,E2.FROMPENDING) <= 1 ) /
( SELECT COUNT( * )
FROM APPL A (NOLOCK) INNER JOIN EDUCAT E2 (NOLOCK) ON A.APNO = E2.APNO
WHERE  E2.IsOnReport = 1 AND E2.FROMPENDING >= @STARTDATE AND E2.FROMPENDING < @ENDDATE AND E2.INVESTIGATOR = E1.INVESTIGATOR AND A.APDATE IS NOT NULL AND E2.FROMPENDING IS NOT NULL  ) AS NUMERIC( 5, 2 ) ) AS 'OneDay',

CAST( 100 * ( SELECT COUNT( * )
FROM APPL A (NOLOCK) INNER JOIN EDUCAT E2 (NOLOCK) ON A.APNO = E2.APNO
WHERE E2.IsOnReport = 1 AND E2.FROMPENDING >= @STARTDATE AND  E2.FROMPENDING < @ENDDATE AND E2.INVESTIGATOR = E1.INVESTIGATOR AND A.APDATE IS NOT NULL AND E2.FROMPENDING IS NOT NULL AND DBO.ELAPSEDBUSINESSDAYS_2(A.APDATE,E2.FROMPENDING) <= 2 ) /
( SELECT COUNT( * )
FROM APPL A (NOLOCK) INNER JOIN EDUCAT E2 (NOLOCK) ON A.APNO = E2.APNO
WHERE  E2.IsOnReport = 1 AND E2.FROMPENDING >= @STARTDATE AND  E2.FROMPENDING < @ENDDATE AND E2.INVESTIGATOR = E1.INVESTIGATOR AND A.APDATE IS NOT NULL AND E2.FROMPENDING IS NOT NULL  ) AS NUMERIC( 5, 2 ) ) AS 'TwoDays',
CAST( 100 * ( SELECT COUNT( * )
FROM APPL A (NOLOCK) INNER JOIN EDUCAT E2 (NOLOCK) ON A.APNO = E2.APNO
WHERE E2.IsOnReport = 1 AND E2.FROMPENDING >= @STARTDATE AND E2.FROMPENDING < @ENDDATE AND E2.INVESTIGATOR = E1.INVESTIGATOR AND A.APDATE IS NOT NULL AND E2.FROMPENDING IS NOT NULL AND DBO.ELAPSEDBUSINESSDAYS_2(A.APDATE,E2.FROMPENDING) <= 3 ) /
( SELECT COUNT( * )
FROM APPL A (NOLOCK) INNER JOIN EDUCAT E2 (NOLOCK) ON A.APNO = E2.APNO
WHERE  E2.IsOnReport = 1 AND E2.FROMPENDING >= @STARTDATE AND  E2.FROMPENDING < @ENDDATE AND E2.INVESTIGATOR = E1.INVESTIGATOR AND A.APDATE IS NOT NULL AND E2.FROMPENDING IS NOT NULL ) AS NUMERIC( 5, 2 ) ) AS 'ThreeDays',
CAST( 100 * ( SELECT COUNT( * )
FROM APPL A (NOLOCK) INNER JOIN EDUCAT E2 (NOLOCK) ON A.APNO = E2.APNO
WHERE  E2.IsOnReport = 1 AND E2.FROMPENDING >= @STARTDATE AND  E2.FROMPENDING < @ENDDATE AND E2.INVESTIGATOR = E1.INVESTIGATOR AND A.APDATE IS NOT NULL AND E2.FROMPENDING IS NOT NULL AND DBO.ELAPSEDBUSINESSDAYS_2(A.APDATE,E2.FROMPENDING) <= 4 ) /
( SELECT COUNT( * )
FROM APPL A (NOLOCK) INNER JOIN EDUCAT E2 (NOLOCK) ON A.APNO = E2.APNO
WHERE E2.IsOnReport = 1 AND E2.FROMPENDING >= @STARTDATE AND  E2.FROMPENDING < @ENDDATE AND E2.INVESTIGATOR = E1.INVESTIGATOR AND A.APDATE IS NOT NULL AND E2.FROMPENDING IS NOT NULL ) AS NUMERIC( 5, 2 ) ) AS 'FourDays',
CAST( 100 * ( SELECT COUNT( * )
FROM APPL A (NOLOCK) INNER JOIN EDUCAT E2 (NOLOCK) ON A.APNO = E2.APNO
WHERE E2.IsOnReport = 1 AND E2.FROMPENDING >= @STARTDATE AND E2.FROMPENDING < @ENDDATE AND E2.INVESTIGATOR = E1.INVESTIGATOR AND A.APDATE IS NOT NULL AND E2.FROMPENDING IS NOT NULL AND DBO.ELAPSEDBUSINESSDAYS_2(A.APDATE, E2.FROMPENDING) <= 5  ) /
( SELECT COUNT( * )
FROM APPL A (NOLOCK) INNER JOIN EDUCAT E2 (NOLOCK) ON A.APNO = E2.APNO
WHERE E2.IsOnReport = 1 AND E2.FROMPENDING >= @STARTDATE AND  E2.FROMPENDING < @ENDDATE AND E2.INVESTIGATOR = E1.INVESTIGATOR AND A.APDATE IS NOT NULL AND E2.FROMPENDING IS NOT NULL ) AS NUMERIC( 5, 2 ) ) AS 'FiveDays',CAST( 100 * ( SELECT COUNT( * )
FROM APPL A (NOLOCK) INNER JOIN EDUCAT E2 (NOLOCK) ON A.APNO = E2.APNO
WHERE E2.IsOnReport = 1 AND  E2.FROMPENDING >= @STARTDATE AND  E2.FROMPENDING < @ENDDATE AND E2.INVESTIGATOR = E1.INVESTIGATOR AND A.APDATE IS NOT NULL AND E2.FROMPENDING IS NOT NULL AND DBO.ELAPSEDBUSINESSDAYS_2(A.APDATE,E2.FROMPENDING) <= 6  ) /
( SELECT COUNT( * )
FROM APPL A (NOLOCK) INNER JOIN EDUCAT E2 (NOLOCK) ON A.APNO = E2.APNO
WHERE E2.IsOnReport = 1 AND E2.FROMPENDING >= @STARTDATE AND  E2.FROMPENDING < @ENDDATE AND E2.INVESTIGATOR = E1.INVESTIGATOR AND A.APDATE IS NOT NULL AND E2.FROMPENDING IS NOT NULL ) AS NUMERIC( 5, 2 ) ) AS 'SixDays',
--CAST( 100 * ( SELECT COUNT( * )
--FROM APPL A INNER JOIN EDUCAT E2 ON A.APNO = E2.APNO
--WHERE  E2.FROMPENDING >= @STARTDATE AND  E2.FROMPENDING < @ENDDATE AND E2.INVESTIGATOR = E1.INVESTIGATOR AND A.APDATE IS NOT NULL AND E2.FROMPENDING IS NOT NULL AND DBO.ELAPSEDBUSINESSDAYS_2(A.APDATE,E2.FROMPENDING) > 6 ) /
--( SELECT COUNT( * )
--FROM APPL A INNER JOIN EDUCAT E2 ON A.APNO = E2.APNO
--WHERE  E2.FROMPENDING >= @STARTDATE AND  E2.FROMPENDING < @ENDDATE AND E2.INVESTIGATOR = E1.INVESTIGATOR AND A.APDATE IS NOT NULL AND E2.FROMPENDING IS NOT NULL ) AS NUMERIC( 5, 2 ) ) AS '> SixDays'
'100' As  '> SixDays'
FROM APPL A (NOLOCK) INNER JOIN EDUCAT E1 (NOLOCK) ON A.APNO = E1.APNO
WHERE E1.IsOnReport = 1 AND  E1.FROMPENDING >= @STARTDATE AND  E1.FROMPENDING < @ENDDATE AND (E1.INVESTIGATOR IS NOT NULL AND E1.INVESTIGATOR <> '0') AND A.APDATE IS NOT NULL AND E1.FROMPENDING IS NOT NULL
GROUP BY E1.INVESTIGATOR
ORDER BY E1.INVESTIGATOR


