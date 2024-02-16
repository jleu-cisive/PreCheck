﻿
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Description: Set SectSubStatusID in Empl table.
-- exec [dbo].[Verification_AutoClose_MissingInfo] 7000930,'U',0,'Unverified: Missing Info'
-- =============================================

CREATE PROCEDURE [dbo].[Verification_AutoClose_MissingInfo]
	@emplid int,
	@precheckSectStatus char,
	@precheckWebstatus int,
	@resultFound varchar(100) = null,
	@publicNotesId int=0

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


				SELECT @Old_SectStatus = e.SectStat,
						@Old_Pub_Notes = e.Pub_Notes,
						@Old_WebStatus = e.web_status,
						@Old_SectSubStatusID = e.SectSubStatusID
				FROM [dbo].[Empl] e
				WHERE [EmplID]=@emplid;


				SET @ExistingPublicNotes = ISNULL(@ExistingPublicNotes,'')

				IF (@CLNO>0)
				BEGIN

					--Update Public Note
					DECLARE @NewPublicNotes NVARCHAR(MAX)=NULL;
					SELECT @NewPublicNotes=[Text] 
					FROM [dbo].[VerificationsNotes] 
					WHERE [VerificationsNotesId] = ISNULL(@publicNotesId,0);

					

					IF(ISNULL(@NewPublicNotes,'') <> '')
					BEGIN
						SET @ExistingPublicNotes = '['+FORMAT(getdate(), 'MM/dd/yyyy HH:mm')+']: ' +  
													@NewPublicNotes + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
													+ @ExistingPublicNotes + CHAR(13) + CHAR(10)
					END

					SELECT @SectStatus = s.Code
					FROM dbo.SectStat s
					WHERE s.[Description] = 'UNVERIFIED'


					SELECT @SectSubStatusID = s.SectSubStatusID
					FROM dbo.SectSubStatus s
					WHERE s.SectSubStatus = 'Need More Info' -- Missing Information - sub status does not exist.
					AND s.ApplSectionID = 1

					IF(ISNULL(@precheckWebstatus,0) > 0)
					BEGIN
						SET @WebStatus = @precheckWebstatus
					END
							
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
														('Empl.Pub_Notes',@emplid,cast(@Old_Pub_Notes as varchar(8000)),cast(@ExistingPublicNotes as varchar(8000)),GETDATE(),'SJV'),
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