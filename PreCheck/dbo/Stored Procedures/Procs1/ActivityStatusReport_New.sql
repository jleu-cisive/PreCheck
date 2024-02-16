-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
/*
[ActivityStatusReport_New] '06/26/2017','06/26/2017'
EXEC [ActivityStatusReport] '06/26/2017','06/26/2017'
*/
CREATE PROCEDURE [dbo].[ActivityStatusReport_New]
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
CREATE TABLE #TempReports (APNO INT,CLNO INT,EnteredBy VARCHAR(20),UserID VARCHAR(18),Enteredvia	VARCHAR(20),Investigator VARCHAR(20),ApStatus CHAR(1),compdate DATETIME,OrigCompDate DATETIME)

INSERT INTO #TempReports
        ( APNO ,CLNO,
          EnteredBy ,
          UserID ,
          Enteredvia ,Investigator,
          ApStatus,
		  compdate,
		  OrigCompDate
        )
SELECT APNO ,CLNO,
          EnteredBy ,
          UserID ,
          Enteredvia ,Investigator,
          ApStatus,
		  CompDate,OrigCompDate
FROM dbo.Appl
WHERE ((CAST(ApDate AS DATE) BETWEEN @StartDate AND @EndDate) OR (CAST(CreatedDate AS DATE) BETWEEN @StartDate AND @EndDate)
		OR (case when compdate>ISNULL(origcompdate,'1/1/1900')  then CAST(ISNULL(Compdate,'1/1/1900')  AS DATE) ELSE CAST(ISNULL(OrigCompdate,'1/1/1900') AS DATE) end) between @StartDate AND @EndDate
		)
AND CLNO NOT IN (3468,2135,3079)

CREATE TABLE #TempCertified (APNO INT,ClientCertified BIT,EnteredVia VARCHAR(20),Investigator VARCHAR(20))

INSERT INTO #TempCertified
        ( APNO ,
          ClientCertified ,
          EnteredVia ,
          Investigator
        )
SELECT A.APNO,CASE WHEN ISNULL(C.ClientCertReceived,'No') = 'No' THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END,EnteredVia	,Investigator
FROM #TempReports A LEFT JOIN dbo.ClientCertification C ON A.APNO = C.APNO
WHERE a.ApStatus='M'

CREATE Table #Temp1
(
UserId varchar(18),
EnteredBy int,
DEMI int,
Operator int,
PendingStatus int,
OnHold_Certified int,
UnCertified INT,
FinaledByCam int,
Automated int
)


