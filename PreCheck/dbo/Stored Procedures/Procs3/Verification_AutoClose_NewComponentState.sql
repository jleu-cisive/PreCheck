
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Description: Set SectSubStatusID in Empl table.
-- exec [dbo].[Verification_AutoClose] 7000930,'U',0,null,14,''
-- =============================================

CREATE PROCEDURE [dbo].[Verification_AutoClose_NewComponentState]
	@emplid int,
	@precheckSectStatus char,
	@precheckWebstatus int,
	@resultFound varchar(100) = null,
	@publicNotesId int=null

AS
BEGIN
	DECLARE @IsSuccess BIT=0;
	
	IF(@emplid>0)
	BEGIN
		
			IF EXISTS(SELECT TOP 1 1 FROM [dbo].[Empl] WHERE EmplID=@emplid)
			BEGIN
				DECLARE @CLNO INT;
				SELECT TOP 1 @CLNO=a.CLNO from [dbo].[Empl] e join [dbo].[Appl] a on e.Apno=a.APNO where e.EmplID=@emplid;
				PRINT @CLNO;

				DECLARE @ExistingPublicNotes NVARCHAR(MAX)=NULL;
				DECLARE @SectStatus CHAR;
				DECLARE @WebStatus INT;
				DECLARE @SectSubStatusID int =NULL; --Default if client not exist
				DECLARE @Old_Pub_Notes NVARCHAR(MAX)=NULL;
				DECLARE @Old_SectStatus CHAR;
				DECLARE @Old_WebStatus INT;
				DECLARE @Old_SectSubStatusID INT;

				SELECT TOP 1 @ExistingPublicNotes= [Pub_Notes],@SectStatus= [SectStat], @WebStatus =[web_status], @SectSubStatusID=SectSubStatusID from [dbo].[Empl] WHERE EmplID=@emplid;

				--Set the old variables for change logs
				SET @Old_Pub_Notes=@ExistingPublicNotes;
				SET @Old_SectStatus=@SectStatus;
				SET @Old_WebStatus=@WebStatus;
				SET @Old_SectSubStatusID = @SectSubStatusID;

				SET @ExistingPublicNotes = ISNULL(@ExistingPublicNotes,'')

				IF (@CLNO>0)
				BEGIN

					----Update Public Note
					--DECLARE @NewPublicNotes NVARCHAR(MAX)=NULL;
					--SELECT @NewPublicNotes=[Text] 
					--FROM [dbo].[VerificationsNotes] 
					--WHERE [VerificationsNotesId]=@publicNotesId;

					

					--IF(ISNULL(@NewPublicNotes,'') <> '')
					--BEGIN
					--	SET @ExistingPublicNotes = '['+FORMAT(getdate(), 'MM/dd/yyyy HH:mm')+']: ' +  
					--								@NewPublicNotes + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
					--								+ @ExistingPublicNotes + CHAR(13) + CHAR(10)
					--END

						
					--Update SecStatus
					IF(@precheckSectStatus IS NOT NULL and @precheckSectStatus<>'')
					BEGIN
						SET @SectStatus=@precheckSectStatus;
					END

					--Update SecStatus
					IF(@precheckWebstatus IS NOT NULL and @precheckWebstatus>0)
					BEGIN
						SET @WebStatus=@precheckWebstatus;
					END

					SELECT @SectSubStatusID = s.SectSubStatusID
					FROM dbo.SectSubStatus s
					WHERE s.SectSubStatus = 'New Component State'
					AND s.ApplSectionID = 1

					
					--Update SecSubStatusID   ---Amyliu on 06/03/2020 for status-substatus
					--if (@precheckSectStatus = '9')  --Pending
					--	SET @SectSubStatusID = NULL; 
					--else if exists( select * from SectSubStatus sss where sss.ApplSectionID=1 and sss.ResultFound =@resultFound and sss.SectStatusCode = @precheckSectStatus)
					--	select top 1 @SectSubStatusID = sss.SectSubStatusID from SectSubStatus sss where sss.ApplSectionID=1 and sss.ResultFound =@resultFound and sss.SectStatusCode = @precheckSectStatus
					--else
					--	SET @SectSubStatusID = NULL;  --- this never happen ---just in case.
							
				END

					BEGIN TRANSACTION [Tran1]
							BEGIN TRY
								UPDATE [dbo].[Empl] SET
													[Pub_Notes]=LEFT(@ExistingPublicNotes,8000),
													[SectStat]=@SectStatus,
													[web_status]=@WebStatus,
													SectSubStatusID = @SectSubStatusID
													WHERE [EmplID]=@emplid;

								--Change Logs for Public Notes/web_status/SecStatus
								INSERT INTO dbo.[ChangeLog]([TableName],[ID],[OldValue],[NewValue],[ChangeDate],[UserID]) Values
															--('Empl.Pub_Notes',@emplid,cast(@Old_Pub_Notes as varchar(8000)),cast(@ExistingPublicNotes as varchar(8000)),GETDATE(),'SJV'),
															('Empl.web_status',@emplid,cast(@Old_WebStatus as varchar(8000)),cast(@WebStatus as varchar(8000)),GETDATE(),'SJV'),
															('Empl.SectSubStatus',@emplid,cast(@Old_SectSubStatusID as varchar(8000)),cast(@SectSubStatusID as varchar(8000)),GETDATE(),'SJV'),
															('Empl.SectStat',@emplid,cast(@Old_SectStatus as varchar(8000)),cast(@SectStatus as varchar(8000)),GETDATE(),'SJV');

								SET @IsSuccess=1;
								COMMIT TRANSACTION [Tran1]
							END TRY

							BEGIN CATCH

								ROLLBACK TRANSACTION [Tran1] 

							END CATCH  


			END
	END

	SELECT @IsSuccess AS Success
END

--go
--exec [dbo].[Verification_AutoClose] 7000930,'U',0,'Unverified: Record Not Kept',14
