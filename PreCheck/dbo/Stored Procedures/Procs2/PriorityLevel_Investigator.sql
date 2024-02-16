CREATE PROCEDURE dbo.PriorityLevel_Investigator
(
	@Investigator varchar(8)
)
AS
SET NOCOUNT ON

DECLARE @PriorityAvg float
	, @ClientAvg float
	, @PriorityCount int
	, @ClientCount int
	, @APNO int

--these variables are used for normalization
SELECT @PriorityCount = COUNT(*) FROM dbo.PriorityLevel WHERE PriorityType = 'Investigator'
SELECT @ClientCount = COUNT(*) FROM dbo.ClientWeight
SELECT @PriorityAvg = SUM(Weight) / @PriorityCount FROM dbo.PriorityLevel WHERE PriorityType = 'Investigator'
SELECT @ClientAvg = SUM(Weight) / @ClientCount FROM dbo.ClientWeight

SELECT TOP 100
	A.APNO
	, CONVERT(varchar, A.ApDate, 101) AS ApDate
	, A.CLNO 
	, C.Name
	, DATEDIFF(hour, A.ApDate, getdate()) * 
	  (SELECT TOP 1 Weight / @PriorityAvg FROM dbo.PriorityLevel WHERE PriorityType = 'Investigator' AND FieldName = 'ApDate')
	  +
	  ISNULL((SELECT TOP 1 Weight / @ClientAvg FROM dbo.ClientWeight WHERE CLNO = C.CLNO), 50) *
	  (SELECT TOP 1 Weight / @PriorityAvg FROM dbo.PriorityLevel WHERE PriorityType = 'Investigator' AND FieldName = 'CLNO') AS Weight
FROM dbo.Appl A
	INNER JOIN dbo.Client C ON A.CLNO = C.CLNO
WHERE A.ApStatus IN ('P','W')
	AND ISNULL(A.Investigator, '') = ''
	AND (C.Investigator1 = @Investigator OR C.Investigator2 = @Investigator OR LEN(ISNULL(C.Investigator1, '') + ISNULL(C.Investigator2, '')) = 0)
ORDER BY Weight DESC, A.APNO ASC

SET NOCOUNT OFF