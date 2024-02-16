


-- Verification_UpdateEmplWebStatus '140863004','TALXReceived','22-10-31'
CREATE procedure [dbo].[Verification_UpdateEmplWebStatus] 
(
	@orderId varchar(30),
	@updateType VARCHAR(30),
	@typeValue VARCHAR(30)
)
AS
BEGIN
	SET NOCOUNT ON;  
	
	DECLARE @CLNO INT
	DECLARE @ProofClient VARCHAR(30)
	DECLARE @OldValue_WebStatusID INT
	DECLARE @OldValue_SubStatusID INT

	DECLARE @SubStatusID INT
	DECLARE @WebStatusID INT
	DECLARE @old_SectStat VARCHAR(10)

	DECLARE @APNO INT
	DECLARE @EmplID INT

	Declare @old_PrivNotes varchar(max)
	Declare @new_PrivNotes varchar(max)

	Declare @old_PublicNotes varchar(max)
	Declare @new_PublicNotes varchar(max)

	DECLARE @BusinessClosed_SectSubStatusID INT
	DECLARE @RecordArchive_SectSubStatusID INT

	DECLARE @FollowupOnDate Date
		

	SELECT @old_PublicNotes = e.Pub_Notes,
			@old_PrivNotes = e.Priv_Notes,
			@APNO = e.Apno,
			@EmplID = e.EmplId,
			@old_SectStat = e.SectStat
	FROM dbo.Empl e
	where e.OrderId = @orderId

	-- Remove follow up if auto close.
	IF(@old_SectStat = '4' OR @old_SectStat = 'U') -- Is closed with Verified or UnVerified.
	BEGIN
		UPDATE af
		SET af.CompletedBy = 'SJV', af.CompletedOn = GETDATE(), af.IsCompleted = 1
		FROM dbo.ApplSections_Followup af 
		WHERE af.ApplSectionID = @EmplID
		and af.Apno = @APNO
		AND af.CompletedBy IS NULL
		AND af.IsCompleted = 0
	END
		


	--
	-- Make sure that the status for one condition does not overrides the other.
	--IF(@updateType = 'Proof')
	--BEGIN
	--	SELECT @CLNO = c.clno,
	--			@OldValue_WebStatusID = e.web_status,
	--			@OldValue_SubStatusID = e.SubStatusID
	--	FROM dbo.Empl e
	--	INNER JOIN dbo.appl a WITH (NOLOCK) ON a.apno = e.apno
	--	INNER JOIN dbo.client c WITH (NOLOCK) ON c.CLNO = a.CLNO
	--	WHERE e.OrderId = @orderId
	
	--	SELECT @ProofClient = cc.[Value]
	--	FROM dbo.ClientConfiguration cc
	--	WHERE cc.CLNO = @CLNO
	--	AND cc.ConfigurationKey = 'ProofClient'

	--	SELECT @WebStatusID = w.code
	--	FROM dbo.Websectstat w 
	--	WHERE w.Empl = 1 
	--	AND w.[description] = 'TALX Review'

	--	-- reset web status to blank. with exception of TALX Review.
	--	IF NOT EXISTS(SELECT 1
	--	FROM dbo.Empl e
	--	WHERE e.OrderId = @orderId
	--	AND e.web_status = @WebStatusID )
	--	BEGIN
	--		SET @WebStatusID = 0
	--	END


		
	--	 -- User story #3 is cancelled. no need of redacting. 
	--	 ------------------------------------------------------------

	--		--IF(LTRIM(RTRIM(ISNULL(@ProofClient,''))) = 'true')
	--		--BEGIN
	--		--	-- UPdate status
	--		--	print 'Update webstatus to Proof and substatus to pending'
		
	--		--	SELECT @SubStatusID = ss.Code  -- 9 
	--		--	FROM dbo.SectStat ss 
	--		--	WHERE ss.[Description] = 'PENDING'

		
	--		--	SELECT @WebStatusID = w.code  -- 96 
	--		--	FROM dbo.Websectstat w 
	--		--	WHERE w.Empl = 1 
	--		--	AND w.[description] = 'Proof'
		
	--		--	UPDATE e SET e.web_status = @WebStatusID
	--		--	FROM dbo.Empl e
	--		--	WHERE e.OrderId = @orderId

		
	--		--	UPDATE e SET e.SectStat = @SubStatusID
	--		--	FROM dbo.Empl e
	--		--	WHERE e.OrderId = @orderId

	--		--	-- change log
	--		--	INSERT INTO dbo.ChangeLog(TableName,ID, OldValue,NewValue,ChangeDate,UserID)
	--		--	SELECT 'Empl.SubStatusID',@orderId, @OldValue_SubStatusID,@SubStatusID,GETDATE(), 'SJV'

	--		--END

	--END

	--ELSE 
	IF(@updateType = 'CallAttempted')
	BEGIN
		
		SELECT @WebStatusID = w.code
		FROM dbo.Websectstat w 
		WHERE w.[description] = 'Reference Call ' + @typeValue

	END
	ELSE IF(@updateType = 'TALXReceived' OR @updateType = 'TALXOrdered_NoRecord')
	BEGIN
		IF(@updateType = 'TALXReceived' AND ISNULL(@old_SectStat,0) <> '9')  -- not 9	PENDING
		BEGIN
			SELECT @WebStatusID = w.code
			FROM dbo.Websectstat w 
			WHERE w.[description] = 'TALX Review'
		END

		
		Declare @typeValueDate Date = GETDATE()
		IF(ISDATE(@typeValue) = 1)
		BEGIN
			SET @typeValueDate = CAST(@typeValue as date)
		END


		IF EXISTS(select 1 from dbo.TALXINFO t WHERE t.APNO = @APNO)
		BEGIN
			DECLARE @OldValue datetime
			SELECT @OldValue = t.TALXOrderedDate 
			from dbo.TALXINFO t 
			WHERE t.APNO = @APNO
			

			UPDATE t
			SET t.TALXOrderedDate = @typeValueDate
			from dbo.TALXINFO t WHERE t.APNO = @APNO

			-- change log
			INSERT INTO dbo.ChangeLog(TableName,ID, OldValue,NewValue,ChangeDate,UserID)
			SELECT 'TALXINFO.TALXOrderedDate',@APNO, @OldValue,@typeValue,GETDATE(), 'SJV'

			SET @new_PrivNotes = 'The work number has been ran for this SSN on a separate report. Please see documents.'
			SET @new_PrivNotes =  CONCAT(@new_PrivNotes, ' [TALXOrdered:', @typeValue, '] ', CHAR(13)+CHAR(10), CHAR(13)+CHAR(10), @old_PrivNotes)

		END
		ELSE
		BEGIN
			INSERT INTO dbo.TALXINFO(APNO, TALXOrderedDate,CreatedDate, CreatedBy)
			VALUES(@APNO,@typeValueDate,GETDATE(),'SJV')

			SET @new_PrivNotes = 'Alert a work number has been ran for this report, please review the TALX document for review. DO NOT Run Work Number'
			SET @new_PrivNotes =  CONCAT(@new_PrivNotes, ' [TALXOrdered:', @typeValue, '] ', CHAR(13)+CHAR(10), @old_PrivNotes)

		END


		-- add private note
		UPDATE e
		SET e.Priv_Notes = @new_PrivNotes
		from dbo.Empl e
		where e.OrderId = @orderId

		-- change log
		INSERT INTO dbo.ChangeLog(TableName,ID, OldValue,NewValue,ChangeDate,UserID)
		SELECT 'Empl.Priv_Notes',@EmplID, @old_PrivNotes,@new_PrivNotes,GETDATE(), 'SJV'


	END
	ELSE IF(@updateType = 'ProofReceived')
		BEGIN

			SELECT @RecordArchive_SectSubStatusID = s.SectSubStatusID
			FROM dbo.SectSubStatus s
			WHERE s.SectSubStatus = 'Records No Longer Available'
			AND s.ApplSectionID = 1

			SELECT @BusinessClosed_SectSubStatusID = s.SectSubStatusID
			FROM dbo.SectSubStatus s
			WHERE s.SectSubStatus = 'Business Closed'
			AND s.ApplSectionID = 1

			-- If Auto Closed
			IF EXISTS(Select 1
				FROM dbo.Empl e
				WHERE e.EmplID = @emplid
				AND e.SectSubStatusID IN(@BusinessClosed_SectSubStatusID,@RecordArchive_SectSubStatusID)
			)
			BEGIN
				-- Temp fix: A new doc attached. PUt in private note. 
				SET @new_PrivNotes = 'The applicant has provided proof of employment. Please see documents.'
				SET @new_PrivNotes =  CONCAT(@new_PrivNotes, ' ', CHAR(13)+CHAR(10), CHAR(13)+CHAR(10), @old_PrivNotes)

				-- add private note
				UPDATE e
				SET e.Priv_Notes = @new_PrivNotes  -- temp fix.
				-- select e.Priv_Notes, * 
				from dbo.Empl e
				where e.OrderId = @orderId

				-- change log
				INSERT INTO dbo.ChangeLog(TableName,ID, OldValue,NewValue,ChangeDate,UserID)
				SELECT 'Empl.Priv_Notes',@emplid, @old_PrivNotes,@new_PrivNotes,GETDATE(), 'SJV'

			END


		END
		

	IF(@WebStatusID IS NOT NULL)
	BEGIN

		UPDATE e SET e.web_status = @WebStatusID
		FROM dbo.Empl e
		WHERE e.OrderId = @orderId

		-- change log
		INSERT INTO dbo.ChangeLog(TableName,ID, OldValue,NewValue,ChangeDate,UserID)
		SELECT 'Empl.web_status',@emplid, @OldValue_WebStatusID,@WebStatusID,GETDATE(), 'SJV'

	END

END

