
	CREATE PROCEDURE GetClientNotes
		@clno int, @notesType varchar(13) = NULL 
	AS
	BEGIN
		SET NOCOUNT ON;

		SELECT cn.NoteID, cn.CLNO, cn.NoteType, cn.NoteBy,cn.NoteDate, cn.NoteText 
		FROM dbo.ClientNotes cn 
		WHERE cn.CLNO = @clno AND (@notesType IS NULL OR @notesType = cn.NoteType)
	END
