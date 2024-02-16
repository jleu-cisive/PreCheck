CREATE PROCEDURE Iris_Automated_Pending_Fax  @vendorid int AS

-- IrisAutoFax Program 
SELECT     dbo.crim.ordered,datediff(hh,crim.ordered,getdate()),dbo.Appl.[Last], dbo.Appl.[First], dbo.Appl.Middle, dbo.Appl.SSN, dbo.Appl.DOB, 
                      dbo.Crim.txtlast, dbo.Crim.txtalias, dbo.Crim.txtalias2, dbo.Crim.txtalias3, dbo.Crim.txtalias4, dbo.Appl.Alias AS Expr1, 
                      dbo.Appl.Alias1_Last, dbo.Appl.Alias1_First, dbo.Appl.Alias1_Middle, dbo.Appl.Alias1_Generation, dbo.Appl.Alias2_Last, dbo.Appl.Alias2_First, 
                      dbo.Appl.Alias2_Middle, dbo.Appl.Alias2_Generation, dbo.Appl.Alias3_Last, dbo.Appl.Alias3_First, dbo.Appl.Alias3_Middle, dbo.Appl.Alias3_Generation, 
                      dbo.Appl.Alias4_Last, dbo.Appl.Alias4_First, dbo.Appl.Alias4_Middle, dbo.Appl.Alias4_Generation, dbo.Appl.Alias2 AS Expr2, dbo.Appl.Alias3 AS Expr3, 
                      dbo.Appl.Alias4 AS Expr4, dbo.Iris_Researchers.R_Name, dbo.Iris_Researchers.R_Phone, dbo.Iris_Researchers.R_Fax, dbo.Iris_Researchers.R_Firstname, dbo.Iris_Researchers.R_Lastname, 
                      dbo.Iris_Researchers.R_Middlename, dbo.Crim.batchnumber, dbo.Iris_Researchers.R_VendorNotes,  
                      dbo.Appl.APNO, dbo.Counties.A_County, dbo.Counties.State AS crimstate,dbo.iris_researchers.r_address,counties.country ,
  'HoursOut'  = 
    case 
         when  datediff(hh,crim.ordered,getdate()) >= 48  then 48
         when  (datediff(hh,crim.ordered,getdate()) >=24 and datediff(hh,crim.ordered,getdate()) <= 48) then 24
        else
        1
        
   end
                     
FROM         dbo.Appl WITH (NOLOCK) INNER JOIN
                      dbo.Crim WITH (NOLOCK) ON dbo.Appl.APNO = dbo.Crim.APNO INNER JOIN
                      dbo.Iris_Researchers WITH (NOLOCK) ON dbo.Crim.vendorid = dbo.Iris_Researchers.R_id INNER JOIN
                      dbo.Counties WITH (NOLOCK) ON dbo.Crim.CNTY_NO = dbo.Counties.CNTY_NO 
WHERE     (dbo.Appl.ApStatus = 'p' OR  dbo.Appl.ApStatus = 'w') AND (dbo.Crim.clear = 'o') and (iris_researchers.r_delivery = 'fax') 
                   and (iris_researchers.r_id = @vendorid) order by iris_researchers.r_name