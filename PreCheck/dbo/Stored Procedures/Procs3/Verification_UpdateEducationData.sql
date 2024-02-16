
--new
create procedure [dbo].[Verification_UpdateEducationData]
(	
	@EducatId int,
	@ReasonForContact varchar(50),
	@MethodOfContact varchar(50),
	@VerifiedByDocument varchar(50)
)
AS
BEGIN 
	
	DECLARE @refMethodOfContactID INT
	DECLARE @refReasonForContactID INT
	DECLARE @apno INT


	SELECT @refMethodOfContactID = mc.refMethodOfContactID
	FROM dbo. refMethodOfContact mc
	WHERE mc.ItemName = @MethodOfContact

	SELECT @refReasonForContactID = rc.refReasonForContactID
	FROM dbo. refReasonForContact rc
	WHERE rc.ItemName = @ReasonForContact

	SET @refMethodOfContactID = ISNULL(@refMethodOfContactID,1) -- default to Email

	IF(@EducatId > 0 AND @refReasonForContactID > 0) 
	BEGIN
		
		SELECT @apno = ac.Apno 
		FROM Educat ac 
		WHERE ac.EducatID = @EducatId

		

		
		IF NOT EXISTS( SELECT 1 FROM ApplicantContact ac WHERE ac.APNO = @apno AND ac.SectionUniqueID = @EducatId)
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
			SELECT @apno, 1, @EducatId,@refMethodOfContactID, @refReasonForContactID,'nsch',GETDATE(),'nsch',null,null
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
			AND ac.SectionUniqueID = @EducatId
		END


	END

	SELECT 1 AS InvDetID -- return TRUE
		
END

