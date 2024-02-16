
CREATE PROCEDURE [dbo].[OnlineRelease_InsertNewRelease]
    @pdf AS IMAGE,
    @ssn AS VARCHAR (11),
    @i94 AS VARCHAR (50) = null,
    @first AS VARCHAR (50),
    @last AS VARCHAR (50),
	@CLNO as INT,
	@EnteredVia as VARCHAR (15)=null,
	@ClientAppNo as VARCHAR (50) = null,
	@DOB as DateTime = null,
	@ApplicantInfopdf AS IMAGE  = null
	
AS
INSERT INTO ReleaseForm (PDF,ssn,i94,first,last,clno,EnteredVia,ClientAppNo,DOB,applicantinfo_pdf)
VALUES ( @PDF,@SSN,@i94,@first,@last,@CLNO,@EnteredVia,@ClientAppNo,@DOB,@ApplicantInfopdf)

declare @ReleaseFormID int

Set @ReleaseFormID = SCOPE_IDENTITY()

Set @SSN = replace(@SSN,'-','')
Set @ClientAppNo = Isnull(@ClientAppNo,'')

	--if ((select count(1) from dbo.Appl (NoLock) where (ClientAPNO = @ClientAppNo or ClientApplicantNO = @ClientAppNo or replace(SSN,'-','')= @SSN or (last=@last and first = @first))  
	--		and (clno = @CLNO or clno in(Select clno from dbo.ClientHierarchyByService  (NoLock) 
	--							where parentclno in(select parentclno from dbo.ClientHierarchyByService  (NoLock) 
	--												where clno = @CLNO and refHierarchyServiceID=2 ))))>0)
	--	begin

	--		Declare @Apstatus AS VARCHAR(2),@appSSN AS VARCHAR(11),@appDOB as datetime,@APNO as int

	--		select @Apstatus = ApStatus ,@appSSN=SSN ,@appDOB = DOB ,@APNO = APNO 
	--		from dbo.Appl (NoLock)
	--		where (ClientAPNO = @ClientAppNo or ClientApplicantNO = @ClientAppNo or replace(SSN,'-','')= @SSN or (last=@last and first = @first))  
	--		and (clno = @CLNO or clno in(Select clno from dbo.ClientHierarchyByService  (NoLock)
	--			where parentclno in(select parentclno from dbo.ClientHierarchyByService  (NoLock)
	--								where clno = @CLNO and refHierarchyServiceID=2 )))
										
	--		--select @Apstatus  ,@appSSN ,@appDOB  ,@APNO --from Appl where ClientAPNO = '301882' and clno = 2179 
		
	--		if (@Apstatus = 'M')
	--		begin
	--			--select @Apstatus   ,@APNO
	--			update dbo.appl
	--			set ApStatus = 'P',
	--			SSN = Case When isnull(@appSSN ,'')='' Then @ssn else SSN end,
	--			DOB = Case When isnull(@appDOB ,'')='' Then @DOB else DOB end
	--			where APNO = @APNO

	--			Insert into DBO.ChangeLog (TableName,ID,OldValue,NewValue,ChangeDate,UserID)
	--			Select 'APPL.ApStatus',@APNO,@Apstatus,'P',Current_TimeStamp,'Online Release'

	--			BEGIN TRY
	--			Insert into ReleaseLog_Temp (APNO,AppSSN,AppDOB,SSN,DOB)
	--			Select @APNO,@appSSN,@appDOB,@ssn,@DOB
	--			END TRY
	--			BEGIN CATCH
	--				--test
	--			END CATCH

	--		end

	--	end
	--else
	--	begin
	--	    IF (@CLNO  in (Select CLNO From DBO.ClientConfiguration Where ConfigurationKey = 'Notification_Release_NoMatchingApp' and Value='True'))
	--		BEGIN
	--			--Notify about UnResolved Jobs
	--			Declare @msg nvarchar(4000),@Email nvarchar(400)

	--			Select @Email = EmailAddress 
	--			From client c left join users u on c.cam = u.userid
	--			Where CLNO = @CLNO

	--			Set @Email = Isnull(@Email,'') + (Case when ltrim(rtrim(Isnull(@Email,''))) = '' then '' else ';' end) + N'SantoshChapyala@precheck.com;LoriMcGowan@precheck.com;RyanTrevino@precheck.com'

	--			set @msg = 'Greetings,' +  char(9) + char(13) + 'This is to inform you that ' +  @last + ', ' + @first  + ' has completed a release for CLNO: ' + cast(@CLNO as varchar) + char(9) + char(13)+ char(9) + char(13)  

	--			set @msg = @msg + 'A matching application was not found using SSN; last and first for the client.' + char(9) + char(13)+ char(9) + char(13) + ' Thank you. ' + char(9) + char(13) 

	--			EXEC msdb.dbo.sp_send_dbmail    @from_address = 'Release Notification <DoNotReply@PreCheck.com>',@subject=N'Release submitted - App/Report not found',@recipients=@Email,    @body=@msg ;
	--		END
	--	end

if (@ClientAppNo<> '')
begin
	--Modified by SChapyala on 07/09/2013
	--To insert into the ReleaseFormAcknowledgement table based on Integration configuration

	Declare @AcknowledgeRelease varchar(10),@ParentCLNO int

	

	set @AcknowledgeRelease = 'false'

	Select @ParentCLNO =  ParentCLNO from [dbo].[ClientHierarchyByService] (NoLock) Where CLNO = @CLNO and [refHierarchyServiceID] = 2

	Set @ParentCLNO = Isnull(@ParentCLNO,@CLNO)

	SELECT @AcknowledgeRelease = cast(NewTable.RequestXML.query('data(AcknowledgeRelease)')  as varchar(10))
	FROM dbo.[ClientConfig_Integration] (Nolock) CROSS APPLY [ConfigSettings].nodes('//ClientConfigSettings') AS NewTable(RequestXML)
	WHERE [CLNO] = @CLNO
	OR CLNO = @ParentCLNO -- OnlineRelease Hierarchy


	--Only insert into the acknoweldgement if the release acknowledgment is required as part of the integration
	If @AcknowledgeRelease = 'true' 
		INSERT INTO [dbo].[ReleaseFormAcknowledgement]
			   ([ReleaseFormId],CLNO,ClientApno)
		 VALUES
			   (@ReleaseFormID,@ParentCLNO,@ClientAppNo)

	--Select @ReleaseFormID as releaseid

	--END Modification by SChapyala on 07/09/2013
end



Select @ReleaseFormID as releaseid





