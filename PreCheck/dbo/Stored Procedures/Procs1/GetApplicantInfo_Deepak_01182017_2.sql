﻿
/*
Procedure Name : [dbo].[GetApplicantInfo_Deepak_01182017_2] 
Modified By: Deepak Vodethela
Description: Added logic for expiration link. 
Execution : EXEC [dbo].[GetApplicantInfo_Deepak_01182017_2]  2655450,'227-55-8501','1989-08-20','Lilly','relilly891@gmail.com',176
			EXEC [dbo].[GetApplicantInfo_Deepak_01182017_2]  null,'227-55-8501','1989-08-20','Lilly','relilly891@gmail.com',176
*/

CREATE  PROCEDURE [dbo].[GetApplicantInfo_Deepak_01182017_2]    
	@APNO  INT = NULL,
    @SSN  Varchar(11) = NULL,
    @DOB  DateTime = NULL,
	@Last varchar(100) = NULL,
	@Email varchar(100) = NULL,
	@OCHS_ID Int = NULL
AS
BEGIN
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @IsAuthenticated Bit
--DECLARE  @OCHS_ApplInfo TABLE (APNO INT,SSN varchar(11),DOB Date)
DECLARE  @OCHS_ApplInfo TABLE (APNO INT,OCHS_CandidateInfoID INT,IsValidLink bit ,ClientName varchar(100),CLNO Int)

DECLARE @OldOrderStatus VARCHAR(25), @OldLastUpdate DATETIME, @TID INT, @OldIsValidLink BIT, @OldLastModifiedDate DATETIME, @OCHS_CandidateScheduleID INT


SET @SSN = Replace(@SSN, '-', '')

IF @SSN IS NOT NULL 
	BEGIN
		IF @APNO IS NOT NULL	
			BEGIN
				Insert into @OCHS_ApplInfo (APNO,OCHS_CandidateInfoID,IsValidLink,ClientName,CLNO)
				Select @APNO APNO, OCHS_CandidateInfoID,1,'',CLNO
				From dbo.OCHS_CandidateInfo A 
				Where (A.APNO = @APNO)  and Replace(A.SSN, '-', '')=@SSN and A.DOB=cast(@DOB as Date)

				IF (Select count(1) From @OCHS_ApplInfo)=0
					Insert into @OCHS_ApplInfo (APNO,OCHS_CandidateInfoID,IsValidLink,ClientName,CLNO)
					Select A.Apno,0,1,'',CLNO
					From dbo.Appl A
					Where A.APNO = @APNO and A.DOB=@DOB and Replace(A.SSN, '-', '')=@SSN
			END
		ELSE
			Insert into @OCHS_ApplInfo (APNO,OCHS_CandidateInfoID,IsValidLink,ClientName,CLNO)
			Select @OCHS_ID APNO, OCHS_CandidateInfoID,1,'',CLNO
			From dbo.OCHS_CandidateInfo A 
			Where (OCHS_CandidateInfoID = @OCHS_ID ) and Replace(A.SSN, '-', '')=@SSN and A.DOB=cast(@DOB as Date)		
	END
