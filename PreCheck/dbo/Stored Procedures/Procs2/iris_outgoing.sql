/*
[dbo].[iris_outgoing] 86420, 'Call_In',2480
[dbo].[iris_outgoing] 262, 'InHouse',2682
[dbo].[iris_outgoing] 2602325, 'ONLINEDB',2231
[dbo].[iris_outgoing] 824460,'WEB SERVICE',2569
*/

CREATE PROCEDURE [dbo].[iris_outgoing]
    @vendorid INT NULL,
    @delivery VARCHAR(25),
    @cntyno INT
AS

SET NOCOUNT ON       --stop the server from returning a message to the client, reduce network traffic
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

/* Updated 8/10/2005 JS - filter onlinedb and cnty 2480 to 20minutes*/

if ((UPPER(@delivery) = 'ONLINEDB') AND (@cntyno = 2480))
Begin
SELECT DISTINCT
    C.County,
    C.CrimID,
    C.vendorid,
    C.status,
     A.[Last],
    A.[First],
    A.Middle,
	A.Generation,
    A.Alias,
    A.Alias1_Last,
    A.Alias1_First,
    A.Alias1_Middle,
    A.Alias1_Generation,
    A.Alias2_Last,
    A.Alias2_First,
    A.Alias2_Middle,
    A.Alias2_Generation,
    A.Alias3_Last,
    A.Alias3_First,
    A.Alias3_Middle,
    A.Alias3_Generation,
    A.Alias4_Last,
    A.Alias4_First,
    A.Alias4_Middle,
    A.Alias4_Generation,
    A.Alias2,
    A.Alias3,
    A.Alias4,
    A.SSN,
    A.DOB,
    A.DL_Number,
    C.deliverymethod,
    R.R_Delivery,
     C.APNO,
    C.iris_rec,
    C.txtalias,
    C.txtalias2,
    C.txtalias3,
    C.txtalias4,
    C.txtlast,
    C.ordered
FROM DBO.Crim C(NOLOCK)
    INNER JOIN DBO.Iris_Researchers R(NOLOCK) ON C.vendorid = R.R_id
    LEFT OUTER JOIN DBO.Appl A(NOLOCK) ON C.APNO = A.APNO
WHERE
    (UPPER(A.ApStatus) IN ('P','W'))
    AND (UPPER(C.iris_rec) = 'YES')
    AND (UPPER(C.clear) = 'R') 
    and (C.vendorid = @vendorid)
    and (C.cnty_no = @cntyno)
    and (C.batchnumber IS NULL OR C.batchnumber = '0')
    and (A.inuse IS NULL)
    AND (DATEDIFF(mi, C.Crimenteredtime, GETDATE()) >= 20)
ORDER BY C.APNO ASC;
end 
ELSE IF (UPPER(@delivery) LIKE 'WEB%SERVICE%')
BEGIN
SELECT DISTINCT
    C.county,
    C.crimid,
    C.vendorid,
    C.status,
    A.[last],
    A.[first],
    A.middle,
	A.Generation,
    A.alias,
    A.alias1_last,
    A.alias1_first,
    A.alias1_middle,
    A.alias1_generation,
    A.alias2_last,
    A.alias2_first,
    A.alias2_middle,
    A.alias2_generation,
    A.alias3_last,
    A.alias3_first,
    A.alias3_middle,
    A.alias3_generation,
    A.alias4_last,
    A.alias4_first,
    A.alias4_middle,
    A.alias4_generation,
    A.alias2,
    A.alias3,
    A.alias4,
    A.ssn,
    A.dob,
    A.dl_number,
    C.deliverymethod,
    R.r_delivery,
    C.apno,
    C.iris_rec,
    C.txtalias,
    C.txtalias2,
    C.txtalias3,
    C.txtalias4,
    C.txtlast,
    C.ordered
FROM DBO.crim C(NOLOCK)
    INNER JOIN DBO.iris_researchers R(NOLOCK) ON C.vendorid = R.r_id
    LEFT OUTER JOIN DBO.appl A(NOLOCK) ON C.apno = A.apno
WHERE
    (UPPER(A.apstatus) IN ('P','W'))
    AND (UPPER(C.iris_rec) = 'YES')
    AND (C.clear IN ('R','E')) 
    AND (C.vendorid = @vendorid)
    AND (C.cnty_no = @cntyno)
    AND (C.batchnumber IS NULL OR C.batchnumber = '0')
    AND (A.inuse IS NULL)
    AND (DATEDIFF(mi, C.crimenteredtime, GETDATE()) >= 1)
ORDER BY C.APNO ASC;
END ELSE
begin
SELECT  DISTINCT
    C.County,
    C.CrimID,
    C.vendorid,
    C.status,
    A.[Last],
    A.[First],
    A.Middle,
	A.Generation,
    A.Alias,
    A.Alias1_Last,
    A.Alias1_First,
    A.Alias1_Middle,
    A.Alias1_Generation,
    A.Alias2_Last,
    A.Alias2_First,
    A.Alias2_Middle,
    A.Alias2_Generation,
    A.Alias3_Last,
    A.Alias3_First,
    A.Alias3_Middle,
    A.Alias3_Generation,
    A.Alias4_Last,
    A.Alias4_First,
    A.Alias4_Middle,
    A.Alias4_Generation,
    A.Alias2,
    A.Alias3,
    A.Alias4,
    A.SSN,
    A.DOB,
    A.DL_Number,
    C.deliverymethod,
     C.deliverymethod as R_Delivery,
    C.APNO,
    C.iris_rec, 
    C.ordered,
	C.cnty_no
FROM DBO.Crim C(NOLOCK)
    --INNER JOIN Iris_Researchers R ON C.vendorid = R.R_id
    INNER JOIN DBO.Appl A(NOLOCK) ON C.APNO = A.APNO
WHERE
    (A.apstatus IN ('P','W'))
    AND (C.iris_rec = 'YES')
    and (C.clear = 'R') 
    and (C.vendorid = @vendorid)
    and (C.cnty_no = @cntyno)
    and (C.batchnumber IS NULL OR C.batchnumber = '0')
    and (A.inuse IS NULL)
    AND (DATEDIFF(mi, C.Crimenteredtime, GETDATE()) >= 1)
ORDER BY C.APNO ASC;
    
    
SET NOCOUNT OFF
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
    
end

