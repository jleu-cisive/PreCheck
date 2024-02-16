-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

--[ActivityStatusReport] '02/01/2021','02/01/2021'

CREATE PROCEDURE [dbo].[ActivityStatusReport_NotWorking]
	-- Add the parameters for the stored procedure here
	 @StartDate DateTime,
	 @EndDate DateTime 
	  
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

    -- Insert statements for procedure here
Drop table IF EXISTS #temp1
Drop table IF EXISTS #temp2
Drop table IF EXISTS #temp3
Drop table IF EXISTS #temp4
Drop table IF EXISTS #temp5
Drop table IF EXISTS #temp6
Drop table IF EXISTS #temp7
Drop table IF EXISTS #temp8
Drop table IF EXISTS #temp9
Drop table IF EXISTS #temp10
Drop table IF EXISTS #temp11
Drop table IF EXISTS #temp12	



CREATE Table #Temp1
(
UserId varchar(8),
EnteredBy int,
DEMI int,
Operator int,
PendingStatus int,
OnHoldStatus int,
FinaledByCam int,
Automated int
)


INSERT INTO #Temp1 (UserId, EnteredBy, DEMI, Operator, PendingStatus, OnHoldStatus, FinaledByCam, Automated)
Select U.UserId, 
(SELECT Count(Appl.EnteredBy) FROM Appl with (NOLOCK) WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate) 
AND Enteredby = U.UserId AND (ISNULL(Enteredvia,'') = '' or ISNULL(Enteredvia,'') = 'DEMI') and CLNO not in (3468 )) As EnteredBy,
(SELECT Count(Appl.EnteredBy) FROM Appl with (NOLOCK) WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate) 
AND Enteredby = U.UserId AND  ISNULL(Enteredvia,'') = 'DEMI' and CLNO not in (3468 )) As DEMI,
(SELECT Count(Appl.UserId) FROM Appl with (NOLOCK) WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate)
AND Appl.UserId = U.UserId and CLNO not in (3468 )) As Operator,
(SELECT Count(Appl.Investigator) FROM Appl with (NOLOCK) WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate) 
AND Investigator = U.UserId AND ApStatus <> 'M' and CLNO not in (3468)) As PendingStatus,
(Select Count(Appl.Investigator) from Appl with (NOLOCK) WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate)
 AND Investigator = U.UserId AND ApStatus = 'M' and CLNO not in (3468)) As OnHoldStatus,
(select count (1)Count from Appl with (NOLOCK) where 
(case when compdate>ISNULL(origcompdate,'1/1/1900')
 then Compdate else origcompdate end) >= @StartDate AND  
(case when compdate>ISNULL(origcompdate,'1/1/1900') 
 then Compdate else origcompdate end) < DateAdd(d,1,@EndDate )
 and ApStatus='F' and UserId = U.UserID and CLNO not in (3468 )) AS FinaledByCam,
(Select 0) As Automated FROM Users U with (NOLOCK) WHERE (SELECT Count(Appl.Investigator) FROM Appl with (NOLOCK)
 WHERE  CLNO not in (3468 )and ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate) AND Investigator = U.UserId) > 0 or 
(SELECT Count(Appl.EnteredBy) FROM Appl with (NOLOCK) WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate) 
AND Enteredby = U.UserId AND (ISNULL(Enteredvia,'') = '' Or ISNULL(Enteredvia,'') = 'DEMI')) > 0 or
(SELECT Count(Appl.Investigator) FROM Appl with (NOLOCK) WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate) AND Investigator = U.UserId) > 0 or
(SELECT Count(Appl.UserId) FROM Appl with (NOLOCK) WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate) AND Appl.UserId = U.UserId) > 0 or
(select count (1)Count from Appl with (NOLOCK) where (case when compdate>ISNULL(origcompdate,'1/1/1900') 
then Compdate else origcompdate end) >= @StartDate AND  (case when compdate>ISNULL(origcompdate,'1/1/1900') 
then Compdate else origcompdate end) < DateAdd(d,1,@EndDate) and ApStatus='F' and UserId = U.UserID) > 0 


CREATE Table #Temp2
(
UserId varchar(8),
EnteredBy int,
DEMI int,
Operator int,
PendingStatus int,
OnHoldStatus int,
FinaledByCam int,
Automated int
)

