-- =============================================
-- Author:		Deepak Vodethela
-- Create date: 03/14/2017
-- Description:	Provide list of Company Names, Alias List, Contact Methods and External Reference ID's
-- Execution: EXEC Rolodex_CompanyNames
-- =============================================
CREATE PROCEDURE [dbo].[Rolodex_CompanyNames] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT Company, AliasList, EmplContactMethod, ExternalReferenceIDs FROM ClientEmployer WHERE deleted != 1 ORDER BY 1
END
