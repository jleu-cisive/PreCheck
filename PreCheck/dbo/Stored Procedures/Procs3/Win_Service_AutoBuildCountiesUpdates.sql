
-- =============================================
-- Author:		Najma Begum
-- Create date: 06/19/2012
-- Description:	Get NeedsReview & inuse status of appl table after 
--              completion of CountyAliasesAutomation
-- Update: Added the missing check of 'AUTO';
-- =============================================
CREATE PROCEDURE [dbo].[Win_Service_AutoBuildCountiesUpdates]
	-- Add the parameters for the stored procedure here
	@apno int = 0, @NeedsReview varchar(1), @StartStatus varchar(8),@WhereStatus varchar(8)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

Exec Win_Service_AutoOrderStatusUpdate @apno,@NeedsReview, @StartStatus, @WhereStatus
Declare @notes varchar(150);
IF (EXISTS (SELECT * FROM dbo.Appl WHERE Apno=@Apno and Investigator = 'AUTO'))
	SET @notes = Convert(varchar(30),getdate()) + ' : The positiveID is a rerun and investigator is reset.' + CHAR(10);
ELSE
	SET @notes = Convert(varchar(30),getdate()) + ' : The positiveID is a rerun.' + CHAR(10);

Update dbo.Appl set priv_notes =   @notes + Convert(varchar(MAX),priv_notes) where apno = @apno
Update dbo.Appl set Investigator = '' where apno = @apno and Investigator = 'AUTO'

END


