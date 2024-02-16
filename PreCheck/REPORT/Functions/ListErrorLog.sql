


CREATE FUNCTION [REPORT].[ListErrorLog]
(
	@StartDate DATETIME, 
	@EndDate DATETIME, 
	@ClientId INT NULL, 
	@FilterPattern VARCHAR(100) NULL,
	@FilterPatternTwo VARCHAR(100) NULL
)
	RETURNS @Results TABLE(CreateDate DATETIME, ClientId INT null, UserName VARCHAR(20) NULL, ExecutionTime DECIMAL(18,4) NULL, 
	ParameterInfo VARCHAR(MAX) NULL, RawMessage VARCHAR(MAX), SearchType VARCHAR(50))
AS
BEGIN
	
--DECLARE @clientId INT = 15355
--DECLARE @stDate DATETIME = '2/2/2020'
--DECLARE @endDate DATETIME = '2/4/2020'
--PRINT LEN('Search completed for client ')
DECLARE @startClientIndex  INT = 29

INSERT INTO @Results
(
    CreateDate,
    ClientId,
    UserName,
    ExecutionTime,
    ParameterInfo,
    RawMessage,
	SearchType
)

SELECT 
	CreateDate, 
	ClientId = TRY_CAST(REPLACE(SUBSTRING(l.Message,@startClientIndex,5),',','') AS INT),
	[User]= REPLACE(SUBSTRING(l.Message,41,8),' i',''),
	[ExecutionTime]= TRY_CAST(SUBSTRING(l.Message,(3+CHARINDEX(' in ',l.Message)),7) AS decimal(18,4)),
	[Parameters] = SUBSTRING(l.Message,CHARINDEX(' {"IsDrugScreen',l.Message),LEN(l.Message)),
	l.Message,
	SearchType = CASE 
					WHEN (l.message LIKE '%"APNO":4%' OR l.message LIKE '%"APNO":3%') THEN 'APNO'
					WHEN (l.message NOT LIKE '%"FirstName":""%' and l.message NOT LIKE '%"LastName":""%') THEN 'Name Search'
					WHEN (l.message NOT LIKE '%"FirstName":""%') THEN 'FirstName Search'
					WHEN (l.message NOT LIKE '%"LastName":""%') THEN 'LastName Search'
					WHEN (l.message NOT LIKE '%"Ssn":""%') THEN 'Social Search'
					WHEN (l.Message not LIKE '%"LastOrderedDateBg":null%') THEN 'Background Date Search'
					WHEN (l.Message not LIKE '%"LastOrderedDateOh":null%') THEN 'DrugTest Date Search'
					ELSE 'other'
				END
FROM dbo.ErrorLog l WITH (NOLOCK) 
	INNER JOIN Enterprise.PreCheck.vwClient c WITH (NOLOCK)
	ON l.Message LIKE '%for client ' + CONVERT(VARCHAR(10),c.ClientId) + ',%'
WHERE (c.ParentId=@clientId OR c.ClientId=@clientId)
AND l.CreateDate BETWEEN @StartDate AND @EndDate
AND l.Message LIKE '%' + ISNULL(@FilterPattern,'') + '%'
--AND l.Message LIKE 'Search completed%'
AND l.Message LIKE '%' + ISNULL(@FilterPatternTwo,'') + '%'
ORDER BY CreateDate DESC
	RETURN

END

