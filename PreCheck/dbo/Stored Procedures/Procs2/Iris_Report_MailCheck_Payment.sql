CREATE PROCEDURE Iris_Report_MailCheck_Payment  @begdate varchar(10) , @enddate varchar(10) AS


SELECT     dbo.Iris_Researchers.R_PaymentMethod, dbo.Crim.Crimenteredtime, dbo.Counties.State, dbo.Counties.A_County, dbo.Counties.Country, 
                      dbo.Iris_Researchers.R_Address, dbo.Iris_Researchers.R_City, dbo.Iris_Researchers.R_State_Province, dbo.Iris_Researchers.R_Phone, 
                      dbo.Iris_Researchers.R_Zip, dbo.Appl.[Last], dbo.Appl.[First], dbo.Appl.Middle, dbo.Appl.Alias, dbo.Appl.Alias1_Last, dbo.Appl.Alias1_First, 
                      dbo.Appl.Alias1_Middle, dbo.Appl.Alias1_Generation, dbo.Appl.Alias2_Last, dbo.Appl.Alias2_First, dbo.Appl.Alias2_Middle, dbo.Appl.Alias2_Generation, 
                      dbo.Appl.Alias3_Last, dbo.Appl.Alias3_First, dbo.Appl.Alias3_Middle, dbo.Appl.Alias3_Generation, dbo.Appl.Alias4_Last, dbo.Appl.Alias4_First, 
                      dbo.Appl.Alias4_Middle, dbo.Appl.Alias4_Generation, dbo.Appl.Alias2, dbo.Appl.Alias3, dbo.Appl.Alias4, dbo.Crim.txtlast, dbo.Crim.txtalias, 
                      dbo.Crim.txtalias2, dbo.Crim.txtalias3, dbo.Crim.txtalias4, dbo.Crim.Clear, dbo.Iris_Researchers.R_Name, dbo.Crim.APNO, 
                      dbo.Crimsectstat.crimdescription, dbo.Iris_Researcher_Charges.Researcher_Fel, dbo.Iris_Researcher_Charges.Researcher_Mis, 
                      dbo.Iris_Researcher_Charges.Researcher_fed, dbo.Iris_Researcher_Charges.Researcher_alias, dbo.Iris_Researcher_Charges.Researcher_combo, 
                      dbo.Iris_Researcher_Charges.Researcher_other
FROM         dbo.Crim WITH (NOLOCK)  INNER JOIN
                      dbo.Iris_Researchers WITH (NOLOCK) ON dbo.Crim.vendorid = dbo.Iris_Researchers.R_id INNER JOIN
                      dbo.Counties WITH (NOLOCK) ON dbo.Crim.CNTY_NO = dbo.Counties.CNTY_NO INNER JOIN
                      dbo.Crimsectstat WITH (NOLOCK) ON dbo.Crim.Clear = dbo.Crimsectstat.crimsect INNER JOIN
                      dbo.Appl WITH (NOLOCK) ON dbo.Crim.APNO = dbo.Appl.APNO LEFT OUTER JOIN
                      dbo.Iris_Researcher_Charges WITH (NOLOCK)  ON dbo.Crim.vendorid = dbo.Iris_Researcher_Charges.Researcher_id AND 
                      dbo.Crim.CNTY_NO = dbo.Iris_Researcher_Charges.cnty_no
WHERE     (dbo.Iris_Researchers.R_PaymentMethod = 'Mail Check') AND (iris_researchers.r_id <> '234') and (dbo.Crim.Clear IS NOT NULL OR
                      dbo.Crim.Clear = '9') AND (Crim.Crimenteredtime  BETWEEN @begdate AND @enddate) AND (dbo.Appl.ApStatus <> 'M')