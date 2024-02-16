


CREATE PROCEDURE [dbo].[Iris_Reports_Vendor_Cost] @rid int,@Startdate varchar(10), @enddate varchar(10)  AS
 
if( DateDiff(m,@StartDate,@enddate) <= 4)
BEGIN
DECLARE @begdateD datetime,@enddateD datetime;

SET @begdateD = CAST(@Startdate As DateTime);
SET @enddateD = CAST(@enddate As DateTime);

SELECT     dbo.Iris_Researchers.R_id, dbo.Iris_Researchers.R_Name, dbo.Iris_Researcher_Charges.Researcher_Fel, 
                      dbo.Iris_Researcher_Charges.Researcher_Mis, dbo.Crim.Ordered, dbo.Iris_Researchers.R_VendorNotes, 
                      dbo.Iris_Researcher_Charges.Researcher_fed, dbo.Iris_Researcher_Charges.Researcher_alias, dbo.Iris_Researcher_Charges.Researcher_combo, 
                      dbo.Iris_Researcher_Charges.Researcher_other, dbo.Crim.APNO, dbo.Counties.CNTY_NO, dbo.Crim.Ordered AS Expr2, dbo.Crim.Degree, 
                      dbo.Counties.A_County, dbo.Counties.State, dbo.Counties.Country, dbo.Crim.vendorid, dbo.Iris_Researcher_Charges.Researcher_CourtFees
FROM         dbo.Iris_Researchers with (nolock) INNER JOIN
                      dbo.Iris_Researcher_Charges with (nolock) INNER JOIN
                      dbo.Crim with (nolock) ON dbo.Iris_Researcher_Charges.Researcher_id = dbo.Crim.vendorid INNER JOIN
                      dbo.Counties with (nolock) ON dbo.Crim.CNTY_NO = dbo.Counties.CNTY_NO ON dbo.Iris_Researchers.R_id = dbo.Iris_Researcher_Charges.Researcher_id
WHERE
(dbo.crim.vendorid  = @rid) AND ((CASE ISDATE(ordered) WHEN 1 THEN CAST(ordered As DateTime) ELSE null END) between @begdateD and @enddateD)
END
ELSE
raiserror('Error, the date range provided is too large. Please limit date range to 4 months.',16,1)



