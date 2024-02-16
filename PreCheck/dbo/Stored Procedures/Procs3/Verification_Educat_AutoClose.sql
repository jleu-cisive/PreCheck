

-- exec [dbo].[Verification_AutoClose] 9442437,'9',0,'Unverified: Source Not In Existence',11
-- =============================================
--new
create PROCEDURE [dbo].[Verification_Educat_AutoClose]
	@educatid int
	--,
	--@precheckSectStatus char,
	--@precheckWebstatus int,
	--@resultFound varchar(100) = null,
	--@publicNotesId int=null

AS
BEGIN
	DECLARE @IsSuccess BIT=0;

	DECLARE @precheckSectStatus char
	DECLARE @precheckWebstatus int
	DECLARE @resultFound varchar(100) = null
	DECLARE @publicNotesId int=null
	
	IF(@educatid>0)
	BEGIN
	-- GK@2022-09-29: 
	 -- Please move this transaction to the end, right before where the actual data editing is being done (right before update statement)
	 -- transactions causes locks and if we start a transaction that will make changes on the DB then the records
	 -- we've selected will also be locked. In this case this is not necessary so moving the transaction where the
	 -- data modification is being done would allow sql server not to lock those records to other queries 
	 -- because of all these select statements

			IF EXISTS(SELECT TOP 1 1 FROM [dbo].[Educat] WHERE EducatID=@educatid)
			BEGIN
				DECLARE @CLNO INT;
				SELECT TOP 1 @CLNO=a.CLNO from [dbo].[Educat] e join [dbo].[Appl] a on e.Apno=a.APNO where e.EducatId=@educatid;
				PRINT @CLNO;

				DECLARE @ExistingPublicNotes NVARCHAR(MAX)=NULL;
				DECLARE @SectStatus CHAR;
				DECLARE @WebStatus INT;
				DECLARE @SectSubStatusID int =NULL; --Default if client not exist
				DECLARE @Old_Pub_Notes NVARCHAR(MAX)=NULL;
				DECLARE @Old_SectStatus CHAR;
				DECLARE @Old_WebStatus INT;
				DECLARE @Old_SectSubStatusID INT;

				SELECT TOP 1 @ExistingPublicNotes= [Pub_Notes],@SectStatus= [SectStat], @WebStatus =[web_status], @SectSubStatusID=SectSubStatusID from [dbo].[Educat] WHERE EducatId=@educatid;

				--Set the old variables for change logs
				SET @Old_Pub_Notes=@ExistingPublicNotes;
				SET @Old_SectStatus=@SectStatus;
				SET @Old_WebStatus=@WebStatus;
				SET @Old_SectSubStatusID = @SectSubStatusID;

				SET @ExistingPublicNotes = ISNULL(@ExistingPublicNotes,'')

				IF (@CLNO>0)
				BEGIN

					--Update Public Note
					DECLARE @NewPublicNotes NVARCHAR(MAX)=NULL;
					SELECT @NewPublicNotes=[Text] 
					FROM [dbo].[VerificationsNotes] 
					WHERE [VerificationsNotesId]=@publicNotesId;

					

					IF(ISNULL(@NewPublicNotes,'') <> '')
					BEGIN
						SET @ExistingPublicNotes = '['+FORMAT(getdate(), 'MM/dd/yyyy HH:mm')+']: ' +  
													@NewPublicNotes + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
													+ @ExistingPublicNotes + CHAR(13) + CHAR(10)
					END

						
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
					
					--Update SecSubStatusID   ---Amyliu on 06/03/2020 for status-substatus
					if (@precheckSectStatus = '9')  --Pending
						SET @SectSubStatusID = NULL; 
					else if exists( select * from SectSubStatus sss where sss.ApplSectionID=1 and sss.ResultFound =@resultFound and sss.SectStatusCode = @precheckSectStatus)
						select top 1 @SectSubStatusID = sss.SectSubStatusID from SectSubStatus sss where sss.ApplSectionID=1 and sss.ResultFound =@resultFound and sss.SectStatusCode = @precheckSectStatus
					else
						SET @SectSubStatusID = NULL;  --- this never happen ---just in case.
							
				END

					BEGIN TRANSACTION
							BEGIN TRY
								UPDATE [dbo].[Educat] SET
												[Pub_Notes]=LEFT(@ExistingPublicNotes,8000),
												[SectStat]=@SectStatus,
												[web_status]=@WebStatus,
												SectSubStatusID = @SectSubStatusID
												WHERE [EducatID]=@educatid;

								--Change Logs for Public Notes/web_status/SecStatus
								INSERT INTO dbo.[ChangeLog]([TableName],[ID],[OldValue],[NewValue],[ChangeDate],[UserID]) Values
														('Educat.Pub_Notes',@educatid,cast(@Old_Pub_Notes as varchar(8000)),cast(@ExistingPublicNotes as varchar(8000)),GETDATE(),'NSCH'),
														('Educat.web_status',@educatid,cast(@Old_WebStatus as varchar(8000)),cast(@WebStatus as varchar(8000)),GETDATE(),'NSCH'),
														('Educat.SectSubStatus',@educatid,cast(@Old_SectSubStatusID as varchar(8000)),cast(@SectSubStatusID as varchar(8000)),GETDATE(),'NSCH'),
														('Educat.SectStat',@educatid,cast(@Old_SectStatus as varchar(8000)),cast(@SectStatus as varchar(8000)),GETDATE(),'NSCH');

								SET @IsSuccess=1;
								COMMIT
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