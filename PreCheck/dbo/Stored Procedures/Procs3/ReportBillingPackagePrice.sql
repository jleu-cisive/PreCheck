﻿
Create PROCEDURE [dbo].[ReportBillingPackagePrice] @CLNO INT AS
DECLARE @TABLE1 TABLE ( PACKAGEDESC VARCHAR( 50 ) )
INSERT INTO @TABLE1
SELECT PM.PACKAGEDESC
FROM CLIENT C INNER JOIN CLIENTPACKAGES CP ON C.CLNO = CP.CLNO INNER JOIN PACKAGEMAIN PM ON CP.PACKAGEID = PM.PACKAGEID
WHERE C.CLNO = @CLNO
ORDER BY PM.PACKAGEDESC
DECLARE @TABLE2 TABLE ( CLNO VARCHAR( 10 ), NAME VARCHAR( 50 ), INVOICENUMBER INT, INVDATE VARCHAR( 11 ), DESCRIPTION VARCHAR( 50 ), AMOUNT VARCHAR( 10 ) )
WHILE ( SELECT COUNT( * ) FROM @TABLE1 ) > 0
BEGIN
INSERT INTO @TABLE2
SELECT @CLNO, ( SELECT NAME FROM CLIENT WHERE CLNO = @CLNO ), ID.INVOICENUMBER, CAST( IM.INVDATE AS VARCHAR( 11 ) ), ID.DESCRIPTION, CAST( MAX( ID.AMOUNT ) AS VARCHAR( 10 ) )
FROM INVMASTER IM INNER JOIN INVDETAIL ID ON IM.INVOICENUMBER = ID.INVOICENUMBER
WHERE IM.CLNO = @CLNO AND ID.TYPE = 0 AND ID.DESCRIPTION LIKE '%' + 
( SELECT TOP 1 PACKAGEDESC
FROM @TABLE1 )
GROUP BY ID.INVOICENUMBER, IM.INVDATE, ID.DESCRIPTION
ORDER BY ID.INVOICENUMBER
IF ( SELECT COUNT( * )
FROM
( SELECT COUNT( * ) AS COUNT
FROM INVMASTER IM INNER JOIN INVDETAIL ID ON IM.INVOICENUMBER = ID.INVOICENUMBER
WHERE IM.CLNO = @CLNO AND ID.TYPE = 0 AND ID.DESCRIPTION LIKE '%' + 
( SELECT TOP 1 PACKAGEDESC
FROM @TABLE1 )
GROUP BY ID.INVOICENUMBER, IM.INVDATE, ID.DESCRIPTION ) QUERY ) > 0
INSERT INTO @TABLE2 VALUES ( '', '', '', '', '', '' )
DELETE FROM @TABLE1
WHERE PACKAGEDESC = ( SELECT TOP 1 PACKAGEDESC FROM @TABLE1 )
END
SELECT CLNO, NAME, DESCRIPTION, INVDATE, AMOUNT
FROM @TABLE2