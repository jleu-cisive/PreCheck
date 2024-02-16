
CREATE PROCEDURE [dbo].[iris_outgoing_min]
    @vendorid INT NULL,
    @delivery VARCHAR(25),
    @cntyno INT
AS

SET NOCOUNT ON       --stop the server from returning a message to the client, reduce network traffic
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

/* Updated 8/10/2005 JS - filter onlinedb and cnty 2480 to 20minutes*/

if ((UPPER(@delivery) = 'ONLINEDB') AND (@cntyno = 2480))
Begin
SELECT distinct
    C.CrimID,
	C.deliverymethod,
	C.vendorid
FROM DBO.Crim C
    INNER JOIN DBO.Iris_Researchers R ON C.vendorid = R.R_id
    LEFT OUTER JOIN DBO.Appl A ON C.APNO = A.APNO
WHERE
    (UPPER(A.ApStatus) IN ('P','W'))
    AND (UPPER(C.iris_rec) = 'YES')
    AND (UPPER(C.clear) = 'R') 
    and (C.vendorid = @vendorid)
    and (C.cnty_no = @cntyno)
    and (C.batchnumber IS NULL OR C.batchnumber = '0')
    and (A.inuse IS NULL)
    AND (DATEDIFF(mi, C.Crimenteredtime, GETDATE()) >= 20);
end 
ELSE IF (UPPER(@delivery) LIKE 'WEB%SERVICE%')
BEGIN
SELECT DISTINCT
    C.crimid,
	C.deliverymethod,
	C.vendorid
FROM DBO.crim C
    INNER JOIN DBO.iris_researchers R ON C.vendorid = R.r_id
    LEFT OUTER JOIN DBO.appl A ON C.apno = A.apno
WHERE
    (UPPER(A.apstatus) IN ('P','W'))
    AND (UPPER(C.iris_rec) = 'YES')
    AND (C.clear IN ('R','E')) 
    AND (C.vendorid = @vendorid)
    AND (C.cnty_no = @cntyno)
    AND (C.batchnumber IS NULL OR C.batchnumber = '0')
    AND (A.inuse IS NULL)
    AND (DATEDIFF(mi, C.crimenteredtime, GETDATE()) >= 1);
END 
ELSE
begin
SELECT distinct
    C.CrimID,
	C.deliverymethod,
	C.vendorid
FROM DBO.Crim C
    --INNER JOIN Iris_Researchers R ON C.vendorid = R.R_id
    INNER JOIN DBO.Appl A ON C.APNO = A.APNO
WHERE
    (A.apstatus IN ('P','W'))
    AND (C.iris_rec = 'YES')
    and (C.clear = 'R') 
    and (C.vendorid = @vendorid)
    and (C.cnty_no = @cntyno)
    and (C.batchnumber IS NULL OR C.batchnumber = '0')
    and (A.inuse IS NULL)
    AND (DATEDIFF(mi, C.Crimenteredtime, GETDATE()) >= 1);
    
    
SET NOCOUNT OFF
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
    
end
