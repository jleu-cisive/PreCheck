






-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[StateBoardSource_Select]
	-- Add the parameters for the stored procedure here
	
AS
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

    -- Insert statements for procedure here
	SELECT DISTINCT SourceName, SourceState, Abbreviation, ContactPhone, Frequency, LastUpdated, NextRunDate, VerificationURL, VerificationPhone 
	FROM dbo.VWLicenseAuthority 
	
	SET NOCOUNT OFF
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED








