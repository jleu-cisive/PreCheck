



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SRS_ApplicationActivityReport]
	-- Add the parameters for the stored procedure here
	@StartDate datetime,@EndDate datetime
AS
BEGIN
	

Select U.UserId, (SELECT Count(Appl.EnteredBy) FROM Appl with (nolock)
WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate) AND Enteredby = U.UserId AND ISNULL(Enteredvia,'') = '') As EnteredBy,
(SELECT Count(Appl.UserId) FROM Appl with (nolock) WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate) AND Appl.UserId = U.UserId) As Operator,
(SELECT Count(Appl.Investigator) FROM Appl with (nolock) WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate) AND Investigator = U.UserId) As Investigator,
(select count (1)Count from Appl with (nolock) 
 where (case when compdate>ISNULL(origcompdate,'1/1/1900') then Compdate else origcompdate end) >= @StartDate AND  (case when compdate>ISNULL(origcompdate,'1/1/1900') then Compdate else origcompdate end) < DateAdd(d,1,@EndDate)
   and ApStatus='F' and UserId = U.UserID) AS FinaledByCam,
(Select 0) As Automated
 FROM Users U with (nolock) WHERE (SELECT Count(Appl.Investigator) FROM Appl with (nolock) WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate) AND Investigator = U.UserId) > 0 or 
(SELECT Count(Appl.EnteredBy) FROM Appl with (nolock) WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate) AND Enteredby = U.UserId AND ISNULL(Enteredvia,'') = '') > 0 or
(SELECT Count(Appl.Investigator) FROM Appl with (nolock) WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate) AND Investigator = U.UserId) > 0 or
(SELECT Count(Appl.UserId) FROM Appl with (nolock) WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate) AND Appl.UserId = U.UserId) > 0 or
(select count (1)Count from Appl with (nolock) where (case when compdate>ISNULL(origcompdate,'1/1/1900') then Compdate else origcompdate end) >= @StartDate AND  (case when compdate>ISNULL(origcompdate,'1/1/1900') then Compdate else origcompdate end) < DateAdd(d,1,@EndDate) and ApStatus='F' and UserId = U.UserID) > 0
UNION
Select 'XML' AS UserId, (SELECT Count(Appl.EnteredVia) FROM Appl with (nolock)
WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate) AND EnteredVia = 'XML') As EnteredBy,
(SELECT 0) As Operator,
(SELECT 0) As Investigator,
(SELECT 0) As FinaledByCam,
(Select 1) As Automated
UNION
Select 'STAGING' AS UserId, (SELECT Count(Appl.EnteredVia) FROM Appl with (nolock)
WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate) AND EnteredVia = 'STAGING') As EnteredBy,
(SELECT 0) As Operator,
(SELECT 0) As Investigator,
(SELECT 0) As FinaledByCam,
(Select 1) As Automated
UNION
Select 'WEB' AS UserId, (SELECT Count(Appl.EnteredVia) FROM Appl with (nolock)
WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate) AND EnteredVia = 'WEB') As EnteredBy,
(SELECT 0) As Operator,
(SELECT 0) As Investigator,
(SELECT 0) As FinaledByCam,
(Select 1) As Automated
UNION
Select 'StuWeb' AS UserId, (SELECT Count(Appl.EnteredVia) FROM Appl with (nolock)
WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate) AND EnteredVia = 'StuWeb') As EnteredBy,
(SELECT 0) As Operator,
(SELECT 0) As Investigator,
(SELECT 0) As FinaledByCam,
(Select 1) As Automated
UNION
Select 'HTMLPARS' AS UserId, (SELECT Count(Appl.EnteredVia) FROM Appl with (nolock)
WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate) AND EnteredVia = 'HTMLPARS') As EnteredBy,
(SELECT 0) As Operator,
(SELECT 0) As Investigator,
(SELECT 0) As FinaledByCam,
(Select 1) As Automated
UNION
Select 'SYSTEM' AS UserId, (SELECT Count(Appl.EnteredVia) FROM Appl with (nolock)
WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate) AND EnteredVia = 'SYSTEM') As EnteredBy,
(SELECT 0) As Operator,
(SELECT 0) As Investigator,
(SELECT 0) As FinaledByCam,
(Select 1) As Automated
Union
Select '<blank>' AS UserId, (SELECT Count(*) FROM Appl with (nolock)
WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate) AND Enteredby is null AND ISNULL(Enteredvia,'') = '') As EnteredBy,
(SELECT Count(*) FROM Appl with (nolock) WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate) AND Appl.UserId is null) As Operator,
(SELECT Count(*) FROM Appl with (nolock) WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate) AND Investigator is null) As Investigator,
(SELECT 0) As FinaledByCam,
(Select -1) As Automated
Union
Select 'TOTAL' As UserId, (Select Count(EnteredVia) FROM Appl with (nolock) WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate) AND LEN(EnteredVia) > 0) +
(Select Count(EnteredBy) FROM Appl with (nolock) WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate) AND ISNULL(Enteredvia,'') = '') As EnteredBy,
(SELECT Count(*) FROM Appl with (nolock) WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate)) As Operator,
(SELECT Count(*) FROM Appl with (nolock) WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate)) As Investigator,
(select count (1)Count from Appl with (nolock)
 where (case when compdate>ISNULL(origcompdate,'1/1/1900') then Compdate else origcompdate end) >= @StartDate AND  (case when compdate>ISNULL(origcompdate,'1/1/1900') then Compdate else origcompdate end) < DateAdd(d,1,@EndDate)
  and ApStatus='F') AS FinaledByCam,
(Select 2) As Automated
order by Automated,UserId
END




