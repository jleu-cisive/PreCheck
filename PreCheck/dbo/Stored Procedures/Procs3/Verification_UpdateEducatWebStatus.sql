
--new
-- Verification_UpdateEducatWebStatus '38578900','CallAttempted','1'
create procedure [dbo].[Verification_UpdateEducatWebStatus] 
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
	DECLARE @EducatID INT

	Declare @old_PrivNotes varchar(max)
	Declare @new_PrivNotes varchar(max)

	Declare @old_PublicNotes varchar(max)
	Declare @new_PublicNotes varchar(max)

	DECLARE @BusinessClosed_SectSubStatusID INT
	DECLARE @RecordArchive_SectSubStatusID INT

	
	
	DECLARE @FollowupOnDate Date
		

	SELECT  @old_PublicNotes = e.Pub_Notes,
			@old_PrivNotes = e.Priv_Notes,
			@APNO = e.Apno,
			@EducatID = e.EducatId,
			@old_SectStat = e.SectStat
	FROM dbo.Educat e
	where e.OrderId = @orderId

	-- Remove follow up if auto close.
	IF(@old_SectStat = '4' OR @old_SectStat = 'U') -- Is closed with Verified or UnVerified.
	BEGIN
		UPDATE af
		SET af.CompletedBy = 'NSCH', af.CompletedOn = GETDATE(), af.IsCompleted = 1
		FROM dbo.ApplSections_Followup af 
		WHERE af.ApplSectionID = @EducatID
		and af.Apno = @APNO
		AND af.CompletedBy IS NULL
		AND af.IsCompleted = 0
	END
		
	IF(@updateType = 'CallAttempted')
	BEGIN
		
		SELECT @WebStatusID = w.code
		FROM dbo.Websectstat w 
		WHERE w.[description] = 'Reference Call ' + @typeValue  --?? is this correct for education

	END
	--ELSE IF(@updateType = 'TALXReceived' OR @updateType = 'TALXOrdered_NoRecord')
	--BEGIN
	--	IF(@updateType = 'TALXReceived' AND ISNULL(@old_SectStat,0) <> '9')  -- not 9	PENDING
	--	BEGIN
	--		SELECT @WebStatusID = w.code
	--		FROM dbo.Websectstat w 
	--		WHERE w.[description] = 'TALX Review'
	--	END

		
	--	Declare @typeValueDate Date = GETDATE()
	--	IF(ISDATE(@typeValue) = 1)
	--	BEGIN
	--		SET @typeValueDate = CAST(@typeValue as date)
	--	END
	--	ELSE
	--	BEGIN
	--		SET @typeValueDate =  CAST(REPLACE(@typeValue, '-22', '-' + Convert(varchar(20),(RIGHT(@typeValue,2) + 2000)))as date)
	--	END


	--	IF EXISTS(select 1 from dbo.TALXINFO t WHERE t.APNO = @APNO)
	--	BEGIN
	--		DECLARE @OldValue datetime
	--		SELECT @OldValue = t.TALXOrderedDate 
	--		from dbo.TALXINFO t 
	--		WHERE t.APNO = @APNO
			

	--		UPDATE t
	--		SET t.TALXOrderedDate = @typeValueDate
	--		from dbo.TALXINFO t WHERE t.APNO = @APNO

	--		-- change log
	--		INSERT INTO dbo.ChangeLog(TableName,ID, OldValue,NewValue,ChangeDate,UserID)
	--		SELECT 'TALXINFO.TALXOrderedDate',@APNO, @OldValue,@typeValue,GETDATE(), 'NSCH'

	--		SET @new_PrivNotes = 'The work number has been ran for this SSN on a separate report. Please see documents.'
	--		SET @new_PrivNotes =  CONCAT(@new_PrivNotes, ' [TALXOrdered:', @typeValue, '] ', CHAR(13)+CHAR(10), CHAR(13)+CHAR(10), @old_PrivNotes)

	--	END
	--	ELSE
	--	BEGIN
	--		INSERT INTO dbo.TALXINFO(APNO, TALXOrderedDate,CreatedDate, CreatedBy)
	--		VALUES(@APNO,@typeValueDate,GETDATE(),'NSCH')

	--		SET @new_PrivNotes = 'Alert a work number has been ran for this report, please review the TALX document for review. DO NOT Run Work Number'
	--		SET @new_PrivNotes =  CONCAT(@new_PrivNotes, ' [TALXOrdered:', @typeValue, '] ', CHAR(13)+CHAR(10), @old_PrivNotes)

	--	END


	--	-- add private note
	--	UPDATE e
	--	SET e.Priv_Notes = @new_PrivNotes
	--	from dbo.Educat e
	--	where e.OrderId = @orderId

	--	-- change log
	--	INSERT INTO dbo.ChangeLog(TableName,ID, OldValue,NewValue,ChangeDate,UserID)
	--	SELECT 'Educat.Priv_Notes',@EducatID, @old_PrivNotes,@new_PrivNotes,GETDATE(), 'NSCH'


	--END
	--ELSE IF(@updateType = 'ProofReceived')
	--	BEGIN

	--		SELECT @RecordArchive_SectSubStatusID = s.SectSubStatusID
	--		FROM dbo.SectSubStatus s
	--		WHERE s.SectSubStatus = 'Records No Longer Available'
	--		AND s.ApplSectionID = 1

	--		SELECT @BusinessClosed_SectSubStatusID = s.SectSubStatusID
	--		FROM dbo.SectSubStatus s
	--		WHERE s.SectSubStatus = 'Business Closed'
	--		AND s.ApplSectionID = 1

	--		-- If Auto Closed
	--		IF EXISTS(Select 1
	--			FROM dbo.Educat e
	--			WHERE e.EducatID = @EducatID
	--			AND e.SectSubStatusID IN(@BusinessClosed_SectSubStatusID,@RecordArchive_SectSubStatusID)
	--		)
	--		BEGIN
	--			-- Temp fix: A new doc attached. PUt in private note. 
	--			SET @new_PrivNotes = 'The applicant has provided proof of employment. Please see documents.'
	--			SET @new_PrivNotes =  CONCAT(@new_PrivNotes, ' ', CHAR(13)+CHAR(10), CHAR(13)+CHAR(10), @old_PrivNotes)

	--			-- add private note
	--			UPDATE e
	--			SET e.Priv_Notes = @new_PrivNotes  -- temp fix.
	--			-- select e.Priv_Notes, * 
	--			from dbo.Educat e
	--			where e.OrderId = @orderId

	--			-- change log
	--			INSERT INTO dbo.ChangeLog(TableName,ID, OldValue,NewValue,ChangeDate,UserID)
	--			SELECT 'Educat.Priv_Notes',@EducatID, @old_PrivNotes,@new_PrivNotes,GETDATE(), 'NSCH'

	--		END


	--	END
		

	IF(@WebStatusID IS NOT NULL)
	BEGIN

		UPDATE e SET e.web_status = @WebStatusID
		FROM dbo.Educat e
		WHERE e.OrderId = @orderId

		-- change log
		INSERT INTO dbo.ChangeLog(TableName,ID, OldValue,NewValue,ChangeDate,UserID)
		SELECT 'Educat.web_status',@EducatID, @OldValue_WebStatusID,@WebStatusID,GETDATE(), 'NSCH'

	END

END


