

-- =============================================
-- Author:		<Najma,Begum>
-- Create date: <07/09/2012>
-- Description:	<Auto Close Applications process>
-- =============================================
-- =============================================
-- Edited By:		Kiran miryala	
-- Edited date: 8/1/2012
-- Description:	 dont know why we are using the substatus id, but Updated SubstatusID with 22, as it was giving error for billing when they are trying to remove passthru charges.
--					need to revisit this again.
-- =============================================
-- =============================================
-- Edited By:	Deepak Vodethela
-- Edited date: 06/16/2020
-- Description:	Do not update OrigCompDate if there is a date already. Added ISNULL() for OrigCompDate
-- Edited By:	Deepak Vodethela
-- Edited date: 07/28/2020
-- Description:	Added conditions to AutoClose ZipCrim reports and applied special handling of adding a delay of 1 hr to ReOpend reports.
-- Edited date: 11/11/2020
-- Description:	Removed the Review Reportability log details for qualifying ZipCrim records 

-- =============================================
CREATE PROCEDURE [dbo].[ApplAutoClose_Finalize_Old] 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	-- Insert statements for procedure here
    DECLARE @ATable AS Table( [APNO] INT, OrigCompDate datetime, EnteredVia varchar(50), ReopenDate datetime);
	insert into @ATable
	Exec [dbo].[ApplAutoClose_GetAppsToClose]

	--select * from @ATable
	--select * into #Temp from @ATable
	declare @Id int
	declare @Orig datetime
	DECLARE @EnteredVia varchar(50), @ReopenDate datetime

	while (Select count(*) from @ATable) > 0
	begin
	select Top 1 @Id = Apno from @ATable;
	select @Orig=OrigCompDate, @EnteredVia = [@ATable].EnteredVia, @ReopenDate = ISNULL(ReopenDate,'01/01/1900') from @ATable where Apno = @Id;
	
	BEGIN TRANSACTION

		IF(@Orig is NULL)
		BEGIN
			update Appl set OrigCompDate = ISNULL(OrigCompDate, getdate()), 
							CompDate = getdate(), ApStatus = 'F',
							SubStatusID = ISNULL(SubStatusID, 22)
						where Apno = @Id;

			exec RunApplFinalLogic @Id;
			insert into ApplAutoCloseLog (Apno,closedOn) values(@Id,getdate());
		END

		-- ZipCrim Process Start
		-- VD:07/22/2020 - for AffiliateID = 249 - Reopens only
		-- Adding a buffer of 1 hr to ReOpened ZipCrim reports to be auto-closed.
		IF (@Orig IS NOT NULL AND @EnteredVia = 'ZipCrim' AND DATEADD(HOUR, 1, @ReopenDate) <= CURRENT_TIMESTAMP)
		BEGIN
			update Appl set CompDate = getdate(),  ApStatus = 'F',
							SubStatusID = ISNULL(SubStatusID, 22)
						where Apno = @Id;
	
			exec RunApplFinalLogic @Id;
			insert into ApplAutoCloseLog (Apno,closedOn) values(@Id,getdate());			
		END
		-- ZipCrim Process End

			delete from @ATable where Apno = @Id;
	
		IF (@@Error<>0)
	BEGIN
		RollBack Transaction
		Return (-@@Error)
	END
	ELSE
		Commit Transaction
	end

	-- Temp area for the onhold Report processing to execute 9/12015 kiran
	Exec  Win_Service_OnHold_ReportProcessing

END


