
CREATE PROCEDURE [dbo].[InUse_Lock]
(
	@RecordType varchar(15)
	, @PrimaryKeyID int
	, @Investigator varchar(8)
)
AS
SET NOCOUNT ON

IF @RecordType = 'Appl'
BEGIN
	DECLARE @InUseBy Varchar(8)

	SELECT @InUseBy = Inuse	 FROM dbo.Appl WHERE Appl.[APNO] = @PrimaryKeyID 

	IF (@InUseBy != @Investigator) 
		BEGIN
			UPDATE dbo.Appl SET InUse = @Investigator 
			WHERE APNO = @PrimaryKeyID AND InUse IS NULL 
				AND ApStatus = 'P' 
				--AND (SELECT MainStatusID FROM dbo.SubStatus WHERE dbo.SubStatus.SubStatusID = dbo.Appl.SubStatusID) = 3
			IF @@ROWCOUNT <> 0
				SELECT @PrimaryKeyID AS PrimaryKeyID
			ELSE
				SELECT '' AS PrimaryKeyID
		END
	ELSE
		SELECT @PrimaryKeyID AS PrimaryKeyID
	

	DELETE FROM dbo.WorkBin WHERE APNO = @PrimaryKeyID AND UserID = @Investigator
	
END

SET NOCOUNT OFF