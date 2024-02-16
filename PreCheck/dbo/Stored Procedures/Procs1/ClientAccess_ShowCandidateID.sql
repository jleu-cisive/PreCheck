-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 12/23/2014
-- Description:	Check if the ConfigurationKey '' exists for the CLNO
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_ShowCandidateID] 
	-- Add the parameters for the stored procedure here
	@CLNO int,
	@ReturnValue varchar(500) output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DECLARE @ConfigKey varchar(50)

SET @ConfigKey ='ClientAccess_ShowCandidateID' 


SET @ReturnValue = (SELECT Value FROM  ClientConfiguration WHERE ConfigurationKey = @ConfigKey and CLNO = @CLNO)

   
SET NOCOUNT OFF


END
