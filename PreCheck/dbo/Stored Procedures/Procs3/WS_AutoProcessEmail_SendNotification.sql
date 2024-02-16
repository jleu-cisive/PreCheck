﻿--dbo.WS_AutoProcessEmail_SendNotification  null,'09/22/2016 14:09','','','',3375141 
CREATE Procedure [dbo].[WS_AutoProcessEmail_SendNotification] ( @PartnerTrackingId varchar(20) = null, @DateEmailReceived DateTime,@Last varchar(100) = null,@First varchar(100) = null,@EmailFrom varchar(100),@apno int = null)
AS
SET NOCOUNT ON
Declare @TimeLag int
Declare @CCList nvarchar(1000)

Set @TimeLag = -60 --60 hour time lag to adjust for order placement and the recruiter sharing candidate profile.
--set @CCList = 'DionnaAllen@Precheck.Com;JessicaViera@Precheck.com;CynthiaDoherty@Precheck.com;EmilyTorticill@Precheck.com;'
SET @CCLIST = 'emailattachmentnotification@precheck.com'


Declare @InvestigatorEmail nvarchar(100),@CAM_Email nvarchar(100)

IF isnull(@APNO,'')<>'' 
	select Top 1 @InvestigatorEmail = isnull(U.EmailAddress,'') ,@CAM_Email = isnull(U2.EmailAddress,'') 
	from dbo.Integration_OrderMgmt_Request IOR (nolock) inner join dbo.appl A (nolock) 
	 on IOR.APNO = A.APNO 
	left join dbo.Users U (Nolock) ON A.Investigator = U.UserID
	left join dbo.Users U2 (Nolock) ON A.UserID = U2.UserID
	where RequestDate >= DateAdd(hour, @TimeLag,@DateEmailReceived)
	AND  (  A.APNO = @Apno)
	Order By IOR.APNO Desc
else
	select Top 1 @APNO = IsNull(@Apno,A.APNO),@InvestigatorEmail = isnull(U.EmailAddress,'') ,@CAM_Email = isnull(U2.EmailAddress,'') 
	from dbo.Integration_OrderMgmt_Request IOR (nolock) inner join dbo.appl A (nolock) 
	 on IOR.APNO = A.APNO 
	left join dbo.Users U (Nolock) ON A.Investigator = U.UserID
	left join dbo.Users U2 (Nolock) ON A.UserID = U2.UserID
	--where (Isnull(partner_tracking_number,@PartnerTrackingId) =  @PartnerTrackingId OR @PartnerTrackingId IS NULL) 
	where RequestDate >= DateAdd(hour, @TimeLag,@DateEmailReceived)
	AND  (A.[Last] = @Last AND   A.[First] = @First)
	--AND   UserName = @EmailFrom
	Order By IOR.APNO Desc

--IF (isnull(@InvestigatorEmail,'')<>'')
	BEGIN
		Declare @msg nvarchar(1000),@RecipientList nvarchar(250)

		BEGIN TRY
			
			--set @CCList = ''
			If isnull(@CAM_Email,'')<>''  
				Set @RecipientList = @InvestigatorEmail  + '; ' + @CAM_Email
			else
				Set @RecipientList = @InvestigatorEmail
				
			--Set @RecipientList = @RecipientList    + '; SantoshChapyala@precheck.com; douglasdegenaro@precheck.com;' 

			set @msg = 'Greetings,' +  char(9) + char(13) + 'This is to notify that Images have been attached (probably after being reviewed) for Applicant: ' + IsNull(@Last,'') +', ' + IsNull(@First,'')  + ' with APNO: ' + cast(IsNull(@APNO,'') as varchar) + char(9) + char(13)+ char(9) + char(13) 

			set @msg = @msg + 'Please review for additional information.' + char(9) + char(13)+ char(9) + char(13) + ' Thank you, ' + char(9) + char(13) + 'Email Attachment Auto Processor'

			EXEC msdb.dbo.sp_send_dbmail
					@recipients=@RecipientList,
					@copy_recipients=@CCList,
					@subject=N'Email Attachment notification',
					@body=@msg,
					@from_address=N'EmailAutoProcessor@PreCheck.com' 

			Update DBO.APPL Set Priv_Notes = cast(Current_TimeStamp as varchar(20)) +  ': Images have been attached (probably after being reviewed)' + char(9) + char(13) + Priv_Notes
			Where APNO  = @APNO
		END TRY
		BEGIN CATCH
			set @msg = 'Error Notifying the Investigator and the CAM that the attachments have been processed after the APP has been reviewed.'  + char(9) + char(13) + ' APNO: ' + cast(isnull(@APNO,'') as varchar)  + char(9) + char(13) + ' Name: ' + Isnull(@Last,'') + ', ' + Isnull(@First,'')
			EXEC msdb.dbo.sp_send_dbmail @recipients=@CCLIST,--'santoshchapyala@precheck.com;douglasdegenaro@precheck.com;',
					@subject=N'Email Attachment notification',
					@body=@msg,
					@from_address=N'EmailAutoProcessor@PreCheck.com' 
		END CATCH
	END

Select @APNO APNO

SET NOCOUNT OFF