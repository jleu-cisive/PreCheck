CREATE PROCEDURE Iris_Report_County @begdate varchar(10),@enddate varchar(10) ,@cnty_no int

as




SELECT     dbo.Counties.State, dbo.Counties.A_County, dbo.Counties.Country, dbo.Crim.CNTY_NO, dbo.Crim.CrimID AS totalcount, dbo.Crim.Clear, 
                      dbo.Client.Name,counties.a_county,CONVERT(numeric(7,2), dbo.ElapsedBusinessDays(crim.ordered,crim.last_updated) )as average,
'Hits' = 
 case  
 when clear = 'F' then 1
 when clear = 'P' then 1
else
   0
end

FROM         dbo.Counties WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.Crim WITH (NOLOCK)  ON dbo.Counties.CNTY_NO = dbo.Crim.CNTY_NO LEFT OUTER JOIN
                      dbo.Appl WITH (NOLOCK)   ON dbo.Crim.APNO = dbo.Appl.APNO LEFT OUTER JOIN
                      dbo.Client ON dbo.Appl.CLNO = dbo.Client.CLNO
WHERE     (dbo.Fix_Crim_Ordered_Date(crim.Ordered)  BETWEEN @begdate AND @enddate) AND (NOT (dbo.Crim.batchnumber IS NULL)) AND (dbo.Crim.CNTY_NO = @cnty_no) AND (dbo.Appl.ApStatus <> 'M')