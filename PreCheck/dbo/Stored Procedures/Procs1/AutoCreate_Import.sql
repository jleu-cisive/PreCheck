-- Batch submitted through debugger: SQLQuery11.sql|7|0|C:\Users\schapyala\AppData\Local\Temp\~vs3896.sql

--exec AutoCreate_Import 0,0,1,3519,2738,2682,null,null,null,null,1,1,0,0,0,NULL

--create and set TX-DPS search Inprogress with PID only 
--exec AutoCreate_Import 0,0,1,2682,null,null,null,null,null,null,1,0,0,0,0,'MHHS Annual ReCheck Project: Report all records from TX DPS. Do not order individual counties.'

--exec AutoCreate_Import 0,0,1,2682,3519,2738,null,null,null,null,1,1,0,0,0,null

--for edu:exec AutoCreate_Import 0,1,0,null,null,null,null,null,null,null,0,0,0,0,1,0

--This is for License only reports (no counties, no sanction, no PID, no Crim, no education)
--exec AutoCreate_Import 0,1,0,null,null,null,null,null,null,null,0,0,0,1,0,NULL

--TX DPS, National, Sex offender & Sanctioncheck

-- this is for Education and License Only verification
---exec AutoCreate_Import 0,1,0,null,null,null,null,null,null,null,0,0,0,1,1,NULL


---only Education
--exec AutoCreate_Import 0,1,0,null,null,null,null,null,null,null,0,0,0,0,1,NULL

--only PID and SanctionCheck
--exec AutoCreate_Import 0,0,0,null,null,null,null,null,null,null,0,0,0,0,0,NULL

-- exec AutoCreate_Import 0,0,1,3519,2738,2682,3906,null,null,null,1,0,0,0,0,NULL -- HDT53228
--exec AutoCreate_Import 0,1,1,5860,null,null,null,null,null,null,1,0,0,0,0,NULL  -- MVR issue OH SW zipcrim


CREATE Procedure [dbo].[AutoCreate_Import]
(@CreateMVR bit = 0, --set the param to be 1 if you  want to create MVR.
 @SkipWinService bit = 1, --set the param to be 0 if you want the winservice to order PositiveID and SanctionCheck.
 @CreateCrim bit = 0, --set the param to be 1 if you  want to create Crim records.
 @CNTY1 Int = null, --crim county
 @CNTY2 Int = null,  --crim county
 @CNTY3 Int = null, --crim county
 @CNTY4 Int = null,  --crim county
 @CNTY5 Int = null, --crim county
 @CNTY6 Int = null,  --crim county
 @CNTY7 Int = null,  --crim county
 @SetCrim_Pending Bit = 1, --Sets the above crims into pending. Set to 0, if the crims should not be set to pending
 @CreateSexoffender Bit = 0,
@CreateSanction Bit = 0, --Set to 1 to Create Sanction only and no Positive ID,
@CreateProfLicense Bit = 0, --Set to 1 if there is License information in the spreadsheet to be imported
@CreateEducation Bit = 0, --Set to 1 if there is Education information in the spreadsheet to be imported
@CrimPrivateNote varchar(5000) = NULL,
@DoNotSetEducation2Pending Bit = 0 --Set to 1 if you do not want to set Education to Pending status - schapyala added on 12/23/2019
) 
 as 
/*
Unit Name: [AutoCreate_Import]
Author Name:Santosh Chapyala
Date of Creation: 10/01/09
Brief Description:This Procedure is used to process the imported Excel file (MVR_Import table) 
				  to create Apps and the corresponding MVR,crim records. The status on the App 
				  and the MVR(DL),Crim records are set to pending so that they are directly put in
				  the queue without any further verification.
OUTPUT values : List of Apps created by this SP. please forward the App range to the requestor
Date Modified: 10/01/09
Details of Modification: Added CAM and Investigator to the temp table and removed the parameters...Clearing the
						 temp table at the end. Changed the EnterBy to 'System'
Date Modified: 10/01/09
Details of Modification: Added address details for the applicant and a param to create just an app 
*/

