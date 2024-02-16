CREATE procedure HCA_Send_Release_CaseTicket_Email
@Reqnum varchar(10),@COID varchar(10),@Name varchar(50),@releaseid int,@client varchar(200),@clno int,@RecruiterEmail nvarchar(100) AS
Begin

declare @msg nvarchar(max),@sub nvarchar(500),@To nvarchar(500)
set @msg = '[ATSCaseEmails]
 [Hire/Onboard My Employees]
 [No]
 []
 Req. Number: ' + @Reqnum + '
 PL: ' + @COID + '

 This is to notify you that ''' + @Name + ' with ReleaseID: ' + cast(@releaseid as varchar) + ' from ' + @client + ' (CLNO: ' + cast(@clno as varchar) + ')' + ''' has completed the Precheck Online Release(Authorization and Disclosure).

 Thanks,
 Precheck Client Services.'
 
 set @sub  = 'BG Auth Complete: ' + @Name + '; PL: ' + @COID + '; Req#: ' + @Reqnum

 set @to = @RecruiterEmail + ';Release@precheck.com;HCA_201404@cmmx.enwisen.net'

		EXEC msdb.dbo.sp_send_dbmail   @from_address = 'Release@PreCheck.com',@subject=@sub , @recipients=@To,    @body=@msg ;
END