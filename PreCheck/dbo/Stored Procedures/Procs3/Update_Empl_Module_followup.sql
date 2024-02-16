
-- =============================================
-- Author:		Larry / Deepak / Santosh
-- Create date: 10/07/2015
-- Description:	Inserts data into dbo.AppSections_Followup table and determines the followupdate using the dbo.AddWorkDays function.
--
-- Modified : Deepak
-- Date		: 11/05/2015
-- Description: a.) Updates dbo.EmplGetNextStaging table.
--				b.) Updates dbo.Empl
--				c.) Added Conditions for updates and etc
-- =============================================
Create PROCEDURE [dbo].[Update_Empl_Module_followup] 
(
	@apno int,
    @emplid int,
	@sectstat char(1),
	@webstatus int,
    @t_followupinterval int,
    @investigator varchar(8),
	@FollowupDate DateTime = Null
)
AS

SET NOCOUNT ON 

DECLARE @followupNeededDate AS DATETIME



IF @FollowupDate is null
	BEGIN
		If @webstatus = 89
			BEGIN
				SET @followupNeededDate = Cast((dbo.DatePart([dbo].[AddWorkDays](1,Current_TimeStamp)) + ' 9:30 AM') AS datetime)
				SET @t_followupinterval = 0
			END
		else IF @t_followupinterval = 1
			Set @followupNeededDate = DATEADD (MINUTE , 15 , Current_TimeStamp)
		else if @t_followupinterval = 2
			Set @followupNeededDate = DATEADD (MINUTE , 30 , Current_TimeStamp)
		else if @t_followupinterval = 3
			Set @followupNeededDate = DATEADD (MINUTE , 60 , Current_TimeStamp)
		else if @t_followupinterval = 4
			Set @followupNeededDate = DATEADD (HOUR , 4 , Current_TimeStamp)
		else if @t_followupinterval = 5
			Set @followupNeededDate = DATEADD (HOUR , 6 , Current_TimeStamp)
		else if @t_followupinterval = 6
			Set @followupNeededDate = DATEADD (HOUR , 18 , Current_TimeStamp)
		else if @t_followupinterval = 7
			Set @followupNeededDate = DATEADD (HOUR , 30 , Current_TimeStamp)
		else if @t_followupinterval = 8
			set @followupNeededDate = [dbo].[AddWorkDays](1,Current_TimeStamp)
		else if @t_followupinterval = 9
			set @followupNeededDate = [dbo].[AddWorkDays](2,Current_TimeStamp)
		else if @t_followupinterval = 10
			set @followupNeededDate = [dbo].[AddWorkDays](3,Current_TimeStamp)
		else if @t_followupinterval = 11
			set @followupNeededDate = [dbo].[AddWorkDays](4,Current_TimeStamp)
		else if @t_followupinterval = 12
			set @followupNeededDate = [dbo].[AddWorkDays](5,Current_TimeStamp)
		else if @t_followupinterval = 13
			set @followupNeededDate = [dbo].[AddWorkDays](6,Current_TimeStamp)
		else if @t_followupinterval = 14
			set @followupNeededDate = [dbo].[AddWorkDays](7,Current_TimeStamp)
		else if @t_followupinterval = 15
			set @followupNeededDate = [dbo].[AddWorkDays](14,Current_TimeStamp)
		else if @t_followupinterval = 16
			set @followupNeededDate = [dbo].[AddWorkDays](21,Current_TimeStamp)
	END
else
	SET @followupNeededDate = @FollowupDate


	-- Follow-UP Web_Status
	IF @webstatus in (74,89)
		BEGIN	

			-- Update dbo.ApplSections_Followup table
			UPDATE dbo.ApplSections_Followup 
				SET Repeat_Followup = 1,
					CompletedBy = @investigator,
					CompletedOn = GETDATE() 
				WHERE ApplSectionID = @emplid 
				  AND Apno = @apno 
				  AND Repeat_Followup = 0

			-- Insert INTO ApplSections_Followup
			INSERT INTO dbo.ApplSections_Followup (
				ApplSectionID,
				Apno,
				SectionID,
				Reason,
				CreatedBy,
				CreatedOn,
				FollowupOn,
				--CompletedBy,
				--CompletedOn,
				IsCompleted,
				Repeat_Followup)
			Values(
				@emplid,
				@apno,
				'empl',
				'Follow-up Interval',
				@investigator,
				CURRENT_TIMESTAMP,
				@followupNeededDate,
				--@investigator,
				-- getdate(),
				0,
				0)

	
		END
    ELSE
		BEGIN
			UPDATE dbo.ApplSections_Followup 
				SET IsCompleted = 1,
					CompletedBy = @investigator,
					CompletedOn = CURRENT_TIMESTAMP 
				WHERE ApplSectionID = @emplid 
				  AND Apno = @apno 
				  AND Repeat_Followup = 0
		END





