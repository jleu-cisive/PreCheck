CREATE       PROCEDURE dbo.ReportClientCrim 
( 
	@bDate datetime, 
	@eDate datetime,
	@clientID int
	
)
AS


SELECT     dbo.Appl.CLNO, dbo.Client.Name, dbo.Appl.[Last], dbo.Appl.[First], dbo.Crim.SSN, dbo.Crim.APNO, dbo.Crim.County, dbo.Appl.State, 
                      dbo.Crim.Degree
FROM         dbo.Appl INNER JOIN
                      dbo.Crim ON dbo.Appl.APNO = dbo.Crim.APNO INNER JOIN
                      dbo.Client ON dbo.Appl.CLNO = dbo.Client.CLNO
WHERE     (dbo.Crim.Degree = 'M' OR
                      dbo.Crim.Degree = 'F') AND (dbo.Appl.OrigCompDate >= @bDate) AND 
                      (dbo.Appl.OrigCompDate <= @eDate) AND (dbo.Appl.CLNO = @clientID or dbo.Client.WebOrderParentCLNO= @clientID)
ORDER BY dbo.Appl.CLNO


