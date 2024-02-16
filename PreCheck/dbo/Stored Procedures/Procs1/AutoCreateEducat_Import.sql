




CREATE Procedure [dbo].[AutoCreateEducat_Import]
 AS 

BEGIN

BEGIN TRANSACTION

	DECLARE @DateEntered DateTime

	Set @DateEntered = getdate()

BEGIN TRY
	INSERT INTO DBO.[Appl]
			   ([ApStatus]
			   ,Attn
			   ,[EnteredBy]
			   ,enteredvia
			   ,CAM
			   ,UserID
			   ,Investigator
			   ,[ApDate]
			   ,[CLNO]
			   ,[Last]
			   ,[First]
			   ,[SSN]
			    ,[NeedsReview]
				)
	SELECT  'P',
			SUBSTRING([ATTN To should go to ],1,25),
			'System',
			'System',
			'CCALDARE',
			'CCALDARE',
			'CCALDARE',
		    @DateEntered,
			1887,
			[Last Name],
			[1st Name],
			[SS#:],
			'R2'
	FROM  DBO.educat_import


   INSERT  INTO DBO.Educat	
           ([APNO]
           ,[SectStat]
           ,[CreatedDate]
			,School,State,city,Degree_A,isonreport
			)
	Select Apno,'9',ApDate,
            ei.[School Name],ei.[School State],ei.[School City],ei.Degree,1
	From DBO.Appl app INNER JOIN DBO.educat_import ei
	ON app.SSN = ei.[SS#:]
	Where [EnteredBy] = 'System'
	And	  [ApDate] = @DateEntered


  --Clear Temp table contents
--	Truncate Table DBO.educat_import

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
	From DBO.Appl 
	Where [EnteredBy] = 'System'
	And	  [ApDate] = @DateEntered


END












