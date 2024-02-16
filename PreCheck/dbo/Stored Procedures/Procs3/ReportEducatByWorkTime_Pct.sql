﻿
CREATE PROCEDURE [dbo].[ReportEducatByWorkTime_Pct] @TOPENDING DATETIME, @FROMPENDING DATETIME AS
SELECT E1.INVESTIGATOR,
( SELECT COUNT( * )
FROM EDUCAT E2 (NOLOCK) 
WHERE E2.INVESTIGATOR = E1.INVESTIGATOR AND E2.TOPENDING IS NOT NULL AND E2.FROMPENDING IS NOT NULL AND E2.FROMPENDING BETWEEN @TOPENDING AND @FROMPENDING AND E2.IsOnReport = 1) AS TOTAL,
CAST( 100 * ( SELECT COUNT( * )
FROM EDUCAT E2 (NOLOCK) 
WHERE E2.INVESTIGATOR = E1.INVESTIGATOR AND E2.TOPENDING IS NOT NULL AND E2.FROMPENDING IS NOT NULL AND E2.FROMPENDING BETWEEN @TOPENDING AND @FROMPENDING AND DBO.BUSINESSHOURS( TOPENDING, FROMPENDING ) <= 8 AND E2.IsOnReport = 1) /
( SELECT COUNT( * )
FROM EDUCAT E2 (NOLOCK) 
WHERE E2.INVESTIGATOR = E1.INVESTIGATOR AND E2.TOPENDING IS NOT NULL AND E2.FROMPENDING IS NOT NULL AND E2.FROMPENDING BETWEEN @TOPENDING AND @FROMPENDING AND E2.IsOnReport = 1) AS NUMERIC( 5, 2 ) ) AS '<= 8 HOURS',
CAST( 100 * ( SELECT COUNT( * )
FROM EDUCAT E2 (NOLOCK) 
WHERE E2.INVESTIGATOR = E1.INVESTIGATOR AND E2.TOPENDING IS NOT NULL AND E2.FROMPENDING IS NOT NULL AND E2.FROMPENDING BETWEEN @TOPENDING AND @FROMPENDING AND DBO.BUSINESSHOURS( TOPENDING, FROMPENDING ) <= 16 AND E2.IsOnReport = 1) /
( SELECT COUNT( * )
FROM EDUCAT E2 (NOLOCK) 
WHERE E2.INVESTIGATOR = E1.INVESTIGATOR AND E2.TOPENDING IS NOT NULL AND E2.FROMPENDING IS NOT NULL AND E2.FROMPENDING BETWEEN @TOPENDING AND @FROMPENDING AND E2.IsOnReport = 1) AS NUMERIC( 5, 2 ) ) AS '<= 16 HOURS',
CAST( 100 * ( SELECT COUNT( * )
FROM EDUCAT E2 (NOLOCK) 
WHERE E2.INVESTIGATOR = E1.INVESTIGATOR AND E2.TOPENDING IS NOT NULL AND E2.FROMPENDING IS NOT NULL AND E2.FROMPENDING BETWEEN @TOPENDING AND @FROMPENDING AND DBO.BUSINESSHOURS( TOPENDING, FROMPENDING ) <= 24 AND E2.IsOnReport = 1) /
( SELECT COUNT( * )
FROM EDUCAT E2 (NOLOCK) 
WHERE E2.INVESTIGATOR = E1.INVESTIGATOR AND E2.TOPENDING IS NOT NULL AND E2.FROMPENDING IS NOT NULL AND E2.FROMPENDING BETWEEN @TOPENDING AND @FROMPENDING AND E2.IsOnReport = 1) AS NUMERIC( 5, 2 ) ) AS '<= 24 HOURS',
CAST( 100 * ( SELECT COUNT( * )
FROM EDUCAT E2 (NOLOCK) 
WHERE E2.INVESTIGATOR = E1.INVESTIGATOR AND E2.TOPENDING IS NOT NULL AND E2.FROMPENDING IS NOT NULL AND E2.FROMPENDING BETWEEN @TOPENDING AND @FROMPENDING AND DBO.BUSINESSHOURS( TOPENDING, FROMPENDING ) <= 32 AND E2.IsOnReport = 1) /
( SELECT COUNT( * )
FROM EDUCAT E2 (NOLOCK) 
WHERE E2.INVESTIGATOR = E1.INVESTIGATOR AND E2.TOPENDING IS NOT NULL AND E2.FROMPENDING IS NOT NULL AND E2.FROMPENDING BETWEEN @TOPENDING AND @FROMPENDING AND E2.IsOnReport = 1) AS NUMERIC( 5, 2 ) ) AS '<= 32 HOURS',
CAST( 100 * ( SELECT COUNT( * )
FROM EDUCAT E2 (NOLOCK) 
WHERE E2.INVESTIGATOR = E1.INVESTIGATOR AND E2.TOPENDING IS NOT NULL AND E2.FROMPENDING IS NOT NULL AND E2.FROMPENDING BETWEEN @TOPENDING AND @FROMPENDING AND DBO.BUSINESSHOURS( TOPENDING, FROMPENDING ) <= 40 AND E2.IsOnReport = 1) /
( SELECT COUNT( * )
FROM EDUCAT E2 (NOLOCK) 
WHERE E2.INVESTIGATOR = E1.INVESTIGATOR AND E2.TOPENDING IS NOT NULL AND E2.FROMPENDING IS NOT NULL AND E2.FROMPENDING BETWEEN @TOPENDING AND @FROMPENDING AND E2.IsOnReport = 1) AS NUMERIC( 5, 2 ) ) AS '<= 40 HOURS',
CAST( 100 * ( SELECT COUNT( * )
FROM EDUCAT E2 (NOLOCK) 
WHERE E2.INVESTIGATOR = E1.INVESTIGATOR AND E2.TOPENDING IS NOT NULL AND E2.FROMPENDING IS NOT NULL AND E2.FROMPENDING BETWEEN @TOPENDING AND @FROMPENDING AND DBO.BUSINESSHOURS( TOPENDING, FROMPENDING ) <= 48 AND E2.IsOnReport = 1) /
( SELECT COUNT( * )
FROM EDUCAT E2 (NOLOCK) 
WHERE E2.INVESTIGATOR = E1.INVESTIGATOR AND E2.TOPENDING IS NOT NULL AND E2.FROMPENDING IS NOT NULL AND E2.FROMPENDING BETWEEN @TOPENDING AND @FROMPENDING AND E2.IsOnReport = 1) AS NUMERIC( 5, 2 ) ) AS '<= 48 HOURS',
CAST( 100 * ( SELECT COUNT( * )
FROM EDUCAT E2 (NOLOCK) 
WHERE E2.INVESTIGATOR = E1.INVESTIGATOR AND E2.TOPENDING IS NOT NULL AND E2.FROMPENDING IS NOT NULL AND E2.FROMPENDING BETWEEN @TOPENDING AND @FROMPENDING AND DBO.BUSINESSHOURS( TOPENDING, FROMPENDING ) > 48 AND E2.IsOnReport = 1) /
( SELECT COUNT( * )
FROM EDUCAT E2 (NOLOCK) 
WHERE E2.INVESTIGATOR = E1.INVESTIGATOR AND E2.TOPENDING IS NOT NULL AND E2.FROMPENDING IS NOT NULL AND E2.FROMPENDING BETWEEN @TOPENDING AND @FROMPENDING AND E2.IsOnReport = 1) AS NUMERIC( 5, 2 ) ) AS '> 48 HOURS'
FROM EDUCAT E1 (NOLOCK) 
WHERE E1.INVESTIGATOR IS NOT NULL AND E1.TOPENDING IS NOT NULL AND E1.FROMPENDING IS NOT NULL AND E1.FROMPENDING BETWEEN @TOPENDING AND @FROMPENDING AND  E1.IsOnReport = 1
GROUP BY E1.INVESTIGATOR
ORDER BY E1.INVESTIGATOR