INSERT INTO #Temp1 (UserId, EnteredBy, DEMI, Operator, PendingStatus, OnHold_Certified,UnCertified, FinaledByCam, Automated)
Select U.UserId, 
(SELECT Count(EnteredBy) From #TempReports with (NOLOCK) WHERE  Enteredby = U.UserId AND (ISNULL(Enteredvia,'') = '' or ISNULL(Enteredvia,'') = 'DEMI') ) As EnteredBy,
(SELECT Count(EnteredBy) From #TempReports with (NOLOCK) WHERE  Enteredby = U.UserId AND  ISNULL(Enteredvia,'') = 'DEMI' ) As DEMI,
(SELECT Count(UserId) From #TempReports with (NOLOCK) WHERE UserId = U.UserId ) As Operator,
(SELECT Count(Investigator) From #TempReports with (NOLOCK) WHERE Investigator = U.UserId AND ApStatus  = 'P' ) As PendingStatus,
(Select Count(Investigator) From #TempCertified with (NOLOCK) WHERE Investigator = U.UserId AND (ClientCertified = 1 OR EnteredVia = 'StuWeb')) As OnHold_Certified,
 (Select Count(Investigator) From #TempCertified with (NOLOCK) WHERE Investigator = U.UserId AND ClientCertified = 0 AND EnteredVia <> 'StuWeb') As UnCertified,
(select count (1)Count From #TempReports with (NOLOCK) where 
 ApStatus='F' and UserId = U.UserID ) AS FinaledByCam,
(Select 0) As Automated 
FROM Users U 
WHERE (SELECT Count(Investigator) From #TempReports with (NOLOCK)
 WHERE   Investigator = U.UserId) > 0 or 
(SELECT Count(EnteredBy) From #TempReports with (NOLOCK) WHERE  Enteredby = U.UserId AND (ISNULL(Enteredvia,'') = '' Or ISNULL(Enteredvia,'') = 'DEMI')) > 0 or
(SELECT Count(Investigator) From #TempReports with (NOLOCK) Where Investigator = U.UserId) > 0 or
(SELECT Count(UserId) From #TempReports with (NOLOCK) Where UserId = U.UserId) > 0 or
(select count (1)Count From #TempReports with (NOLOCK) where ApStatus='F' and UserId = U.UserID) > 0 


CREATE Table #Temp2
(
UserId varchar(18),
EnteredBy int,
DEMI int,
Operator int,
PendingStatus int,
OnHold_Certified int,
UnCertified INT,
FinaledByCam int,
Automated int
)

INSERT INTO #Temp2 (UserId, EnteredBy, DEMI, Operator, PendingStatus, OnHold_Certified,UnCertified, FinaledByCam, Automated)
Select 'XML' AS UserId, (SELECT Count(EnteredVia) From #TempReports with (NOLOCK) 
Where EnteredVia = 'XML'  
) As EnteredBy,
(SELECT 0) As DEMI,
(SELECT 0) As Operator,
(SELECT Count(Investigator) From #TempReports with (NOLOCK) WHERE EnteredVia = 'XML'  AND ApStatus  = 'P' ) As PendingStatus,
(SELECT Count(EnteredVia) From #TempCertified with (NOLOCK) Where EnteredVia = 'XML' AND ClientCertified = 1) As OnHoldStatus,
(SELECT Count(EnteredVia) From #TempCertified with (NOLOCK) Where EnteredVia = 'XML' AND ClientCertified = 0) As Uncertified,
(SELECT Count(Investigator) From #TempReports with (NOLOCK) WHERE EnteredVia = 'XML'  AND ApStatus  in ('F','W' ) ) As FinaledByCam,(Select 1) As Automated


--CREATE Table #Temp3
--(
--UserId varchar(8),
--EnteredBy int,
--DEMI int,
--Operator int,
--PendingStatus int,
--OnHold_Certified int,
--UnCertified INT,
--FinaledByCam int,
--Automated int
--)

INSERT INTO #Temp2 (UserId, EnteredBy, DEMI, Operator, PendingStatus, OnHold_Certified,UnCertified, FinaledByCam, Automated)
Select 'STAGING' AS UserId, (SELECT Count(EnteredVia) From #TempReports  with (nolock) 
Where EnteredVia = 'STAGING'   ) As EnteredBy,
(SELECT 0) As DEMI,(SELECT 0) As Operator,
(SELECT Count(Investigator) From #TempReports with (NOLOCK) WHERE EnteredVia = 'STAGING'  AND ApStatus  = 'P' ) As PendingStatus,
(SELECT Count(EnteredVia) From #TempCertified with (NOLOCK) Where EnteredVia = 'STAGING' AND ClientCertified = 1) As OnHoldStatus,
(SELECT Count(EnteredVia) From #TempCertified with (NOLOCK) Where EnteredVia = 'STAGING' AND ClientCertified = 0) As Uncertified,
(SELECT Count(Investigator) From #TempReports with (NOLOCK) WHERE EnteredVia = 'STAGING'  AND ApStatus  in ('F','W' ) ) As FinaledByCam,
(Select 1) As Automated


--CREATE Table #Temp4
--(
--UserId varchar(8),
--EnteredBy int,
--DEMI int,
--Operator int,
--PendingStatus int,
--OnHold_Certified int,
--UnCertified INT,
--FinaledByCam int,
--Automated int
--)

INSERT INTO #Temp2 (UserId, EnteredBy, DEMI, Operator, PendingStatus, OnHold_Certified,UnCertified, FinaledByCam, Automated)
Select 'WEB' AS UserId, (SELECT Count(EnteredVia) From #TempReports with (NOLOCK) 
Where EnteredVia = 'WEB'   ) As EnteredBy,
(SELECT 0) As DEMI,(SELECT 0) As Operator,
(SELECT Count(Investigator) From #TempReports with (NOLOCK) WHERE EnteredVia = 'WEB'  AND ApStatus  = 'P' ) As PendingStatus,
(SELECT Count(EnteredVia) From #TempCertified with (NOLOCK) Where EnteredVia = 'WEB' AND ClientCertified = 1) As OnHoldStatus,
(SELECT Count(EnteredVia) From #TempCertified with (NOLOCK) Where EnteredVia = 'WEB' AND ClientCertified = 0) As Uncertified,
(SELECT Count(Investigator) From #TempReports with (NOLOCK) WHERE EnteredVia = 'WEB'  AND ApStatus  in ('F','W' ) ) As FinaledByCam,
(Select 1) As Automated


--CREATE Table #Temp5
--(
--UserId varchar(8),
--EnteredBy int,
--DEMI int,
--Operator int,
--PendingStatus int,
--OnHold_Certified int,
--UnCertified INT,
--FinaledByCam int,
--Automated int
--)
INSERT INTO #Temp2 (UserId, EnteredBy, DEMI, Operator, PendingStatus, OnHold_Certified,UnCertified, FinaledByCam, Automated)
Select 'StuWeb' AS UserId, (SELECT Count(EnteredVia) From #TempReports with (NOLOCK) 
Where EnteredVia = 'StuWeb'   ) As EnteredBy,
(SELECT 0) As DEMI,(SELECT 0) As Operator,
(SELECT Count(Investigator) From #TempReports with (NOLOCK) WHERE EnteredVia = 'StuWeb'  AND ApStatus  = 'P' ) As PendingStatus,
(SELECT Count(EnteredVia) From #TempCertified with (NOLOCK) Where EnteredVia = 'StuWeb' ) As OnHoldStatus,
(SELECT 0) As Uncertified,
(SELECT Count(Investigator) From #TempReports with (NOLOCK) WHERE EnteredVia = 'Stuweb'  AND ApStatus  in ('F','W' ) ) As FinaledByCam,
(Select 1) As Automated


--CREATE Table #Temp6
--(
--UserId varchar(8),
--EnteredBy int,
--DEMI int,
--Operator int,
--PendingStatus int,
--OnHold_Certified int,
--UnCertified INT,
--FinaledByCam int,
--Automated int
--)

INSERT INTO #Temp2 (UserId, EnteredBy, DEMI, Operator, PendingStatus, OnHold_Certified,UnCertified, FinaledByCam, Automated)
Select 'HTMLPARS' AS UserId, (SELECT Count(EnteredVia) From #TempReports with (NOLOCK) 
Where EnteredVia = 'HTMLPARS'   ) As EnteredBy,
(SELECT 0) As DEMI,(SELECT 0) As Operator,
(SELECT Count(Investigator) From #TempReports with (NOLOCK) WHERE EnteredVia = 'HTMLPARS'  AND ApStatus  = 'P' ) As PendingStatus,
(SELECT Count(EnteredVia) From #TempCertified with (NOLOCK) Where EnteredVia = 'HTMLPARS' AND ClientCertified = 1) As OnHoldStatus,
(SELECT Count(EnteredVia) From #TempCertified with (NOLOCK) Where EnteredVia = 'HTMLPARS' AND ClientCertified = 0) As Uncertified,
(SELECT Count(Investigator) From #TempReports with (NOLOCK) WHERE EnteredVia = 'HTMLPARS'  AND ApStatus  in ('F','W' ) ) As FinaledByCam,
(Select 1) As Automated


--CREATE Table #Temp7
--(
--UserId varchar(8),
--EnteredBy int,
--DEMI int,
--Operator int,
--PendingStatus int,
--OnHold_Certified int,
--UnCertified INT,
--FinaledByCam int,
--Automated int
--)

INSERT INTO #Temp2 (UserId, EnteredBy, DEMI, Operator, PendingStatus, OnHold_Certified,UnCertified, FinaledByCam, Automated)
Select 'SYSTEM' AS UserId, (SELECT Count(EnteredVia) From #TempReports with (NOLOCK) 
Where EnteredVia = 'SYSTEM'   ) As EnteredBy,
(SELECT 0) As DEMI,(SELECT 0) As Operator,
(SELECT Count(Investigator) From #TempReports with (NOLOCK) WHERE EnteredVia = 'SYSTEM'  AND ApStatus  = 'P' ) As PendingStatus,
(SELECT Count(EnteredVia) From #TempCertified with (NOLOCK) Where EnteredVia = 'SYSTEM' AND ClientCertified = 1) As OnHoldStatus,
(SELECT  0) As Uncertified,
(SELECT Count(Investigator) From #TempReports with (NOLOCK) WHERE EnteredVia = 'SYSTEM'  AND ApStatus  in ('F','W' ) ) As FinaledByCam,
(Select 1) As Automated


--CREATE Table #Temp8
--(
--UserId varchar(15),
--EnteredBy int,
--DEMI int,
--Operator int,
--PendingStatus int,
--OnHold_Certified int,
--UnCertified INT,
--FinaledByCam int,
--Automated int
--)

INSERT INTO #Temp2 (UserId, EnteredBy, DEMI, Operator, PendingStatus, OnHold_Certified,UnCertified, FinaledByCam, Automated)
Select 'OMNI RESELLER' AS UserId, (SELECT Count(EnteredBy) From #TempReports with (NOLOCK) 
Where EnteredBy = 'Reseller'   ) As EnteredBy,
(SELECT 0) As DEMI,
(SELECT 0) As Operator,
(SELECT Count(Investigator) From #TempReports with (NOLOCK) WHERE EnteredVia = 'Reseller'  AND ApStatus  = 'P' ) As PendingStatus,
(SELECT Count(EnteredVia) From #TempCertified with (NOLOCK) Where EnteredVia = 'Reseller' AND ClientCertified = 1) As OnHoldStatus,
(SELECT Count(EnteredVia) From #TempCertified with (NOLOCK) Where EnteredVia = 'Reseller' AND ClientCertified = 0) As Uncertified,
(SELECT Count(Investigator) From #TempReports with (NOLOCK) WHERE EnteredVia = 'Reseller'  AND ApStatus  in ('F','W' ) ) As FinaledByCam,
(Select 1) As Automated


----CREATE Table #Temp9
----(
----UserId varchar(8),
----EnteredBy int,
----DEMI int,
----Operator int,
----PendingStatus int,
----OnHold_Certified int,
----UnCertified INT,
----FinaledByCam int,
----Automated int
----)

INSERT INTO #Temp2 (UserId, EnteredBy, DEMI, Operator, PendingStatus, OnHold_Certified,UnCertified, FinaledByCam, Automated)
Select '<blank>' AS UserId, (SELECT Count(*) From #TempReports with (NOLOCK) 
Where Enteredby is null AND ISNULL(Enteredvia,'') = '' ) As EnteredBy,
(SELECT 0) As DEMI,
(SELECT Count(*) From #TempReports with (NOLOCK) Where UserId is null ) As Operator,
(SELECT Count(*) From #TempReports with (NOLOCK) Where Investigator is null  AND ApStatus ='P') As PendingStatus,
(SELECT 0) As OnHoldStatus,
(SELECT 0) As Uncertified,
(SELECT Count(Investigator) From #TempReports with (NOLOCK) WHERE Enteredby is null AND ISNULL(Enteredvia,'') = ''  AND ApStatus  in ('F','W' ) ) As FinaledByCam,
(Select -1) As Automated


--CREATE Table #Temp12
--(
--UserId varchar(8),
--EnteredBy int,
--DEMI int,
--Operator int,
--PendingStatus int,
--OnHold_Certified int,
--UnCertified INT,
--FinaledByCam int,
--Automated int
--)

INSERT INTO #Temp2 (UserId, EnteredBy, DEMI, Operator, PendingStatus, OnHold_Certified,UnCertified, FinaledByCam, Automated)
Select 'CIC' AS UserId, (SELECT Count(EnteredVia) From #TempReports with (NOLOCK) 
Where EnteredVia = 'CIC'   ) As EnteredBy,
(SELECT 0) As DEMI,(SELECT 0) As Operator,
(SELECT Count(Investigator) From #TempReports with (NOLOCK) WHERE EnteredVia = 'CIC'  AND ApStatus  = 'P' ) As PendingStatus,
(SELECT Count(EnteredVia) From #TempCertified with (NOLOCK) Where EnteredVia = 'CIC' AND ClientCertified = 1) As OnHoldStatus,
(SELECT Count(EnteredVia) From #TempCertified with (NOLOCK) Where EnteredVia = 'CIC' AND ClientCertified = 0) As Uncertified,
(SELECT Count(Investigator) From #TempReports with (NOLOCK) WHERE EnteredVia = 'CIC'  AND ApStatus  in ('F','W' ) ) As FinaledByCam,
(Select 1) As Automated


--CREATE Table #Temp13
--(
--UserId varchar(8),
--EnteredBy int,
--DEMI int,
--Operator int,
--PendingStatus int,
--OnHold_Certified int,
--UnCertified INT,
--FinaledByCam int,
--Automated int
--)

INSERT INTO #Temp2 (UserId, EnteredBy, DEMI, Operator, PendingStatus, OnHold_Certified,UnCertified, FinaledByCam, Automated)
Select 'DEMI' AS UserId, (SELECT Count(EnteredVia) From #TempReports with (NOLOCK) 
Where EnteredVia = 'DEMI'  
) As EnteredBy,
(SELECT 0) As DEMI,
(SELECT 0) As Operator,
(SELECT Count(Investigator) From #TempReports with (NOLOCK) WHERE EnteredVia = 'DEMI'  AND ApStatus  = 'P' ) As PendingStatus,
(SELECT Count(EnteredVia) From #TempCertified with (NOLOCK) Where EnteredVia = 'DEMI' AND ClientCertified = 1) As OnHoldStatus,
(SELECT Count(EnteredVia) From #TempCertified with (NOLOCK) Where EnteredVia = 'DEMI' AND ClientCertified = 0) As Uncertified,
(SELECT Count(Investigator) From #TempReports with (NOLOCK) WHERE EnteredVia = 'DEMI'  AND ApStatus  in ('F','W' ) ) As FinaledByCam,
(Select 1) As Automated


--CREATE Table #Temp10
--(
--UserId varchar(15),
--EnteredBy int,
--DEMI int,
--Operator int,
--PendingStatus int,
--OnHold_Certified int,
--UnCertified INT,
--FinaledByCam int,
--Automated int
--)
--INSERT INTO #Temp10 (UserId, EnteredBy, DEMI, Operator, PendingStatus, OnHold_Certified,UnCertified, FinaledByCam, Automated)
--(
--Select * from #Temp2
--UNION ALL
--Select * from #Temp3
--UNION ALL
--Select * from #Temp4
--UNION ALL
--Select * from #Temp5
--UNION ALL
--Select * from #Temp6
--UNION ALL
--Select * from #Temp7
--UNION ALL
--Select * from #Temp8
--UNION ALL
--Select * from #Temp9
--UNION ALL
--Select * from #Temp12
--UNION ALL
--Select * from #Temp13) Order by UserID
 

CREATE Table #Temp11
(
UserId varchar(18),
EnteredBy int,
DEMI int,
Operator int,
PendingStatus int,
OnHold_Certified int,
UnCertified INT,
FinaledByCam int,
Automated int
)

INSERT INTO #Temp2 (UserId, EnteredBy, DEMI, Operator, PendingStatus, OnHold_Certified,UnCertified, FinaledByCam, Automated)
Select 'ZTOTAL' As UserId,
Sum(EnteredBy) as EnteredBy,
(SELECT SUM(DEMI) FROM #temp1) as DEMI,
Sum(Operator) + (SELECT SUM(Operator) FROM #temp1) as Operator,
Sum(PendingStatus) as PendingStatus,
Sum(OnHold_Certified) as OnHoldStatus,
Sum(UnCertified) as UnCertified,
Sum(FinaledByCam) as FinaledByCam,
Sum(Automated) as Automated from #Temp2

SELECT * FROM (
SELECT * FROM #Temp1
UNION ALL	
Select * From #temp2 
UNION ALL
Select * FROM #temp11) QRY ORDER BY UserID

DROP TABLE #TempReports
DROP TABLE #TempCertified
Drop table #temp1
Drop table #temp2
--Drop table #temp3
--Drop table #temp4
--Drop table #temp5
--Drop table #temp6
--Drop table #temp7
--Drop table #temp8
--Drop table #temp9
--Drop table #temp10
Drop table #temp11
--Drop table #temp12


SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SET NOCOUNT OFF;


END
