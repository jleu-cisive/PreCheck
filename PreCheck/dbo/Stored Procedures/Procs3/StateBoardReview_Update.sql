
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[StateBoardReview_Update]
	-- Add the parameters for the stored procedure here
(
@FirstName varchar(50),
@LastName varchar (50),
@LicenseNumber varchar(50),
@LicenseType varchar(50),
@State varchar(50),
@ActionDate datetime,
@ReportDate varchar(20),
@BatchDate datetime,
@Description varchar(50),
@NoBoardAction bit,
@StateBoardDisciplinaryRunID int,
@StateBoardSourceID int,
@StateBoardReviewID int
)
	
AS
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON

    -- Insert statements for procedure here
	UPDATE dbo.StateBoardReview SET FirstName=@FirstName, LastName=@LastName,LicenseNumber=@LicenseNumber,LicenseType=@LicenseType,State=@State,ActionDate=@ActionDate,Description=@Description,
	NoBoardAction=@NoBoardAction,ReportDate=@ReportDate,BatchDate=@BatchDate, StateBoardDisciplinaryRunID=@StateBoardDisciplinaryRunID,StateBoardSourceID=@StateBoardSourceID
    WHERE StateBoardReviewID=@StateBoardReviewID	
	
	SET NOCOUNT OFF





















































































