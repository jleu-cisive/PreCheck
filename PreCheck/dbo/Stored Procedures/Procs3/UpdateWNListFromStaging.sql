-- =============================================
-- Author:		Douglas DeGenaro
-- Create date: 03/07/2017
-- Description:	Update WNList from staging table
-- =============================================
CREATE PROCEDURE [dbo].[UpdateWNListFromStaging] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.	
	BEGIN TRY
	     
		BEGIN TRANSACTION
		
		truncate table dbo.WNList

		INSERT INTO [dbo].[WNList]
           ([EmployerCode]
           ,[Name1])
		select distinct [EmployerCode]
           ,[Name1]
		   from dbo.WNListStage
	
	truncate table dbo.WNListStage

		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTIOn
	END CATCH
	


END