INSERT INTO #Temp2 (UserId, EnteredBy, DEMI, Operator, PendingStatus, OnHoldStatus, FinaledByCam, Automated)
Select 'XML' AS UserId, (SELECT Count(Appl.EnteredVia) FROM Appl with (NOLOCK) 
WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate) AND EnteredVia = 'XML' and CLNO not in (3468 )
) As EnteredBy,
(SELECT 0) As DEMI,
(SELECT 0) As Operator,
(SELECT 0) As PendingStatus,
(Select 0) As OnHoldStatus,
(SELECT 0) As FinaledByCam,(Select 1) As Automated


CREATE Table #Temp3
(
UserId varchar(8),
EnteredBy int,
DEMI int,
Operator int,
PendingStatus int,
OnHoldStatus int,
FinaledByCam int,
Automated int
)

INSERT INTO #Temp3 (UserId, EnteredBy, DEMI, Operator, PendingStatus, OnHoldStatus, FinaledByCam, Automated)
Select 'STAGING' AS UserId, (SELECT Count(Appl.EnteredVia) FROM Appl  with (nolock) 
WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate) AND EnteredVia = 'STAGING' and CLNO not in (3468 )) As EnteredBy,
(SELECT 0) As DEMI,(SELECT 0) As Operator,
(SELECT 0) As PendingStatus,
(Select 0) As OnHoldStatus,
(SELECT 0) As FinaledByCam,
(Select 1) As Automated


CREATE Table #Temp4
(
UserId varchar(8),
EnteredBy int,
DEMI int,
Operator int,
PendingStatus int,
OnHoldStatus int,
FinaledByCam int,
Automated int
)

INSERT INTO #Temp4 (UserId, EnteredBy, DEMI, Operator, PendingStatus, OnHoldStatus, FinaledByCam, Automated)
Select 'WEB' AS UserId, (SELECT Count(Appl.EnteredVia) FROM Appl with (NOLOCK) 
WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate) AND EnteredVia = 'WEB' and CLNO not in (3468 )) As EnteredBy,
(SELECT 0) As DEMI,(SELECT 0) As Operator,
(SELECT 0) As PendingStatus,
(Select 0) As OnHoldStatus,
(SELECT 0) As FinaledByCam,
(Select 1) As Automated


CREATE Table #Temp5
(
UserId varchar(8),
EnteredBy int,
DEMI int,
Operator int,
PendingStatus int,
OnHoldStatus int,
FinaledByCam int,
Automated int
)
INSERT INTO #Temp5 (UserId, EnteredBy, DEMI, Operator, PendingStatus, OnHoldStatus, FinaledByCam, Automated)
Select 'StuWeb' AS UserId, (SELECT Count(Appl.EnteredVia) FROM Appl with (NOLOCK) 
WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate) AND EnteredVia = 'StuWeb' and CLNO not in (3468 )) As EnteredBy,
(SELECT 0) As DEMI,(SELECT 0) As Operator,
(SELECT 0) As PendingStatus,
(Select 0) As OnHoldStatus,
(SELECT 0) As FinaledByCam,
(Select 1) As Automated


CREATE Table #Temp6
(
UserId varchar(8),
EnteredBy int,
DEMI int,
Operator int,
PendingStatus int,
OnHoldStatus int,
FinaledByCam int,
Automated int
)

INSERT INTO #Temp6 (UserId, EnteredBy, DEMI, Operator, PendingStatus, OnHoldStatus, FinaledByCam, Automated)
Select 'HTMLPARS' AS UserId, (SELECT Count(Appl.EnteredVia) FROM Appl with (NOLOCK) 
WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate) AND EnteredVia = 'HTMLPARS' and CLNO not in (3468 )) As EnteredBy,
(SELECT 0) As DEMI,(SELECT 0) As Operator,
(SELECT 0) As PendingStatus,
(Select 0) As OnHoldStatus,
(SELECT 0) As FinaledByCam,
(Select 1) As Automated


CREATE Table #Temp7
(
UserId varchar(8),
EnteredBy int,
DEMI int,
Operator int,
PendingStatus int,
OnHoldStatus int,
FinaledByCam int,
Automated int
)

INSERT INTO #Temp7 (UserId, EnteredBy, DEMI, Operator, PendingStatus, OnHoldStatus, FinaledByCam, Automated)
Select 'SYSTEM' AS UserId, (SELECT Count(Appl.EnteredVia) FROM Appl with (NOLOCK) 
WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate) AND EnteredVia = 'SYSTEM' and CLNO not in (3468 )) As EnteredBy,
(SELECT 0) As DEMI,(SELECT 0) As Operator,
(SELECT 0) As PendingStatus,
(Select 0) As OnHoldStatus,
(SELECT 0) As FinaledByCam,
(Select 1) As Automated


