



-- =============================================
-- Author:		Najma Begum
-- Create date: 03/09/2013
-- Description:	Log raw xml response from pembrooke website
-- =============================================
Create PROCEDURE [dbo].[OCHS_LogRawResponse]
	-- Add the parameters for the stored procedure here
	@Response text, @ProviderRefID varchar(25)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	INSERT INTO [dbo].[OCHS_ResultsLog]
           ([XMLResponse], ProviderID)
     VALUES
           (@Response, @ProviderRefID);
   
	
END

