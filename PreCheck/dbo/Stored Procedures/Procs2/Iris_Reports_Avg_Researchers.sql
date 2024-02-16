

CREATE PROCEDURE [dbo].[Iris_Reports_Avg_Researchers] @rid int,@startdate varchar(10), @enddate varchar(10) AS
 


if( DateDiff(m,@startdate,@enddate) <= 4)
BEGIN
SELECT     dbo.Iris_Researchers.R_id, dbo.Crim.Last_Updated, dbo.Counties.State, dbo.crim.clear,dbo.Counties.A_County, dbo.Counties.Country, dbo.Crim.Ordered
,CONVERT(numeric(7,2), dbo.ElapsedBusinessDays(crim.ordered,crim.last_updated)) as Elapsed, 
crim.last_updated,     dbo.Iris_Researchers.R_Name
FROM         dbo.Counties WITH (NOLOCK) INNER JOIN
                      dbo.Crim WITH (NOLOCK) ON dbo.Counties.CNTY_NO = dbo.Crim.CNTY_NO INNER JOIN
                      dbo.Iris_Researchers WITH (NOLOCK) ON dbo.Crim.vendorid = dbo.Iris_Researchers.R_id
WHERE     (dbo.Crim.Last_Updated IS NOT NULL) 
and (isdate(crim.ordered) <> 0) and (iris_researchers.r_id = @rid) and 
 (convert(varchar(11),cast(dbo.crim.last_updated as datetime),102)  BETWEEN convert(varchar(11),cast(@startdate as datetime),102) 
and convert(varchar(11),cast(@enddate as datetime),102) ) and (crim.clear is not null or crim.clear <> 'O')
order by iris_researchers.r_name
END
ELSE
raiserror('Error, the date range provided is too large. Please limit date range to 4 months.',16,1)


