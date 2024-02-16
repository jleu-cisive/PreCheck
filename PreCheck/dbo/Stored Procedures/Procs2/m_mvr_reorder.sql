CREATE procedure [dbo].[m_mvr_reorder] 
(
	@apno int,@UserName varchar(10) = null,@UpdateReleaseSent bit = 0
)

as 

if @UpdateReleaseSent = 0
	BEGIN
		update dl set sectstat = '9',web_status = null,dateordered = null,report = null ,last_updated=Current_TimeStamp
		where apno = @apno

		INSERT INTO [dbo].[DLActivityLog]
				   ([APNO]
				   ,[UserName]
				   ,[Status]
				   ,[ChangeDate]
				   ,[ReOrdered])
			 VALUES
				   (@apno
				   ,@UserName
				   ,'9'
				   ,Current_TimeStamp
				   ,1)
	END
ELSE
	BEGIN
		update DBO.DL set IsReleaseNeeded = 0,web_status = null, last_Updated = Current_TimeStamp where APNO = @apno
		
		INSERT INTO [dbo].[DLActivityLog]
				   ([APNO]
				   ,[UserName]
				   ,[Status]
				   ,[ChangeDate]
				   ,ReleaseSent)
			 VALUES
				   (@apno
				   ,@UserName
				   ,'9'
				   ,Current_TimeStamp
				   ,1)	
	END
	