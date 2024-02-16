CREATE PROCEDURE [dbo].[Iris_Outgoing_Show_InUse] @vendorid int, @delivery varchar(25),@cntyno int AS


SELECT distinct
                      Crim.County, Crim.CrimID, Crim.vendorid, Crim.status, Appl.[Last], Appl.[First], Appl.Middle, Appl.Alias,Appl.Inuse,
                      Appl.Alias1_Last, Appl.Alias1_First, Appl.Alias1_Middle, Appl.Alias1_Generation, Appl.Alias2_Last, Appl.Alias2_First, 
                      Appl.Alias2_Middle, Appl.Alias2_Generation, Appl.Alias3_Last, Appl.Alias3_First, Appl.Alias3_Middle, Appl.Alias3_Generation, 
                      Appl.Alias4_Last, Appl.Alias4_First, Appl.Alias4_Middle, Appl.Alias4_Generation, Appl.Alias2, Appl.Alias3, Appl.Alias4, 
                      Appl.SSN, Appl.DOB, Appl.DL_Number, Crim.deliverymethod, Iris_Researchers.R_Delivery, Crim.APNO, 
                     Crim.iris_rec,txtalias,txtalias2,txtalias3,txtalias4,txtlast,crim.ordered
FROM         DBO.Crim WITH (NOLOCK) INNER JOIN
                      Iris_Researchers WITH (NOLOCK) ON Crim.vendorid = Iris_Researchers.R_id LEFT OUTER JOIN
                      DBO.Appl (nolock) ON Crim.APNO = Appl.APNO
WHERE     (Appl.ApStatus = 'p' OR Appl.ApStatus = 'w') AND (Crim.iris_rec = 'yes') and  (Crim.Clear IS NULL or Crim.clear = 'R') 
               and (crim.vendorid = @vendorid) and (crim.cnty_no = @cntyno) and (crim.batchnumber is null or crim.batchnumber = '0')  and (appl.inuse is not null)
             AND   (DATEDIFF(mi, Crim.Crimenteredtime, GETDATE()) >= 1)