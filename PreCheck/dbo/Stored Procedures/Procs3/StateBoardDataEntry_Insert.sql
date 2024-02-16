
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[StateBoardDataEntry_Insert]
	-- Add the parameters for the stored procedure here
	(
     @FirstName varchar(50)
	,@LastName varchar(50)
	,@LicenseNumber varchar(50)
	,@LicenseType varchar(50)
	,@State varchar(50)
	,@ActionDate varchar(50)
	,@Description varchar(8000)
	,@UserID varchar(10)
	,@StateBoardDisciplinaryRunID int
	,@ReportDate varchar(20)
	,@BatchDate varchar(50)
	,@NoBoardAction bit
	)
AS
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON
	
	INSERT INTO dbo.StateBoardDataEntry (FirstName, LastName, LicenseNumber, LicenseType, State, ActionDate, Description, UserID, NoBoardAction, ReportDate, BatchDate, StateBoardDisciplinaryRunID) 
	VALUES(@FirstName, @LastName, @LicenseNumber, @LicenseType, @State, @ActionDate, @Description, @UserID, @NoBoardAction, @ReportDate,@BatchDate, @StateBoardDisciplinaryRunID)
    -- Insert statements for procedure here

	SET NOCOUNT OFF
--==================================================================

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
