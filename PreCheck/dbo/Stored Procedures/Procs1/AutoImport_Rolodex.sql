-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 06/30/2015
-- Description:	Rolodex Batch Run for HCA CLients
-- =============================================

--exec AutoImport_Rolodex

CREATE PROCEDURE AutoImport_Rolodex
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	BEGIN TRANSACTION

BEGIN TRY
		INSERT INTO DBO.[ClientEmployer]
			   (Company
			   ,MainPhone
			   ,Phone
			   ,Phone2
			   ,Fax
			   ,FirstName
			   ,LastName
			   ,Title
			   ,Email
			   ,[Address]
			   ,City
			   ,[State]
			   ,Zip
			   ,Country
			   ,Comment
			   ,Comment2
			   ,IsClient
			   ,CLNO
			   ,EmplContactMethod
			   ,PreferredInvestigator
			   ,EmplReleaseRequired
			   ,Deleted
			   ,LastUpdate
			   ,CreatedDate
			   ,KeyName
			   ,WorkNumberID
			   )
		Select Company,MainPhone, null, null, null, null, null, null, null,null, city, State, Zip, null, Comment, null, 1, CLNO, EmplContactMethod, null, null, 0, Current_TimeStamp, Current_TimeStamp, null, null
		From DBO.Rolodex_Temp




Truncate Table DBO.Rolodex_Temp
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


END