/*
--Select * from counties where  county = 'NATIONAL,USA,USA' --use this to get the countyid that need to be passed
--3519 - NATIONAL,USA,USA
--2682 - *DPS STATEWIDE*, TX

EXAMPLE: The below query will order DPS, National and Sex Offender searches. It skips MVR and Winservice (PositiveID and SanctionCheck). Execute below after populating MVR_import table.

[dbo].[AutoCreate_Import]
@CreateMVR  = 0, --set the param to be 1 if you  want to create MVR.
 @SkipWinService  = 1, --set the param to be 0 if you want the winservice to order PositiveID and SanctionCheck.
 @CreateCrim  = 1, --set the param to be 1 if you  want to create Crim records.
 @CNTY1  = 2682, --crim county -- *DPS STATEWIDE*, TX
 @CNTY2  = 3519,  --crim county -- NATIONAL,USA,USA
 @CreateSexoffender  = 1

EXAMPLE: The below query will order DPS, Statewide-TX, Harris and Montgommery counties and Sex Offender searches and leaves them in NEEDS REVIEW status. It skips MVR. 
		 It calls Winservice to order (PositiveID and SanctionCheck). Execute below after populating MVR_import table.

[dbo].[AutoCreate_Import]
@CreateMVR  = 0, --set the param to be 1 if you  want to create MVR.
 @SkipWinService  = 0, --order PositiveID and SanctionCheck.
 @CreateCrim  = 1, --set the param to be 1 if you  want to create Crim records.
 @CNTY1  = 2682, --crim county -- *DPS STATEWIDE*, TX
 @CNTY2  = 1,  --crim county -- **STATEWIDE**, TX
 @CNTY3  = 597, --crim county -- HARRIS, TX
 @CNTY4  = 1916,  --crim county -- Montgomery, TX
 @SetCrim_Pending = 0, --Leave the crims as Needs Review
 @CreateSexoffender  = 1

EXAMPLE: The below query will Order MVR and update status to Pending. 
		 It skips Winservice. Execute below after populating MVR_import table.

[dbo].[AutoCreate_Import] @CreateMVR  = 1

[dbo].[AutoCreate_Import] @CreateEducation  = 1
*/

BEGIN

BEGIN TRANSACTION

	DECLARE @DateEntered DateTime
	declare @id int
	declare @apno int
	declare @CLNO int

	Set @DateEntered = getdate()
	Select distinct @CLNO = [client ID] From DBO.MVR_Import

   	Update MVR_Import
	Set SSN = substring(SSN,1,3) + '-' + substring(SSN,4,2) +'-' + substring(SSN,6,4)
	where len(SSN) = 9 and charindex('-',SSN) = 0

	if @SkipWinService = 0  
	   BEGIN
		 Set @SetCrim_Pending = 0 --Do not set crims to pending if PID is ordered.
	   END

BEGIN TRY
	INSERT INTO DBO.[Appl]
			   ([ApStatus]
			   ,[EnteredBy]
			   ,enteredvia
			   ,UserID
			   ,Investigator
			   ,[ApDate]
			   ,[CLNO]
			   ,[Last]
			   ,[First]
			   ,Middle
			   ,[SSN]
			   ,[DOB]
			   ,[DL_State]
			   ,[DL_Number]
			   ,[NeedsReview]
			   ,[DeptCode]
			   ,[Addr_Street]
			   ,[City]
			   ,[State]
			   ,[zip]
			   --,Priv_Notes
			   ,inUse
			   ,ClientAPNO
			   ,Phone
			   ,Email
			--, Attn
			--, StartDate 
			, PackageID 
			,Pos_Sought
				)
	Select distinct 'P','System','System',CAM,case when len(ltrim(rtrim(Investigator)))=0 then Null else Investigator end,@DateEntered,
			[client ID],[Last Name],[First Name],Middle,[SSN],[Date of Birth],
			DL_State,[License number],
			Case when (@SkipWinService = 1) then 'R2' else 'R1' end,
			substring(Department,1,20),
		    SUBSTRING(ltrim(rtrim(isnull(Address1,'') + ' ' + isnull(Address2,''))),1,100), city, state, substring(zip,1,5),
			--PrivateNotes, 
			Case when @CreateSexoffender = 1 then 'TCHoff_S' else null end,ClientAPNO,
		    [ApplicantPhone] ,[ApplicantEmail],PackageID,Pos_Sought
			--,'05/25/2012'--
			--,1176
			--,714
			
	from DBO.MVR_Import
	

