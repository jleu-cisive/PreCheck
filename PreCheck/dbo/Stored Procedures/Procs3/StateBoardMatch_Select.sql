




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[StateBoardMatch_Select]
	-- Add the parameters for the stored procedure here
(
	@StateBoardDisciplinaryRunID int
)
AS
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
    -- Insert statements for procedure here
	SELECT StateBoardMatchID, StateBoardDisciplinaryRunID, EmployeeFirstName, EmployeeMiddleName, EmployeeLastName, EmployeeSSN, CLNO, StateBoardLicenseNumber, StateBoardLicenseType, StateBoardLicenseState, EmailDate, CredentCheckBis FROM dbo.StateBoardMatch 
	WHERE StateBoardDisciplinaryRunID = @StateBoardDisciplinaryRunID
	
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	SET NOCOUNT OFF





