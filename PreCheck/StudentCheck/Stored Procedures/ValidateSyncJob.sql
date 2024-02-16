/********************************************************
 Author: Gaurav Bangia
 Date: 3/29/2022
 Validating OrderSummary data state (Student Check - school/clinic orders)
 - missing new orders
 - incorrect order statuses (background, drugtest, immunization)
***********************************************************/
CREATE PROCEDURE [StudentCheck].[ValidateSyncJob]
(
	@StartDate DATETIME,
	@EndDate DATETIME,
	@ClientId INT = null 
)
AS
BEGIN
--DECLARE @StartDate DATETIME = '1/1/2021'
--DECLARE @EndDate DATETIME = '1/1/2022'
DECLARE @CHECK_FOR_BG BIT = 1
DECLARE @CHECK_FOR_DT BIT = 0
DECLARE @CHECK_FOR_IMM BIT = 0

--DECLARE @ClientId INT = 16070

/*Drop all temp tables*/
DROP TABLE IF EXISTS #BG_ORDERS
DROP TABLE IF EXISTS #Orders_missing
DROP TABLE IF EXISTS #Orders_unexpected
DROP TABLE IF EXISTS #Orders_DiffStatus

/*Retrieve from the source*/
SELECT
A.APNO,
A.ApStatus,
a.EnteredVia,
AFS.FlagStatus,
A.CLNO,
A.CreatedDate,
A.ApDate,
A.OrigCompDate,
A.CompDate,
A.ReopenDate,
A.LastModifiedDate
INTO #BG_ORDERS
FROM dbo.Appl A WITH (NOLOCK)
	INNER JOIN dbo.Client C WITH (NOLOCK) ON C.CLNO = A.CLNO
	LEFT OUTER JOIN dbo.ApplFlagStatus AFS WITH (NOLOCK) ON AFS.APNO = A.APNO
WHERE A.CLNO=COALESCE(@ClientId, a.clno)
AND 
(
	-- BG TRIGGERS
	ISNULL(a.CreatedDate,'1/1/1900') BETWEEN @StartDate AND @EndDate
	OR
	ISNULL(A.ApDate,'1/1/1900') BETWEEN @StartDate AND @EndDate
	OR 
	ISNULL(A.OrigCompDate,'1/1/1900') BETWEEN @StartDate AND @EndDate
	OR 
	ISNULL(A.CompDate,'1/1/1900') BETWEEN @StartDate AND @EndDate
	OR
	ISNULL(A.ReopenDate,'1/1/1900') BETWEEN @StartDate AND @EndDate
)
-- ONLY STUDENT CHECK ACCOUNTS
AND C.ClientTypeID IN (6,8,11)

/* validate against the order summary */
-- missing orders
SELECT
	s.APNO,
	S.CLNO,
	S.CreatedDate,
	S.ApDate,
	S.OrigCompDate,
	S.EnteredVia,
	S.ApStatus,
	S.ReopenDate,
	S.CompDate
INTO #Orders_missing
FROM #BG_ORDERS s
	LEFT OUTER JOIN REPORT.OrderSummary D ON s.APNO=d.OrderNumber
WHERE d.OrderNumber IS NULL

SELECT Missing_apno = APNO, * FROM #Orders_missing

-- unexpected orders
SELECT
	D.OrderNumber,
	DestinationClientId = D.ClientId
INTO #Orders_unexpected
FROM 
	REPORT.OrderSummary D 
	LEFT OUTER JOIN #BG_ORDERS s ON s.APNO=d.OrderNumber
WHERE s.APNO IS NULL
AND (D.OrderCreateDate BETWEEN @StartDate AND @EndDate
OR D.BG_CompleteDate BETWEEN @StartDate AND @EndDate)
AND D.ClientId=@ClientId

-- returning all unexpected orders (likely different client) 
SELECT 
	UO.OrderNumber,
	UO.DestinationClientId,
	SouceClientId = A.CLNO
 FROM #Orders_unexpected UO INNER JOIN dbo.Appl A WITH (NOLOCK)
	ON UO.OrderNumber=A.ApNO

-- different statuses
SELECT
bo.APNO,
SourceStatus=bo.ApStatus,
DestStatus = OS.BG_OrderStatus,
A.CreatedDate, 
A.OrigCompDate,
A.CompDate,
A.ReopenDate,
DestCreateDate=OS.OrderCreateDate,
DestModifyDate = os.ModifyDate,
DestCompleteDate = OS.BG_CompleteDate,
DestStatusId = os.BG_OrderStatusId,
DestOrderStatusId = os.OrderStatusId 
INTO #Orders_DiffStatus
FROM #BG_ORDERS BO
	INNER JOIN REPORT.OrderSummary OS ON BO.APNO=OS.OrderNumber
	INNER JOIN dbo.Appl A WITH (NOLOCK) ON A.APNO = BO.APNO
WHERE os.BG_OrderStatus<>bo.ApStatus

SELECT * FROM #Orders_DiffStatus

/*Drop all temp tables*/
DROP TABLE IF EXISTS #BG_ORDERS
DROP TABLE IF EXISTS #Orders_missing
DROP TABLE IF EXISTS #Orders_unexpected
DROP TABLE IF EXISTS #Orders_DiffStatus

END