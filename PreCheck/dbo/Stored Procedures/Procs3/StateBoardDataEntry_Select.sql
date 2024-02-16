-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[StateBoardDataEntry_Select]
	-- Add the parameters for the stored procedure here
	(
	 @UserID varchar(20)
	,@StateBoardDisciplinaryRunID int
	)	
AS
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
    -- Insert statements for procedure here
	SELECT StateBoardDataEntryID, FirstName, LastName, LicenseNumber, LicenseType, State, ActionDate, Description, UserID, ReportDate, BatchDate, NoBoardAction, StateBoardDisciplinaryRunID 
	FROM dbo.StateBoardDataEntry WHERE (UserID=@UserID) AND (StateBoardDisciplinaryRunID=@StateBoardDisciplinaryRunID)
	
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	SET NOCOUNT OFF
--==================================================

SET ANSI_NULLS ON
