-- =============================================
-- Author:		Douglas DeGenaro
-- Create date: 06/25/2013
-- Description:	Upserts into AppClientData
-- =============================================
CREATE PROCEDURE [dbo].[PrecheckFramework_UpsertApplClientData] 
	-- Add the parameters for the stored procedure here
	@CustomData XML = null, 
	@Clno int,
	@ClientApNo varchar(50),
	@OCHS_CandidateInfoID int = null,
	@Apno int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;

	declare @currDate datetime

	set @currDate = getdate()

	if(isnull(@OCHS_CandidateInfoID,0) > 0)

	Begin
	if (select count(1) from dbo.ApplClientData where apno = @apno) > 0
		Update dbo.ApplClientData 
		SET 
			XMLD = @CustomData,
			Updated = @currDate,
			OCHS_CandidateInfoID = @OCHS_CandidateInfoID
		WHERE 
			apno = @Apno
    else
		INSERT INTO dbo.ApplClientData(
				APNO,
				CLNO,
				XMLD,
				OCHS_CandidateInfoID,
				Updated) 
			VALUES(
				@Apno,
				@Clno,
				@CustomData,
				@OCHS_CandidateInfoID,
				@currDate)
	End

	if (select count(1) from dbo.ApplClientData where apno = @apno) > 0
		Update dbo.ApplClientData 
		SET 
			XMLD = @CustomData,
			CLNO = @Clno,
			ClientAPNO = @ClientApNo,
			Updated = @currDate
			
		WHERE 
			apno = @Apno
	else
		INSERT INTO dbo.ApplClientData(
			APNO,
			CLNO,
			ClientAPNO,
			XMLD,
			Updated) 
		VALUES(
			@Apno,
			@Clno,
			@ClientApNo,
			@CustomData,
		    @currDate)

			
END
