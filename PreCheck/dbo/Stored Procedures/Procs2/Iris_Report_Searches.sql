



CREATE PROCEDURE [dbo].[Iris_Report_Searches] @begdate varchar(10),@enddate varchar(10) ,@cnty_no int

as

if( DateDiff(m,@begdate,@enddate) <= 6)
BEGIN

DECLARE @begdateD datetime,@enddateD datetime;
SET @begdateD = CAST(@begdate As DateTime);
SET @enddateD = CAST(@enddate As DateTime);

SELECT     dbo.Counties.State, dbo.Counties.A_County, dbo.Counties.Country, CNTY_NO, ( select COUNT(dbo.Crim.CrimID)
from crim with (nolock) where (CASE ISDATE(ordered) WHEN 1 THEN CAST(ordered As DateTime) ELSE null END) between @begdateD and @enddateD
and dbo.Crim.CNTY_NO = @cnty_no) AS totalcount
FROM         dbo.Counties WITH (NOLOCK) 
WHERE   dbo.Counties.cnty_no = @cnty_no

END
ELSE
raiserror('Error, the date range provided is too large. Please limit date range to 6 months.',16,1)



