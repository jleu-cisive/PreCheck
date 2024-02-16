-- =============================================  
-- Created By :  YSharma
-- Create date: 06-Feb-2024 
-- Description: This stored procedure as per HDT #124908 New QReport requirement   
--				to fetch exceptions greater than 30%  for CC, SBM and Nursys jobs.
-- Execution  : Exec QReport_ApplicationsExceptionsGreaterThan30 'TX-RN','01/01/2023','01/31/2024'
-- =============================================  
Create PROCEDURE Dbo.QReport_ApplicationsExceptionsGreaterThan30
	(
		@SectionKeyID varchar(20)
	,  @Startdate  datetime
	,  @Enddate  datetime
	)
AS 
BEGIN
	---- Getting XtId's details for given filter
	DROP TABLE IF EXISTS #Base;
	SELECT  lg.DataXtract_LoggingId,IsNull(Parent_LoggingId,lg.DataXtract_LoggingId) AS Parent_LoggingId 
	, LG.SectionKeyId,LG.Section,DateLogRequest
	,(CASE WHEN IsNull(Parent_LoggingId,lg.DataXtract_LoggingId)=lg.DataXtract_LoggingId THEN Total_Records 
	ELSE NULL END) AS Total_Records
	,Total_Exceptions  
	INTO #Base
	FROM dbo.DataXtract_Logging LG WITH (NOLOCK)
	Where LG.Section <> 'Crim'   
	AND DateLogRequest BETWEEN @Startdate and DateAdd(d,1,@Enddate)  
	AND LG.SectionKeyID = (CASE WHEN len(@SectionKeyID) > 0 THEN  @SectionKeyID  ELSE LG.SectionKeyID END)  
	ORDER BY DateLogRequest

	----- Summarizing details 
	Drop table IF EXISTS #Info;
	SELECT   
		Parent_LoggingId , LG.SectionKeyId 
		, SUM(ISNULL(Total_Records,0)) AS Total_Records
		, SUM(ISNULL(Total_Exceptions,0)) AS Total_Exceptions
	INTO #Info 
	FROM #Base LG WITH (NOLOCK)
	WHERE (Total_Records <>0 OR ISNULL(Total_Exceptions,0)<>0)
	GROUP BY Parent_LoggingId,LG.SectionKeyId, Total_Records
	ORDER BY Parent_LoggingId

	----- Calculating required result
	SELECT 
		Cast(DateLogRequest AS Date) AS DateLogRequest,I.Parent_LoggingId AS LoggingID,I.SectionKeyId
		, Sum(I.Total_Records) As TotalRecords, Sum(I.Total_Exceptions) AS TotalExceptions
		,(Sum(I.Total_Exceptions) *1.00) /NULLIF(Sum(I.Total_Records), 0)*100 AS Per
	FROM #Info I
	LEFT JOIN DataXtract_Logging L WITH (NOLOCK) ON I.Parent_LoggingId=L.DataXtract_LoggingId
	GROUP BY DateLogRequest,I.Parent_LoggingId,I.SectionKeyId
	HAVING (Sum(I.Total_Exceptions) *1.00) /NULLIF(Sum(I.Total_Records), 0)*100 >30

END