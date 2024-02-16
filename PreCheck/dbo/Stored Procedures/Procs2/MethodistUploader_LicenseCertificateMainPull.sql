
-- EXEC [dbo].[MethodistUploader_LicenseCertificateMainPull] 1616,'12/01/2018', '12/10/2018'

CREATE PROCEDURE [dbo].[MethodistUploader_LicenseCertificateMainPull]
	
	@CLNO int, @StartDate datetime,@EndDate datetime

AS
BEGIN
SET NOCOUNT ON 

--set  @StartDate = '12/01/2018' 
--set @EndDate  = '12/15/2018'
insert into winservicelog (logdate,logmessage) values(getdate(),'MethodistParamsRelease: ' + cast(@CLNO as varchar(20)) + ' ' + convert(varchar,@StartDate,101) + ' ' + convert(varchar,@EndDate,101));


if @CLNO = 7519
	begin
	Exec CredentCheckDocuments.dbo.[HCA_LicenseCertificateMainPull] @CLNO,@StartDate ,@EndDate
	end
else if @CLNO = 1616
	begin
			set  @StartDate = '1/01/1999' 
			set @EndDate  = DATEADD(d,1,current_timestamp)
			Exec CredentCheckDocuments.dbo.[LicenseCertificateMainPull] @CLNO,@StartDate ,@EndDate
	end
--else if @CLNO = 9900
--Begin
--	Exec CredentCheckDocuments.dbo.[LicenseCertificateMainPull_9900] @CLNO
--End
else
	begin
	Exec CredentCheckDocuments.dbo.[LicenseCertificateMainPull] @CLNO,@StartDate ,@EndDate
	end	

SET NOCOUNT OFF 
END


