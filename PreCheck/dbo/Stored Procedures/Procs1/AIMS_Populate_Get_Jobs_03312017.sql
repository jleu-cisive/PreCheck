-- Alter Procedure AIMS_Populate_Get_Jobs_03312017

-- =============================================
-- Author:		Santosh Chapyala
-- Create date: 10/02/2013
-- Description:	This SP is used to populate the different Job Sources that needs to be automated through AIMS Service.
--              It tackles all Sections namely Public Record Pending Counties, BG Prof. License Pending Boards, CredentCheck Qualified Boards (based on Board schedule).
--              This SP returns the list of Jobs that needs to be initiated by the service, based on configured number of concurrent jobs that can be run at a given time
-- =============================================

CREATE PROCEDURE [dbo].[AIMS_Populate_Get_Jobs_03312017]  AS
BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	CREATE TABLE #tmpSource
	(
	   Section varchar(20),
	   SectionKeyID varchar(50),
	   VendorAccountId int DEFAULT 5  --default to Mozenda
	)

	CREATE TABLE #tmpJobs
	(
		AIMS_JobID int,
		AIMS_JobStatus varchar(1),
		CreatedDate DateTime,
		SectionKeyID varchar(50),
		Section varchar(20),
		RetryCount int,		
		VendorAccountId int,
		IsPriority bit
	)

	DECLARE @time time(3) = Current_TimeStamp;
	---- $$$$$$$$$$$$$$$$$$$$$$$ Email Recipients after N number of tries $$$$$$$$$$$$$$$$$$$$$$$$$$
	---- $$$$$$$$$$$$$$$$$$ Please change this to fit your environment needs $$$$$$$$$$$$$$$$$$$$$$$$
	DECLARE @currentEmailRecipients varchar(max) = N'AIMSHelpDesk@Precheck.com'
	DECLARE @currentFromAddress varchar(3000) = N'AIMSService@Precheck.com'
	---- $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
	
	--Get Distinct Pending PR County List
	
	--IF @time > '5 AM' and @time <'7 AM' 
		--Dont schedule any new
		--Select 'Skip scheduling'
	--else
		--Insert into #tmpSource (Section,SectionKeyID,VendorAccountId)		
		--Exec [IRIS_PendingOrders] null,1
		Insert into #tmpSource (Section,SectionKeyID,VendorAccountId)		
		Exec [IRIS_PendingOrders_C] null,1,1
		
 
	--Get Distinct Pending Prof. License Board List
	--IF @time > '6 AM' and @time <'7 PM' 
		--Dont schedule any new
		--Select 'Skip scheduling'
	--else
	--	Insert into #tmpSource  (Section,SectionKeyID)	
	--	Exec [dbo].[SP_ProfessionalLicense_ByType_ByState] null,null,0,0,1

	--Get Distinct Qualified AIMS Schedule Jobs
	--IF @time > '7 PM' and @time <'6 AM' 
		Insert into #tmpSource 
		Exec [dbo].[Aims_GetJobsBySchedule] 

		--SELECT * from #tmpSource


		--select Distinct SectionKeyID,Section,SectionTypeCode into #tmpSource1 from #tmpSource


	--Insert the above lists into the Jobs table		
		Insert Into DBO.AIMS_Jobs (Section,SectionKeyID,VendorAccountId)
		Select distinct Section,SectionKeyID,VendorAccountId from #tmpSource 
		Except
		Select distinct Section,SectionKeyID,VendorAccountId from DBO.AIMS_Jobs
		Where ( AIMS_JobStatus in ('Q','A','E') 
			OR (AIMS_JobStatus = 'U' AND DateDiff(hh,JobStart,CURRENT_TIMESTAMP) < 5)--If UnResolved Error(3 unsuccessful Retry attempts) exists, re-add them only after 5 hours passed
			--OR (AIMS_JobStatus = 'D' AND DateDiff(hh,JobStart,CURRENT_TIMESTAMP) > 2) --If Disabled (updated to D by DataXtract Utility trying to manually run a Queued Source) exists, re-add them only after 2 hours passed		
			  )
	
    --Identify Errored Jobs that need to be reprocessed
 --   Select AIMS_JobID,AIMS_JobStatus,CreatedDate,SectionKeyID,Section,RetryCount into #tmpJobs From DBO.AIMS_Jobs
	--Where  AIMS_JobStatus = 'E' 
	--AND    (DateDiff(mi,JobEnd,CURRENT_TIMESTAMP) >= 10 Or RetryCount>=3 Or (JobEnd is Null and  DateDiff(hh,JobStart,CURRENT_TIMESTAMP) >= 24)) --Reprocess Errored records every 10 minutes. If 3 Retrys errored out, they need to be marked as UnResolved and the team notified.
	-- Updated by Doug DeGenaro on 05/05/2014
	INSERT INTO #tmpJobs(AIMS_JobID,AIMS_JobStatus,CreatedDate,SectionKeyID,Section,RetryCount,VendorAccountId)
	select AIMS_JobID,AIMS_JobStatus,CreatedDate,SectionKeyID,Section,RetryCount,VendorAccountId from dbo.AIMS_Jobs with (nolock)
	Where  AIMS_JobStatus = 'E' 
	AND    (DateDiff(mi,JobEnd,CURRENT_TIMESTAMP) >= 10 Or RetryCount>=3 Or (JobEnd is Null and  DateDiff(hh,JobStart,CURRENT_TIMESTAMP) >= 24)) --Reprocess Errored records every 10 minutes. If 3 Retrys errored out, they need to be marked as UnResolved and the team notified.
	

	--Reprocess Errored Jobs for 3 Re-trys and mark it UnResolved if still an error
	Update J 
	Set    AIMS_JobStatus = Case When J.RetryCount >=3 then 'U' else 'Q' end, -- Retry attempts are limited to 3 after which the record is marked as UnResolved and the same source will be blocked out for 24 hours.
		   J.RetryCount =  J.RetryCount + 1,
		   J.AgentStatus = null
	From DBO.AIMS_Jobs J inner join #tmpJobs T on J.AIMS_JobID = T.AIMS_JobID

	--Notify about UnResolved Jobs
	Declare @County_List nvarchar(4000),@msg nvarchar(4000)
	Select @County_List =  COALESCE(@County_List + '; ', '') + (case when isnull(County,'')='' then A_County + ', ' + [State] else County end)  From #tmpJobs T inner join dbo.TblCounties c on T.SectionKeyID = cast(c.CNTY_NO as varchar) Where Section = 'Crim' and T.RetryCount >=3 

	
	if (IsNull(@County_List,'') <> '')
	BEGIN
		
		set @msg = 'Greetings,' +  char(9) + char(13) + 'The following AIMS - Public Records Agents have errored out (after 3 retries). ' + char(9) + char(13)+ char(9) + char(13) + @County_List  + char(9) + char(13)+ char(9) + char(13) + 'The pending searches for these counties/Jurisdictions will be reprocessed by the service in 5 hours.' + char(9) + char(13)+ char(9) + char(13) 

		set @msg = @msg + 'Please cross check and manually process.' + char(9) + char(13)+ char(9) + char(13) + ' Thank you, ' + char(9) + char(13) + 'AIMS Automation Service'

		EXEC msdb.dbo.sp_send_dbmail
			    @recipients=@currentEmailRecipients,
				@body=@msg,
				@from_address=@currentFromAddress,
				@subject=N'AIMS Service Error/Warning Notification'
			
	END
	
	--If we have a queued sex offender job, set the priority as high and
	-- move it to the top of the list.
	--If we have queued Harris job's and it is off peak hours, then
	-- move it to the front of the list

	update dbo.AIMS_Jobs
	set IsPriority=1
	where ((SectionKeyID='2480' and AIMS_JobStatus='Q') or (SectionKeyID='TX-RN' and AIMS_JobStatus='Q')
	or  (SectionKeyID in ('597') and AIMS_JobStatus='Q' and 
	(Case when (@time > '4 AM' and @time <'6 PM') then 0 else 1 end) = 1))	-- only when  its between 7 PM and 5 AM CST set priority to 1
	
	update dbo.AIMS_Jobs
	set AIMS_JobStatus='K'
	where AIMS_JobID in (select top 1 AIMS_JobID from dbo.AIMS_Jobs
	where SectionKeyID = '597' and AIMS_jobStatus in ('Q','D','E','U')
	and  (@time > '4 AM' and @time <'6 PM') order by AIMS_JobID desc
	)	
	DROP TABLE #tmpSource
	--DROP TABLE #tmpSource1
	DELETE #tmpJobs

	--Return the list of Jobs that qualifiy to be active. 

	DECLARE @ActiveJobCount Int,@MaxAllowedJobsBySection int

	Set @MaxAllowedJobsBySection= 10

	select @ActiveJobCount = count(1) from AIMS_Jobs where AIMS_JobStatus = 'A'

	IF @ActiveJobCount IS NULL
		Set @ActiveJobCount = 0

		if (Select count(1)  From AIMS_Jobs T  Where Section = 'Crim' and  AIMS_JobStatus = 'A' and DateDiff(hh,JobStart,CURRENT_TIMESTAMP)>2) > 0
		BEGIN
			EXEC msdb.dbo.sp_send_dbmail   @from_address = 'AIMS Service<DoNotReply@PreCheck.com>',@subject=N'AIMS Service Error/Warning Notification', @recipients=N'ApplicationMonitoring_IT@PreCheck.com;AIMSHelpDesk@Precheck.com',    @body='Public Record Agent/s have been active for more than 2 hours. Please cross check' ;
		END

	--If max jobs are active, notify IT in case it is stuck for a long time

	select @ActiveJobCount = count(1) from AIMS_Jobs where AIMS_JobStatus = 'A' AND Section = 'Crim'

	IF @ActiveJobCount = @MaxAllowedJobsBySection
		BEGIN
			
			Select @County_List = COALESCE(@County_List + '; ', '') + (case when isnull(County,'')='' then A_County + ', ' + [State] else County end) + '(' + Cast(Jobstart as varchar) + ')' + char(9) + char(13)  From AIMS_Jobs T inner join dbo.TblCounties c on T.SectionKeyID = cast(c.CNTY_NO as varchar) Where Section = 'Crim' and  AIMS_JobStatus = 'A'
			Set @County_List = 'The following agents have been active through more than one Schedule. Cross Check if it is too long ' + char(9) + char(13)   + isnull(@County_List,'')
			--EXEC msdb.dbo.sp_send_dbmail    @recipients=N'santoshchapyala@Precheck.com',    @body=@County_List ;
			EXEC msdb.dbo.sp_send_dbmail  @from_address = 'AIMS Service<DoNotReply@PreCheck.com>',@subject=N'AIMS Service Error/Warning Notification',  @recipients=N'ApplicationMonitoring_IT@PreCheck.com;AIMSHelpDesk@Precheck.com',    @body=@County_List ;
		END

	
	IF (@MaxAllowedJobsBySection - @ActiveJobCount) > 0
		INSERT INTO #tmpJobs (AIMS_JobID,Section,SectionKeyID,VendorAccountId,IsPriority)
		Select Top  (@MaxAllowedJobsBySection - @ActiveJobCount) AIMS_JobID,A.Section,A.SectionKeyID,A.VendorAccountId,IsPriority
		From AIMS_Jobs A join dbo.VendorAccounts V on V.VendorAccountId = a.VendorAccountId 
		where VendorAccountName = 'Mozenda' --Mozenda
		and AIMS_JobStatus = 'Q' AND  Section = 'Crim'
		order by IsPriority desc,AIMS_JobID


	select @ActiveJobCount = count(1) from AIMS_Jobs where AIMS_JobStatus = 'A' AND Section IN  ('SBM','CC') AND VendorAccountId<>4 --Mozenda LMP agents


	IF (@MaxAllowedJobsBySection - @ActiveJobCount) > 0
		INSERT INTO #tmpJobs (AIMS_JobID,Section,SectionKeyID,VendorAccountId,IsPriority)
		Select Top  (@MaxAllowedJobsBySection - @ActiveJobCount) AIMS_JobID,A.Section,A.SectionKeyID,A.VendorAccountId,IsPriority
		From AIMS_Jobs A join dbo.VendorAccounts V on V.VendorAccountId = a.VendorAccountId 
		where VendorAccountName = 'Mozenda' --Mozenda
		and AIMS_JobStatus = 'Q' AND  Section in ('CC','SBM')
		order by IsPriority desc,AIMS_JobID
		 
		INSERT INTO #tmpJobs (AIMS_JobID,Section,SectionKeyID,VendorAccountId,IsPriority)
		Select AIMS_JobID,A.Section,A.SectionKeyID,A.VendorAccountId,IsPriority
		From AIMS_Jobs A join dbo.VendorAccounts V on V.VendorAccountId = a.VendorAccountId 
		where VendorAccountName = 'Nursys'
		and AIMS_JobStatus = 'Q' 
		UNION ALL
		Select AIMS_JobID,A.Section,A.SectionKeyID,VendorAccountId,IsPriority
		From AIMS_Jobs A 
		where VendorAccountId = 7 --Baxter
		and AIMS_JobStatus = 'Q' 
	
	



	Delete #tmpJobs
	Where SectionKeyID in
	(Select SectionKeyID from #tmpJobs
	Group By SectionKeyID
	Having count(SectionKeyID)>1) and Section = 'Licensing'

	Select AIMS_JobID,Section,SectionKeyID,VendorAccountName as [Source],va.VendorAccountId,va.AssemblyFullName as AssemblyName,va.[AIMSTypeFullName] ClassFullName from #tmpJobs tj inner join dbo.VendorAccounts va 
	--Select AIMS_JobID,Section,SectionKeyID,VendorAccountName as [Source],va.AssemblyFullName as AssemblyName,va.[AIMSTypeFullName] ClassFullName from #tmpJobs tj inner join dbo.VendorAccounts va 
	on tj.VendorAccountId = va.VendorAccountId
	--Where 1 = 0
	order by IsPriority desc,AIMS_JobID
	

	DROP TABLE #tmpJobs

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	SET NOCOUNT OFF

END
