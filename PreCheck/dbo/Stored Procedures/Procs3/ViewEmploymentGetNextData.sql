
/*
Procedure Name : ViewEmploymentGetNextData
Requested By: As part of Verification Get Next Project, there is need to display the data that business is working on
Developer: Santosh Chapyala
Execution : EXEC [ViewEmploymentGetNextData]
*/
CREATE PROCEDURE [dbo].[ViewEmploymentGetNextData] (@ShowAll bit = 0)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

if @ShowAll = 1
	Select EmplGetNextStagingID,Investigator, QueueType, TimeZone, ApDate, ClientName, StagingRunDate,  APNO, EmplID, Employer, TransitionalState,SectStat, web_status, EmplInvestigatorID1, EmplInvestigatorID2, EmplInvestigatorID3, EmplInvestigatorID4, FollowUpOn,
	'Complete List shown in the prioritized order by QueueType' ListType
	From EmplGetNextStaging
else
	BEGIN

		Declare @DefaultDateTime DateTime 

		Set @DefaultDateTime =  DateAdd(HH,1,CURRENT_TIMESTAMP)

		SELECT EmplGetNextStagingID,Investigator, QueueType, E.TimeZone, E.ApDate, E.ClientName, StagingRunDate,  APNO, EmplID, Employer, TransitionalState,SectStat, web_status, EmplInvestigatorID1, EmplInvestigatorID2, EmplInvestigatorID3, EmplInvestigatorID4, FollowUpOn
		into #tmpFollowup
		FROM EmplGetNextStaging E inner join DBO.[fnGetSupportedTimeZonesByTime] (convert(time,CURRENT_TIMESTAMP)) Z on E.TimeZone = Z.TimeZone and FollowUpOn <=  @DefaultDateTime --only qualified timezones that are in today's date
		WHERE FollowUpOn IS NOT NULL 

		SELECT EmplGetNextStagingID,Investigator, QueueType, E.TimeZone, ApDate, ClientName, StagingRunDate,  APNO, EmplID, Employer, TransitionalState,SectStat, web_status, EmplInvestigatorID1, EmplInvestigatorID2, EmplInvestigatorID3, EmplInvestigatorID4,  FollowupOn
		into #tmpGeneralBucket
		FROM [dbo].[EmplGetNextStaging] E inner join DBO.[fnGetSupportedTimeZonesByTime] (convert(time,CURRENT_TIMESTAMP)) Z on E.TimeZone = Z.TimeZone 
		Where EmplGetNextStagingID not in (Select EmplGetNextStagingID from #tmpFollowup)

		Select top 100 Investigator, QueueType, TimeZone, ApDate, ClientName, StagingRunDate,  APNO, EmplID, Employer, TransitionalState,SectStat, web_status, EmplInvestigatorID1, EmplInvestigatorID2, EmplInvestigatorID3, EmplInvestigatorID4, FollowUpOn
		into #tmpTop100General
		From #tmpGeneralBucket

		Create TABLE #GetNextQue (ID Int Identity PRIMARY Key,Investigator varchar(20), QueueType varchar(50), TimeZone varchar(10), ApDate datetime2, ClientName varchar(300), StagingRunDate datetime2,  APNO int, EmplID int, Employer varchar(100), TransitionalState varchar(50)
		,SectStat char(1), web_status int, EmplInvestigatorID1 varchar(20), EmplInvestigatorID2 varchar(20), EmplInvestigatorID3 varchar(20), EmplInvestigatorID4 varchar(20), FollowUpOn datetime2)

		Insert INTO #GetNextQue (Investigator, QueueType, TimeZone, ApDate, ClientName, StagingRunDate,  APNO, EmplID, Employer, TransitionalState,SectStat, web_status, EmplInvestigatorID1, EmplInvestigatorID2, EmplInvestigatorID3, EmplInvestigatorID4, FollowUpOn)
		Select top 100 percent Investigator, QueueType, TimeZone, ApDate, ClientName, StagingRunDate,  APNO, EmplID, Employer, TransitionalState,SectStat, web_status, EmplInvestigatorID1, EmplInvestigatorID2, EmplInvestigatorID3, EmplInvestigatorID4, FollowUpOn
		From #tmpFollowup Where FollowUpOn <= CURRENT_TIMESTAMP 
		ORDER BY FollowUpOn,Employer,APNO

		Insert INTO #GetNextQue (Investigator, QueueType, TimeZone, ApDate, ClientName, StagingRunDate,  APNO, EmplID, Employer, TransitionalState,SectStat, web_status, EmplInvestigatorID1, EmplInvestigatorID2, EmplInvestigatorID3, EmplInvestigatorID4, FollowUpOn)
		-- General Bucket excluding qualified Follow up recordset
		Select top 100 percent Investigator, QueueType, TimeZone, ApDate, ClientName, StagingRunDate,  APNO, EmplID, Employer, TransitionalState,SectStat, web_status, EmplInvestigatorID1, EmplInvestigatorID2, EmplInvestigatorID3, EmplInvestigatorID4, FollowUpOn
		From #tmpTop100General


		Insert INTO #GetNextQue (Investigator, QueueType, TimeZone, ApDate, ClientName, StagingRunDate,  APNO, EmplID, Employer, TransitionalState,SectStat, web_status, EmplInvestigatorID1, EmplInvestigatorID2, EmplInvestigatorID3, EmplInvestigatorID4, FollowUpOn)
		Select top 100 percent  Investigator, QueueType, TimeZone, ApDate, ClientName, StagingRunDate,  APNO, EmplID, Employer, TransitionalState,SectStat, web_status, EmplInvestigatorID1, EmplInvestigatorID2, EmplInvestigatorID3, EmplInvestigatorID4, FollowUpOn
		From #tmpFollowup Where FollowUpOn > CURRENT_TIMESTAMP
		ORDER BY FollowUpOn,Employer,APNO


		Insert INTO #GetNextQue (Investigator, QueueType, TimeZone, ApDate, ClientName, StagingRunDate,  APNO, EmplID, Employer, TransitionalState,SectStat, web_status, EmplInvestigatorID1, EmplInvestigatorID2, EmplInvestigatorID3, EmplInvestigatorID4, FollowUpOn)
		 --General Bucket excluding qualified Follow up recordset
		Select top 100 percent  Investigator, QueueType, TimeZone, ApDate, ClientName, StagingRunDate,  APNO, EmplID, Employer, TransitionalState,SectStat, web_status, EmplInvestigatorID1, EmplInvestigatorID2, EmplInvestigatorID3, EmplInvestigatorID4, FollowUpOn
		From #tmpGeneralBucket Where EmplGetNextStagingID not in (Select EmplGetNextStagingID from #tmpTop100General)


		IF (select COUNT(1) from #GetNextQue)>0
			SELECT Investigator, QueueType, TimeZone, ApDate, ClientName, StagingRunDate,  APNO, EmplID, Employer, TransitionalState,SectStat, w.[description] web_status, EmplInvestigatorID1, EmplInvestigatorID2, EmplInvestigatorID3, EmplInvestigatorID4, FollowUpOn,
			'Qualified By TimeZone - Ordered by 1) Followup Time 2) Prioritized QueueType' ListType
			FROM #GetNextQue G LEFT JOIN websectstat w ON G.web_status = w.code	
			Where  web_status not in (5, 69, 75, 77)  --ExcludeWebStatusList
			And ISNULL(TransitionalState,'') not in ('ReRouting')
			Order BY ID 
		ELSE
			SELECT Investigator, QueueType, TimeZone, ApDate, ClientName, StagingRunDate,  APNO, EmplID, Employer, TransitionalState,SectStat, w.[description]  web_status, EmplInvestigatorID1, EmplInvestigatorID2, EmplInvestigatorID3, EmplInvestigatorID4, FollowUpOn,
			'Complete List shown in the prioritized order by QueueType. <br/><br/>Note: No Records qualify to be served for the current Time' ListType
			FROM [dbo].[EmplGetNextStaging] E LEFT JOIN websectstat w ON E.web_status = w.code	
			ORDER BY E.FollowUpOn,E.Employer,Apno


		DROP TABLE #tmpFollowup
		DROP TABLE #tmpGeneralBucket
		DROP TABLE #tmpTop100General
		DROP TABLE #GetNextQue
	END

SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SET NOCOUNT OFF