CREATE Table #Temp8
(
UserId varchar(15),
EnteredBy int,
DEMI int,
Operator int,
PendingStatus int,
OnHoldStatus int,
FinaledByCam int,
Automated int
)

INSERT INTO #Temp8 (UserId, EnteredBy, DEMI, Operator, PendingStatus, OnHoldStatus, FinaledByCam, Automated)
Select 'OMNI RESELLER' AS UserId, (SELECT Count(Appl.EnteredBy) FROM Appl with (NOLOCK) 
WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate) AND EnteredBy = 'Reseller' and CLNO not in (3468 )) As EnteredBy,
(SELECT 0) As DEMI,
(SELECT 0) As Operator,
(SELECT 0) As PendingStatus,
(Select 0) As OnHoldStatus,
(SELECT 0) As FinaledByCam,
(Select 1) As Automated


CREATE Table #Temp9
(
UserId varchar(8),
EnteredBy int,
DEMI int,
Operator int,
PendingStatus int,
OnHoldStatus int,
FinaledByCam int,
Automated int
)

INSERT INTO #Temp9 (UserId, EnteredBy, DEMI, Operator, PendingStatus, OnHoldStatus, FinaledByCam, Automated)
Select '<blank>' AS UserId, (SELECT Count(*) FROM Appl with (NOLOCK) 
WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate) AND Enteredby is null AND ISNULL(Enteredvia,'') = '' and CLNO not in (3468 )) As EnteredBy,
(SELECT 0) As DEMI,
(SELECT Count(*) FROM Appl with (NOLOCK) WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate) AND Appl.UserId is null and CLNO not in (3468 )) As Operator,
(SELECT Count(*) FROM Appl with (NOLOCK) WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate) AND Investigator is null and CLNO not in (3468 ) AND ApStatus <>'M') As PendingStatus,
(Select Count(*) FROM Appl with (NOLOCK) WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate) and Investigator is null AND CLNO not in (3468 ) AND ApStatus ='M') As OnHoldStatus,
(SELECT 0) As FinaledByCam,
(Select -1) As Automated


CREATE Table #Temp12
(
UserId varchar(8),
EnteredBy int,
DEMI int,
Operator int,
PendingStatus int,
OnHoldStatus int,
FinaledByCam int,
Automated int
)

INSERT INTO #Temp12 (UserId, EnteredBy, DEMI, Operator, PendingStatus, OnHoldStatus, FinaledByCam, Automated)
Select 'CIC' AS UserId, (SELECT Count(Appl.EnteredVia) FROM Appl with (NOLOCK) 
WHERE ApDate >= @StartDate AND ApDate < DateAdd(d,1,@EndDate) AND EnteredVia = 'CIC' and CLNO not in (3468 )) As EnteredBy,
(SELECT 0) As DEMI,(SELECT 0) As Operator,
(SELECT 0) As PendingStatus,
(Select 0) As OnHoldStatus,
(SELECT 0) As FinaledByCam,
(Select 1) As Automated


CREATE Table #Temp10
(
UserId varchar(15),
EnteredBy int,
DEMI int,
Operator int,
PendingStatus int,
OnHoldStatus int,
FinaledByCam int,
Automated int
)
INSERT INTO #Temp10 (UserId, EnteredBy, DEMI, Operator, PendingStatus, OnHoldStatus, FinaledByCam, Automated)
(Select * from #Temp1
UNION ALL
Select * from #Temp2
UNION ALL
Select * from #Temp3
UNION ALL
Select * from #Temp4
UNION ALL
Select * from #Temp5
UNION ALL
Select * from #Temp6
UNION ALL
Select * from #Temp7
UNION ALL
Select * from #Temp8
UNION ALL
Select * from #Temp9
UNION ALL
Select * from #Temp12) Order by UserID


CREATE Table #Temp11
(
UserId varchar(15),
EnteredBy int,
DEMI int,
Operator int,
PendingStatus int,
OnHoldStatus int,
FinaledByCam int,
Automated int
)

INSERT INTO #Temp11 (UserId, EnteredBy, DEMI, Operator, PendingStatus, OnHoldStatus, FinaledByCam, Automated)
Select 'TOTAL' As UserId,
Sum(EnteredBy) as EnteredBy,
Sum(DEMI) as DEMI,
Sum(Operator) as Operator,
Sum(PendingStatus) as PendingStatus,
Sum(OnHoldStatus) as OnHoldStatus,
Sum(FinaledByCam) as FinaledByCam,
Sum(Automated) as Automated from #Temp10


Select * From #temp10 
UNION ALL
Select * FROM #temp11




SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SET NOCOUNT OFF;


END
