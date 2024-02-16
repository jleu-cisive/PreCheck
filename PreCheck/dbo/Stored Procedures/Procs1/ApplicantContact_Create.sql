
CREATE PROCEDURE [dbo].[ApplicantContact_Create]
	@APNO INT, @SectionUniqueID INT, @ApplSectionID INT, @Investigator VARCHAR(50), @refMethodOfContactID INT, @refReasonForContactID INT
AS
	SET NOCOUNT ON;

	DECLARE @ID INT, @NewNote VARCHAR(200);
	INSERT INTO ApplicantContact(APNO, SectionUniqueID, ApplSectionID, Investigator, refMethodOfContactID, refReasonForContactID,CreateBy)
		VALUES(@APNO, @SectionUniqueID, @ApplSectionID, @Investigator, @refMethodOfContactID, @refReasonForContactID, @Investigator)

	SELECT @ID = @@IDENTITY;

	SELECT @NewNote = CONCAT(FORMAT(ac.CreateDate, 'HH:MM'), ' ', FORMAT(ac.CreateDate, 'MM/dd/yyyy'), ' ', 'Applicant Contact, ', rmc.ItemName, ', ', rrc.ItemName, ', ', ac.Investigator) 
	FROM ApplicantContact as ac with (nolock)
		inner join refMethodOfContact as rmc with (nolock) on rmc.refMethodOfContactID =ac.refMethodOfContactID
		inner join refReasonForContact as rrc with (nolock) on rrc.refReasonForContactID = ac.refReasonForContactID
	WHERE ac.ApplicantContactID = @ID;

	IF @ApplSectionID = 1
		BEGIN
			UPDATE Empl
				SET Priv_Notes = CONCAT(@NewNote, CHAR(13), CHAR(13), Priv_Notes)
			WHERE EmplID = @SectionUniqueID
		END;
	IF @ApplSectionID = 2
		BEGIN
			UPDATE Educat
				SET Priv_Notes = CONCAT(@NewNote, CHAR(13), CHAR(13), Priv_Notes)
			WHERE EducatID = @SectionUniqueID
		END;
	IF @ApplSectionID = 3
		BEGIN
			UPDATE PersRef
				SET Priv_Notes = CONCAT(@NewNote, CHAR(13), CHAR(13), Priv_Notes)
			WHERE PersRefID = @SectionUniqueID
		END;
	IF @ApplSectionID = 4 
		BEGIN
			UPDATE ProfLic
				SET Priv_Notes = CONCAT(@NewNote, CHAR(13), CHAR(13), Priv_Notes)
			WHERE ProfLicID = @SectionUniqueID
		END;
