CREATE PROCEDURE [dbo].[DrugTestStatusUpdate_LinkExpirations] AS
BEGIN

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	--This is a general catchall to update links as invalid based on current system time
	DECLARE  @ScheduleTemp TABLE (OCHS_CandidateScheduleID INT,OCHS_CandidateID INT,IsValidLink BIT,ExpirationDate DATETIME)

	-- Capture all the records when expiration date is less than current time and if it is a valid link
	INSERT INTO @ScheduleTemp (OCHS_CandidateScheduleID ,OCHS_CandidateID,IsValidLink,ExpirationDate)
	SELECT OCHS_CandidateScheduleID,OCHS_CandidateID,IsvalidLink,ExpirationDate
	FROM OCHS_CandidateSchedule 
	WHERE OCHS_CandidateScheduleID IN (SELECT MAX(OCHS_CandidateScheduleID) 
									   FROM OCHS_CandidateSchedule 									   
									   GROUP BY OCHS_CandidateID )
	AND 	ExpirationDate <= CURRENT_TIMESTAMP  AND IsValidLink = 1 
	

	-- Define a temporary table for capturing all the values based on the conditions
	CREATE TABLE  #tmpExpiredLinks ([TID] INT,[OrderIDOrApno] VARCHAR(25),[SSNOrOtherID] VARCHAR(25), [OrderStatus] VARCHAR(25), [DateReceived] DATETIME, 
									 [LastUpdate] DATETIME, [APNO] INT, [SSN] VARCHAR(11), IsValidLink BIT, OCHS_CandidateID INT, OCHS_CandidateScheduleID INT, LinkExpirationDate DateTime)

	-- For Matching Apno's when Apno > 0
	INSERT INTO #tmpExpiredLinks
	SELECT	[TID],
			[OrderIDOrApno],
			[SSNOrOtherID],
			[OrderStatus],
			[DateReceived],
			[LastUpdate],
			[APNO],
			[SSN],
			S.IsValidLink,
			S.OCHS_CandidateID,
			S.OCHS_CandidateScheduleID,
			S.ExpirationDate 
	FROM OCHS_ResultDetails AS R(NOLOCK)
	INNER JOIN OCHS_CandidateInfo AS I(NOLOCK) ON (R.OrderIDOrApno = CAST(I.APNO AS varchar) AND I.APNO > 0 ) 
	INNER JOIN @ScheduleTemp AS S ON S.OCHS_CandidateID = I.OCHS_CandidateInfoID
	WHERE  R.OrderIDOrApno <> '0' 	

	-- For Matching OCHS_CandidateInfoId's when Apno > 0
	INSERT INTO #tmpExpiredLinks
	SELECT	[TID],
			[OrderIDOrApno],
			[SSNOrOtherID],
			[OrderStatus],
			[DateReceived],
			[LastUpdate],
			[APNO],
			[SSN],
			S.IsValidLink,
			S.OCHS_CandidateID,
			S.OCHS_CandidateScheduleID,
			S.ExpirationDate 
	FROM OCHS_ResultDetails AS R(NOLOCK)
	INNER JOIN OCHS_CandidateInfo AS I(NOLOCK) ON (R.OrderIDOrApno = CAST(I.OCHS_CandidateInfoID AS varchar)  ) 
	INNER JOIN @ScheduleTemp AS S ON S.OCHS_CandidateID = I.OCHS_CandidateInfoID
	WHERE  R.OrderIDOrApno <> '0' 	

	--SELECT * FROM #tmpExpiredLinks WHERE [OrderIDOrApno] IN (select [OrderIDOrApno] FROM #tmpExpiredLinks GROUP BY [OrderIDOrApno] HAVING COUNT(1)>1) ORDER BY [OrderIDOrApno],lastupdate

	DELETE  #tmpExpiredLinks WHERE [OrderIDOrApno] IN (SELECT [OrderIDOrApno] FROM #tmpExpiredLinks GROUP BY [OrderIDOrApno] HAVING COUNT(1)>1) 

	-- For Matching SSN's when OrderIDOrApno = '0'
	INSERT INTO #tmpExpiredLinks
	SELECT	[TID],
			[OrderIDOrApno],
			[SSNOrOtherID],
			[OrderStatus],
			[DateReceived],
			[LastUpdate],
			[APNO],
			[SSN],
			S.IsValidLink,
			S.OCHS_CandidateID,
			S.OCHS_CandidateScheduleID,
			S.ExpirationDate 
	FROM OCHS_ResultDetails AS R(NOLOCK)
	INNER JOIN OCHS_CandidateInfo AS I(NOLOCK) ON (replace(R.SSNOrOtherID,'-','') = replace(I.SSN,'-','') and len(R.SSNOrOtherID)>0 ) 
	INNER JOIN @ScheduleTemp S ON S.OCHS_CandidateID = I.OCHS_CandidateInfoID
	where  R.OrderIDOrApno = '0'

	--SELECT * FROM #tmpExpiredLinks WHERE SSNOrOtherID IN (SELECT SSNOrOtherID FROM #tmpExpiredLinks GROUP BY SSNOrOtherID HAVING COUNT(1)>1) ORDER BY [OrderIDOrApno],lastupdate

	DELETE  #tmpExpiredLinks WHERE SSNOrOtherID IN (SELECT SSNOrOtherID FROM #tmpExpiredLinks GROUP BY SSNOrOtherID,OrderIDOrApno HAVING COUNT(1)>1)

	--Make sure the system will update only those records that are in the PreCheck statuses - might not happen but a precautionary measure
	DELETE #tmpExpiredLinks WHERE OrderStatus NOT IN ('Donor Email Sent','Order Submitted')

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED



	IF (SELECT COUNT(1) FROM #tmpExpiredLinks ) > 0
	BEGIN
		-- Insert Apno value AS ID into Audit
		INSERT INTO [dbo].[OCHS_ChangeLog]
		SELECT 'OCHS_ResultDetails.OrderStatus' AS [TableName], 
				TID AS [ID], 
				OrderStatus AS OldValue, 
				'Link Expired' AS NewValue, 
				CURRENT_TIMESTAMP AS ChangeDate,
				'SYSTEM'	
		FROM  #tmpExpiredLinks


		-- Set the Client Access display value to be 'Link Expired' when these values are set -- 'Donor Email Sent','Order Submitted'
		UPDATE R 
			SET OrderStatus = 'Link Expired'
			/*Modified By: Gaurav 
			Modified Date: 5/15/2019
			Modification Reason: The procedure is executed through new SSIS job (JobMaster) every 5 mins.
			Before the update, the date stamp was not the current date stamp and was of past date.
			*/
			--,LastUpdate = T.LinkExpirationDate
			,LastUpdate = CURRENT_TIMESTAMP
		FROM #tmpExpiredLinks AS T 
		INNER JOIN OCHS_ResultDetails AS R(NOLOCK) ON T.TID = R.TID 
		--Where R.LastUpdate > T.LinkExpirationDate

		INSERT INTO [dbo].[OCHS_ChangeLog]
		SELECT 'OCHS_CandidateSchedule.IsValidLink' AS [TableName], 
				OCHS_CandidateScheduleID AS [ID], 
				IsValidLink AS OldValue, 
				0 AS NewValue, 
				CURRENT_TIMESTAMP AS ChangeDate,
				'SYSTEM'	
		FROM @ScheduleTemp

		-- Mark all the 'Link Expired' records to InvalidLink in the schedule table
		UPDATE O 
			SET IsValidLink = 0
			,LastModifiedDate = CURRENT_TIMESTAMP
		FROM OCHS_CandidateSchedule AS O(NOLOCK)
		INNER JOIN #tmpExpiredLinks AS S ON O.OCHS_CandidateScheduleID = S.OCHS_CandidateScheduleID
		
	END

	DROP TABLE #tmpExpiredLinks

	SET NOCOUNT OFF
	
END