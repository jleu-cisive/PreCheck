
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
CREATE PROCEDURE [dbo].[VerificationGetNext_WebStatus_Updates] 
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
		IF @t_followupinterval = 1
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

			INSERT INTO dbo.getNextAudit 
			SELECT @Apno, @EmplID, '@t_followupinterval : ' + cast(@t_followupinterval as varchar), '@followupNeededDate : ' +  cast(@followupNeededDate as varchar),GETDATE(),@investigator

			IF @webstatus = 89
					-- Update Staging table's FollowUp date
					UPDATE dbo.EmplGetNextStaging
						SET FollowUpOn = @followupNeededDate,
							Investigator = null,
							[web_status] = case when isnull([web_status],0) = 0 then 89 ELSE [web_status] END
						WHERE APNO = @apno
						  AND EmplID = @emplid
			Else
				-- Update Staging table's FollowUp date
				UPDATE dbo.EmplGetNextStaging
					SET FollowUpOn = @followupNeededDate,
						Investigator = @investigator,
						web_status = @webstatus,
						SectStat = @sectstat
					WHERE APNO = @apno
					  AND EmplID = @emplid	
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

	-- WebStatus list for ReRouting
	-- Overseas - 57 / ThirdParty - 76 / EmpCheck - 78 / Nevada -  etc
	IF (@webstatus IN (57, 76, 78,  80,87))
		BEGIN

			-- Update Staging table's TranistionalStatus with approprite Web_Status
			UPDATE dbo.EmplGetNextStaging
				SET TransitionalState = 'ReRouting',
					web_status = @webstatus,
					SectStat = @sectstat
					--AppPickedUpDate = NULL,
					--Investigator = NULL
				WHERE APNO = @apno
				  AND EmplID = @emplid

			-- Update the Empl Table's investigators column to the ReRouting WebStatus such that it can be available in the respective module
			UPDATE dbo.Empl 
				SET Investigator = (SELECT left(Description,8) From Websectstat Where code = @webstatus),
					Last_Updated = GETDATE(),
					web_status = @webstatus
				WHERE APNO = @apno
				  AND EmplID = @emplid
		END
	ELSE IF @webstatus in (79,81, 82, 83, 84, 85)
			-- Update Staging table's TranistionalStatus with approprite Web_Status
			UPDATE dbo.EmplGetNextStaging
				SET web_status = @webstatus,
					SectStat = @sectstat
				WHERE APNO = @apno
				  AND EmplID = @emplid
	ELSE IF  @webstatus not in (74,89)
		BEGIN

			-- Update Staging table's TranistionalStatus marking it as Saved and Completed
			UPDATE dbo.EmplGetNextStaging
				SET TransitionalState = 'Completed',
					web_status = @webstatus,
					SectStat = @sectstat
				WHERE APNO = @apno
				  AND EmplID = @emplid		
		END




