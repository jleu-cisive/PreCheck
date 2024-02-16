

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[StateBoardFinalData_Insert]
	-- Add the parameters for the stored procedure here
	(
	@StateBoardDisciplinaryRunID int
	)

AS
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON

    -- Insert statements for procedure here
	INSERT INTO dbo.StateBoardFinalData (FirstName, LastName, LicenseNumber, LicenseType, State, ActionDate, Description, ReportDate, BatchDate, StateBoardDisciplinaryRunID, StateBoardSourceID) 
	SELECT DISTINCT FirstName, LastName, (LicenseNumber), (LicenseType), State, (ActionDate), Description, ReportDate, BatchDate, StateBoardDisciplinaryRunID, StateBoardSourceID FROM dbo.StateBoardReview WHERE StateBoardDisciplinaryRunID=@StateBoardDisciplinaryRunID
	
	
	SET NOCOUNT OFF
--================================================================

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
