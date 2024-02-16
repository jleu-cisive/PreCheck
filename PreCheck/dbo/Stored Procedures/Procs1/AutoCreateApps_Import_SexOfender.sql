



CREATE Procedure [dbo].[AutoCreateApps_Import_SexOfender]
(
@SkipWinService bit = 1

) 
 as 

/*
date 09/15/2009
created to order only sexofender for these apps
*/
BEGIN

BEGIN TRANSACTION

	DECLARE @DateEntered DateTime
	Set @DateEntered = getdate()
	
Update MVR_Import
	Set SSN = substring(SSN,1,3) + '-' + substring(SSN,4,2) +'-' + substring(SSN,6,4)
	where len(SSN) = 9 and charindex('-',SSN) = 0

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
				,[inuse]
				)
	Select 'P','System','System',CAM,case when len(ltrim(rtrim(Investigator)))=0 then Null else Investigator end,@DateEntered,
			[client ID],[Last Name],[First Name],Middle,[SSN],[Date of Birth],
			DL_State,[License number],
			Case when (@SkipWinService = 1) then 'R2' else 'R1' end,
			Department,
		    SUBSTRING(ltrim(rtrim(isnull(Address1,'') + ' ' + isnull(Address2,''))),1,100), city, state, substring(zip,1,5),
			'TCHoff_S'
	from DBO.MVR_Import


Execute AutoSexOffenderTCH

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

update Crim
set Clear = 'R'
where Apno in (
Select Apno
	From DBO.Appl 
	Where [EnteredBy] = 'System'
	And	  [ApDate] = @DateEntered)






	Select Apno
	From DBO.Appl 
	Where [EnteredBy] = 'System'
	And	  [ApDate] = @DateEntered


END


















