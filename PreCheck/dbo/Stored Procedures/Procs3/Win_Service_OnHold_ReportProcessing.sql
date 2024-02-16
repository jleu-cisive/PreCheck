



-- This Sp is ececuted from ApplAutoClose_Finalize SP for time being until we fix and release Precheckwinservice -- 9/1/2015 Kiran


CREATE PROCEDURE [dbo].[Win_Service_OnHold_ReportProcessing]
   
	
AS

Declare @RowCnt	int,@CLNO as INT,@APNO as INT, @ssn AS VARCHAR (11),@ClientAppNo as VARCHAR (50), @first AS VARCHAR (50),    @last AS VARCHAR (50),@ClientApplicantNO varchar(50),@Apstatus AS VARCHAR(2),@DOB as datetime,@ClientCertReceived varchar(5),@IsInLieuOnlineRelease bit
SET @RowCnt = 0
CREATE TABLE #TempCert (RowID INT NOT NULL IDENTITY(1,1) PRIMARY KEY, APNO int,ApStatus varchar(5),SSN varchar(11),DOB datetime,last varchar(50),First varchar(50),CLNO int,ClientAPNO varchar(50),ClientApplicantNO varchar(50),SubStatusID int,  ClientCertReceived varchar(5),  IsInLieuOnlineRelease bit)

  CREATE TABLE #TempReleaseForm(
	[ReleaseFormID] [int],	[ssn] [varchar](50) NULL,	[date] [datetime] NULL,	[first] [varchar](50) NULL,	[last] [varchar](50) NULL,	[EnteredVia] [varchar](15) NULL,[CLNO] [int] NULL,	[i94] [varchar](50) NULL,	
		[DOB] [datetime] NULL,	[ClientAPPNO] [varchar](50) NULL)
		 
	-- Deepak Vodethela - 09/10/2019 - Added logic to capture manual removals of SSN's / DOB's on Reports.
	CREATE TABLE #tmpManualRemovals(
		[APNO] [int] NULL,
		[OldValue] [varchar](8000) NULL,
		[NewValue] [varchar](8000) NULL,
		[ChangeDate] [datetime] NOT NULL,
		[UserID] [varchar](50) NULL
	)

	INSERT INTO #TempCert(APNO,ApStatus,SSN,DOB,last,First,CLNO,ClientAPNO,ClientApplicantNO,SubStatusID, ClientCertReceived,  IsInLieuOnlineRelease)	
	Select a.APNO,a.ApStatus,SSN,DOB,last,First,a.CLNO,ClientAPNO,ClientApplicantNO,SubStatusID, Isnull(ClientCertReceived,'No') , Isnull(IsInLieuOnlineRelease,0) 
	from APPL a left join ClientCertification c on  A.Apno = c.Apno
	INNER JOIN Client Cl ON a.CLNO = Cl.CLNO
	where ApStatus = 'M'  and a.CreatedDate > '9/1/2015' and EnteredVia not in( 'StuWeb','System') and Inuse is null and a.CLNO not in (3468,2135,12922)  
	and a.Apno not in (Select APNO from appl where EnteredVia = 'CIC' and isnull(PackageID,0)= 0 and APstatus = 'M')
	AND ( CL.IsOnCreditHold = 0 OR Cl.BillingStatusID = 1) --added by schapyala on 05/11/2018 to leave OnHold/Inactive client apps On Hold.
	SET @RowCnt = @@ROWCOUNT

	--SELECT @RowCnt AS RowCnt
	--SELECT * FROM #TempCert
	-------------------------------------------------------------------------------------------------------------------------------
	-- Deepak Vodethela - Added logic to capture manual removals of SSN's / DOB's on Reports.
	;WITH ManualRemovalOfSSNAndDOB AS
	(
	SELECT	cl.ID AS APNO, cl.OldValue, cl.NewValue, cl.ChangeDate, cl.UserID,
			ROW_NUMBER() OVER (PARTITION BY cl.ID ORDER BY cl.ChangeDate) AS RowNumber
	FROM dbo.ChangeLog cl (NOLOCK)
	INNER JOIN #TempCert tc ON TC.APNO = CL.ID AND ((tc.DOB IS NULL OR LEN(tc.DOB) = 0) OR (tc.SSN	IS NULL	OR LEN(tc.SSN) = 0))
	WHERE (cl.TableName = 'Appl.DOB' OR cl.TableName = 'Appl.SSN')
	  AND (CL.NewValue IS NULL OR LEN(CL.NewValue) = 0)
	)
	INSERT INTO #tmpManualRemovals
	SELECT C.APNO, C.OldValue, C.NewValue, C.ChangeDate, C.UserID
	FROM ManualRemovalOfSSNAndDOB C 
	WHERE C.RowNumber = 1

	-- Deepak Vodethela - If a Report is found with manual removal of SSN/DOB, then remove the report from the main result set, 
	--					so that service will not update SSN and DOB from ReleaseForm table.

	--SELECT * FROM #TempCert tc WHERE TC.APNO IN (SELECT tmr.APNO FROM #tmpManualRemovals tmr)
	DELETE tc FROM #TempCert tc WHERE TC.APNO IN (SELECT DISTINCT tmr.APNO FROM #tmpManualRemovals tmr)
	------------------------------------------------------------------------------------

 Update a set SubStatusID = case when T.ClientCertReceived = 'NO' then 29 else  (case  when  T.SubStatusID = 29 then 28 else a.SubStatusID end) end
   from Appl a inner join #TempCert T on A.APno = T.Apno 


   ---Select  t.APNO,t.SSN,t.DOB,t.last,t.First,t.CLNO,t.ClientAPNO,SubStatusID,ISNULL(rf.SSN,rf.I94) as SSN_Release,rf.DOB as DOB_Release,ClientAppNo as ClientAppNo_Release into #TempRelease
		 --from #TempCert  t cross join dbo.ClientHierarchyByService c on t.CLNO = c.CLNO or  parentclno in(select parentclno from dbo.ClientHierarchyByService  (NoLock) where clno =  t.CLNO and refHierarchyServiceID=2 )
		 --		 left join dbo.ReleaseForm rf on  t.SSN = RF.SSN and t.CLNO = rf.CLNO




 --Select APNO,ApStatus,SSN,DOB,last,First,CLNO,ClientAPNO,SubStatusID,  ClientCertReceived  into #TempCertRelease from #TempCert where ClientCertReceived = 'Yes'

 --DECLARE @apno int 

 --select @apno = min( APNO ) from #TempCert


	WHILE @RowCnt > 0
	begin

		 Select @APNO =APNO,@CLNO = clno,@ssn =SSN,@ClientAppNo = ClientAPNO, @first =First,    @last =last,@ClientApplicantNO =ClientApplicantNO,@Apstatus = ApStatus,@DOB =DOB,@ClientCertReceived = ClientCertReceived,@IsInLieuOnlineRelease = IsInLieuOnlineRelease
			 from #TempCert where RowID = @RowCnt


			 Insert into #TempReleaseForm([ReleaseFormID] ,[ssn],[date],[first] ,[last]   ,[CLNO]  ,[i94]  ,[EnteredVia]   ,[DOB]   ,[ClientAPPNO] )
			 SELECT [ReleaseFormID] ,[ssn],[date],[first] ,[last]   ,[CLNO]  ,[i94]  ,[EnteredVia]   ,[DOB]   ,[ClientAPPNO]     
			 FROM [dbo].[ReleaseForm] with (NOLOCK)
			 where (ClientAPPNO = @ClientAppNo or ClientAPPNO = @ClientApplicantNO or replace(SSN,'-','')= replace(@ssn,'-','') --or (last=@last and first = @first)
			 )  
								and (clno = @CLNO or clno in(Select clno from dbo.ClientHierarchyByService  (NoLock) 
													where parentclno in(select parentclno from dbo.ClientHierarchyByService  (NoLock) 
																		where clno = @CLNO and refHierarchyServiceID=2 )))
								and DateDiff(dd,[Date],CURRENT_TIMESTAMP) <= 30

					if (select count(1) from #TempReleaseForm) >0
							begin

								Declare @ReleaseSSN AS VARCHAR(50),@ReleaseDOB as datetime

								select top 1 @ReleaseSSN = SSN,@ReleaseDOB = DOB from #TempReleaseForm
								order by ReleaseFormID desc
										
										
								
									
									update dbo.appl
									set ApStatus = case when @ClientCertReceived = 'Yes' then 'P' else  @Apstatus end,
									Apdate = case when @ClientCertReceived = 'Yes' then CURRENT_TIMESTAMP else ApDate end,
									SSN = Case When isnull(@ssn ,'')='' Then @ReleaseSSN else SSN end,
									DOB = Case When isnull(@DOB ,'')='' Then @ReleaseDOB else DOB end
									where APNO = @APNO
									
									if isnull(@ssn ,'')='' 
									Insert into DBO.ChangeLog (TableName,ID,OldValue,NewValue,ChangeDate,UserID)
									Select 'APPL.SSN',@APNO,@ssn,@ReleaseSSN,Current_TimeStamp,'OnHold_Service_SP'

									if isnull(@DOB ,'')='' 
									Insert into DBO.ChangeLog (TableName,ID,OldValue,NewValue,ChangeDate,UserID)
									Select 'APPL.DOB',@APNO,@DOB,@ReleaseDOB,Current_TimeStamp,'OnHold_Service_SP'

							
								Truncate table #TempReleaseForm

								end
					/* disabling the service till we have a discussion with Misty and team
						else
							Begin

							
							
								Update appl set  ApStatus = 'P',Apdate =  CURRENT_TIMESTAMP  
								where APNO = @APNO and (isnull(ltrim(rtrim(SSN)),'')<>'' and len(SSN) >= 11) and DOB is not null and @IsInLieuOnlineRelease = 1 and @ClientCertReceived = 'Yes'
								
								If @@ROWCOUNT >0 
									Insert into DBO.ChangeLog (TableName,ID,OldValue,NewValue,ChangeDate,UserID)
									Select 'APPL.ApStatus',@APNO,@Apstatus,'P',Current_TimeStamp,'OnHold_Service_SP'
						
								 --IF (@CLNO  in (Select CLNO From DBO.ClientConfiguration Where ConfigurationKey = 'Notification_Release_NoMatchingApp' and Value='True') and @IsInLieuOnlineRelease = 0 and @ClientCertReceived = 'No')
									--BEGIN
									--	--Notify about UnResolved Jobs
									--	Declare @msg nvarchar(4000),@Email nvarchar(400)

									--	Select @Email = EmailAddress 
									--	From client c left join users u on c.cam = u.userid
									--	Where CLNO = @CLNO

									--	Set @Email = Isnull(@Email,'') + (Case when ltrim(rtrim(Isnull(@Email,''))) = '' then '' else ';' end) + N'SantoshChapyala@precheck.com;LoriMcGowan@precheck.com;RyanTrevino@precheck.com'

									--	set @msg = 'Greetings,' +  char(9) + char(13) + 'This is to inform you that ' +  @last + ', ' + @first  + ' has completed a release for CLNO: ' + cast(@CLNO as varchar) + char(9) + char(13)+ char(9) + char(13)  

									--	set @msg = @msg + 'A matching application was not found using SSN; last and first for the client.' + char(9) + char(13)+ char(9) + char(13) + ' Thank you. ' + char(9) + char(13) 

									--	EXEC msdb.dbo.sp_send_dbmail    @from_address = 'Release Notification <DoNotReply@PreCheck.com>',@subject=N'Release submitted - App/Report not found',@recipients=@Email,    @body=@msg ;
									--END


							End
					end comment*/
						

SET @RowCnt  = @RowCnt  - 1
		end







Select * from #TempCert


drop table #TempCert
drop table #TempReleaseForm