if @CreateSexoffender = 1
	Execute AutoSexOffenderTCH

create table #tmpAppl (  id int identity,apno int, ApDate Datetime,ssn varchar(11))

	insert into #tmpAppl
	Select Apno,ApDate,SSN 
	From DBO.Appl 
	Where [EnteredBy] = 'System'
	And	  [ApDate] = @DateEntered
	And   CLNO = @CLNO

if @SkipWinService = 1
begin
insert into dbo.ApplAlias(APNO,First,[Middle],[Last],CreatedDate,AddedBy,CLNO,SSN,IsPrimaryName,IsActive,CreatedBy,LastUpdateDate,LastUpdatedBy,IsPublicRecordQualified)
select APNO,[First],Middle,[Last],@DateEntered,'System',clno,ssn,1,1,'System',@DateEntered,'System',1 from APPl where APNO in (select APNO from #tmpAppl)
end

If @CreateMVR = 1 --Create MVR Records and set them to Pending
	Begin
		INSERT INTO DBO.[DL]
			   ([APNO]
			   ,[SectStat]
			   ,[CreatedDate])
		Select Apno,'9',ApDate
		From #tmpAppl
	End

If @CreateSanction = 1 --Create Sanction only and no Positive ID
	Begin
		INSERT INTO Medinteg (apno,sectstat,CreatedDate) 
Select Apno,'9',getdate()
		From #tmpAppl
	End

If @CreateCrim = 1 -- Loop through the apps created and create crim records for the counties specified and set them to pending
	Begin

		declare @crimid int
		
        select @id = 0
		while @id < (select max(id) from #tmpAppl)
                begin
					select @id = @id + 1

                    select 	@apno = apno
					from	#tmpAppl
					where	#tmpAppl.id = @id
					
					if @CNTY1 is not null
						exec  createcrim  @apno, @CNTY1, @crimid

					if @CNTY2 is not null
						exec  createcrim  @apno, @CNTY2, @crimid					
 
					if @CNTY3 is not null
						exec  createcrim  @apno, @CNTY3, @crimid	

					if @CNTY4 is not null
						exec  createcrim  @apno, @CNTY4, @crimid	

					if @CNTY5 is not null
						exec  createcrim  @apno, @CNTY5, @crimid	

					if @CNTY6 is not null
						exec  createcrim  @apno, @CNTY6, @crimid	 

					if @CNTY7 is not null
						exec  createcrim  @apno, @CNTY7, @crimid	
              
                 end	

		if @SetCrim_Pending = 1 --Set Crim records to Pending. This will be skipped if @SetCrim_Pending = 0
			Update Crim set Clear = 'R' ,Priv_Notes = Isnull(@CrimPrivateNote,'') + case when Priv_Notes is null then '' else ('; ' + Priv_Notes) End
			--,CRIM_SpecialInstr='7 year search scope'
			Where Apno in (Select Apno From #tmpAppl)

	     else if Isnull(@CrimPrivateNote,'')<>''
			Update Crim set Priv_Notes = @CrimPrivateNote + case when Priv_Notes is null then '' else ('; ' + Priv_Notes) End
			Where Apno in (Select Apno From #tmpAppl)		  
	End


If @CreateProfLicense = 1 -- Loop through the apps created and create License records based on data provided
	BEGIN
	-- Added by Radhika on 05/08/2017 to include 2 licneses
		declare @count int
        select @count = 0

		while @count < (select max(id) from #tmpAppl)
			Begin
				select @count = @count + 1	

				INSERT INTO [PreCheck].[dbo].[ProfLic]
						   ([Apno] ,[SectStat]             
						   ,[Lic_Type]
						   ,[Lic_No]
						   ,[State], [IsOnReport])
				Select a.apno,'9', i.licensetype,i.licensenumber,i.licensestate, 1
				from Appl a inner join mvr_import i on a.ssn = i.ssn where a.apno = (Select apno from #tmpAppl ap where ap.id = @count) 
				and isnull(licensetype,'')<>''

	
			
				INSERT INTO [PreCheck].[dbo].[ProfLic]
						   ([Apno],[SectStat]       
						   ,[Lic_Type]
						   ,[Lic_No]
						   ,[State],
						   [IsOnReport])
				Select a.apno, '9', i.Licensetype2, i.LicenseNumber2, i.LicenseState2, 1
				from Appl a inner join mvr_import i on a.ssn = i.ssn where apno = (Select apno from #tmpAppl ap where ap.id = @count) 
				and isnull(licensetype2,'')<>''
			
			End

	END

--exec AutoCreate_Import 0,1,0,null,null,null,null,null,null,null,0,0,0,0,1
If @CreateEducation = 1 -- Loop through the apps created and create Education records based on data provided
	Begin
--
--	Select distinct ssn,a.apno  from appl a (nolock) inner join educat e (nolock) on a.apno = e.apno 
--		where ssn  in (Select ssn from #tmpAppl)

create table #tmpeducat ( MyID INT IDENTITY(1, 1), ssn varchar(11),apno int)
		
insert into #tmpeducat	
Select distinct ssn,a.apno    from appl a (nolock) inner join educat e (nolock) on a.apno = e.apno where ssn  in (Select ssn from #tmpAppl)
		
		INSERT  INTO DBO.Educat	
			   ([APNO]
			   ,[CreatedDate]
				,School,[State],city,Degree_A,From_A,To_A,CampusName,Name,isonreport,Priv_Notes,SectStat,Studies_A
				)
		Select Apno,ApDate,
				substring(i.[SchoolName],1,50),i.[SchoolState],substring(i.[SchoolCity],1,16),substring(i.[Degree],1,25),[School_From],[School_To],substring([SchoolCampusLocation],1,25),[NameOnGraduation],1,
				--School_Notes,
				i.PrivateNotes,
				9,
				substring(i.[Studies],1,25)

		From DBO.Appl a inner join mvr_import i on a.ssn = i.ssn 
		where a.apno in (Select apno from #tmpAppl) 


		
		select distinct SSN into #tmpssn1 from #tmpAppl  where ssn   in (Select SSN from #tmpeducat)

		IF (@DoNotSetEducation2Pending = 0) -- defaut setting. the below will be skipped when explicity set - schapyala 12/23/2019
		Begin
		
			update appl set investigator = null where clno = @CLNO and ssn   in (Select SSN from #tmpssn1)	and apno in (Select apno from #tmpAppl)
		
			--DISABLE TRIGGER edupendingupdate ON educat
		
			ALTER TABLE dbo.educat DISABLE TRIGGER edupendingupdate
 


			update educat set sectstat = 9,pendingupdated = convert(varchar, getdate(), 101) 
			--select * from educat 
			where apno in (select distinct apno from #tmpAppl where  ssn  not  in (Select SSN from #tmpssn1) )
			 and isnull(sectstat,0) =0
		 
			ALTER TABLE dbo.educat ENABLE TRIGGER edupendingupdate
					--ENABLE TRIGGER edupendingupdate ON educat		
		END

		DROP TABLE #tmpeducat
		DROP TABLE #tmpssn1
	End	
	

	--Clear Temp table contents
Truncate Table DBO.MVR_Import
END TRY
BEGIN CATCH
   SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_STATE() AS ErrorState,
        ERROR_PROCEDURE() AS ErrorProcedure,
        ERROR_LINE() AS ErrorLine,
        ERROR_MESSAGE() AS ErrorMessage;

	RollBack TRANSACTION
	Return
END CATCH	

	Commit TRANSACTION

	Select Apno
	From #tmpAppl

DROP TABLE #tmpAppl


END
