
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[StateBoardReview_Insert]
	-- Add the parameters for the stored procedure here
	(
  @FirstName varchar(50)
, @LastName varchar(50)
, @LicenseNumber varchar(50)
, @LicenseType varchar(50)
, @State  varchar(50)
, @ActionDate datetime
, @Description varchar(8000)
, @NoBoardAction bit 
, @ReportDate varchar(20)
, @BatchDate datetime
, @StateBoardDisciplinaryRunID int
, @StateBoardSourceID int
  )

AS
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON

    -- Insert statements for procedure here
	INSERT INTO dbo.StateBoardReview (FirstName, LastName, LicenseNumber, LicenseType, State, ActionDate, Description, NoBoardAction,ReportDate, BatchDate, StateBoardDisciplinaryRunID, StateBoardSourceID) 
	VALUES(@FirstName, @LastName, @LicenseNumber, @LicenseType, @State, @ActionDate, @Description, @NoBoardAction, @ReportDate, @BatchDate, @StateBoardDisciplinaryRunID, @StateBoardSourceID) 
	
	
	SET NOCOUNT OFF

--==========================================================================

