CREATE Procedure [dbo].[WS_EmailAttachment_Processor_GetAPNO_12292015] ( @PartnerTrackingId varchar(20) = null, @DateEmailReceived DateTime,@Last varchar(100),@First varchar(100),@EmailFrom varchar(100))
AS
SET NOCOUNT ON
Declare @TimeLag int

Set @TimeLag = -60 --60 hour time lag to adjust for order placement and the recruiter sharing candidate profile.



Declare @APNO Int,@InvestigatorEmail nvarchar(100),@CAM_Email nvarchar(100)
select Top 1 @APNO = IOR.APNO,@InvestigatorEmail = isnull(U.EmailAddress,'') ,@CAM_Email = isnull(U2.EmailAddress,'') 
from dbo.Integration_OrderMgmt_Request IOR (nolock) inner join dbo.appl A (nolock) 
 on IOR.APNO = A.APNO 
left join dbo.Users U (Nolock) ON A.Investigator = U.UserID
left join dbo.Users U2 (Nolock) ON A.UserID = U2.UserID
where (Isnull(partner_tracking_number,@PartnerTrackingId) =  @PartnerTrackingId OR @PartnerTrackingId IS NULL) 
AND   RequestDate >= DateAdd(hour, @TimeLag,@DateEmailReceived)
AND   A.[Last] = @Last 
AND   A.[First] = @First
AND   UserName = @EmailFrom
Order By IOR.APNO Desc

IF (isnull(@InvestigatorEmail,'')<>'')
	BEGIN
		Declare @msg nvarchar(1000),@RecipientList nvarchar(250)

		BEGIN TRY
			If isnull(@CAM_Email,'')<>''  
				Set @RecipientList = @InvestigatorEmail  + '; ' + @CAM_Email
			else
				Set @RecipientList = @InvestigatorEmail
				
			Set @RecipientList = @RecipientList    + '; SantoshChapyala@precheck.com; MistySmallwood@precheck.com' 

			set @msg = 'Greetings,' +  char(9) + char(13) + 'This is to notify that Images have been attached (probably after being reviewed) for Applicant: ' + @Last +', ' + @First  + ' with APNO: ' + cast(@APNO as varchar) + char(9) + char(13)+ char(9) + char(13) 

			set @msg = @msg + 'Please review for additional information.' + char(9) + char(13)+ char(9) + char(13) + ' Thank you, ' + char(9) + char(13) + 'Email Attachment Auto Processor'

			EXEC msdb.dbo.sp_send_dbmail
					@recipients=@RecipientList,
					@subject=N'Email Attachment notification',
					@body=@msg,
					@from_address=N'EmailAutoProcessor@PreCheck.com' 

			Update DBO.APPL Set Priv_Notes = cast(Current_TimeStamp as varchar(20)) +  ': Images have been attached (probably after being reviewed)' + char(9) + char(13) + Priv_Notes
			Where APNO  = @APNO
		END TRY
		BEGIN CATCH
			EXEC msdb.dbo.sp_send_dbmail @recipients='santoshchapyala@precheck.com',
					@subject=N'Email Attachment notification',
					@body='Error Notifying the Investigator and the CAM that the attachments have been processed after the APP has been reviewed',
					@from_address=N'EmailAutoProcessor@PreCheck.com' 
		END CATCH
	END

Select @APNO APNO

SET NOCOUNT OFF