ELSE
	BEGIN
		IF @APNO IS NOT NULL
			BEGIN	
				Insert into @OCHS_ApplInfo (APNO,OCHS_CandidateInfoID,IsValidLink,ClientName,CLNO)
				Select isnull(@APNO,@OCHS_ID) APNO, OCHS_CandidateInfoID,1,'',CLNO
				From dbo.OCHS_CandidateInfo A 
				Where (A.APNO = @APNO) and A.[LASTNAME]=@Last and A.Email = @Email
				
				IF (Select count(1) From @OCHS_ApplInfo)=0
					Insert into @OCHS_ApplInfo (APNO,OCHS_CandidateInfoID,IsValidLink,ClientName,CLNO)
					Select A.Apno, 0,1,'',CLNO
					From dbo.Appl A
					Where A.APNO = @APNO and A.[LAST]=@Last and A.Email = @Email
			END
		ELSE
			Insert into @OCHS_ApplInfo (APNO,OCHS_CandidateInfoID,IsValidLink,ClientName,CLNO)
			Select @OCHS_ID APNO, OCHS_CandidateInfoID,1,'',CLNO
			From dbo.OCHS_CandidateInfo A 
			Where (OCHS_CandidateInfoID = @OCHS_ID) and A.[LASTNAME]=@Last and A.Email = @Email
	END

	-- Get the records to be authenticated
	IF (SELECT COUNT(1) FROM @OCHS_ApplInfo) > 0
		SET @IsAuthenticated = 1
	ELSE
		SET @IsAuthenticated = 0

	INSERT INTO [dbo].[OCHS_edrugVerifyLog]
			   ([APNO]
			   ,[OCHS_ID]
			   ,[SSN]
			   ,[DOB]
			   ,[Last]
			   ,[Email]
			   ,[LogDate],
			   IsAuthenticated)
	SELECT @APNO,@OCHS_ID,@SSN,cast(@DOB as Date),@Last,@Email,current_timestamp,@IsAuthenticated

	--This is a general catchall to update links as invalid based on current system time
	DECLARE  @ScheduleTemp TABLE (OCHS_CandidateScheduleID INT,OCHS_CandidateID INT,IsValidLink bit)

	-- Capture all the records when expiration date is less than current time and if it is a valid link
	INSERT INTO @ScheduleTemp (OCHS_CandidateScheduleID ,OCHS_CandidateID,IsValidLink)
	SELECT OCHS_CandidateScheduleID,OCHS_CandidateID,IsvalidLink
	FROM OCHS_CandidateSchedule
	WHERE ExpirationDate < CURRENT_TIMESTAMP 
	  AND IsValidLink = 1
	

	IF (SELECT COUNT(1)	From @ScheduleTemp) > 0
	BEGIN
		INSERT INTO [dbo].[OCHS_ChangeLog]
		SELECT 'OCHS_CandidateSchedule.IsValidLink' AS [TableName], 
				OCHS_CandidateScheduleID AS [ID], 
				IsValidLink AS OldValue, 
				0 AS NewValue, 
				CURRENT_TIMESTAMP AS ChangeDate,
				'By SP'	
		FROM @ScheduleTemp

		-- Update all the captured records
		UPDATE O 
			SET IsValidLink = 0
			--,LastModifiedDate = CURRENT_TIMESTAMP
		FROM OCHS_CandidateSchedule AS O(NOLOCK)
		INNER JOIN @ScheduleTemp AS S ON O.OCHS_CandidateScheduleID = S.OCHS_CandidateScheduleID
	END

	-- Define a temporary table for capturing all the values based on the conditions
	CREATE TABLE  #tmpExpiredLinks ([TID] INT,[OrderIDOrApno] VARCHAR(25),[SSNOrOtherID] VARCHAR(25), [OrderStatus] VARCHAR(25), [DateReceived] DATETIME, 
									 [LastUpdate] DATETIME, [APNO] INT, [SSN] VARCHAR(11), IsValidLink BIT, OCHS_CandidateID INT, OCHS_CandidateScheduleID INT, Result INT)

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
			1 -- For Matching Apno's (Added to identify records based on condition)
	FROM OCHS_ResultDetails AS R(NOLOCK)
	INNER JOIN OCHS_CandidateInfo AS I(NOLOCK) ON (R.OrderIDOrApno = CAST(I.APNO AS varchar) AND I.APNO > 0 ) 
	INNER JOIN @ScheduleTemp AS S ON S.OCHS_CandidateID = I.OCHS_CandidateInfoID
	WHERE OrderStatus IN ('Donor Email Sent','Order Submitted')
		AND R.OrderIDOrApno <> '0' 	

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
			2  -- For Matching OCHS_CandidateInfoID's  (Added to identify records based on condition)
	FROM OCHS_ResultDetails AS R(NOLOCK)
	INNER JOIN OCHS_CandidateInfo AS I(NOLOCK) ON (R.OrderIDOrApno = CAST(I.OCHS_CandidateInfoID AS varchar) AND I.APNO > 0 ) 
	INNER JOIN @ScheduleTemp AS S ON S.OCHS_CandidateID = I.OCHS_CandidateInfoID
	WHERE OrderStatus IN ('Donor Email Sent','Order Submitted')
		AND R.OrderIDOrApno <> '0' 	

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
			3 --For Matching SSN's  (Added to identify records based on condition)
	FROM OCHS_ResultDetails AS R(NOLOCK)
	INNER JOIN OCHS_CandidateInfo AS I(NOLOCK) ON (R.SSNOrOtherID = I.SSN AND R.OrderIDOrApno = '0' ) 
	INNER JOIN @ScheduleTemp S ON S.OCHS_CandidateID = I.OCHS_CandidateInfoID
	WHERE OrderStatus IN ('Donor Email Sent','Order Submitted')

	IF (SELECT COUNT(1) FROM #tmpExpiredLinks ) > 0
	BEGIN
		-- Insert Apno value AS ID into Audit
		INSERT INTO [dbo].[OCHS_ChangeLog]
		SELECT 'OCHS_CandidateSchedule.OrderStatus' AS [TableName], 
				APNO AS [ID], 
				OrderStatus AS OldValue, 
				'Link Expired' AS NewValue, 
				CURRENT_TIMESTAMP AS ChangeDate,
				'By SP'	
		FROM  #tmpExpiredLinks
		WHERE Result = 1 

		-- Insert OCHS_CandidateInfoID value AS ID into Audit
		INSERT INTO [dbo].[OCHS_ChangeLog]
		SELECT 'OCHS_CandidateSchedule.OrderStatus' AS [TableName], 
				CAST(OrderIDOrApno AS INT) AS [ID], 
				OrderStatus AS OldValue, 
				'Link Expired' AS NewValue, 
				CURRENT_TIMESTAMP AS ChangeDate,
				'By SP'	
		FROM #tmpExpiredLinks 
		WHERE Result = 2

		-- Insert SSN value AS ID into Audit
		INSERT INTO [dbo].[OCHS_ChangeLog]
		SELECT 'OCHS_CandidateSchedule.OrderStatus' AS [TableName], 
				SSN AS [ID], 
				OrderStatus AS OldValue, 
				'Link Expired' AS NewValue, 
				CURRENT_TIMESTAMP AS ChangeDate,
				'By SP'	
		FROM #tmpExpiredLinks 
		WHERE Result = 3

		-- Set the Client Access display value to be 'Link Expired' when these values are set -- 'Donor Email Sent','Order Submitted'
		UPDATE R 
			SET OrderStatus = 'Link Expired'
			--,LastUpdate = CURRENT_TIMESTAMP
		FROM #tmpExpiredLinks AS T 
		INNER JOIN OCHS_ResultDetails AS R(NOLOCK) ON T.TID = R.TID
		
	END

	DROP TABLE #tmpExpiredLinks

	-- Set the links value to true when the condition is set.
	If @IsAuthenticated = 1  
		UPDATE O 
			SET IsValidLink = Isnull(S.IsValidLink,1) ,
				ClientName = C.Name
		FROM @OCHS_ApplInfo O 
		LEFT JOIN OCHS_CandidateSchedule S ON O.OCHS_CandidateInfoID = S.OCHS_CandidateID
		INNER JOIN Client C on O.CLNO = C.CLNO
	
	SELECT Apno,IsValidLink,ClientName from @OCHS_ApplInfo




SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SET NOCOUNT OFF
END
