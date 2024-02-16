﻿

--[dbo].[AppSectionLocks] 2251465
CREATE PROCEDURE [dbo].[AppSectionLocks] 
	@APNO int
AS

BEGIN
	SELECT CASE WHEN ISNULL(INUSE, '') <> '' THEN 'Yes' ELSE  'No' END AS LOCKED, 
	APNO,
	[FIRST] + ', ' + [LAST] + ' SSN: ' + SSN AS [SECTION INFO],
	'Application' AS Section 
	FROM PRECHECK.DBO.APPL WHERE APNO = @APNO
	--FROM APPL WHERE APNO = @APNO

	UNION ALL
	--SELECT CASE WHEN ISNULL(INUSE, '') <> '' THEN 'Yes' ELSE  'No' END AS LOCKED, 
	SELECT 
	--CASE WHEN SECTSTAT = 'H' then 'Yes' ELSE 'No need to lock' END AS LOCKED, 
	SECTSTAT AS LOCKED, 
	APNO,
	Employer AS [SECTION INFO],
	'Employment' AS Section 
	--FROM [ALA-DB-01].PRECHECK.DBO.EMPL  WHERE APNO = @APNO
	FROM PRECHECK.DBO.EMPL  WHERE APNO = @APNO

	UNION ALL
	--SELECT CASE WHEN SECTSTAT = 'H' THEN 'Yes' ELSE  'No need to lock' END AS LOCKED, 
	SELECT SECTSTAT AS LOCKED,
	APNO,
	SCHOOL AS [SECTION INFO],
	'Education' AS Section 
	FROM PRECHECK.DBO.EDUCAT  WHERE APNO = @APNO

	UNION ALL
	--SELECT CASE WHEN SECTSTAT = 'H' THEN 'Yes' ELSE  'No need to lock' END AS LOCKED, 
	SELECT SECTSTAT AS LOCKED,
	APNO,
	LiC_Type + ', ' + Lic_no AS [SECTION INFO],
	'License' AS Section 
	FROM PRECHECK.DBO.PROFLIC  WHERE APNO = @APNO

	UNION ALL
	--SELECT CASE WHEN SECTSTAT = 'H' THEN 'Yes' ELSE  'No need to lock' END AS LOCKED, 
	SELECT SECTSTAT AS LOCKED,
	APNO,
	NAME  AS [SECTION INFO],
	'Reference' AS Section 
	FROM PRECHECK.DBO.PERSREF  WHERE APNO = @APNO

	UNION ALL
	--SELECT CASE WHEN Clear = 'H' THEN 'Yes' ELSE  'No need to lock' END AS LOCKED,  
	SELECT CLEAR AS LOCKED,
	APNO,
	COUNTY  AS [SECTION INFO],
	'CRIM' AS Section 
	FROM PRECHECK.DBO.CRIM  WHERE APNO = @APNO
   

END

