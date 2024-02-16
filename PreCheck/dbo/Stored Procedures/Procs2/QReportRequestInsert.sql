-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[QReportRequestInsert] 
	-- Add the parameters for the stored procedure here
	(@QueryName varchar(250),@Parameters varchar(300),@Description varchar(1500),@UserID varchar(8),@NeededBy datetime)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   Insert into QReportRequest (QueryName,Parameters,Description,UserID,CreatedDate,NeededBy) VALUES (@QueryName,@Parameters,@Description,@UserID,getDate(),@NeededBy)
END

