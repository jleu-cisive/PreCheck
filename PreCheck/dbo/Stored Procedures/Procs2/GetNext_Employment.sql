CREATE PROCEDURE [dbo].[GetNext_Employment]
(
	@Investigator varchar(8)
	, @QueueType varchar(20) = 'Get Next'
)
AS
SET NOCOUNT ON

DECLARE @ClientSum float, @ClientCount int, @ClientAvg float
SELECT @ClientSum = SUM(ISNULL(W.Weight, 50)) 
FROM dbo.Client C LEFT OUTER JOIN dbo.ClientWeight W ON C.CLNO = W.CLNO AND W.WeightType = 'Employment'

SELECT @ClientCount = COUNT(*) FROM dbo.Client
SET @ClientAvg = @ClientSum / @ClientCount

DECLARE @CLNOWeight float, @ApDateWeight float, @PriorityAvg float, @Normalized_CLNO float, @Normalized_ApDate float
SELECT TOP 1 @CLNOWeight = Weight FROM dbo.PriorityLevel WHERE PriorityType = 'Employment' AND FieldName = 'CLNO'
SELECT TOP 1 @ApDateWeight = Weight FROM dbo.PriorityLevel WHERE PriorityType = 'Employment' AND FieldName = 'ApDate'
SET @PriorityAvg = (@CLNOWeight + @ApDateWeight) / 2
SET @Normalized_CLNO = @CLNOWeight / @PriorityAvg
SET @Normalized_ApDate = @ApDateWeight / @PriorityAvg

DECLARE @EmplID int
SET @EmplID = NULL
--SELECT TOP 1 @EmplID = EmplID FROM dbo.Empl WHERE GetNextDate IS NOT NULL AND GetNextDate <= getdate() ORDER BY GetNextDate

IF @EmplID IS NULL
BEGIN
	DECLARE @Is900 bit, @IsAutoProcess bit, @IsHEVN bit
	SET @Is900 = 0
	SET	@IsAutoProcess = 0
	SET @IsHEVN = 0

	IF @QueueType = '900 Number'
		SET @Is900 = 1
	ELSE IF @QueueType = 'Auto Process'
		SET @IsAutoProcess = 1
	ELSE IF @QueueType = 'HEVN'
		SET @IsHEVN = 1

	SELECT TOP 1 @EmplID = E.EmplID
		--, A.APNO
		--, A.ApDate
		--, C.CLNO
		--, C.Name
		--, C.EmplInvestigatorByClient1
		--, C.EmplInvestigatorByClient2
		--, C.EmplInvestigatorByClient3
		--, C.EmplInvestigatorByClient4
		--, C.EmplInvestigatorByEmployer1
		--, C.EmplInvestigatorByEmployer2
		--, (DATEDIFF(hour, A.ApDate, getdate()) * @Normalized_ApDate) + ((ISNULL(W.Weight, 50) / @ClientAvg) * @Normalized_CLNO) AS Weight
	FROM dbo.Empl E
		INNER JOIN dbo.Appl A ON E.APNO = A.APNO 
			AND E.SectStat = '9' 
			AND ISNULL(E.Investigator, '') = ''
			AND A.ApStatus IN ('P','W') 
			AND A.ApDate IS NOT NULL
--		INNER JOIN dbo.ClientEmployer CE ON E.ClientEmployerID = CE.ClientEmployerID
--		INNER JOIN dbo.refEmplContactMethod CM ON CE.EmplContactMethod = CM.ComboOrder 
--			AND CM.Is900 = @Is900
--			AND CM.IsAutoProcess = @IsAutoProcess
--			AND CM.IsHEVN = @IsHEVN
		INNER JOIN dbo.Client C ON A.CLNO = C.CLNO
		LEFT OUTER JOIN dbo.ClientWeight W ON C.CLNO = W.CLNO AND W.WeightType = 'Employment'
	WHERE (C.EmplInvestigatorByClient1 = @Investigator 
			OR C.EmplInvestigatorByClient2 = @Investigator 
			OR C.EmplInvestigatorByClient3 = @Investigator 
			OR C.EmplInvestigatorByClient4 = @Investigator)
		OR (ISNULL(C.EmplInvestigatorByClient1, '') = ''
			AND ISNULL(C.EmplInvestigatorByClient2, '') = ''
			AND ISNULL(C.EmplInvestigatorByClient3, '') = ''
			AND ISNULL(C.EmplInvestigatorByClient4, '') = ''
			AND (C.PersRefInvestigator1 = @Investigator OR C.PersRefInvestigator2 = @Investigator))
		OR (ISNULL(C.EmplInvestigatorByClient1, '') = ''
			AND ISNULL(C.EmplInvestigatorByClient2, '') = ''
			AND ISNULL(C.EmplInvestigatorByClient3, '') = ''
			AND ISNULL(C.EmplInvestigatorByClient4, '') = ''
			AND ISNULL(C.PersRefInvestigator1, '') = ''
			AND ISNULL(C.PersRefInvestigator2, '') = ''
			AND (C.EduInvestigator1 = @Investigator OR C.EduInvestigator2 = @Investigator))
		OR (ISNULL(C.EmplInvestigatorByClient1, '') = ''
			AND ISNULL(C.EmplInvestigatorByClient2, '') = ''
			AND ISNULL(C.EmplInvestigatorByClient3, '') = ''
			AND ISNULL(C.EmplInvestigatorByClient4, '') = ''
			AND ISNULL(C.PersRefInvestigator1, '') = ''
			AND ISNULL(C.PersRefInvestigator2, '') = ''
			AND ISNULL(C.EduInvestigator1, '') = ''
			AND ISNULL(C.EduInvestigator2, '') = '')
	ORDER BY (DATEDIFF(hour, A.ApDate, getdate()) * @Normalized_ApDate) + ((ISNULL(W.Weight, 50) / @ClientAvg) * @Normalized_CLNO) DESC
		, A.APNO ASC
	--ORDER BY Weight DESC, A.APNO ASC
END

IF @EmplID IS NOT NULL
BEGIN
	UPDATE dbo.Empl SET Investigator = @Investigator WHERE EmplID = @EmplID
	SELECT @EmplID AS EmplID
END

SET NOCOUNT OFF