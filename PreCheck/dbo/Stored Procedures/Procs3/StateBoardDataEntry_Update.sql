
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[StateBoardDataEntry_Update]
	-- Add the parameters for the stored procedure here
	(
	 @FirstName varchar(50)
	,@LastName varchar(50)
	,@LicenseNumber varchar(50)
	,@LicenseType varchar(50)
	,@State varchar(50)
	,@ActionDate datetime
	,@Description varchar(8000)
	,@UserID varchar(20)
	,@StateBoardDataEntryID int
	)
AS
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON
	UPDATE dbo.StateBoardDataEntry SET FirstName=@FirstName, LastName=@LastName, LicenseNumber=@LicenseNumber, LicenseType=@LicenseType, State=@State, ActionDate=@ActionDate, Description=@Description 
	WHERE (UserID=@UserID) AND (StateBoardDataEntryID=@StateBoardDataEntryID)
    -- Insert statements for procedure here
	SET NOCOUNT OFF

--========================================================

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
