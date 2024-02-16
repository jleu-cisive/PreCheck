-- =============================================
-- Author:		Santosh Chapyala
-- Create date: 08/07/2019
-- Description:	This is an urgent situation to send out the Background Release Case tickets to HCA
-- The notification was not sent to the HCA since last night 08/06/2019 07:24PM to 08/07/2019 11:27AM, where 146 applicant releases came through that time frame
-- So Santosh created a procedure to send out these emails without having to do a mail merge.
-- Comments written by Radhika Dereddy on 08/07/2019 5:10PM
-- =============================================
CREATE PROCEDURE [dbo].[Release_HCA_BGAuth_Resend] (@StartDate DateTime,@EndDate DateTime,@StartReleaseFormID Int, @EndReleaseFormID Int)
AS
BEGIN
	select releaseformid,ssn,first,last,clno,clientappno,date  into #tmprelease from ReleaseForm R

	where CLNO in (Select FacilityCLno from HEVn..Facility Where ParentEmployerID= 7519) and Date > @StartDate  and Date < @EndDate order by ssn,date

	--Select distinct clno,first,last from #tmprelease

	--Select * from #tmprelease order by date

	--Select distinct clno,first,last from #tmprelease where releaseformid in (
	--Select releaseformid from #tmprelease where releaseformid > 2945677 and releaseformid<2947956  )


	Select SSN, first, last, clno, ClientAPPNO into #tmpReleasedistinct from #tmprelease where releaseformid > @StartReleaseFormID and releaseformid<@EndReleaseFormID  
	group by SSN, first, last, clno, ClientAPPNO

	--select * from #tmpreleasedistinct

	--Select max(releaseformid) as releaseformid, SSN, first, last, clno, ClientAPPNO, max(date) as [date]
	--From #tmprelease 
	--where releaseformid > 2945677 and releaseformid<2947956
	--Group by SSN, first, last, clno, ClientAPPNO
	--order by ssn, date desc

	 Declare @msg nvarchar(4000),@Email nvarchar(400) ,@subjectline nvarchar(400)
	 DECLARE @CandidateID varchar(20) ,@ReqNumber varchar(20) ,@COID varchar(20) ,@releaseformid varchar(20) ,@first varchar(50) ,@last varchar(50) ,@clno varchar(20) ,@FacilityName varchar(200) 
 
	 DECLARE RESULT_CURSOR CURSOR FOR
	select distinct L.ClientAppNo as CandidateID, L.ReqNumber, L.COID, t.releaseformid,t.first, t.last, t.clno,  c.Name as FacilityName
	from Release_Log L
	inner join (Select max(releaseformid) as releaseformid, SSN, first, last, clno, ClientAPPNO, max(date) as [date]
						 From #tmprelease 
						 where releaseformid > 2945677 and releaseformid<2947956
						 Group by SSN, first, last, clno, ClientAPPNO
				  ) t on L.ClientAppNo=t.ClientAPPNO and L.ClientIdOut = t.clno
	inner join client C ON t.clno = c.clno   
	where L.CreatedDate > @StartDate  and L.CreatedDate < @EndDate 
	order by L.ClientAppNo
    
	 OPEN RESULT_CURSOR;

	FETCH NEXT FROM RESULT_CURSOR INTO @CandidateID,@ReqNumber,@COID,@releaseformid,@first,@last,@clno,@FacilityName;

	WHILE @@FETCH_STATUS = 0

		BEGIN
					Set @Email =  N'UnixPMG@HCAHealthcare.com;HCA_201404@hrsdprod.aws.infor.com'     
				   set @msg = '[ATSCaseEmails]' +  char(9) + char(13) + '[Z-Auto-BG Check Auth]' +  char(9) + char(13) + '[No]' +  char(9) + char(13) + '[]' +  char(9) + char(13) + 'Req. Number: ' + @ReqNumber +  char(9) + char(13) + 'PL: ' + @COID +  char(9) + char(13)  +  char(9) + char(13) 
				   set @msg = @msg + 'This is to notify you that ''' + @first  + ' ' +  @last + ' with Release ID : ' + @releaseformid + ' from Coliseum Medical Centers (CLNO : '+ @clno + '); CandidateID: ' + @CandidateID + ''' has completed the Online Release(Authorization and Disclosure).' +  char(9) + char(13) +  char(9) + char(13) 
				   set @msg = @msg + 'Thanks,' +  char(9) + char(13) + 'PreCheck Client Services.'
 	
					SET @subjectline =   N'BG Auth Complete: ' + @first + ' ' + @last + '; PL: ' + @COID + '; Req#: '  + @ReqNumber 
	 
					EXEC msdb.dbo.sp_send_dbmail    @from_address = 'Release<Release@precheck.com>',@subject=@subjectline,@recipients=@Email,@copy_recipients = 'Release@precheck.com', @body=@msg ;  
	
			FETCH NEXT FROM RESULT_CURSOR INTO @CandidateID,@ReqNumber,@COID,@releaseformid,@first,@last,@clno,@FacilityName;

		END

	CLOSE RESULT_CURSOR;

	DEALLOCATE RESULT_CURSOR;
	drop table #tmprelease

	DROP TABLE #tmpreleasedistinct

END