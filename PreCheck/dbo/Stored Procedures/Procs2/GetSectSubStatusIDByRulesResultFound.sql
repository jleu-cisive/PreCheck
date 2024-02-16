-- =============================================
-- Author:		<Amy Liu>
-- Create date: <06/03/2020 >
-- Description:	GetSectSubStatusID based on sectStatus, ResultFound and SubStatus rules
-- Due to the field's value is not clear, we will use hard code mostly here.
-- exec [dbo].[GetSectSubStatusIDByRulesResultFound] @ResultFound='Verified: Requires Review',@PrecheckSectStatus='C', @IsJobtitleVerified=1,@IsWithinDatepolicy=0,@IsReasonForDischarge=1,@IsEligibleforRehire=1
-- exec [dbo].[GetSectSubStatusIDByRulesResultFound] @ResultFound='Unverified: No Record of Subject',@PrecheckSectStatus='U'
-- Modified by Amy Liu on 06/30/2020 added AlternateStatus as parameter and changed substatus for 'force close' on 'Unverified: Closed Per Policy'
-- =============================================
CREATE PROCEDURE [dbo].[GetSectSubStatusIDByRulesResultFound]
(
	@ResultFound varchar(100),
	@PrecheckSectStatus char ='',
    @IsJobtitleVerified bit=null,
    @IsWithinDatepolicy bit = NULL,
    @IsReasonForDischarge bit = NULL,
    @IsEligibleforRehire bit = NULL,
	@AlternateStatus nvarchar(250)=''
)
AS
BEGIN
	SET NOCOUNT ON;

		if ((@PrecheckSectStatus= '9') or isnull(@ResultFound,'')='' or isnull(@PrecheckSectStatus,'')='') ---pending
		Begin
			select  0 as SectSubStatusID;     --- either 'pending' or error.
			return;
		End
		
		if(@ResultFound='Verified: Success')
		Begin
			select isnull(sss.SectSubStatusID,0) as SectSubStatusID from dbo.SectSubStatus sss where sss.ResultFound ='Verified: Success'
			return;
		End 

		if(@ResultFound='Verified: Requires Review')
		Begin		
					If (@IsEligibleforRehire= 0)
					Begin
						select isnull(sss.SectSubStatusID,0) as SectSubStatusID 
						from SectSubStatus sss 
						where sss.ApplSectionID=1 
							and sss.ResultFound = @resultFound 
							and sss.SectStatusCode = @PrecheckSectStatus
							and sss.EligbleForRehire = @IsEligibleforRehire
							return;
					End
					if ( @IsReasonForDischarge=0)   --2 cases
					Begin
						select isnull(sss.SectSubStatusID,0) as SectSubStatusID 
						from SectSubStatus sss 
						where sss.ApplSectionID=1 
							and sss.ResultFound = @resultFound 
							and sss.SectStatusCode = @PrecheckSectStatus
							and sss.ReasonForDischarge = @IsReasonForDischarge
							return;
					End

					if(@IsJobtitleVerified = 0)
					Begin
						select isnull(sss.SectSubStatusID,0) as SectSubStatusID
						from SectSubStatus sss 
						where sss.ApplSectionID=1 
							and sss.ResultFound = @resultFound 
							and sss.SectStatusCode = @PrecheckSectStatus
							and sss.JobTiltleVerified   = @IsJobtitleVerified
							return;
					End 
					if(@IsWithinDatepolicy=0)
					Begin
						select isnull(sss.SectSubStatusID,0) as SectSubStatusID
						from SectSubStatus sss 
						where sss.ApplSectionID=1 
							and sss.ResultFound = @resultFound 
							and sss.SectStatusCode = @PrecheckSectStatus
							and sss.WithDatePolicy = @IsWithinDatepolicy
							return;
					End 
					 ---AmyLiu added on 10/12/2020 for all other un-matched issues (SJV side issue)
						select isnull(sss.SectSubStatusID,0) as SectSubStatusID
						from SectSubStatus sss 
						where sss.ApplSectionID=1 
							and sss.ResultFound = @resultFound 
							and sss.SectStatusCode = @PrecheckSectStatus
							and sss.SectSubStatus='Third Party Verification'
						return;

		End 
		else if (@ResultFound='Unverified: Closed per Policy' and @AlternateStatus='force close' and @PrecheckSectStatus='U')
			begin
					select isnull(sss.SectSubStatusID,0) as SectSubStatusID
					from SectSubStatus sss 
					where sss.ApplSectionID=1 and sss.SectSubStatus='No Response' and sss.SectStatusCode='U'
			end 	
		else if (@ResultFound='Unverified: Closed per Policy' and @AlternateStatus='CLNO Does Not allow fees' and @PrecheckSectStatus='U')
			begin
					select isnull(sss.SectSubStatusID,0) as SectSubStatusID
					from SectSubStatus sss 
					where sss.ApplSectionID=1 and sss.SectSubStatus='Fees Not Approved' and sss.SectStatusCode='U'
			end					
		else
			Begin
							select isnull(sss.SectSubStatusID,0) as SectSubStatusID
							from SectSubStatus sss 
							where sss.ApplSectionID=1 
								and sss.ResultFound = @resultFound 
								and sss.SectStatusCode = @PrecheckSectStatus
								return;
			End


END
