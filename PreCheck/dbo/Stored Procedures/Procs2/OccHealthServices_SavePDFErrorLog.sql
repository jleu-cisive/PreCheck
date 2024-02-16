



-- =============================================
-- Author:		Najma Begum
-- Create date: 09/26/2012
-- Description:	Log results if there is error while saving pdf files
-- =============================================
CREATE PROCEDURE [dbo].[OccHealthServices_SavePDFErrorLog]
	-- Add the parameters for the stored procedure here
	@ProviderID varchar(25),@OrderID varchar(25), @SSN varchar(25), @Error varchar(500)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	INSERT INTO [dbo].[OccHealthServicesSavePDFErrorLog]
           ([ProviderID]
           ,[OrderID]
           ,[SSNOrOtherID]
           ,[ErrorDesc])
           
     VALUES
           (@ProviderID
           ,@OrderID
           ,@SSN
           ,@Error
           )

    -- Insert statements for procedure here
	
	
END



