




CREATE PROCEDURE [dbo].[OnlineRelease_InsertNewRelease_test]
    @pdf AS IMAGE,
    @ssn AS VARCHAR (11),
    @i94 AS VARCHAR (50) = null,
    @first AS VARCHAR (50),
    @last AS VARCHAR (50),
	@CLNO as INT,
	@EnteredVia as VARCHAR (15)=null,
	@ClientAppNo as VARCHAR (50) = null
	,@DOB as DateTime = null
AS
INSERT INTO ReleaseForm (PDF,ssn,i94,first,last,clno,EnteredVia,ClientAppNo,DOB)
VALUES ( @PDF,@SSN,@i94,@first,@last,@CLNO,@EnteredVia,@ClientAppNo,@DOB)

select cast(scope_identity() as int) as releaseid

if (isnull(@ClientAppNo,'')<> '')
begin
	Declare @Apstatus AS VARCHAR(2),@appSSN AS VARCHAR(11),@appDOB as datetime,@APNO as int

	if ((select count(*) from Appl where (ClientAPNO = @ClientAppNo or ClientApplicantNO = @ClientAppNo)  and clno = @CLNO)>0)
	begin
		select @Apstatus = ApStatus ,@appSSN=SSN ,@appDOB = DOB ,@APNO = APNO from Appl where (ClientAPNO = @ClientAppNo or ClientApplicantNO = @ClientAppNo) and clno = @CLNO 
		--select @Apstatus  ,@appSSN ,@appDOB  ,@APNO --from Appl where ClientAPNO = '301882' and clno = 2179 
		
		if (@Apstatus = 'M')
		begin
			--select @Apstatus   ,@APNO
			update appl
			set ApStatus = 'P'
			where APNO = @APNO
		end

		if (isnull(@appSSN ,'')='')
		begin
--			select @Apstatus  ,@appSSN   ,@APNO
			update appl
			set SSN = @appSSN
			where APNO = @APNO

		end

		if (isnull(@appDOB ,'')='')
		begin
			--select @Apstatus  ,@appSSN ,@appDOB  ,@APNO
			update appl
			set DOB = @appDOB
			where APNO = @APNO
		end

	end
end




