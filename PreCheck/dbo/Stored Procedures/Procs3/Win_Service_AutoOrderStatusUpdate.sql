-- =============================================
-- Author:		Najma Begum
-- Create date: 06/19/2012
-- Description:	Get NeedsReview & inuse status of appl table after 
--              completion of CountyAliasesAutomation
-- =============================================
CREATE PROCEDURE [dbo].[Win_Service_AutoOrderStatusUpdate]
	-- Add the parameters for the stored procedure here
	@apno int = 0, @NeedsReview varchar(1), @StartStatus varchar(8),@WhereStatus varchar(8)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--Update Appl set NeedsReview = substring(NeedsReview,1,1) + '5', inuse = NULL
--where apno = @apno and EnteredVia = 'StuWeb'and inuse='CNTY_W';
if(@apno = 0)
BEGIN
	Update dbo.Appl set NeedsReview = substring(NeedsReview,1,1) + @NeedsReview, inuse = @StartStatus
	where inuse=@WhereStatus;
	--where EnteredVia = 'StuWeb'and inuse=@WhereStatus;
END
Else
Begin
	if(@WhereStatus is NULL)
	BEGIN
		Update dbo.Appl set NeedsReview = substring(NeedsReview,1,1) + @NeedsReview, inuse = @StartStatus
		--where apno = @apno and EnteredVia = 'StuWeb'and inuse is NULL;
		where apno = @apno and inuse is NULL;
	END
	else
	Begin
		Update dbo.Appl set NeedsReview = substring(NeedsReview,1,1) + @NeedsReview, inuse = @StartStatus
		--where apno = @apno and EnteredVia = 'StuWeb'and inuse=@WhereStatus;
		where apno = @apno and inuse=@WhereStatus;
	End
	END
END


-- This is a temporary fix for the issue described : The Client#14131 is unique and they are not processing any criminal searches besides the Sex Offender.
-- This functionality is does non exist in the current ApplPreprocessor. When ever it finds Client record count is set to "0" and finds any counties, then it puts into ApplCountiesExceptionLog

DECLARE @Clno int

IF (@NeedsReview = '3' AND @WhereStatus = 'CNTY_W')
BEGIN
	SELECT @Clno = CLNO FROM Appl(NOLOCK) WHERE Apno = @apno

	IF (@Clno = 14131)
	BEGIN
		UPDATE Appl
			SET Investigator = 'AUTO'
		WHERE APNO = @apno
	END
END
