
--[AutoCreateMVR_Import] 0,1

CREATE Procedure [dbo].[AutoCreateMVR_Import]
(@AppOnly bit = 0,@SkipWinService bit = 1) --set the param to be 1 if you only want to create an app.
 as 
/*
Unit Name: [AutoCreateMVR_Import]
Author Name:Santosh Chapyala
Date of Creation: 11/02/07
Brief Description:This Procedure is used to process the imported Excel file (MVR_Import table) 
				  to create Apps and the corresponding MVR records. The status on the App 
				  and the MVR(DL) record are set to pending so that the MVR's are directly put in
				  the queue without any further verification.
OUTPUT values : List of Apps created by this SP. please forward the App range to the requestor
Date Modified: 11/12/07
Details of Modification: Added CAM and Investigator to the temp table and removed the parameters...Clearing the
						 temp table at the end. Changed the EnterBy to 'System'
Date Modified: 10/01/08
Details of Modification: Added address details for the applicant and a param to create just an app 
*/
BEGIN

BEGIN TRANSACTION

	DECLARE @DateEntered DateTime

	Set @DateEntered = getdate()
	--select @DateEntered

 --  	Update MVR_Import
	--Set SSN = substring(SSN,1,3) + '-' + substring(SSN,4,2) +'-' + substring(SSN,6,4)
	--where len(SSN) = 9 and charindex('-',SSN) = 0

BEGIN TRY
	INSERT INTO DBO.[Appl]
			   ([ApStatus]
			   ,[EnteredBy]
			   ,enteredvia
			   ,UserID
			   ,Investigator
			   ,[ApDate]
			   ,[CLNO]
			   ,[Attn]
			   ,[Last]
			   ,[First]
			   ,Middle
			  -- ,[SSN]
			   ,[DOB]
			   ,[DL_State]
			   ,[DL_Number]
			   ,[NeedsReview]
			  -- ,[DeptCode]
			   --,[Addr_Street]
			   --,[City]
			   --,[State]
			   --,[zip]
			   --,Priv_Notes,
			  ,PackageID
				)
	Select 'P','System','System',CAM,case when len(ltrim(rtrim(Investigator)))=0 then Null else Investigator end,@DateEntered,
			[client ID],[Attn], [Last Name],[First Name],Middle,--[SSN],
			[Date of Birth],
			DL_State,ltrim(rtrim([License number])),
			Case when (@SkipWinService = 1) then 'R2' else 'R1' end--,Department
			--,
		 --   SUBSTRING(ltrim(rtrim(isnull(Address1,'') + ' ' + isnull(Address2,''))),1,100), city, state, substring(zip,1,5),PrivateNotes,Attn
--,179
			, PackageID
	from DBO.MVR_Import

If @AppOnly = 0 
	Begin
		INSERT INTO DBO.[DL]
			   ([APNO]
			   ,[SectStat]
			   ,[CreatedDate])
		Select Apno,'9',ApDate
		From DBO.Appl 
		Where [EnteredBy] = 'System'
		And	  [ApDate] = @DateEntered
	End

	Select Apno into #temp1
	From DBO.Appl 
	Where [EnteredBy] = 'System'
	And	  [ApDate] = @DateEntered

	--INSERT INTO [dbo].[ClientCertification]
 --          ([APNO]
 --          ,[ClientCertReceived]
 --          ,[ClientCertBy]
 --          ,[ClientCertUpdated]
 --          ,[ClientICertByPAddress]
 --          ,[IsInLieuOnlineRelease])
	--	   Select Apno
	--	   ,'Yes'
	--	   ,'' -- Attn
	--	   ,CreatedDate
	--	   ,Null,Null
	--	--   From #temp1
	--	From DBO.Appl 
	--Where [EnteredBy] = 'System'
	--And	  [ApDate] >'2/8/2016'
     


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
	From #temp1 
	
	Drop table #temp1

END
















