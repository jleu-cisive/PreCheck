/***************************************************************/
--Modified by AmyLiu on 04/28/2020: Project:IntranetModule-Status-Substatus
--Modified by AmyLiu on 08/21/2020: Fix 53508: public note was not logged into log table
/****************************************************************/
CREATE PROCEDURE [dbo].[Update_PersRef_Module]
      @Apno int,
      @PersrefID int,
      @User_ID char(8),
      @sectstat char(1),
	  @sectSubStatusID int,  --Amyliu added on 02/25/2020
      @name varchar(20),
      @phone varchar(20),
      @rel_v varchar(20),
      @years_v varchar(20),
	  @Email varchar(50),
      @priv_notes text,
      @pub_notes text,
      @web_status int,
      @IsCamReview bit,
      @Last_Worked datetime
   
as
  set nocount on
	if (@sectSubStatusID=0) set @sectSubStatusID= null  ---AmyLiu added to allow NULL value inserted into SectSubStatus column as I don't want to chage code with parameter varibles for existing code.
 Declare @OldValue as varchar(8), @oldPrivateNotes varchar(8000),@OldPublicNotes varchar(8000), --added by radhika dereddy on 05/13/2014 - Dana's request
 @Old_Last_Worked datetime, @OldWebStatValue as varchar(8) --added by radhika dereddy on 07/24/2014 to be similar to (Update_Educat_Module)Educat, Empl and Lic stored Procedures
 ,@OldReopenDate datetime, @NewReopenDate datetime  --Added by Radhika Dereddy on 01/02/2020 for Reopen Date for Modules
 ,@OldSectSubStatusID int --AmyLiu added on 02/25/2020


select @OldValue = SectStat, @oldPrivateNotes = cast(Priv_Notes as varchar(8000)), @OldPublicNotes = cast(Pub_Notes  as varchar(8000)), @Old_Last_Worked = Last_Worked, @OldWebStatValue = web_status
	  ,@OldSectSubStatusID= SectSubStatusID  --AmyLiu added on 02/25/2020
 from PersRef where APNO = @Apno and PersRefID = @PersRefID 


--added Apstatus code by Radhika dereddy on 07/24/2014
UPDATE DBO.APPL Set InUse = @User_ID  -- added by radhika dereddy on 07/24/2014
Where APNO = @Apno

if ((Select apstatus from dbo.appl where apno  = @Apno) = 'F') 
BEGIN

	--Get Existing ReopenDate from Appl Table Added by Radhika Dereddy on 01/02/2020
	SELECT @OldReopenDate = ReopenDate FROM APPL WHERE APNO = @APNO 

	UPDATE DBO.APPL Set ApStatus = 'P',last_updated = current_timestamp, ReopenDate = current_timestamp --added ReopenDate by Radhika Dereddy on 07/24/2014
	Where APNO = @Apno

	--Get Updated ReopenDate from Appl Table Added by Radhika Dereddy on 01/02/2020
	SELECT @NewReopenDate = ReopenDate FROM APPL WHERE APNO = @Apno

	INSERT INTO [dbo].[ChangeLog]
           ([TableName]
           ,[ID]
           ,[OldValue]
           ,[NewValue]
           ,[ChangeDate]
           ,[UserID])
     VALUES
           ('appl.apstatus'
           ,@Apno
           ,'F'
           ,'P'
           ,current_timestamp
           ,@User_ID + '-PersRef')


	-- Added by Radhika Dereddy to log the Reopen date and the User From module on 01/02/2020 CR682
	INSERT INTO [dbo].[ChangeLog]
			   ([TableName]
			   ,[ID]
			   ,[OldValue]
			   ,[NewValue]
			   ,[ChangeDate]
			   ,[UserID])
	 VALUES
			   ('appl.ReopenDate'
			   ,@Apno
			   ,@OldReopenDate
			   ,@NewReopenDate
			   ,current_timestamp
			   ,@User_ID + '-PersRef')

END

if (@sectstat <> @OldValue)
Begin
INSERT INTO [dbo].[ChangeLog]
           ([TableName]
           ,[ID]
           ,[OldValue]
           ,[NewValue]
           ,[ChangeDate]
           ,[UserID])
     VALUES
           ('PersRef.SectStat'
           ,@PersRefID
           ,@OldValue
           ,@sectstat
           ,@Last_Worked
           ,@User_ID)
END
	IF (isnull(@sectSubStatusID,0) <> isnull(@OldSectSubStatusID,0))  --AmyLiu added on 02/25/2020
	BEGIN
	INSERT INTO [dbo].[ChangeLog]
			   ([TableName]
			   ,[ID]
			   ,[OldValue]
			   ,[NewValue]
			   ,[ChangeDate]
			   ,[UserID])
		 VALUES
			   ('PersRef.SectSubStat'
			   ,@PersRefID
			   ,@OldSectSubStatusID
			   , cast(@sectSubStatusID as varchar)
			   ,@Last_Worked
			   ,@User_ID )
	END

--Added by Radhika Dereddy on 07/24/2014 
if (@web_status <> @OldWebStatValue)
Begin
INSERT INTO [dbo].[ChangeLog]
           ([TableName]
           ,[ID]
           ,[OldValue]
           ,[NewValue]
           ,[ChangeDate]
           ,[UserID])
     VALUES
           ('PersRef.web_status'
           ,@PersRefID
           ,@OldWebStatValue
           ,@web_status
           ,@Last_Worked
           ,@User_ID)
End


---- Added the below change for updating Private Notes
----added by radhika dereddy on 05/13/2014 - Dana's request

if (cast(@priv_notes as varchar(8000)) <> isnull(@oldPrivateNotes,''))
Begin
INSERT INTO [dbo].[ChangeLog]
           ([TableName]
           ,[ID]
           ,[OldValue]
           ,[NewValue]
           ,[ChangeDate]
           ,[UserID])
     VALUES
           ('PersRef.priv_notes'
           ,@PersRefID
           ,@oldPrivateNotes
           ,cast(@priv_notes as varchar(8000))
           ,@Last_Worked
           ,@User_ID)
--end
End


---- Added the below change for updating web status.
----added by radhika dereddy on 05/13/2014 - Dana's request

if (cast(@pub_notes as varchar(8000)) <> isnull(@OldPublicNotes,''))
Begin
INSERT INTO [dbo].[ChangeLog]
           ([TableName]
           ,[ID]
           ,[OldValue]
           ,[NewValue]
           ,[ChangeDate]
           ,[UserID])
     VALUES
           ('PersRef.pub_notes'
           ,@PersRefID
           ,@OldPublicNotes
           ,cast(@pub_notes as varchar(8000))
           ,@Last_Worked
           ,@User_ID)
--end
End


Update PersRef
 SET 
      sectstat = @sectstat,
	  [SectSubStatusID] = @sectSubStatusID,    ---AmyLiu added on 02/25/2020
      [name] = @name,
      phone = @phone,
      rel_v = @rel_v,
      years_v = @years_v,
	  Email = @Email,
      priv_notes = @priv_notes,
      pub_notes = @pub_notes,
      web_status = @web_status,
      IsCamReview = @IsCamReview,
      Last_Worked = @Last_Worked
where APNO = @Apno and
	  PersRefID = @PersRefID 




UPDATE DBO.APPL Set InUse = null
Where APNO = @Apno


