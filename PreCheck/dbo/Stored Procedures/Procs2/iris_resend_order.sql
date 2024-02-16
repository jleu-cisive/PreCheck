CREATE PROCEDURE [dbo].[iris_resend_order]
--@vendorid int, 
--@delivery varchar(25),
--'@county varchar(25), 
--'@state varchar(25) ,
@cnum int --batchnumber
AS
/*SELECT DISTINCT 
                      dbo.Crim_Que.Bis_Crim_County, dbo.Crim_Que.County, dbo.Crim_Que.State, dbo.Crim_Que.Appno, dbo.Crim_Que.Crimid, dbo.Crim_Que.Vendorid, 
                      dbo.Crim_Que.Status, dbo.Appl.[Last], dbo.Appl.[First], dbo.Appl.Middle, dbo.Appl.Alias, dbo.Appl.Alias2, dbo.Appl.Alias3, dbo.Appl.Alias4, 
                      dbo.Appl.SSN, dbo.Appl.DOB, dbo.Appl.DL_Number, dbo.Crim_Que.deliveryMethod, dbo.Iris_Researchers.R_Delivery
FROM         dbo.Crim_Que LEFT OUTER JOIN
                      dbo.Iris_Researchers ON dbo.Crim_Que.Vendorid = dbo.Iris_Researchers.R_id LEFT OUTER JOIN
                      dbo.Appl ON dbo.Crim_Que.Appno = dbo.Appl.APNO
WHERE     (crim_que.batchnumber = @cnum) and (dbo.Crim_Que.Vendorid = @vendorid) AND (dbo.Crim_Que.State = @state) AND (dbo.Crim_Que.County = @county)
and  (Appl.ApStatus = 'p' OR  Appl.ApStatus = 'w') and (Crim_que.clear = 'o')
GO*/
SELECT DISTINCT 
	C.County,
	C.CrimID,
	C.vendorid,
	C.status,
	A.[Last],
	A.[First],
	A.Middle,
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
	C.txtlast,
	C.iris_rec,
	C.txtalias,
	C.txtalias2,
	C.txtalias3,
	C.txtalias4
FROM
	dbo.Crim C WITH (NOLOCK)
	INNER JOIN dbo.Iris_Researchers R WITH (NOLOCK) ON C.vendorid = R.R_id
	LEFT OUTER JOIN dbo.Appl A WITH (NOLOCK) ON C.APNO = A.APNO
WHERE
	(UPPER(A.ApStatus) = 'P' OR UPPER(A.ApStatus) = 'W')
	AND (UPPER(C.clear) IN ('O','X','W'))
	AND (C.batchnumber = @cnum)


