
CREATE procedure [dbo].[Verification_UpdateEmploymentData]
(	
	@EmplId int,
	@ReasonForContact varchar(50),
	@MethodOfContact varchar(50),
	@VerifiedByDocument varchar(50)
)
AS
BEGIN 
	
	DECLARE @refMethodOfContactID INT
	DECLARE @refReasonForContactID INT
	DECLARE @apno INT

	Declare @old_PrivNotes varchar(max)
	Declare @new_PrivNotes varchar(max)

	SELECT @refMethodOfContactID = mc.refMethodOfContactID
	FROM dbo. refMethodOfContact mc
	WHERE mc.ItemName = @MethodOfContact

	SELECT @refReasonForContactID = rc.refReasonForContactID
	FROM dbo. refReasonForContact rc
	WHERE rc.ItemName = @ReasonForContact

	SET @refMethodOfContactID = ISNULL(@refMethodOfContactID,1) -- default to Email

	IF(@EmplId > 0 AND @refReasonForContactID > 0) 
	BEGIN
		
		SELECT @apno = ac.Apno,
				@old_PrivNotes = ac.Priv_Notes
		FROM Empl ac 
		WHERE ac.EmplID = @EmplId

		

		
		IF NOT EXISTS( SELECT 1 FROM ApplicantContact ac WHERE ac.APNO = @apno AND ac.SectionUniqueID = @EmplId)
		BEGIN
			-- if not exist 
			INSERT INTO [dbo].[ApplicantContact]
			   ([APNO]
			   ,[ApplSectionID]
			   ,[SectionUniqueID]
			   ,[refMethodOfContactID]
			   ,[refReasonForContactID]
			   ,[Investigator]
			   ,[CreateDate]
			   ,[CreateBy]
			   ,[ModifyDate]
			   ,[ModifyBy])
			SELECT @apno, 1, @EmplId,@refMethodOfContactID, @refReasonForContactID,'sjv',GETDATE(),'sjv',null,null
		END
		ELSE
		BEGIN
			-- if exist update
			UPDATE ac
			SET ac.refMethodOfContactID = @refMethodOfContactID,
				ac.refReasonForContactID = @refReasonForContactID
			-- select *
			from ApplicantContact ac
			WHERE ac.APNO = @apno
			AND ac.SectionUniqueID = @EmplId
		END

		-- Update private note

		SET @new_PrivNotes = 'Applicant Contacted: Yes' + CHAR(13)+CHAR(10) 
							 + 'Method of Contact: Email' + CHAR(13)+CHAR(10)  -- Method of Contact is always Email.
							 + 'Reason for Contact: ' + @ReasonForContact + CHAR(13)+CHAR(10) 
		SET @new_PrivNotes =  CONCAT(@new_PrivNotes, CHAR(13)+CHAR(10), @old_PrivNotes) 

		-- add private note
		UPDATE e
		SET e.Priv_Notes = SUBSTRING(@new_PrivNotes, 1, 8000) -- max is 8000
		FROM Empl e 
		WHERE e.EmplID = @EmplId

		-- change log
		INSERT INTO dbo.ChangeLog(TableName,ID, OldValue,NewValue,ChangeDate,UserID)
		SELECT 'Empl.Priv_Notes',@EmplId, @old_PrivNotes,
		SUBSTRING(@new_PrivNotes, 1, 8000), -- max is 8000
		--@new_PrivNotes,
		GETDATE(), 'SJV'


	END

	SELECT 1 AS InvDetID -- return TRUE
		
END

